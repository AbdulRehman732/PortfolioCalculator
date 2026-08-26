/**
 * PSX Dividend Machine — Backend API Server
 * ─────────────────────────────────────────
 * Production-ready, security-hardened Express server.
 * Scrapes live PSX stock data from dps.psx.com.pk.
 *
 * Security layers:
 *  1. Helmet — HTTP security headers
 *  2. Rate Limiting — 60 req/min per IP
 *  3. API Key — X-Api-Key header on all private endpoints
 *  4. Symbol whitelist — [A-Z0-9]{1,10} only
 *  5. Body size limit — 10 KB
 *  6. No stack traces in production
 */

"use strict";

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const axios = require("axios");
const cheerio = require("cheerio");
const cron = require("node-cron");
require("dotenv").config({ path: ".env" });

const app = express();
const PORT = process.env.PORT || 3001;
const IS_PROD = process.env.NODE_ENV === "production";

// ─── Security Config ──────────────────────────────────────────────────────────

/**
 * API key for protecting private endpoints.
 * Set API_KEY env var on Render. Default is only for local dev.
 */
const API_KEY = process.env.API_KEY || "psx-local-dev-key";

// ─── Middleware ───────────────────────────────────────────────────────────────

// 1. Remove X-Powered-By header
app.disable("x-powered-by");

// 2. Helmet security headers (XSS, clickjacking, MIME, HSTS, etc.)
app.use(
  helmet({
    contentSecurityPolicy: false, // We are an API; CSP is for HTML pages
    crossOriginResourcePolicy: { policy: "cross-origin" }, // Allow Flutter/mobile
  })
);

// 3. CORS — restrict to known origins in production if needed
// For Flutter mobile, we must allow all (Flutter doesn't have a browser origin)
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type", "X-Api-Key"],
  })
);

// 4. Body size limit — prevent huge request bodies
app.use(express.json({ limit: "10kb" }));
app.use(express.urlencoded({ extended: false, limit: "10kb" }));

// 5. Global rate limiter — 60 requests per IP per minute
const globalLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests. Please slow down.", code: 429 },
  skip: (req) => req.path === "/api/health", // Health check is never rate-limited
});
app.use(globalLimiter);

// ─── API Key Middleware ───────────────────────────────────────────────────────

/**
 * Validates X-Api-Key header.
 * Applied to all routes EXCEPT /api/health (which is always public).
 */
function requireApiKey(req, res, next) {
  const key = req.headers["x-api-key"];
  if (!key || key !== API_KEY) {
    return res.status(401).json({
      error: "Unauthorized. Provide a valid X-Api-Key header.",
    });
  }
  next();
}

// ─── Symbol Validation ────────────────────────────────────────────────────────

/** Allowed PSX symbol pattern — uppercase letters + numbers, 1-10 chars */
const SYMBOL_REGEX = /^[A-Z0-9]{1,10}$/;

function validateSymbol(req, res, next) {
  const { symbol } = req.params;
  if (!symbol || !SYMBOL_REGEX.test(symbol.toUpperCase())) {
    return res.status(400).json({
      error: "Invalid symbol. Only uppercase letters and numbers (1-10 chars).",
    });
  }
  req.params.symbol = symbol.toUpperCase();
  next();
}

// ─── In-Memory Caches ─────────────────────────────────────────────────────────

const priceCache = new Map();     // symbol → { price, timestamp }
const dividendCache = new Map();  // symbol → { dpshist, timestamp }
const scoreCache = new Map();     // symbol → { signal, score, yieldPct, reason, timestamp }
const detailsCache = new Map();   // symbol → { ...details, timestamp }

const PRICE_TTL = 5 * 60 * 1000;     // 5 minutes
const DIVIDEND_TTL = 60 * 60 * 1000; // 1 hour
const SCORE_TTL = 30 * 60 * 1000;    // 30 minutes
const DETAILS_TTL = 15 * 60 * 1000;  // 15 minutes

// ─── HTTP Client Config ───────────────────────────────────────────────────────

const PSX_HEADERS = {
  "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Accept-Language": "en-US,en;q=0.9",
  Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Cache-Control": "no-cache",
};

// ─── Core Helpers ─────────────────────────────────────────────────────────────

/**
 * Parse a price string from PSX (e.g. "Rs.1,234.56", "1,234.56").
 * @param {string} text
 * @returns {number|null}
 */
function parsePriceText(text) {
  if (!text || typeof text !== "string") return null;
  const match = text.match(/([\d,]+\.?\d*)/);
  if (!match) return null;
  const price = parseFloat(match[1].replace(/,/g, ""));
  return isNaN(price) || price <= 0 ? null : price;
}

/**
 * Fetch the live closing price for a PSX stock with retry + exponential backoff.
 * @param {string} symbol - Uppercase PSX symbol
 * @param {number} [attempt=1] - Internal retry counter
 * @returns {Promise<number|null>}
 */
async function fetchLivePrice(symbol, attempt = 1) {
  const MAX_RETRIES = 3;
  const BASE_DELAY_MS = 500;

  try {
    const response = await axios.get(
      `https://dps.psx.com.pk/company/${symbol}`,
      { timeout: 10000, headers: PSX_HEADERS }
    );

    const $ = cheerio.load(response.data);
    const priceText = $(".quote__close").first().text().trim();
    const price = parsePriceText(priceText);

    if (price !== null) return price;

    console.warn(
      `[price] Parse failed for ${symbol}: "${priceText}" (attempt ${attempt}/${MAX_RETRIES})`
    );
  } catch (err) {
    console.error(
      `[price] ${err.code === "ECONNABORTED" ? "Timeout" : "Error"} for ${symbol} (attempt ${attempt}/${MAX_RETRIES}): ${err.message}`
    );
  }

  if (attempt < MAX_RETRIES) {
    await new Promise((r) => setTimeout(r, BASE_DELAY_MS * Math.pow(2, attempt - 1)));
    return fetchLivePrice(symbol, attempt + 1);
  }

  return null;
}

/**
 * Scrape full details for a stock from PSX.
 * @param {string} symbol
 * @returns {Promise<object|null>}
 */
async function fetchStockDetails(symbol) {
  try {
    const response = await axios.get(
      `https://dps.psx.com.pk/company/${symbol}`,
      { timeout: 10000, headers: PSX_HEADERS }
    );

    const $ = cheerio.load(response.data);

    const price = parsePriceText($(".quote__close").first().text().trim());
    const yieldText = $(".quote__yield, [class*='yield']").first().text().trim();
    const yieldVal = yieldText
      ? parseFloat(yieldText.replace(/[%,\s]/g, ""))
      : null;
    const changeText = $(".quote__change, [class*='change']").first().text().trim();
    const volumeText = $(".quote__volume, [class*='volume']").first().text().trim();
    const sectorText = $(".company__sector, [class*='sector']").first().text().trim();
    const nameText = $("h1").first().text().trim() || symbol;

    return {
      symbol,
      name: nameText || symbol,
      price,
      yieldPct: isNaN(yieldVal) ? null : yieldVal,
      change: changeText || null,
      volume: volumeText || null,
      sector: sectorText || "Unknown",
    };
  } catch (err) {
    console.error(`[details] Error for ${symbol}: ${err.message}`);
    return null;
  }
}

/**
 * Fetch annual DPS for a stock from PSX.
 * @param {string} symbol
 * @returns {Promise<number|null>}
 */
async function fetchDividend(symbol) {
  try {
    const details = await fetchStockDetails(symbol);
    if (!details) return null;

    // Calculate DPS from yield if available
    if (details.yieldPct !== null && details.price !== null) {
      const dps = (details.yieldPct / 100) * details.price;
      return Math.round(dps * 100) / 100;
    }
    return null;
  } catch (err) {
    console.error(`[dividend] Error for ${symbol}: ${err.message}`);
    return null;
  }
}

/**
 * Calculate BUY/HOLD/AVOID signal for any stock based on live yield.
 * @param {string} symbol
 * @returns {Promise<object>}
 */
async function calculateStockScore(symbol) {
  const details = await fetchStockDetails(symbol);

  if (!details || !details.price) {
    return {
      symbol,
      signal: "UNKNOWN",
      score: 0,
      yieldPct: null,
      reason: "Price data unavailable — check symbol or try again later.",
    };
  }

  const yieldPct = details.yieldPct ?? 0;
  let signal, score, reason;

  if (yieldPct >= 9) {
    signal = "STRONG BUY";
    score = 90 + Math.min(yieldPct - 9, 10);
    reason = `Exceptional yield of ${yieldPct.toFixed(1)}% — well above SIP threshold of 7%.`;
  } else if (yieldPct >= 7) {
    signal = "BUY";
    score = 70 + Math.round((yieldPct - 7) * 10);
    reason = `Good yield of ${yieldPct.toFixed(1)}% — meets SIP minimum. Monitor quarterly.`;
  } else if (yieldPct >= 5) {
    signal = "HOLD";
    score = 50 + Math.round((yieldPct - 5) * 10);
    reason = `Yield ${yieldPct.toFixed(1)}% is below 7% target. Hold existing position; don't add more.`;
  } else if (yieldPct > 0) {
    signal = "AVOID";
    score = Math.round(yieldPct * 10);
    reason = `Yield only ${yieldPct.toFixed(1)}%. Far below 7% SIP threshold. Better alternatives exist.`;
  } else {
    signal = "HOLD";
    score = 40;
    reason = "Dividend yield data not available from PSX. Research manually.";
  }

  return {
    symbol,
    signal,
    score: Math.min(100, Math.round(score)),
    yieldPct: details.yieldPct,
    price: details.price,
    name: details.name,
    sector: details.sector,
    reason,
  };
}

// ─── Routes ───────────────────────────────────────────────────────────────────

/**
 * GET /api/health
 * Public — no API key required. Used by keep-alive ping and Flutter.
 */
app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: Date.now(),
    uptime: Math.round(process.uptime()),
    caches: {
      prices: priceCache.size,
      dividends: dividendCache.size,
      scores: scoreCache.size,
    },
    version: "3.0.0",
  });
});

// Apply API key to all routes below this point
app.use("/api", requireApiKey);

/**
 * GET /api/stock/:symbol/price
 * Live price for a single stock (cached 5 min).
 */
app.get("/api/stock/:symbol/price", validateSymbol, async (req, res) => {
  const { symbol } = req.params;
  try {
    const cached = priceCache.get(symbol);
    if (cached && Date.now() - cached.timestamp < PRICE_TTL) {
      return res.json({ symbol, price: cached.price, cached: true, timestamp: cached.timestamp });
    }

    const price = await fetchLivePrice(symbol);
    if (price !== null) {
      priceCache.set(symbol, { price, timestamp: Date.now() });
      return res.json({ symbol, price, cached: false, timestamp: Date.now() });
    }

    res.status(404).json({ error: `Price not found for ${symbol}`, symbol });
  } catch (err) {
    safeError(res, "Failed to fetch price", err);
  }
});

/**
 * POST /api/stocks/prices
 * Bulk price fetch for portfolio.
 * Body: { symbols: ['FFC', 'HUBC', ...] }
 */
app.post("/api/stocks/prices", async (req, res) => {
  const { symbols } = req.body;

  if (!Array.isArray(symbols) || symbols.length === 0) {
    return res.status(400).json({ error: "symbols must be a non-empty array" });
  }

  // Validate all symbols
  const invalid = symbols.filter((s) => !SYMBOL_REGEX.test(String(s).toUpperCase()));
  if (invalid.length > 0) {
    return res.status(400).json({ error: `Invalid symbols: ${invalid.join(", ")}` });
  }

  // Limit bulk requests
  if (symbols.length > 30) {
    return res.status(400).json({ error: "Maximum 30 symbols per bulk request" });
  }

  try {
    const prices = {};
    await Promise.allSettled(
      symbols.map(async (sym) => {
        const upper = sym.toUpperCase();
        const cached = priceCache.get(upper);
        if (cached && Date.now() - cached.timestamp < PRICE_TTL) {
          prices[upper] = cached.price;
          return;
        }
        const price = await fetchLivePrice(upper);
        if (price !== null) {
          prices[upper] = price;
          priceCache.set(upper, { price, timestamp: Date.now() });
        }
      })
    );

    res.json({ prices, fetched: Object.keys(prices).length, requested: symbols.length, timestamp: Date.now() });
  } catch (err) {
    safeError(res, "Failed to fetch prices", err);
  }
});

/**
 * GET /api/stock/:symbol/dividend
 * Annual DPS for a stock (cached 1 hour).
 */
app.get("/api/stock/:symbol/dividend", validateSymbol, async (req, res) => {
  const { symbol } = req.params;
  try {
    const cached = dividendCache.get(symbol);
    if (cached && Date.now() - cached.timestamp < DIVIDEND_TTL) {
      return res.json({ symbol, dpshist: cached.dpshist, cached: true, timestamp: cached.timestamp });
    }

    const dpshist = await fetchDividend(symbol);
    if (dpshist !== null) {
      dividendCache.set(symbol, { dpshist, timestamp: Date.now() });
      return res.json({ symbol, dpshist, cached: false, timestamp: Date.now() });
    }

    res.status(404).json({ error: `Dividend data not found for ${symbol}`, symbol });
  } catch (err) {
    safeError(res, "Failed to fetch dividend", err);
  }
});

/**
 * GET /api/stock/:symbol/score
 * BUY/HOLD/AVOID signal for ANY stock, based on live yield (cached 30 min).
 * Works for stocks not in PsxData.ratios.
 */
app.get("/api/stock/:symbol/score", validateSymbol, async (req, res) => {
  const { symbol } = req.params;
  try {
    const cached = scoreCache.get(symbol);
    if (cached && Date.now() - cached.timestamp < SCORE_TTL) {
      return res.json({ ...cached, cached: true });
    }

    const result = await calculateStockScore(symbol);
    scoreCache.set(symbol, { ...result, timestamp: Date.now() });
    res.json({ ...result, cached: false, timestamp: Date.now() });
  } catch (err) {
    safeError(res, "Failed to calculate score", err);
  }
});

/**
 * GET /api/stock/:symbol/details
 * Full stock details — price, yield, sector, name (cached 15 min).
 */
app.get("/api/stock/:symbol/details", validateSymbol, async (req, res) => {
  const { symbol } = req.params;
  try {
    const cached = detailsCache.get(symbol);
    if (cached && Date.now() - cached.timestamp < DETAILS_TTL) {
      return res.json({ ...cached, cached: true });
    }

    const details = await fetchStockDetails(symbol);
    if (details) {
      const result = { ...details, timestamp: Date.now() };
      detailsCache.set(symbol, result);
      return res.json({ ...result, cached: false });
    }

    res.status(404).json({ error: `Details not found for ${symbol}`, symbol });
  } catch (err) {
    safeError(res, "Failed to fetch details", err);
  }
});

/**
 * GET /api/stocks/search?q=FFC
 * Search for stocks by symbol prefix (max 20 results).
 */
app.get("/api/stocks/search", async (req, res) => {
  const q = String(req.query.q || "").trim().toUpperCase();

  if (!q || q.length < 1) {
    return res.status(400).json({ error: "q parameter is required" });
  }

  // Sanitize search query
  const sanitized = q.replace(/[^A-Z0-9]/g, "").slice(0, 10);
  if (!sanitized) {
    return res.status(400).json({ error: "Invalid search query" });
  }

  try {
    const response = await axios.get(
      `https://dps.psx.com.pk/search?q=${encodeURIComponent(sanitized)}`,
      { timeout: 10000, headers: PSX_HEADERS }
    );

    const $ = cheerio.load(response.data);
    const results = [];

    $("a[href*='/company/']").each((_, elem) => {
      if (results.length >= 20) return;
      const symbol = $(elem).text().trim().toUpperCase();
      if (symbol && SYMBOL_REGEX.test(symbol)) {
        results.push({ symbol });
      }
    });

    res.json({ query: sanitized, results, count: results.length, timestamp: Date.now() });
  } catch (err) {
    safeError(res, "Search failed", err);
  }
});

/**
 * POST /api/validate/symbol
 * Check if a symbol is valid on PSX and return its live price + signal.
 * Used by Flutter stock search to validate any symbol before adding.
 */
app.post("/api/validate/symbol", async (req, res) => {
  const raw = String(req.body.symbol || "").trim().toUpperCase();

  if (!raw || !SYMBOL_REGEX.test(raw)) {
    return res.status(400).json({ error: "Invalid symbol format", valid: false });
  }

  try {
    const score = await calculateStockScore(raw);
    if (score.price) {
      res.json({ symbol: raw, valid: true, ...score, timestamp: Date.now() });
    } else {
      res.json({ symbol: raw, valid: false, reason: "Symbol not found on PSX", timestamp: Date.now() });
    }
  } catch (err) {
    res.json({ symbol: raw, valid: false, reason: "Validation failed" });
  }
});

/**
 * GET /api/cache/clear (admin — requires API key, only accessible locally or via key)
 */
app.get("/api/cache/clear", (req, res) => {
  priceCache.clear();
  dividendCache.clear();
  scoreCache.clear();
  detailsCache.clear();
  res.json({ status: "all caches cleared", timestamp: Date.now() });
});

// ─── 404 Handler ─────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: "Endpoint not found", path: req.path });
});

// ─── Error Handler ────────────────────────────────────────────────────────────
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error("[UnhandledError]", err.message);
  res.status(500).json({ error: "Internal server error" });
});

/**
 * Safe error responder — never exposes stack traces in production.
 */
function safeError(res, message, err) {
  const statusCode = err?.status || 500;
  console.error(`[Error] ${message}:`, err?.message ?? err);
  res.status(statusCode).json({
    error: message,
    ...(IS_PROD ? {} : { detail: err?.message }),
  });
}

// ─── Keep-Alive Cron (Prevent Render Sleep) ───────────────────────────────────
// Pings /api/health every 14 minutes so Render free tier stays awake
if (require.main === module) {
  const SELF_URL =
    process.env.RENDER_EXTERNAL_URL
      ? `${process.env.RENDER_EXTERNAL_URL}/api/health`
      : `http://localhost:${PORT}/api/health`;

  cron.schedule("*/14 * * * *", async () => {
    try {
      const res = await axios.get(SELF_URL, { timeout: 10000 });
      console.log(`[keep-alive] Pinged ${SELF_URL} → status ${res.status}`);
    } catch (err) {
      console.warn(`[keep-alive] Ping failed: ${err.message}`);
    }
  });

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`\n🚀 PSX Dividend Machine API`);
    console.log(`   Port    : ${PORT}`);
    console.log(`   Mode    : ${IS_PROD ? "Production" : "Development"}`);
    console.log(`   Health  : http://localhost:${PORT}/api/health`);
    console.log(`   Example : http://localhost:${PORT}/api/stock/FFC/price`);
    console.log(`   Keep-alive: Pinging self every 14 minutes\n`);
  });
}

// Export for serverless (Netlify) and tests
module.exports = app;
module.exports.parsePriceText = parsePriceText;

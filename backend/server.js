const express = require("express");
const cors = require("cors");
const axios = require("axios");
const cheerio = require("cheerio");

const app = express();
const PORT = process.env.PORT || 3001;

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Cache for live prices (5 minute TTL)
const priceCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes
// Cache for PSX stock listing (1 hour TTL)
const stockListCache = { data: null, timestamp: null };
const STOCK_LIST_TTL = 60 * 60 * 1000; // 1 hour
/**
 * Parse a price string in Pakistani Rupee format (e.g. "Rs.1,234.56").
 * Extracted as a named helper for testability and reuse.
 *
 * @param {string} text - Raw price text from the PSX page
 * @returns {number|null}  Parsed float, or null if the text is not a valid price
 */
function parsePriceText(text) {
  if (!text || typeof text !== "string") return null;
  // Match the first sequence of digits (with optional commas and a decimal part)
  const match = text.match(/([\d,]+\.?\d*)/);
  if (!match) return null;
  const price = parseFloat(match[1].replace(/,/g, ""));
  return isNaN(price) || price <= 0 ? null : price;
}

/**
 * Fetch the live closing price for a PSX-listed stock with retry logic.
 *
 * Improvements over original:
 *  - Retries up to MAX_RETRIES times with exponential back-off
 *  - Uses the named parsePriceText() helper (easier to unit-test)
 *  - Differentiates between network errors and parsing failures in logs
 *  - Validates that the returned price is a positive finite number
 *
 * @param {string} symbol       Stock symbol (e.g. 'FFC') — case-insensitive
 * @param {number} [attempt=1]  Internal retry counter (do not pass manually)
 * @returns {Promise<number|null>} Closing price, or null on failure
 */
async function fetchLivePrice(symbol, attempt = 1) {
  const MAX_RETRIES = 3;
  const BASE_DELAY_MS = 500;
  const upperSymbol = symbol.toUpperCase();
  const url = `https://dps.psx.com.pk/company/${upperSymbol}`;

  try {
    const response = await axios.get(url, {
      timeout: 10000,
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      },
    });

    const $ = cheerio.load(response.data);
    const priceText = $(".quote__close").first().text().trim();
    const price = parsePriceText(priceText);

    if (price !== null) {
      return price;
    }

    console.warn(
      `[fetchLivePrice] Could not parse price for ${upperSymbol}. ` +
        `Raw text: "${priceText}" (attempt ${attempt}/${MAX_RETRIES})`
    );
  } catch (error) {
    const isTimeout = error.code === "ECONNABORTED" || error.code === "ETIMEDOUT";
    console.error(
      `[fetchLivePrice] ${isTimeout ? "Timeout" : "Network error"} for ` +
        `${upperSymbol} (attempt ${attempt}/${MAX_RETRIES}): ${error.message}`
    );
  }

  // Retry with exponential back-off
  if (attempt < MAX_RETRIES) {
    const delay = BASE_DELAY_MS * Math.pow(2, attempt - 1);
    await new Promise((resolve) => setTimeout(resolve, delay));
    return fetchLivePrice(symbol, attempt + 1);
  }

  return null;
}

/**
 * GET /api/stock/:symbol/price
 * Fetch live price for a single stock with caching
 */
app.get("/api/stock/:symbol/price", async (req, res) => {
  const { symbol } = req.params;

  try {
    // Check cache first
    const cached = priceCache.get(symbol.toUpperCase());
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      return res.json({
        symbol: symbol.toUpperCase(),
        price: cached.price,
        cached: true,
        timestamp: cached.timestamp,
      });
    }

    // Fetch fresh price
    const price = await fetchLivePrice(symbol);

    if (price !== null) {
      // Update cache
      priceCache.set(symbol.toUpperCase(), { price, timestamp: Date.now() });

      return res.json({
        symbol: symbol.toUpperCase(),
        price,
        cached: false,
        timestamp: Date.now(),
      });
    } else {
      return res.status(404).json({
        error: `Could not fetch price for ${symbol}`,
        symbol: symbol.toUpperCase(),
      });
    }
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch price",
      message: error.message,
      symbol: symbol.toUpperCase(),
    });
  }
});

/**
 * POST /api/stocks/prices
 * Fetch prices for multiple stocks
 * Body: { symbols: ['FFC', 'BIPL', ...] }
 */
app.post("/api/stocks/prices", async (req, res) => {
  const { symbols } = req.body;

  if (!Array.isArray(symbols) || symbols.length === 0) {
    return res.status(400).json({ error: "symbols array is required" });
  }

  try {
    const prices = {};
    const promises = symbols.map(async (symbol) => {
      const price = await fetchLivePrice(symbol);
      if (price !== null) {
        prices[symbol.toUpperCase()] = price;
        priceCache.set(symbol.toUpperCase(), { price, timestamp: Date.now() });
      }
    });

    await Promise.all(promises);

    res.json({
      prices,
      timestamp: Date.now(),
      fetched: Object.keys(prices).length,
      requested: symbols.length,
    });
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch prices",
      message: error.message,
    });
  }
});

/**
 * GET /api/health
 * Health check endpoint
 */
app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: Date.now(),
    cacheSize: priceCache.size,
  });
});

/**
 * GET /api/stocks/search?query=
 * Search for stocks by symbol or name
 */
app.get("/api/stocks/search", async (req, res) => {
  const { query } = req.query;

  if (!query || query.trim().length === 0) {
    return res.status(400).json({ error: "query parameter is required" });
  }

  try {
    const q = query.toUpperCase().trim();
    const results = [];

    // PSX search page
    const url = `https://dps.psx.com.pk/search?q=${encodeURIComponent(q)}`;
    const response = await axios.get(url, {
      timeout: 10000,
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      },
    });

    const $ = cheerio.load(response.data);

    // Extract search results - adjust selector based on PSX website structure
    $("a[href*='/company/']").each((i, elem) => {
      if (results.length >= 20) return; // Limit to 20 results

      const symbol = $(elem).text().trim();
      const link = $(elem).attr("href");

      if (symbol && link && /^[A-Z]+$/.test(symbol)) {
        results.push({
          symbol,
          link: `https://dps.psx.com.pk${link}`,
        });
      }
    });

    res.json({
      query: q,
      results,
      count: results.length,
      timestamp: Date.now(),
    });
  } catch (error) {
    res.status(500).json({
      error: "Failed to search stocks",
      message: error.message,
      query,
    });
  }
});

/**
 * GET /api/stock/:symbol/details
 * Get detailed stock information including financial metrics
 */
app.get("/api/stock/:symbol/details", async (req, res) => {
  const { symbol } = req.params;

  try {
    const url = `https://dps.psx.com.pk/company/${symbol.toUpperCase()}`;
    const response = await axios.get(url, {
      timeout: 10000,
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      },
    });

    const $ = cheerio.load(response.data);

    // Extract company name
    const name = $("h1").first().text().trim() || symbol.toUpperCase();

    // Extract price
    const priceText = $(".quote__close").first().text().trim();
    const price = priceText
      ? parseFloat(priceText.replace(/[Rs.,]/g, ""))
      : null;

    // Extract yield
    const yieldText = $(".quote__yield").first().text().trim();
    const yieldValue = yieldText
      ? parseFloat(yieldText.replace(/[%,]/g, ""))
      : null;

    // Extract market cap
    const marketCapText = $(".quote__market-cap").first().text().trim();

    // Extract volume
    const volumeText = $(".quote__volume").first().text().trim();

    // Extract company sector/industry
    const sectorText = $(".company__sector").first().text().trim();

    res.json({
      symbol: symbol.toUpperCase(),
      name,
      price,
      yield: yieldValue,
      marketCap: marketCapText,
      volume: volumeText,
      sector: sectorText,
      timestamp: Date.now(),
    });
  } catch (error) {
    res.status(404).json({
      error: `Could not fetch details for ${symbol}`,
      symbol: symbol.toUpperCase(),
      message: error.message,
    });
  }
});

/**
 * POST /api/validate/symbol
 * Validate if a stock symbol exists on PSX
 */
app.post("/api/validate/symbol", async (req, res) => {
  const { symbol } = req.body;

  if (!symbol) {
    return res.status(400).json({ error: "symbol is required" });
  }

  try {
    const price = await fetchLivePrice(symbol);

    if (price !== null) {
      res.json({
        symbol: symbol.toUpperCase(),
        valid: true,
        price,
        timestamp: Date.now(),
      });
    } else {
      res.json({
        symbol: symbol.toUpperCase(),
        valid: false,
        message: "Stock not found or price unavailable",
      });
    }
  } catch (error) {
    res.json({
      symbol: symbol.toUpperCase(),
      valid: false,
      message: error.message,
    });
  }
});

/**
 * GET /api/cache/clear
 * Clear the price cache
 */
app.get("/api/cache/clear", (req, res) => {
  priceCache.clear();
  res.json({
    status: "cache cleared",
    timestamp: Date.now(),
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`PSX Proxy Server running on http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
  console.log(`Example: http://localhost:${PORT}/api/stock/FFC/price`);
});

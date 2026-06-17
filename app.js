let PORTFOLIO =
  JSON.parse(localStorage.getItem("PSX_PORTFOLIO")) ||
  JSON.parse(JSON.stringify(window.DEFAULT_PORTFOLIO));
let TRANSACTIONS = JSON.parse(localStorage.getItem("PSX_TX")) || [];
let DIVIDENDS = JSON.parse(localStorage.getItem("PSX_DIVS")) || [];
let APP_PIN = localStorage.getItem("PSX_PIN") || "";
let IS_LOCKED = APP_PIN !== "" && !sessionStorage.getItem("PSX_UNLOCKED");
let CURRENT_PIN_INPUT = "";

let FAVORITES = JSON.parse(localStorage.getItem("PSX_FAVORITES")) || [
  "FFC",
  "HUBC",
  "MEBL",
];
window.selectedStockSymbol = null;

const STOCK_METADATA = {
  FFC: {
    name: "Fauji Fertilizer Co",
    sector: "Fertilizer",
    price: 504.27,
    yield: 10.9,
  },
  BIPL: {
    name: "BankIslami Pakistan",
    sector: "Banking",
    price: 24.98,
    yield: 6.0,
  },
  HUBC: {
    name: "Hub Power Company",
    sector: "Energy",
    price: 220.49,
    yield: 9.1,
  },
  NATF: {
    name: "National Foods Limited",
    sector: "Food",
    price: 370.08,
    yield: 4.9,
  },
  OGDC: {
    name: "Oil & Gas Dev Co",
    sector: "Energy",
    price: 303.17,
    yield: 7.3,
  },
  EFERT: {
    name: "Engro Fertilizers",
    sector: "Fertilizer",
    price: 198.83,
    yield: 10.1,
  },
  FATIMA: {
    name: "Fatima Fertilizer Co",
    sector: "Fertilizer",
    price: 130.29,
    yield: 9.2,
  },
  MEBL: { name: "Meezan Bank", sector: "Banking", price: 492.34, yield: 3.0 },
  PPL: {
    name: "Pakistan Petroleum Ltd",
    sector: "Energy",
    price: 206.64,
    yield: 8.2,
  },
  ENGRO: {
    name: "Engro Corporation",
    sector: "Conglomerate",
    price: 330.4,
    yield: 9.5,
  },
  LUCK: { name: "Lucky Cement", sector: "Cement", price: 765.2, yield: 4.2 },
  SYS: {
    name: "Systems Limited",
    sector: "Technology",
    price: 410.8,
    yield: 2.5,
  },
  PSO: {
    name: "Pakistan State Oil",
    sector: "Energy",
    price: 185.3,
    yield: 8.0,
  },
  MCB: {
    name: "MCB Bank Limited",
    sector: "Banking",
    price: 210.4,
    yield: 9.8,
  },
  HBL: {
    name: "Habib Bank Limited",
    sector: "Banking",
    price: 118.5,
    yield: 7.8,
  },
  FFBL: {
    name: "Fauji Fertilizer Bin Qasim",
    sector: "Fertilizer",
    price: 38.4,
    yield: 7.5,
  },
  SEARL: {
    name: "The Searle Company",
    sector: "Pharmaceuticals",
    price: 58.6,
    yield: 3.5,
  },
  MARI: { name: "Mari Petroleum", sector: "Energy", price: 2450.0, yield: 6.5 },
  TRG: { name: "TRG Pakistan", sector: "Technology", price: 65.4, yield: 0.0 },
};

function getStockDetailsLocal(symbol) {
  symbol = symbol.toUpperCase();
  const meta = STOCK_METADATA[symbol] || {
    name: symbol,
    sector: "Other",
    price: 100,
    yield: 0,
  };
  const r = RATIOS.find((x) => x.symbol === symbol) || {
    de: null,
    icr: null,
    netDebtEbitda: null,
    pfcf: null,
    fcfYield: null,
    ocfRatio: null,
    assetTurnover: null,
    invTurnover: null,
    score: 50,
    verdict: "Neutral",
  };
  const portItem = PORTFOLIO.find((p) => p.symbol === symbol);

  return {
    symbol,
    name: portItem?.name || meta.name,
    sector: portItem?.sector || meta.sector,
    price: portItem?.price || meta.price,
    yield: portItem?.yld || meta.yield,
    de: r.de,
    icr: r.icr,
    netDebtEbitda: r.netDebtEbitda,
    pfcf: r.pfcf,
    fcfYield: r.fcfYield,
    ocfRatio: r.ocfRatio,
    assetTurnover: r.assetTurnover,
    invTurnover: r.invTurnover,
    score: r.score,
    verdict: r.verdict,
    avgBuy: portItem?.avgBuy || null,
    pnlPct: portItem?.pnlPct || null,
  };
}

async function getStockDetails(symbol) {
  symbol = symbol.toUpperCase();
  // Offline mode: use local data only
  return getStockDetailsLocal(symbol);
}

// Favorites & Search Actions
window.toggleFavorite = function (symbol) {
  symbol = symbol.toUpperCase();
  const idx = FAVORITES.indexOf(symbol);
  if (idx > -1) {
    FAVORITES.splice(idx, 1);
    showToast(`${symbol} removed from Favorites`, "☆");
  } else {
    FAVORITES.push(symbol);
    showToast(`${symbol} added to Favorites`, "⭐");
  }
  localStorage.setItem("PSX_FAVORITES", JSON.stringify(FAVORITES));
  renderBuyTool();
};

window.selectSearchStock = async function (symbol) {
  symbol = symbol.toUpperCase();
  window.selectedStockSymbol = symbol;

  // Render loading state immediately
  renderBuyTool({ loading: true });

  try {
    const newsData = await fetchNewsAnalysis(symbol);
    renderBuyTool(newsData);
  } catch (err) {
    console.error("Error fetching news:", err);
    renderBuyTool();
  }
};

window.executeStockSearch = function () {
  const inputVal = el("buySearchInput")?.value?.trim()?.toUpperCase() || "";
  if (!inputVal) return;

  const match = RATIOS.find(
    (r) =>
      r.symbol === inputVal ||
      r.symbol.toLowerCase() === inputVal.toLowerCase(),
  );
  if (match) {
    window.selectSearchStock(match.symbol);
  } else {
    const pMatch = PORTFOLIO.find((s) => s.symbol === inputVal);
    if (pMatch) {
      window.selectSearchStock(pMatch.symbol);
    } else {
      showToast(`Stock "${inputVal}" not found.`, "❌");
    }
  }
};

window.handleSearchKey = function (e) {
  if (e.key === "Enter") {
    window.executeStockSearch();
  }
};

window.clearStockSearch = function () {
  window.selectedStockSymbol = null;
  renderBuyTool();
};

window.prefillLogBuy = function (symbol) {
  const symbolEl = el("buySymbol");
  if (symbolEl) {
    symbolEl.value = symbol.toUpperCase();
  }
  openModal("modalAddBuy");
};

window.prefillLogSell = function (symbol) {
  const symbolEl = el("sellSymbol");
  if (symbolEl) {
    symbolEl.value = symbol.toUpperCase();
  }
  openModal("modalSell");
};

// News Sentiment Engine (Offline mode)
async function fetchNewsAnalysis(symbol) {
  // Use client-side news analysis only
  return getClientSideNewsAnalysis(symbol);
}

function getClientSideNewsAnalysis(symbol) {
  symbol = symbol.toUpperCase();

  const s = PORTFOLIO.find((p) => p.symbol === symbol) ||
    RATIOS.find((r) => r.symbol === symbol) || {
      name: symbol,
      sector: "General",
    };
  const companyName = s.name;
  const sector = s.sector || "General";

  const headlinesDb = {
    Fertilizer: [
      {
        t: `${companyName} announces expansion of gas purification facility at Daharki`,
        p: "Positive",
        s: `Strategic infrastructure upgrade ensures stable raw gas supply, boosting long-term production capability.`,
      },
      {
        t: "Urea dispatches drop in off-season, sector margins compress",
        p: "Negative",
        s: `Temporary inventory build-up reported across fertilizer manufacturers, expected to ease with upcoming Kharif season.`,
      },
      {
        t: `${companyName} secures gas subsidy extension from ECC`,
        p: "Positive",
        s: `Government extends subsidized feedstock pricing, safeguarding core profit margins for another quarter.`,
      },
    ],
    Energy: [
      {
        t: "Circular debt reaches record high, power sector cash flows strained",
        p: "Negative",
        s: `Outstanding receivables continue to delay payments to independent power producers, impacting liquidity.`,
      },
      {
        t: `${companyName} reports exploration success with significant gas discovery`,
        p: "Positive",
        s: `Successful testing confirms viable reserves, promising new revenue streams and boosting asset value.`,
      },
      {
        t: `${companyName} board approves payout as earnings jump 15%`,
        p: "Positive",
        s: `Strong operating cash flows enable generous cash distributions, reinforcing its S-tier dividend yield status.`,
      },
    ],
    Banking: [
      {
        t: `Meezan and ${companyName} lead Islamic banking sector profit growth`,
        p: "Positive",
        s: `Consumer shift towards Shariah-compliant finance generates strong asset expansion and operating profit.`,
      },
      {
        t: "SBP signals potential discount rate cut to stimulate private credit",
        p: "Negative",
        s: `Lower interest rates could compress net interest margins for major commercial banks in the coming half.`,
      },
      {
        t: `State Bank issues strict compliance directives on digitizing remittances`,
        p: "Neutral",
        s: `Banks required to enhance digital channels; long-term compliance overhead expected to be minor.`,
      },
    ],
    Cement: [
      {
        t: "Cement dispatches hit by rising coal import prices and tax hike",
        p: "Negative",
        s: `Increased cost of production coupled with slow domestic construction dampens near-term volume growth.`,
      },
      {
        t: `${companyName} expands export footprint into East African markets`,
        p: "Positive",
        s: `Diversification of sales helps offset lower local demand, optimizing capacity utilization.`,
      },
    ],
    Technology: [
      {
        t: `IT export remittances surge as ${companyName} bags major European contract`,
        p: "Positive",
        s: `New software development contract provides strong foreign exchange inflows and recurring revenue.`,
      },
      {
        t: "Global tech spending slows down; tech stocks face valuation checks",
        p: "Negative",
        s: `Macro headwinds compress software vendor valuations, although operational margins remain resilient.`,
      },
    ],
    Food: [
      {
        t: `${companyName} expands retail distribution network, sales up 18%`,
        p: "Positive",
        s: `Brand equity and aggressive distribution expansion drive robust double-digit volume growth.`,
      },
      {
        t: "Rising packaging and raw commodity costs pinch consumer goods margins",
        p: "Negative",
        s: `High inflation pressures operational margins, forcing gradual price increases to pass costs onto consumers.`,
      },
    ],
  };

  const defaultHeadlines = [
    {
      t: `${companyName} announces board meeting to review quarterly accounts`,
      p: "Neutral",
      s: `Routine administrative update. No material impact expected on stock price.`,
    },
    {
      t: `Rupee stabilization provides minor relief to import-dependent sectors`,
      p: "Positive",
      s: `More stable currency reduces raw material cost volatility, benefiting corporate operating expenses.`,
    },
    {
      t: `Finance Ministry reviews corporate tax structure under IMF guidelines`,
      p: "Negative",
      s: `Potential changes in corporate tax or super tax rules could create mild headwinds for major PSX equities.`,
    },
  ];

  const sectorHeadlines = headlinesDb[sector] || defaultHeadlines;

  const POSITIVE_WORDS = [
    "profit",
    "dividend",
    "grow",
    "gain",
    "surplus",
    "up",
    "bull",
    "recover",
    "record",
    "exceed",
    "approve",
    "invest",
    "expand",
    "buy",
    "positive",
    "increase",
    "jump",
    "climb",
    "high",
    "raise",
    "bonus",
    "payout",
    "deal",
    "sales",
    "revenue",
    "strengthen",
    "surge",
    "upward",
  ];
  const NEGATIVE_WORDS = [
    "loss",
    "decline",
    "drop",
    "deficit",
    "down",
    "bear",
    "crisis",
    "cut",
    "decrease",
    "negative",
    "warn",
    "debt",
    "charge",
    "court",
    "penalty",
    "slump",
    "fall",
    "lower",
    "reduce",
    "contract",
    "investigate",
    "fine",
    "tax",
    "inflation",
    "hike",
    "default",
    "weak",
  ];

  const articles = sectorHeadlines.map((h) => {
    const title = h.t;
    const words = title.toLowerCase().split(/[^a-zA-Z]+/);
    let posCount = 0;
    let negCount = 0;

    words.forEach((w) => {
      if (POSITIVE_WORDS.includes(w)) posCount++;
      if (NEGATIVE_WORDS.includes(w)) negCount++;
    });

    let sentiment = "Neutral";
    let score = 0;
    if (posCount > negCount) {
      sentiment = "Positive";
      score = posCount - negCount;
    } else if (negCount > posCount) {
      sentiment = "Negative";
      score = negCount - posCount;
    }

    return {
      title,
      link: "https://www.brecorder.com",
      pubDate:
        new Date().toLocaleDateString("en-PK", {
          day: "numeric",
          month: "short",
          year: "numeric",
        }) + " (Simulated)",
      sentiment,
      score,
      summary: h.s,
    };
  });

  let totalPos = 0;
  let totalNeg = 0;
  articles.forEach((a) => {
    if (a.sentiment === "Positive") totalPos++;
    if (a.sentiment === "Negative") totalNeg++;
  });

  let overallSentiment = "Neutral";
  let impactExplanation = `Balanced simulated news feed for ${companyName}. Latest reports indicate stable operations and standard corporate notifications. No immediate action required.`;

  if (totalPos > totalNeg) {
    overallSentiment = "Positive";
    impactExplanation = `Positive simulated news flow detected for ${companyName} on Business Recorder. Drivers include earnings growth, dividend distributions, or expansion deals. This acts as a catalyst for potential price appreciation.`;
  } else if (totalNeg > totalPos) {
    overallSentiment = "Negative";
    impactExplanation = `Negative simulated news flow or headwinds reported for ${companyName} on Business Recorder. Watch for increasing cost of production, tax increases, or operating profit drops. Suggest reviewing safety ratios before allocating more capital.`;
  }

  return {
    success: true,
    symbol,
    companyName,
    overallSentiment,
    impactExplanation,
    articlesCount: articles.length,
    articles,
  };
}

function savePortfolio() {
  localStorage.setItem("PSX_PORTFOLIO", JSON.stringify(PORTFOLIO));
  localStorage.setItem("PSX_TX", JSON.stringify(TRANSACTIONS));
  localStorage.setItem("PSX_DIVS", JSON.stringify(DIVIDENDS));
  init(); // Re-render everything
}

// ── Helpers ──────────────────────────────────────────────────────────────────
const fmt = (n) => "₨" + Math.round(n).toLocaleString("en-PK");
const fmtN = (n) => (n == null ? "—" : n.toFixed(2));
const pct = (a, b) => (((a - b) / b) * 100).toFixed(1);
const el = (id) => document.getElementById(id);

function ratioColor(key, val) {
  if (val == null) return "color:var(--muted)";
  const good = {
    de: [0, 1],
    icr: [3, 999],
    netDebtEbitda: [-999, 2],
    pfcf: [0, 15],
    fcfYield: [8, 999],
    ocfRatio: [1, 999],
    assetTurnover: [0.5, 999],
    invTurnover: [4, 999],
  };
  const g = good[key];
  if (!g) return "";
  const ok = val >= g[0] && val <= g[1];
  return ok ? "color:var(--green)" : "color:var(--red)";
}

function scoreColor(s) {
  if (s >= 80) return { bg: "rgba(34,197,94,0.15)", color: "#22c55e" };
  if (s >= 65) return { bg: "rgba(245,158,11,0.15)", color: "#f59e0b" };
  return { bg: "rgba(239,68,68,0.15)", color: "#ef4444" };
}

// ── Tab switching ─────────────────────────────────────────────────────────────
const TAB_IDS = [
  "overview",
  "portfolio",
  "roadmap",
  "history",
  "screener",
  "tierlist",
  "buytool",
  "projection",
  "settings",
];
const BNAV_IDS = ["overview", "portfolio", "roadmap", "buytool", "settings"];

function switchTab(id, scroll = true) {
  // Save tab state
  localStorage.setItem("ACTIVE_TAB", id);

  // Top nav
  document.querySelectorAll("#navTabs .tab").forEach((t, i) => {
    t.classList.toggle("active", TAB_IDS[i] === id);
  });
  // Bottom nav
  document.querySelectorAll("#bottomNav .bnav-btn").forEach((t, i) => {
    t.classList.toggle("active", BNAV_IDS[i] === id);
  });
  // Panels
  document
    .querySelectorAll(".tab-panel")
    .forEach((p) => p.classList.remove("active"));
  const target = el("tab-" + id);
  if (target) target.classList.add("active");

  // Scroll to top
  if (scroll) window.scrollTo({ top: 0, behavior: "smooth" });
}

// ── Computed values ───────────────────────────────────────────────────────────
function computePortfolio() {
  let totalInvested = 0,
    totalValue = 0,
    totalDiv = 0;
  PORTFOLIO.forEach((s) => {
    s.cost = s.shares * s.avgBuy;
    s.value = s.shares * s.price;
    s.pnl = s.value - s.cost;
    s.pnlPct = parseFloat(pct(s.price, s.avgBuy));
    s.annDiv = s.shares * s.dpshist;
    s.yld = ((s.dpshist / s.price) * 100).toFixed(1);
    totalInvested += s.cost;
    totalValue += s.value;
    totalDiv += s.annDiv;
  });
  return {
    totalInvested,
    totalValue,
    totalDiv,
    totalPnl: totalValue - totalInvested,
  };
}

// ── OVERVIEW TAB ─────────────────────────────────────────────────────────────
function renderOverview(stats) {
  const now = new Date();
  const startMonth = 0; // Jan
  const startYear = 2026;
  const currentMonthNum =
    (now.getFullYear() - startYear) * 12 + (now.getMonth() - startMonth) + 1;

  const goalPct = ((stats.totalDiv / GOAL_ANNUAL) * 100).toFixed(1);
  el("hMonthNum").textContent = "Month " + currentMonthNum;
  el("hTotal").textContent = fmt(stats.totalInvested);
  el("hGoalPct").textContent = goalPct + "%";

  el("tab-overview").innerHTML = `
    <div class="section-title">📊 Portfolio Overview</div>

    <div class="grid-4 mb-6">
      <div class="card">
        <div class="card-title">Total Invested</div>
        <div class="card-value">${fmt(stats.totalInvested)}</div>
        <div class="card-sub">Month ${currentMonthNum} in progress</div>
      </div>
      <div class="card">
        <div class="card-title">Market Value</div>
        <div class="card-value">${fmt(stats.totalValue)}</div>
        <div class="card-sub ${stats.totalPnl >= 0 ? "green" : "red"}">${stats.totalPnl >= 0 ? "+" : ""}${fmt(stats.totalPnl)} P&L</div>
      </div>
      <div class="card">
        <div class="card-title">Annual Dividend</div>
        <div class="card-value green">${fmt(stats.totalDiv)}</div>
        <div class="card-sub">Estimated this year</div>
      </div>
      <div class="card" style="background:rgba(34,197,94,0.08);border:1px solid var(--green)">
        <div class="card-title">Actual Cash Recv</div>
        <div class="card-value green">${fmt(DIVIDENDS.reduce((a, b) => a + b.amount, 0))}</div>
        <div class="card-sub">Total Payouts Logged</div>
      </div>
    </div>

    <div class="card mb-6">
      <div class="card-title" style="margin-bottom:14px">🎯 Goal Progress — ₨2 Lakh/Year Dividend</div>
      <div style="display:flex;align-items:center;gap:16px;margin-bottom:10px">
        <div style="flex:1">
          <div class="progress-wrap"><div class="progress-fill" style="width:${goalPct}%"></div></div>
        </div>
        <div style="font-size:18px;font-weight:800;color:var(--green)">${goalPct}%</div>
      </div>
      <div style="display:flex;justify-content:space-between;font-size:12px;color:var(--muted)">
        <span>Now: ${fmt(stats.totalDiv)}/yr</span>
        <span>Target: ₨2,00,000/yr by Year 7</span>
      </div>
    </div>

    <div class="section-title">📅 Dividend Waves Calendar</div>
    <div class="grid-3 mb-6">
      ${DIVIDEND_WAVES.map(
        (w) => `
        <div class="wave-card">
          <div class="wave-title" style="color:${w.color}">${w.wave} Wave</div>
          <div class="wave-time">${w.month}</div>
          <div class="wave-stocks">${w.stocks.map((s) => `<div class="wave-chip">${s}</div>`).join("")}</div>
        </div>
      `,
      ).join("")}
    </div>

    <div class="section-title">⚡ Golden Rules (S-Tier Strategy)</div>
    <div class="grid-2">
      ${[
        [
          "💎",
          "HUBC > FFC > EFERT",
          "Always prioritize your Core 3 first. Every month, fill these positions before any secondary or small stocks.",
        ],
        [
          "📅",
          "Never Skip a Month",
          "SIP only works through consistency. Missing one month breaks the compound chain. Automate if possible.",
        ],
        [
          "🔄",
          "Reinvest Every Dividend",
          "When FFC or EFERT pays out, immediately reinvest into more HUBC or EFERT shares. This is where compounding accelerates.",
        ],
        [
          "📰",
          "Read BR Daily",
          "Open brecorder.com every morning. Takes 10 minutes. Keeps you ahead of retail investors trading on rumors.",
        ],
        [
          "🚫",
          "No Viral Stocks (D-Tier)",
          "If a stock is trending on WhatsApp/Twitter, that is your signal to IGNORE it. You buy at the peak.",
        ],
        [
          "📊",
          "Check Ratios Before Buying",
          "Before adding a new position, check D/E < 2, ICR > 3, FCF Yield > 7%. Protects from value traps.",
        ],
      ]
        .map(
          ([icon, title, body]) => `
        <div class="rule-card">
          <div class="rule-icon">${icon}</div>
          <div><div class="rule-title">${title}</div><div class="rule-body">${body}</div></div>
        </div>
      `,
        )
        .join("")}
    </div>
  `;
}

// ── PORTFOLIO TAB ─────────────────────────────────────────────────────────────
function renderPortfolio() {
  const tiers = ["core", "secondary", "small"];
  const tierLabels = {
    core: "🔥 Core — Main Dividend Engine",
    secondary: "⚡ Secondary — Energy Boost",
    small: "🧩 Small — Diversification",
  };

  let html = `
    <div class="section-title">💼 Your Portfolio — Month 5</div>
    <p class="section-sub">Real data from Investify. Manage your holdings below.</p>
    
    <div style="display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap">
      <button class="btn-primary" onclick="openModal('modalAddBuy')" style="background:var(--blue);width:auto;padding:8px 16px">➕ Log Buy</button>
      <button class="btn-primary" onclick="openModal('modalSell')" style="background:var(--red);width:auto;padding:8px 16px">➖ Log Sale</button>
      <button class="btn-primary" onclick="openModal('modalLogDividend')" style="background:var(--green);width:auto;padding:8px 16px">💰 Log Dividend</button>
    </div>
  `;

  tiers.forEach((tier) => {
    const stocks = PORTFOLIO.filter((s) => s.tier === tier);
    html += `<div class="section-title" style="font-size:15px;margin-bottom:12px">${tierLabels[tier]}</div>
      <div class="table-wrap mb-6">
        <table>
          <thead><tr>
            <th>Stock</th><th>Sector</th><th>Shares</th><th>Avg Buy</th><th>Price Now</th>
            <th>Total Cost</th><th>Market Value</th><th>P&L</th><th>Ann. Dividend</th><th>Yield</th><th>Actions</th>
          </tr></thead>
          <tbody>
            ${stocks
              .map(
                (s) => `<tr>
              <td><strong>${s.symbol}</strong><div style="font-size:11px;color:var(--muted)">${s.name}</div></td>
              <td><span class="badge badge-muted">${s.sector}</span></td>
              <td>${s.shares}</td>
              <td>₨${s.avgBuy.toFixed(2)}</td>
              <td>₨${s.price.toFixed(2)}</td>
              <td>${fmt(s.cost)}</td>
              <td>${fmt(s.value)}</td>
              <td class="${s.pnl >= 0 ? "green" : "red"}">${s.pnl >= 0 ? "+" : ""}${fmt(s.pnl)}<br><span style="font-size:11px">${s.pnlPct >= 0 ? "+" : ""}${s.pnlPct}%</span></td>
              <td class="green">${fmt(s.annDiv)}</td>
              <td class="green">${s.yld}%</td>
              <td><button onclick="removeStock('${s.symbol}')" style="background:none;border:none;color:var(--red);cursor:pointer;font-size:16px;padding:4px" title="Remove Stock">🗑️</button></td>
            </tr>`,
              )
              .join("")}
          </tbody>
        </table>
      </div>`;
  });
  el("tab-portfolio").innerHTML = html;
}

// ── SIP TRACKER TAB ───────────────────────────────────────────────────────────
function renderSIP() {
  const months = MONTHLY_PLAN;
  let html = `
    <div class="section-title">📅 SIP Tracker — Month 6 → Month 24</div>
    <p class="section-sub">S-Tier Strategy from Video 1. Invest ₨10,000 every month without fail. Click any month to see the exact buy plan.</p>
    <div class="br-banner mb-6">
      <div class="br-icon">📰</div>
      <div>
        <div class="br-title">S-Tier Tool: Business Recorder (Free)</div>
        <div class="br-body">Read <a href="https://brecorder.com" target="_blank" class="br-link">brecorder.com</a> every morning before buying. Check company results, SBP rate decisions, and sector news. This is the free edge the video creator uses.</div>
      </div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:14px">
      ${months
        .map(
          (m) => `
        <div class="sip-month ${m.month === 6 ? "active-month" : ""}" onclick="toggleSIP(this)">
          <div class="sip-num">Month ${m.month} ${m.month === 6 ? "← YOU ARE HERE" : ""}</div>
          <div class="sip-focus">${m.focus}</div>
          <div style="font-size:12px;color:var(--muted);margin-top:4px">Budget: ₨10,000</div>
          <div class="sip-detail">
            ${m.buys
              .map((b) => {
                const s = PORTFOLIO.find((p) => p.symbol === b.s) || {
                  price: 200,
                };
                const amt = (10000 * b.pct) / 100;
                const shares = Math.floor(amt / s.price);
                return `<div class="buy-row">
                <span style="font-weight:700;width:60px">${b.s}</span>
                <div class="buy-bar-wrap"><div class="buy-bar" style="width:${b.pct}%"></div></div>
                <span style="color:var(--muted);font-size:12px;width:30px">${b.pct}%</span>
                <span style="color:var(--green);width:60px;text-align:right">~${shares} sh</span>
              </div>`;
              })
              .join("")}
            <div style="margin-top:10px;padding:10px;background:rgba(34,197,94,0.06);border-radius:8px">
              <ul class="checklist">
                <li><span class="check">✓</span> Check BR news for these sectors before buying</li>
                <li><span class="check">✓</span> Confirm dividend yield still above 8%</li>
                <li><span class="check">✓</span> No viral/hype news pushing the price up today</li>
              </ul>
            </div>
          </div>
        </div>
      `,
        )
        .join("")}
    </div>`;
  el("tab-sip").innerHTML = html;
}

// ── HISTORY TAB ─────────────────────────────────────────────────────────────
function renderHistory() {
  const sortedTx = [...TRANSACTIONS].reverse();
  const sortedDivs = [...DIVIDENDS].reverse();

  let html = `
    <div class="section-title">📜 Transaction & Dividend History</div>
    <div style="display:flex;gap:12px;margin-bottom:20px">
      <button class="btn-primary" onclick="openModal('modalLogDividend')" style="background:var(--green);width:auto">💰 Log Dividend Arrival</button>
    </div>

    <div class="card mb-6">
      <div class="card-title" style="margin-bottom:12px">🛒 Recent Buys</div>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Date</th><th>Stock</th><th>Action</th><th>Shares</th><th>Price</th><th>Total</th></tr></thead>
          <tbody>
            ${
              sortedTx.length === 0
                ? '<tr><td colspan="6" style="text-align:center;padding:20px;color:var(--muted)">No transactions logged yet.</td></tr>'
                : sortedTx
                    .map(
                      (t) => `<tr>
                <td>${t.date}</td>
                <td><strong>${t.symbol}</strong></td>
                <td><span class="badge badge-green">BUY</span></td>
                <td>${t.shares}</td>
                <td>₨${t.price}</td>
                <td>${fmt(t.shares * t.price)}</td>
              </tr>`,
                    )
                    .join("")
            }
          </tbody>
        </table>
      </div>
    </div>

    <div class="card">
      <div class="card-title" style="margin-bottom:12px">💵 Dividends Received</div>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Date</th><th>Stock</th><th>Amount</th><th>Notes</th></tr></thead>
          <tbody>
            ${
              sortedDivs.length === 0
                ? '<tr><td colspan="4" style="text-align:center;padding:20px;color:var(--muted)">No dividends logged yet.</td></tr>'
                : sortedDivs
                    .map(
                      (d) => `<tr>
                <td>${d.date}</td>
                <td><strong>${d.symbol}</strong></td>
                <td class="green">${fmt(d.amount)}</td>
                <td style="font-size:12px;color:var(--muted)">${d.note || "—"}</td>
              </tr>`,
                    )
                    .join("")
            }
          </tbody>
        </table>
      </div>
    </div>
  `;
  el("tab-history").innerHTML = html;
}

function toggleSIP(el) {
  el.classList.toggle("open");
}
function toggleRoadmapMonth(el) {
  el.classList.toggle("open");
}

// ── ROADMAP TAB ────────────────────────────────────────────────────────
function renderRoadmap() {
  const curMonth = getCurrentMonth();
  const curPart =
    ROADMAP_PARTS.find(
      (p) => curMonth >= p.monthRange[0] && curMonth <= p.monthRange[1],
    ) || ROADMAP_PARTS[0];
  const colors = [
    "#22c55e",
    "#3b82f6",
    "#f59e0b",
    "#a855f7",
    "#ec4899",
    "#ef4444",
    "#22c55e",
  ];

  let partButtons = ROADMAP_PARTS.map((p, i) => {
    const active = p.part === curPart.part;
    return `<button onclick="showPart(${i})" id="partBtn${i}"
      style="background:${active ? colors[i] + "22" : "rgba(255,255,255,0.04)"};
             border:1px solid ${active ? colors[i] : "rgba(255,255,255,0.08)"};
             color:${active ? colors[i] : "#71717a"};
             padding:7px 14px;border-radius:8px;cursor:pointer;font-family:inherit;
             font-size:12px;font-weight:600;transition:all 0.2s">
      ${p.icon} Part ${p.part} <span style="opacity:0.6;font-size:10px">${p.months.split("→")[0].trim()}</span>
    </button>`;
  }).join("");

  let panels = ROADMAP_PARTS.map((p, i) => {
    const col = colors[i];
    const isActive = p.part === curPart.part;
    let allocRows = p.allocs
      .map((a, ai) => {
        const stock = PORTFOLIO.find((s) => s.symbol === a.s) || { price: 200 };
        const shares =
          a.s === "ANY" ? "—" : Math.floor(a.amt / stock.price) + " shares";
        const barW = Math.round((a.amt / p.budget) * 100);
        return `
        <div style="background:${ai % 2 === 0 ? "rgba(255,255,255,0.02)" : "transparent"};border-bottom:1px solid rgba(255,255,255,0.04)">
          <div style="display:flex;align-items:center;gap:12px;padding:11px 14px">
            <div style="width:65px;font-weight:800;font-size:14px;color:${col}">${a.s}</div>
            <div style="flex:1;height:5px;background:rgba(255,255,255,0.07);border-radius:999px;overflow:hidden">
              <div style="height:100%;width:${barW}%;background:${col};border-radius:999px"></div>
            </div>
            <div style="width:80px;text-align:right;font-weight:700">₨${a.amt.toLocaleString()}</div>
            <div style="width:70px;text-align:right;font-size:12px;color:#71717a">${shares}</div>
          </div>
          <div style="font-size:11px;color:#52525b;padding:0 14px 8px">${a.note}</div>
        </div>`;
      })
      .join("");

    return `<div id="partPanel${i}" style="display:${isActive ? "block" : "none"}">
      <div style="background:${col}10;border:1px solid ${col}28;border-radius:14px;padding:22px;margin-bottom:20px">
        <div style="display:flex;align-items:center;gap:14px;margin-bottom:16px">
          <div style="font-size:40px">${p.icon}</div>
          <div>
            <div style="font-size:18px;font-weight:800;color:${col}">${p.label}</div>
            <div style="font-size:13px;color:#71717a;margin-top:3px">${p.months} • ₨10,000/month</div>
            <div style="font-size:13px;margin-top:5px">${p.theme}</div>
          </div>
        </div>
        <div style="background:${col}18;border-radius:10px;padding:12px 16px;margin-bottom:16px;display:flex;gap:10px;align-items:center">
          <span style="font-size:18px">🎯</span>
          <span style="font-weight:700;color:${col}">${p.divTarget}</span>
        </div>
        
        <div style="font-size:12px;font-weight:700;color:#71717a;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:8px">Monthly Breakdowns</div>
        ${Array.from(
          { length: p.monthRange[1] - p.monthRange[0] + 1 },
          (_, j) => {
            const mNum = p.monthRange[0] + j;
            const mPlan = MONTHLY_PLAN.find((m) => m.month === mNum);
            if (!mPlan) return "";
            return `
            <div class="roadmap-month ${mNum === curMonth ? "active-month" : ""}" onclick="toggleRoadmapMonth(this)">
              <div class="roadmap-month-header">
                <span>Month ${mNum} — ${mPlan.focus} ${mNum === curMonth ? "🎯" : ""}</span>
                <span class="arrow">▶</span>
              </div>
              <div class="roadmap-month-detail" style="${mNum === curMonth ? "display:block" : ""}">
                ${mPlan.buys
                  .map((b) => {
                    const s = PORTFOLIO.find((p) => p.symbol === b.s) || {
                      price: 200,
                    };
                    const r = RATIOS.find((x) => x.symbol === b.s);
                    const br = r ? calcBRScore(s, RATIOS) : null;
                    const amt = (10000 * b.pct) / 100;
                    const shares = Math.floor(amt / s.price);
                    const signal = br
                      ? br.signal === "buy"
                        ? "🟢"
                        : "🟡"
                      : "";
                    return `<div class="buy-row">
                    <span style="font-weight:700;width:80px">${signal} ${b.s}</span>
                    <div class="buy-bar-wrap"><div class="buy-bar" style="width:${b.pct}%"></div></div>
                    <span style="color:var(--muted);font-size:12px;width:30px">${b.pct}%</span>
                    <span style="color:var(--green);width:70px;text-align:right">₨${amt.toLocaleString()}</span>
                  </div>`;
                  })
                  .join("")}
              </div>
            </div>`;
          },
        ).join("")}

        <div style="font-size:12px;font-weight:700;color:#71717a;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:8px;margin-top:24px">Base Allocation</div>
        <div style="border-radius:10px;overflow:hidden;border:1px solid rgba(255,255,255,0.07)">
          ${allocRows}
          <div style="display:flex;justify-content:space-between;padding:12px 14px;background:rgba(255,255,255,0.04);font-weight:700">
            <span>Total / Month</span><span style="color:${col}">₨${p.budget.toLocaleString()}</span>
          </div>
        </div>
        ${
          p.special
            ? `
        <div style="margin-top:12px;background:rgba(245,158,11,0.08);border:1px solid rgba(245,158,11,0.2);border-radius:10px;padding:12px 14px">
          <div style="font-size:12px;font-weight:700;color:#f59e0b;margin-bottom:4px">⚡ SPECIAL RULE</div>
          <div style="font-size:12px;color:#a1a1aa">${p.special}</div>
          <div style="display:flex;gap:6px;flex-wrap:wrap;margin-top:8px">
            ${p.specialStocks.map((s) => `<span style="background:rgba(245,158,11,0.1);border:1px solid rgba(245,158,11,0.25);color:#f59e0b;padding:3px 10px;border-radius:6px;font-size:11px;font-weight:700">${s}</span>`).join("")}
          </div>
        </div>`
            : ""
        }
        <div style="margin-top:10px;font-size:12px;color:#71717a">
          <span style="color:${col};font-weight:700">📌 Rule:</span> ${p.rule}
        </div>
      </div>
    </div>`;
  }).join("");

  const checklistState = JSON.parse(
    localStorage.getItem("CHECKLIST_STATE") || "{}",
  );
  const curMonthKey = "m" + curMonth;
  const monthChecks = checklistState[curMonthKey] || [
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  let checklists = [
    [
      "📰",
      "Read B.R. today",
      "brecorder.com — check for result announcements or bad news. Profit warning = skip that stock this month.",
    ],
    [
      "📊",
      "Check yields",
      "Confirm each stock yield is still >7%. If not, redirect money to Core (HUBC/FFC/EFERT).",
    ],
    [
      "🔬",
      "Run screener",
      "Value Screener tab — if any stock dropped below 60, hold and redirect funds to higher-scoring stocks.",
    ],
    [
      "💰",
      "Reinvest dividends first",
      "If dividends arrived this month, reinvest before adding your SIP ₨10,000.",
    ],
    [
      "🛒",
      "Buy using phase plan",
      "Follow the exact PKR amounts above. No improvisation. No changing based on feelings.",
    ],
    [
      "📅",
      "Mark month done",
      "Note down: month number, total invested, estimated annual dividend. Track progress.",
    ],
  ]
    .map(
      ([icon, t, d], i) => `
    <li style="flex-direction:column;align-items:flex-start">
      <div style="display:flex;align-items:center;gap:10px;width:100%">
        <input type="checkbox" id="chk${i}" ${monthChecks[i] ? "checked" : ""} onchange="toggleCheck(${i}, ${curMonth})" style="width:18px;height:18px;cursor:pointer;accent-color:#22c55e">
        <label for="chk${i}" style="font-weight:600;cursor:pointer;flex:1">${icon} ${t}</label>
      </div>
      <div style="font-size:12px;color:#71717a;margin-top:4px;margin-left:28px">${d}</div>
    </li>`,
    )
    .join("");

  el("tab-roadmap").innerHTML = `
    <div class="section-title">📋 7-Part Roadmap — Month 6 → 84</div>
    <p class="section-sub">Exact ₨ per stock every month for 7 years. Currently: <strong>${curPart.icon} ${curPart.label}</strong> (Month ${curMonth}).</p>
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px">${partButtons}</div>
    ${panels}
    <div class="section-title" style="font-size:16px;margin-top:8px">✅ Tick-and-Buy Checklist</div>
    <div class="card"><ul class="checklist">${checklists}</ul></div>
    <div class="section-title" style="font-size:16px;margin-top:24px">🧠 Universal Rules</div>
    <div class="grid-2">${UNIVERSAL_RULES.map(
      (r) => `
      <div class="rule-card">
        <div class="rule-icon">${r.icon}</div>
        <div><div class="rule-title">${r.title}</div><div class="rule-body">${r.body}</div></div>
      </div>`,
    ).join("")}
    </div>
    
    <div class="section-title" style="margin-top:32px">♾️ Phase 8 — Financial Freedom (Year 7+)</div>
    <div class="card" style="background:linear-gradient(135deg, rgba(34,197,94,0.05), rgba(59,130,246,0.05))">
      <div style="font-size:15px;font-weight:700;margin-bottom:12px">What happens after you reach the goal?</div>
      <p style="font-size:13px;line-height:1.6;color:var(--muted);margin-bottom:16px">
        Once you reach Year 7 (Month 84) and hit the ₨2,00,000/year dividend target, you transition to the **Endgame Phase**. This is where your machine works for you.
      </p>
      <div class="grid-2">
        <div class="ref-card">
          <div class="ref-title">Option A: Wealth Withdrawal</div>
          <div class="ref-body">Stop the ₨10,000 monthly SIP. Use the ₨16,000+ monthly dividend income for personal expenses. Your portfolio stays intact, paying you forever.</div>
        </div>
        <div class="ref-card">
          <div class="ref-title">Option B: Hyper-Growth</div>
          <div class="ref-body">Continue the SIP and reinvestment. At 15% compounding, your income will double to ₨4 Lakh/year by Year 12, and ₨8 Lakh/year by Year 17.</div>
        </div>
        <div class="ref-card">
          <div class="ref-title">Rule: Annual Rebalancing</div>
          <div class="ref-body">Every January, check your sector weights. If Fertilizer is >60%, sell some and move to Banking or Energy. Keep the engine balanced.</div>
        </div>
        <div class="ref-card">
          <div class="ref-title">Rule: The 10% Cushion</div>
          <div class="ref-body">Always keep 10% of your annual dividend income in a liquid fund (like MEBL savings) as a buffer for months when companies delay payouts.</div>
        </div>
      </div>
    </div>
  `;
}

function showPart(idx) {
  ROADMAP_PARTS.forEach((_, i) => {
    const p = document.getElementById("partPanel" + i);
    if (p) p.style.display = i === idx ? "block" : "none";
  });
}

// ── VALUE SCREENER TAB ────────────────────────────────────────────────────────
function renderScreener() {
  const ratioKeys = [
    "de",
    "icr",
    "netDebtEbitda",
    "pfcf",
    "fcfYield",
    "ocfRatio",
    "assetTurnover",
    "invTurnover",
  ];
  const ratioLabels = [
    "D/E",
    "ICR",
    "ND/EBITDA",
    "P/FCF",
    "FCF Yield",
    "OCF Ratio",
    "Asset TO",
    "Inv TO",
  ];

  let html = `
    <div class="section-title">🔬 Value Screener + B.R. Score</div>
    <p class="section-sub">Live Value Index (0–100) calculated from all 8 Video 2 ratios. B.R. Score combines ratio health, dividend yield, price momentum, and debt safety — calculated every month automatically.</p>

    <div class="table-wrap mb-6">
      <table>
        <thead><tr>
          <th>Stock</th>
          <th>B.R. Score</th>
          <th>Grade</th>
          <th>Signal</th>
          <th>Value Index</th>
          <th>Yield Scr</th>
          <th>Momentum</th>
          <th>Debt Safe</th>
          ${ratioLabels.map((l) => `<th>${l}</th>`).join("")}
        </tr></thead>
        <tbody>
          ${PORTFOLIO.map((stock) => {
            const r = RATIOS.find((x) => x.symbol === stock.symbol);
            const vi = calcValueIndex(r);
            const br = calcBRScore(stock, RATIOS);
            const sc = scoreColor(br.score);
            const viC = scoreColor(vi);
            const sigColor =
              br.signal === "buy"
                ? "badge-green"
                : br.signal === "hold"
                  ? "badge-yellow"
                  : "badge-red";
            const sigLabel =
              br.signal === "buy"
                ? "🟢 BUY"
                : br.signal === "hold"
                  ? "🟡 HOLD"
                  : "🔴 CAUTION";
            return `<tr>
              <td><strong>${stock.symbol}</strong><div style="font-size:11px;color:#71717a">${stock.name}</div></td>
              <td>
                <div style="display:flex;align-items:center;gap:8px">
                  <div class="score-circle" style="background:${sc.bg};color:${sc.color}">${br.score}</div>
                </div>
              </td>
              <td><span class="badge" style="background:${sc.bg};color:${sc.color}">${br.grade}</span></td>
              <td><span class="badge ${sigColor}">${sigLabel}</span></td>
              <td>
                <div style="display:flex;align-items:center;gap:8px">
                  <div style="width:50px;height:5px;background:rgba(255,255,255,0.07);border-radius:3px;overflow:hidden">
                    <div style="height:100%;width:${vi}%;background:${viC.color};border-radius:3px"></div>
                  </div>
                  <span style="color:${viC.color};font-weight:700;font-size:12px">${vi}</span>
                </div>
              </td>
              <td style="color:${br.yieldScore >= 70 ? "#22c55e" : br.yieldScore >= 50 ? "#f59e0b" : "#ef4444"};font-weight:600">${br.yieldScore}</td>
              <td style="color:${br.momentumScore >= 60 ? "#22c55e" : br.momentumScore >= 40 ? "#f59e0b" : "#ef4444"};font-weight:600">${br.momentumScore}</td>
              <td style="color:${br.debtScore >= 70 ? "#22c55e" : br.debtScore >= 50 ? "#f59e0b" : "#ef4444"};font-weight:600">${br.debtScore}</td>
              ${ratioKeys.map((k) => `<td class="ratio-cell" style="${ratioColor(k, r?.[k])}">${fmtN(r?.[k])}</td>`).join("")}
            </tr>`;
          }).join("")}
        </tbody>
      </table>
    </div>

    <!-- How B.R. Score is calculated -->
    <div class="card mb-6" style="background:rgba(34,197,94,0.05);border-color:rgba(34,197,94,0.2)">
      <div class="card-title" style="margin-bottom:12px">📰 How B.R. Score is Calculated (Monthly)</div>
      <div class="grid-2">
        ${[
          [
            "Value Index (40%)",
            "Weighted score from all 8 financial ratios (D/E, ICR, Net Debt/EBITDA, P/FCF, FCF Yield, OCF, Asset Turnover, Inventory Turnover). Higher = better financial health.",
          ],
          [
            "Dividend Yield Score (30%)",
            "Your actual yield vs the benchmark. 10%+ = 100 points. 7% = 70 points. Below 5% = 50 points. This is the most important factor for your strategy.",
          ],
          [
            "Price Momentum (15%)",
            "If current price is below your avg buy price, the score goes UP — this is a buying opportunity. If price ran ahead, score goes DOWN as a caution signal.",
          ],
          [
            "Debt Safety (15%)",
            "Based on D/E ratio. Below 0.5 = 100 (excellent). Below 1 = 80 (good). Above 2 = 20 (risky). Banks are evaluated differently (D/E not applicable).",
          ],
        ]
          .map(
            ([t, b]) =>
              `<div class="ref-card"><div class="ref-title">${t}</div><div class="ref-body">${b}</div></div>`,
          )
          .join("")}
      </div>
    </div>

    <div class="section-title" style="font-size:15px">📚 Ratio Reference Guide (Video 2)</div>
    <div class="grid-2 mt-6">
      ${[
        [
          "D/E Ratio",
          "Debt ÷ Equity. How much the company borrowed vs what it owns.",
          '<span class="ref-good">Below 1 = safe.</span> <span class="ref-bad">Above 2 = high risk.</span>',
        ],
        [
          "Interest Coverage (ICR)",
          "EBIT ÷ Interest Expense. Can profits cover interest payments?",
          '<span class="ref-good">Above 3 = healthy.</span> <span class="ref-bad">Below 1.5 = danger zone.</span>',
        ],
        [
          "Net Debt / EBITDA",
          "Years of EBITDA needed to repay all net debt.",
          '<span class="ref-good">Below 2 = comfortable.</span> Negative = net cash (OGDC = excellent).',
        ],
        [
          "P/FCF",
          "Price ÷ Free Cash Flow per share. Harder to manipulate than P/E.",
          '<span class="ref-good">Below 15 = good value.</span> <span class="ref-bad">Above 25 = expensive.</span>',
        ],
        [
          "FCF Yield",
          "Free Cash Flow per share ÷ Price × 100.",
          '<span class="ref-good">Above 8% = excellent.</span> Think of this as a "real" dividend yield.',
        ],
        [
          "OCF Ratio",
          "Operating Cash Flow ÷ Current Liabilities.",
          '<span class="ref-good">Above 1 = healthy.</span> <span class="ref-bad">Below 0.8 = liquidity risk.</span>',
        ],
        [
          "Asset Turnover",
          "Revenue ÷ Total Assets. How efficiently assets generate sales.",
          '<span class="ref-good">Higher = better.</span> Low ratios are normal for utilities (HUBC).',
        ],
        [
          "Inventory Turnover",
          "Cost of Goods ÷ Avg Inventory. How fast product sells.",
          '<span class="ref-good">Above 4 = good.</span> Only relevant for fertilizer &amp; food stocks.',
        ],
      ]
        .map(
          ([t, d, v]) =>
            `<div class="ref-card"><div class="ref-title">${t}</div><div class="ref-body" style="margin-bottom:6px">${d}</div><div class="ref-body">${v}</div></div>`,
        )
        .join("")}
    </div>`;
  el("tab-screener").innerHTML = html;
}

// ── TIER LIST TAB ─────────────────────────────────────────────────────────────
function renderTierList() {
  let html = `
    <div class="section-title">🏆 PSX Strategy Tier List — Video 1</div>
    <p class="section-sub">Complete ranking of every investment strategy on PSX. Strategies marked <span style="color:var(--green);font-weight:700">✓ You use this</span> are ones you already have in your plan.</p>`;

  TIERS.forEach((t) => {
    html += `
      <div class="tier-card" style="background:${t.bg};border-color:${t.color}33">
        <div class="tier-header">
          <div class="tier-badge" style="background:${t.color}22;color:${t.color}">${t.tier}</div>
          <div class="tier-info"><h3>${t.label}</h3><p>${t.items.length} strateg${t.items.length > 1 ? "ies" : "y"}</p></div>
        </div>
        ${t.items
          .map(
            (item) => `
          <div class="strategy-item" onclick="this.classList.toggle('open')">
            <div class="strategy-top">
              <div>
                <div class="strategy-name">${item.name}</div>
                ${item.youUse ? `<div class="strategy-you">✓ You use this</div>` : ""}
              </div>
              <span class="strategy-arrow">▶</span>
            </div>
            <div class="strategy-why">${item.why}</div>
          </div>
        `,
          )
          .join("")}
      </div>`;
  });
  el("tab-tierlist").innerHTML = html;
}

// ── BUY TOOL TAB ──────────────────────────────────────────────────────────────
function getCurrentMonth() {
  const startDate = new Date(2026, 0, 1);
  const now = new Date();
  const diffM =
    (now.getFullYear() - startDate.getFullYear()) * 12 +
    (now.getMonth() - startDate.getMonth());
  return Math.max(1, Math.min(84, diffM + 1));
}

window.renderBuyTool = function (newsData = null) {
  const curMonth = getCurrentMonth();
  const monthPlan =
    MONTHLY_PLAN.find((m) => m.month === curMonth) || MONTHLY_PLAN[0];
  const priorityMap = {
    FFC: 2,
    EFERT: 2,
    HUBC: 1,
    OGDC: 2,
    PPL: 3,
    FATIMA: 3,
    MEBL: 3,
    BIPL: 3,
    NATF: 3,
  };

  let html = `
    <div class="section-title">🛒 Monthly Buy Tool — Month ${curMonth} Decision</div>
    <p class="section-sub">S-Tier system: SIP ₨10,000 this month. Focus: <strong>${monthPlan.focus}</strong>. Check ratios + BR news before buying.</p>
    
    <!-- 🔍 Stock Search and B.R. News Analysis Card -->
    <div class="card mb-6" style="background:rgba(20,20,24,0.7); border:1px solid rgba(255,255,255,0.08); border-radius:16px;">
      <div style="font-size: 15px; font-weight: 700; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
        <span>🔍</span> Stock Research & News Sentiment Analyzer
      </div>
      
      <div style="display:flex; gap:12px; margin-bottom:16px; align-items:center;">
        <div style="flex:1; position:relative;">
          <input type="text" id="buySearchInput" list="stockList" 
                 value="${window.selectedStockSymbol || ""}" 
                 placeholder="Search stock symbol (e.g. FFC, HUBC, SYS, ENGRO)..." 
                 style="width:100%; background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.08); border-radius:10px; padding:12px 14px; color:#fff; font-family:inherit; font-size:14px;"
                 onkeydown="handleSearchKey(event)">
        </div>
        <button class="btn-primary" onclick="executeStockSearch()" style="padding:12px 20px; font-size:14px; background:var(--blue); border-radius:10px;">Search</button>
        ${window.selectedStockSymbol ? `<button class="btn-primary" onclick="clearStockSearch()" style="padding:12px 20px; font-size:14px; background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.1); color:#fff; border-radius:10px;">Clear</button>` : ""}
      </div>

      <!-- Searched Stock Details Panel -->
      ${
        window.selectedStockSymbol
          ? renderSearchedStockDetails(window.selectedStockSymbol, newsData)
          : `
        <div style="text-align:center; padding:20px; color:var(--muted); font-size:13px; border:1px dashed rgba(255,255,255,0.05); border-radius:12px;">
          Search a specific stock to view key financial safety ratios, expert ratings, and daily *Business Recorder* sentiment news analysis.
        </div>
      `
      }
    </div>

    <!-- ⭐ Pinned Favorite Stocks (Pins at the top) -->
    <div class="section-title" style="font-size:16px; margin-top:24px; display:flex; align-items:center; gap:8px;">
      <span>⭐</span> Pinned Favorite Stocks
    </div>
    <div style="display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:14px; margin-bottom:28px;">
      ${
        FAVORITES.length === 0
          ? `
        <div style="grid-column: 1 / -1; text-align:center; padding:24px; background:rgba(255,255,255,0.02); border-radius:12px; border:1px dashed rgba(255,255,255,0.05); color:var(--muted); font-size:13px;">
          No favorite stocks pinned yet. Search for a stock above and click the "☆ Add Favorite" button to pin it here.
        </div>
      `
          : FAVORITES.map((sym) => {
              const detail = getStockDetailsLocal(sym);
              const r = RATIOS.find((x) => x.symbol === sym);
              const vi = detail.score;
              const viC = scoreColor(vi);
              const isOwn = PORTFOLIO.some((s) => s.symbol === sym);

              return `
            <div class="card" onclick="selectSearchStock('${sym}')" style="cursor:pointer; padding:16px; background:rgba(34,197,94,0.03); border:1px solid rgba(34,197,94,0.15); border-radius:14px; transition:all 0.2s;">
              <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:10px;">
                <div>
                  <div style="font-size:16px; font-weight:800; display:flex; align-items:center; gap:6px;">
                    ${sym} <span style="font-size:11px; font-weight:600; color:var(--muted);">${isOwn ? "💼 Owned" : ""}</span>
                  </div>
                  <div style="font-size:11px; color:var(--muted); margin-top:2px;">${detail.name}</div>
                </div>
                <div class="score-circle" style="width:34px; height:34px; font-size:11px; background:${viC.bg}; color:${viC.color};">${vi}</div>
              </div>
              <div style="display:flex; justify-content:space-between; font-size:12px; border-bottom:1px solid rgba(255,255,255,0.04); padding-bottom:6px; margin-bottom:6px;">
                <span style="color:var(--muted);">Current Price</span>
                <span style="font-weight:700;">₨${detail.price.toFixed(2)}</span>
              </div>
              <div style="display:flex; justify-content:space-between; font-size:12px; border-bottom:1px solid rgba(255,255,255,0.04); padding-bottom:6px; margin-bottom:6px;">
                <span style="color:var(--muted);">Dividend Yield</span>
                <span style="font-weight:700; color:var(--green);">${detail.yield ? detail.yield.toFixed(1) + "%" : "—"}</span>
              </div>
              <div style="display:flex; justify-content:space-between; font-size:12px;">
                <span style="color:var(--muted);">Screener Verdict</span>
                <span class="badge" style="background:${viC.bg}; color:${viC.color}; font-size:9px; padding:2px 8px;">${detail.verdict}</span>
              </div>
            </div>`;
            }).join("")
      }
    </div>

    <!-- 💼 Recommended SIP Allocations (The original recommended buy tool layout) -->
    <div class="section-title" style="font-size:16px; margin-top:24px;">💼 Recommended Allocations — Month ${curMonth} Focus</div>
    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:14px;margin-bottom:28px">
      ${PORTFOLIO.map((s) => {
        const r = RATIOS.find((x) => x.symbol === s.symbol);
        const inPlan = monthPlan.buys.find(
          (b) => b.symbol === s.symbol || b.s === s.symbol,
        );
        const action = inPlan ? "BUY" : "HOLD";
        const prio = priorityMap[s.symbol] || 3;
        const sharesFor5k = Math.floor(5000 / s.price);
        const sharesFor10k = Math.floor(10000 / s.price);
        return `
          <div class="buy-card priority-${prio}" onclick="selectSearchStock('${s.symbol}')" style="cursor:pointer;">
            <div class="buy-card-top">
              <div>
                <div class="buy-symbol">${s.symbol}</div>
                <div class="buy-name">${s.name}</div>
              </div>
              <div class="buy-action ${action === "BUY" ? "action-buy" : "action-hold"}">${action}</div>
            </div>
            <div class="buy-detail-row"><span class="buy-detail-lbl">Current Price</span><span class="buy-detail-val">₨${s.price}</span></div>
            <div class="buy-detail-row"><span class="buy-detail-lbl">Yield</span><span class="buy-detail-val green">${s.yld}%</span></div>
            <div class="buy-detail-row"><span class="buy-detail-lbl">Screener Score</span><span class="buy-detail-val">${r ? r.score + "/100" : "—"}</span></div>
            <div class="buy-detail-row"><span class="buy-detail-lbl">Shares per ₨5k</span><span class="buy-detail-val">${sharesFor5k} shares</span></div>
            <div class="buy-detail-row"><span class="buy-detail-lbl">Shares per ₨10k</span><span class="buy-detail-val">${sharesFor10k} shares</span></div>
            <div class="buy-detail-row"><span class="buy-detail-lbl">Your Avg Buy</span><span class="buy-detail-val ${s.pnlPct >= 0 ? "green" : "red"}">₨${s.avgBuy} (${s.pnlPct >= 0 ? "+" : ""}${s.pnlPct}%)</span></div>
          </div>`;
      }).join("")}
    </div>

    <div class="section-title" style="font-size:15px">✅ Pre-Buy Checklist (S-Tier Process)</div>
    <div class="card">
      <ul class="checklist">
        <li><span class="check">1</span><span><strong>Read BR today</strong> — brecorder.com. Check if any of your stocks have bad news (profit warning, debt increase, management change). If yes, delay or reduce that stock's buy.</span></li>
        <li><span class="check">2</span><span><strong>Check dividend yield</strong> — Is the stock's yield still above 8%? If price ran up and yield dropped below 7%, shift money to another Core stock instead.</span></li>
        <li><span class="check">3</span><span><strong>D/E below 2?</strong> — From the screener. All your current stocks pass this. Only relevant when adding new stocks.</span></li>
        <li><span class="check">4</span><span><strong>Is it a viral/hype stock?</strong> — If yes, it is D-Tier. Do not buy. Redirect that money to HUBC or EFERT.</span></li>
        <li><span class="check">5</span><span><strong>Reinvest dividends first</strong> — If you received a dividend this month (FFC/EFERT season), reinvest that amount before adding fresh ₨10,000 capital.</span></li>
        <li><span class="check">6</span><span><strong>Buy and forget</strong> — After buying, close the Investify app. Do not check prices daily. Check once a month on buy day only.</span></li>
      </ul>
    </div>`;
  el("tab-buytool").innerHTML = html;
};

// Helper for rendering selected stock details inside search box
function renderSearchedStockDetails(symbol, newsData) {
  const isFav = FAVORITES.includes(symbol);
  const detail = getStockDetailsLocal(symbol);
  const viC = scoreColor(detail.score);
  const isOwn = PORTFOLIO.some((s) => s.symbol === symbol);

  // Setup news loading/sentiment layout
  let newsHtml = "";
  if (newsData && newsData.loading) {
    newsHtml = `
      <div style="text-align:center; padding:30px; color:var(--muted);">
        <div style="display:inline-block; width:24px; height:24px; border:3px solid rgba(255,255,255,0.1); border-radius:50%; border-top-color:var(--green); animation:spin 1s linear infinite; margin-bottom:12px;"></div>
        <div style="font-size:12px;">Analyzing Business Recorder morning publications for sentiment indicators...</div>
      </div>
    `;
  } else if (newsData && newsData.success) {
    const sBadge =
      newsData.overallSentiment === "Positive"
        ? "badge-green"
        : newsData.overallSentiment === "Negative"
          ? "badge-red"
          : "badge-muted";
    const sLabel =
      newsData.overallSentiment === "Positive"
        ? "🟢 POSITIVE SENTIMENT"
        : newsData.overallSentiment === "Negative"
          ? "🔴 NEGATIVE HEADWINDS"
          : "⚪ NEUTRAL FLOW";

    newsHtml = `
      <div style="margin-top:20px; padding-top:16px; border-top:1px solid rgba(255,255,255,0.06);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div style="font-size:12px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:0.5px;">📰 Daily News Analysis (Brecorder)</div>
          <span class="badge ${sBadge}" style="font-size:10px; padding:3px 10px;">${sLabel}</span>
        </div>
        
        <div style="background:rgba(255,255,255,0.02); border-left:3px solid ${newsData.overallSentiment === "Positive" ? "var(--green)" : newsData.overallSentiment === "Negative" ? "var(--red)" : "var(--muted)"}; border-radius:4px; padding:12px; font-size:12px; line-height:1.6; color:#d4d4d8; margin-bottom:14px;">
          ${newsData.impactExplanation}
        </div>
        
        <div style="display:flex; flex-direction:column; gap:8px;">
          ${
            newsData.articles.length === 0
              ? `
            <div style="font-size:11px; color:var(--muted); text-align:center; padding:10px;">No recent sector news.</div>
          `
              : newsData.articles
                  .map((a) => {
                    const aBadge =
                      a.sentiment === "Positive"
                        ? "color:var(--green)"
                        : a.sentiment === "Negative"
                          ? "color:var(--red)"
                          : "color:var(--muted)";
                    const aIcon =
                      a.sentiment === "Positive"
                        ? "📈"
                        : a.sentiment === "Negative"
                          ? "📉"
                          : "◽";
                    return `
                <a href="${a.link}" target="_blank" style="text-decoration:none; display:block; padding:10px; background:rgba(255,255,255,0.02); border:1px solid rgba(255,255,255,0.04); border-radius:8px; transition:background 0.2s;">
                  <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:600; color:#f4f4f5; line-height:1.4;">
                    <span>${aIcon} ${a.title}</span>
                    <span style="font-size:10px; ${aBadge}; margin-left:10px; flex-shrink:0;">${a.sentiment}</span>
                  </div>
                  <div style="font-size:10px; color:var(--muted); margin-top:4px;">${a.pubDate} • ${a.summary || "Click to read full coverage on Business Recorder."}</div>
                </a>
              `;
                  })
                  .join("")
          }
        </div>
      </div>
    `;
  } else {
    newsHtml = `
      <div style="text-align:center; padding:20px; color:var(--muted);">
        <button class="btn-primary" onclick="selectSearchStock('${symbol}')" style="background:rgba(255,255,255,0.06); border:1px solid rgba(255,255,255,0.1); color:#fff; font-size:12px; padding:8px 16px; border-radius:8px;">
          📰 Fetch & Analyze Daily BR News
        </button>
      </div>
    `;
  }

  const goodStyle = (val, goodMin, goodMax) => {
    if (val == null) return "color:var(--muted)";
    return val >= goodMin && val <= goodMax
      ? "color:var(--green)"
      : "color:var(--red)";
  };

  return `
    <div style="padding:16px; background:rgba(255,255,255,0.02); border:1px solid rgba(255,255,255,0.05); border-radius:12px; margin-top:10px;">
      <!-- Title & Actions Row -->
      <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:16px; flex-wrap:wrap; gap:12px;">
        <div>
          <div style="font-size:20px; font-weight:800; display:flex; align-items:center; gap:8px;">
            ${symbol}
            <span class="badge" style="background:${viC.bg}; color:${viC.color}; font-size:10px; padding:3px 10px;">${detail.verdict}</span>
            <span style="font-size:12px; font-weight:600; color:var(--muted);">${isOwn ? "💼 Owned in Portfolio" : "🔬 Watchlist"}</span>
          </div>
          <div style="font-size:13px; color:var(--muted); margin-top:4px;">${detail.name} • <span class="badge badge-muted" style="font-size:9px; padding:2px 8px;">${detail.sector}</span></div>
        </div>
        <div style="display:flex; gap:8px;">
          <button class="btn-primary" onclick="toggleFavorite('${symbol}')" style="padding:8px 16px; font-size:12px; background:${isFav ? "rgba(245,158,11,0.15)" : "rgba(255,255,255,0.06)"}; border:1px solid ${isFav ? "var(--yellow)" : "rgba(255,255,255,0.1)"}; color:${isFav ? "var(--yellow)" : "#fff"}; border-radius:8px;">
            ${isFav ? "⭐ Pinned" : "☆ Add Favorite"}
          </button>
          <button class="btn-primary" onclick="prefillLogBuy('${symbol}')" style="padding:8px 16px; font-size:12px; background:var(--blue); border-radius:8px;">
            ➕ Log Buy
          </button>
          ${
            isOwn
              ? `
            <button class="btn-primary" onclick="prefillLogSell('${symbol}')" style="padding:8px 16px; font-size:12px; background:var(--red); border-radius:8px;">
              ➖ Log Sale
            </button>
          `
              : ""
          }
        </div>
      </div>

      <!-- Financial Metrics Grid -->
      <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:12px; margin-bottom:16px;">
        <div style="background:rgba(255,255,255,0.01); border:1px solid rgba(255,255,255,0.03); border-radius:8px; padding:10px; text-align:center;">
          <div style="font-size:11px; color:var(--muted); text-transform:uppercase; margin-bottom:4px;">Current Price</div>
          <div style="font-size:16px; font-weight:800;">₨${detail.price.toFixed(2)}</div>
        </div>
        <div style="background:rgba(255,255,255,0.01); border:1px solid rgba(255,255,255,0.03); border-radius:8px; padding:10px; text-align:center;">
          <div style="font-size:11px; color:var(--muted); text-transform:uppercase; margin-bottom:4px;">Dividend Yield</div>
          <div style="font-size:16px; font-weight:800; color:var(--green);">${detail.yield ? detail.yield.toFixed(1) + "%" : "—"}</div>
        </div>
        <div style="background:rgba(255,255,255,0.01); border:1px solid rgba(255,255,255,0.03); border-radius:8px; padding:10px; text-align:center;">
          <div style="font-size:11px; color:var(--muted); text-transform:uppercase; margin-bottom:4px;">Screener Index</div>
          <div style="font-size:16px; font-weight:800; color:${viC.color};">${detail.score}/100</div>
        </div>
        ${
          detail.avgBuy
            ? `
          <div style="background:rgba(255,255,255,0.01); border:1px solid rgba(255,255,255,0.03); border-radius:8px; padding:10px; text-align:center;">
            <div style="font-size:11px; color:var(--muted); text-transform:uppercase; margin-bottom:4px;">Your Avg / PNL</div>
            <div style="font-size:14px; font-weight:800; color:${detail.pnlPct >= 0 ? "var(--green)" : "var(--red)"};">
              ₨${detail.avgBuy.toFixed(1)} (${detail.pnlPct >= 0 ? "+" : ""}${detail.pnlPct}%)
            </div>
          </div>
        `
            : ""
        }
      </div>

      <!-- Financial Safety Ratios -->
      <div style="font-size:12px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px;">🛡️ Safety Screener Ratios</div>
      <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(130px, 1fr)); gap:10px;">
        <div style="background:rgba(0,0,0,0.2); border:1px solid rgba(255,255,255,0.02); border-radius:8px; padding:8px 12px; display:flex; justify-content:space-between; align-items:center;">
          <span style="color:var(--muted);">D/E Ratio</span>
          <strong style="${goodStyle(detail.de, 0, 1.2)}">${fmtN(detail.de)}</strong>
        </div>
        <div style="background:rgba(0,0,0,0.2); border:1px solid rgba(255,255,255,0.02); border-radius:8px; padding:8px 12px; display:flex; justify-content:space-between; align-items:center;">
          <span style="color:var(--muted);">ICR (Interest)</span>
          <strong style="${goodStyle(detail.icr, 3, 999)}">${fmtN(detail.icr)}</strong>
        </div>
        <div style="background:rgba(0,0,0,0.2); border:1px solid rgba(255,255,255,0.02); border-radius:8px; padding:8px 12px; display:flex; justify-content:space-between; align-items:center;">
          <span style="color:var(--muted);">FCF Yield</span>
          <strong style="${goodStyle(detail.fcfYield, 8, 999)}">${detail.fcfYield ? detail.fcfYield.toFixed(1) + "%" : "—"}</strong>
        </div>
        <div style="background:rgba(0,0,0,0.2); border:1px solid rgba(255,255,255,0.02); border-radius:8px; padding:8px 12px; display:flex; justify-content:space-between; align-items:center;">
          <span style="color:var(--muted);">OCF Ratio</span>
          <strong style="${goodStyle(detail.ocfRatio, 1, 999)}">${fmtN(detail.ocfRatio)}</strong>
        </div>
      </div>

      <!-- Business Recorder Daily News & Sentiment Analysis -->
      ${newsHtml}
    </div>
  `;
}

// ── PROJECTION TAB ────────────────────────────────────────────────────────────
function renderProjection(stats) {
  const currentMonthNum =
    (new Date().getFullYear() - 2026) * 12 + new Date().getMonth() + 1;
  const maxDiv = Math.max(...PROJECTION.map((p) => p.annualDiv));
  const milestones = {
    3: "🎯 50k/yr milestone!",
    5: "🚀 1 Lakh/yr milestone!",
    7: "🏆 2 Lakh/yr — GOAL!",
  };

  let html = `
    <div class="section-title">📊 7-Year Dividend Projection</div>
    <p class="section-sub">Based on your real Month ${currentMonthNum} data (${fmt(stats.totalInvested)} invested), ₨10,000/month SIP, ~15% annual compounding, and dividend reinvestment. Numbers are estimates.</p>
    ${PROJECTION.map((p) => {
      const barW = ((p.annualDiv / maxDiv) * 100).toFixed(1);
      const barColor =
        p.annualDiv >= 200000
          ? "linear-gradient(90deg,#22c55e,#86efac)"
          : p.annualDiv >= 100000
            ? "linear-gradient(90deg,#3b82f6,#93c5fd)"
            : "linear-gradient(90deg,#a855f7,#d8b4fe)";
      return `
        <div class="proj-year">
          <div class="proj-top">
            <div class="proj-label">${p.label}</div>
            <div class="proj-div ${p.annualDiv >= 200000 ? "green" : p.annualDiv >= 100000 ? "blue" : ""}">${fmt(p.annualDiv)}/yr</div>
          </div>
          <div class="proj-bar-wrap"><div class="proj-bar" style="width:${barW}%;background:${barColor}"></div></div>
          <div class="proj-meta">
            <div class="proj-m">Total Invested: <strong>${fmt(p.invested)}</strong></div>
            <div class="proj-m">Portfolio Value: <strong>${fmt(p.portfolioVal)}</strong></div>
            <div class="proj-m">Monthly Income: <strong>${fmt(p.monthly)}</strong></div>
          </div>
          ${milestones[p.year] ? `<div class="milestone-flag">🎯 ${milestones[p.year]}</div>` : ""}
        </div>`;
    }).join("")}

    <div class="card mt-6">
      <div class="card-title" style="margin-bottom:14px">💡 Why Reinvestment Changes Everything</div>
      <div class="grid-2">
        ${[
          [
            "Without Reinvesting",
            "Keep dividends as cash. Year 7 portfolio: ~₨9 Lakh. Annual dividend: ~₨1.2 Lakh. You miss the 2 Lakh target.",
          ],
          [
            "With Reinvesting (Your Plan)",
            "Reinvest all dividends into more HUBC/EFERT shares. Year 7 portfolio: ~₨15 Lakh. Annual dividend: ~₨2.1 Lakh. Goal achieved.",
          ],
        ]
          .map(
            ([t, b]) =>
              `<div class="ref-card"><div class="ref-title">${t}</div><div class="ref-body">${b}</div></div>`,
          )
          .join("")}
      </div>
    </div>`;
  el("tab-projection").innerHTML = html;
}

// ── SETTINGS / INSTALL GUIDE TAB ────────────────────────────────────────────────
function renderSettings() {
  let html = `
    <div class="section-title">⚙️ Settings & System</div>
    <p class="section-sub">Manage your live data, security, and backups.</p>
    
    <div class="card mb-6" style="background:rgba(59,130,246,0.05);border-color:rgba(59,130,246,0.2)">
      <div class="card-title">🔄 Live Data Sync</div>
      <p style="font-size:13px;color:var(--muted);margin-bottom:12px;line-height:1.6">
        This app fetches live PSX prices directly from the **Official PSX Data Portal** via a secure proxy. You can manually force a refresh below.
      </p>
      <button class="btn-primary" onclick="forceFetchPrices()" style="background:var(--blue);width:auto;display:inline-flex;align-items:center;gap:8px">
        <span>🔄</span> Fetch Live Prices Now
      </button>
    </div>

    <div class="card mb-6" style="background:rgba(34,197,94,0.05);border-color:rgba(34,197,94,0.2)">
      <div class="card-title">🔐 Security Vault</div>
      <p style="font-size:13px;color:var(--muted);margin-bottom:12px">
        Current Status: <strong>${APP_PIN ? "Protected (PIN Active)" : "Unlocked (No PIN)"}</strong>
      </p>
      <div style="display:flex;gap:10px;flex-wrap:wrap">
        <button class="btn-primary" onclick="setAppPin()" style="background:var(--green);width:auto">${APP_PIN ? "Change PIN" : "Set Security PIN"}</button>
        ${APP_PIN ? `<button class="btn-primary" onclick="removeAppPin()" style="background:var(--red);width:auto">Disable PIN</button>` : ""}
        ${APP_PIN && window.PublicKeyCredential ? `<button class="btn-primary" onclick="setupBiometrics()" style="background:var(--blue);width:auto;display:flex;align-items:center;gap:8px"><span>🧬</span> ${localStorage.getItem("PSX_BIOMETRIC_ID") ? "Reset Biometrics" : "Enable Biometrics"}</button>` : ""}
      </div>
    </div>

    <div class="card mb-6" style="background:rgba(168,85,247,0.05);border-color:rgba(168,85,247,0.2)">
      <div class="card-title">💾 Backup & Restore</div>
      <p style="font-size:13px;color:var(--muted);margin-bottom:12px">
        Export your entire portfolio, transactions, and dividend history to a file. You can import this file on any device to restore your data.
      </p>
      <div style="display:flex;gap:10px;flex-wrap:wrap">
        <button class="btn-primary" onclick="exportData()" style="background:var(--purple);width:auto">📤 Export Backup (JSON)</button>
        <label class="btn-primary" style="background:var(--muted);width:auto;cursor:pointer">
          📥 Import Backup
          <input type="file" onchange="importData(event)" style="display:none" accept=".json">
        </label>
      </div>
    </div>

    <div class="card mb-6" style="background:rgba(239,68,68,0.05);border-color:rgba(239,68,68,0.2)">
      <div class="card-title">⚠️ Danger Zone</div>
      <p style="font-size:13px;color:var(--muted);margin-bottom:12px">
        Reset everything to factory defaults. All your custom buys, history, and dividends will be **DELETED FOREVER**.
      </p>
      <button class="btn-primary" onclick="resetPortfolio()" style="background:var(--red);width:auto">Reset All Data</button>
    </div>
  `;
  el("tab-settings").innerHTML = html;
}

function resetPortfolio() {
  if (
    confirm(
      "Are you sure you want to reset all your data? This cannot be undone.",
    )
  ) {
    PORTFOLIO = JSON.parse(JSON.stringify(window.DEFAULT_PORTFOLIO));
    savePortfolio();
    showToast("Portfolio reset to default.", "⚠️");
  }
}

// ── LIVE DATA SYNC (Offline Mode) ────────────────────────────────────────────────
async function fetchLivePrices() {
  showToast("App running in offline mode. Using cached prices.", "📱");
  // In offline mode, we use the cached prices stored in localStorage
  // To update prices, manually edit portfolio or export/import data
}

window.forceFetchPrices = function () {
  fetchLivePrices();
};

// ── TRANSACTION LOGIC ─────────────────────────────────────────────────────────
window.openModal = function (id) {
  el(id).classList.add("open");
};
window.closeModal = function (id) {
  el(id).classList.remove("open");
};

window.submitAddBuy = function () {
  const symbol = el("buySymbol").value;
  const shares = parseInt(el("buyShares").value);
  const price = parseFloat(el("buyPrice").value);

  if (!shares || !price || shares <= 0 || price <= 0) {
    showToast("Please enter valid positive numbers.", "❌");
    return;
  }

  let stock = PORTFOLIO.find((s) => s.symbol === symbol);
  if (!stock) {
    // Create new stock entry if it doesn't exist
    stock = {
      symbol: symbol,
      name: symbol, // Default name to symbol
      tier: "unassigned",
      shares: 0,
      avgBuy: 0,
      price: price,
      dpshist: 0,
      sector: "Other",
    };
    PORTFOLIO.push(stock);
  }

  // Calculate new average: (OldCost + NewCost) / (OldShares + NewShares)
  const oldCost = stock.shares * stock.avgBuy;
  const newCost = shares * price;
  const newTotalShares = stock.shares + shares;
  const newAvgBuy = (oldCost + newCost) / newTotalShares;

  stock.shares = newTotalShares;
  stock.avgBuy = newAvgBuy;
  stock.price = price; // Update current price as well

  // Add to Transactions
  TRANSACTIONS.push({
    date: new Date().toLocaleDateString("en-PK"),
    symbol,
    shares,
    price,
  });

  savePortfolio(); // Re-renders the UI
  closeModal("modalAddBuy");
  el("buyShares").value = "";
  el("buyPrice").value = "";
  showToast(`Added ${shares} shares of ${symbol}`, "🎉");
};

window.submitSell = function () {
  const symbol = el("sellSymbol").value;
  const shares = parseInt(el("sellShares").value);
  const price = parseFloat(el("sellPrice").value);

  if (!shares || !price || shares <= 0 || price <= 0) {
    showToast("Please enter valid positive numbers.", "❌");
    return;
  }

  let stock = PORTFOLIO.find((s) => s.symbol === symbol);
  if (!stock || stock.shares < shares) {
    showToast("Not enough shares to sell.", "❌");
    return;
  }

  stock.shares -= shares;
  stock.price = price; // Update current price

  // Add to Transactions
  TRANSACTIONS.push({
    date: new Date().toLocaleDateString("en-PK"),
    symbol,
    shares: -shares, // Negative for sell
    price,
  });

  if (stock.shares === 0) {
    // Optionally remove or keep with 0 shares. Let's keep for now so history remains easy.
  }

  savePortfolio();
  closeModal("modalSell");
  el("sellShares").value = "";
  el("sellPrice").value = "";
  showToast(`Sold ${shares} shares of ${symbol}`, "📉");
};

// ── TOAST NOTIFICATIONS ───────────────────────────────────────────────────────
function showToast(msg, icon = "ℹ️") {
  const container = el("toastContainer");
  if (!container) return;
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.innerHTML = `<span class="toast-icon">${icon}</span> <span>${msg}</span>`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.classList.add("hide");
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

// ── INIT ──────────────────────────────────────────────────────────────────────
function init() {
  if (IS_LOCKED) {
    el("pinOverlay").style.display = "flex";
    if (localStorage.getItem("PSX_BIOMETRIC_ID")) {
      el("biometricLoginBtn").style.display = "flex";
      if (!window.biometricRunning) authenticateBiometrics();
    }
    return;
  }

  const stats = computePortfolio();
  renderOverview(stats);
  renderPortfolio();
  renderRoadmap();
  renderHistory();

  const elSip = el("tab-sip");
  if (elSip && typeof renderSIP === "function") renderSIP();

  renderScreener();
  renderTierList();
  renderBuyTool();
  renderProjection(stats);
  renderSettings();

  // Restore tab silently (no scroll)
  const lastTab = localStorage.getItem("ACTIVE_TAB");
  if (lastTab && TAB_IDS.includes(lastTab)) {
    switchTab(lastTab, false);
  }
}

// ── PIN SECURITY ──────────────────────────────────────────────────────────────
function handlePinInput(key) {
  if (key === "✕") {
    CURRENT_PIN_INPUT = "";
  } else if (key === "C") {
    CURRENT_PIN_INPUT = CURRENT_PIN_INPUT.slice(0, -1);
  } else if (CURRENT_PIN_INPUT.length < 4) {
    CURRENT_PIN_INPUT += key;
  }

  el("pinDisplay").textContent = "•".repeat(CURRENT_PIN_INPUT.length);

  if (CURRENT_PIN_INPUT.length === 4) {
    if (CURRENT_PIN_INPUT === APP_PIN) {
      unlockVault();
    } else {
      showToast("Incorrect PIN", "❌");
      CURRENT_PIN_INPUT = "";
      el("pinDisplay").textContent = "";
    }
  }
}

function unlockVault() {
  IS_LOCKED = false;
  sessionStorage.setItem("PSX_UNLOCKED", "true");
  el("pinOverlay").style.display = "none";
  showToast("Vault Unlocked", "🔓");
  init();
}

function setAppPin() {
  const p1 = prompt("Enter new 4-digit PIN:");
  if (!p1) return;
  if (p1.length !== 4 || isNaN(p1)) return alert("PIN must be 4 digits");
  const p2 = prompt("Confirm PIN:");
  if (p1 === p2) {
    APP_PIN = p1;
    localStorage.setItem("PSX_PIN", APP_PIN);
    showToast("PIN Updated Successfully", "🔐");
    init();
  } else {
    alert("PINs do not match");
  }
}

function removeAppPin() {
  if (
    confirm("Disable security lock? Your portfolio will be visible to anyone.")
  ) {
    APP_PIN = "";
    localStorage.removeItem("PSX_PIN");
    localStorage.removeItem("PSX_BIOMETRIC_ID");
    IS_LOCKED = false;
    sessionStorage.removeItem("PSX_UNLOCKED");
    showToast("Security Lock Disabled", "🔓");
    init();
  }
}

// ── DIVIDEND LOGGING ──────────────────────────────────────────────────────────
function submitLogDividend() {
  const symbol = el("divSymbol").value;
  const amount = parseFloat(el("divAmount").value);
  const note = el("divNote").value;
  if (!symbol || !amount) return showToast("Enter symbol and amount", "⚠️");

  DIVIDENDS.push({
    date: new Date().toLocaleDateString("en-PK"),
    symbol,
    amount,
    note,
  });
  savePortfolio();
  closeModal("modalLogDividend");
  el("divAmount").value = "";
  el("divNote").value = "";
  showToast(`Logged ₨${amount} from ${symbol}`, "💰");
}

// ── DATA BACKUP ───────────────────────────────────────────────────────────────
function exportData() {
  const data = {
    portfolio: PORTFOLIO,
    transactions: TRANSACTIONS,
    dividends: DIVIDENDS,
    pin: APP_PIN,
    checklist: JSON.parse(localStorage.getItem("CHECKLIST_STATE") || "{}"),
  };
  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: "application/json",
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `psx_backup_${new Date().toISOString().slice(0, 10)}.json`;
  a.click();
  showToast("Backup file created", "💾");
}

function importData(event) {
  const file = event.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = function (e) {
    try {
      const data = JSON.parse(e.target.result);
      if (confirm("This will overwrite all your current data. Continue?")) {
        PORTFOLIO = data.portfolio || [];
        TRANSACTIONS = data.transactions || [];
        DIVIDENDS = data.dividends || [];
        APP_PIN = data.pin || "";
        localStorage.setItem("PSX_PIN", APP_PIN);
        localStorage.setItem(
          "CHECKLIST_STATE",
          JSON.stringify(data.checklist || {}),
        );
        savePortfolio();
        location.reload();
      }
    } catch (err) {
      alert("Invalid backup file");
    }
  };
  reader.readAsText(file);
}

function toggleCheck(idx, month) {
  const state = JSON.parse(localStorage.getItem("CHECKLIST_STATE") || "{}");
  const key = "m" + month;
  if (!state[key]) state[key] = [false, false, false, false, false, false];
  state[key][idx] = !state[key][idx];
  localStorage.setItem("CHECKLIST_STATE", JSON.stringify(state));

  // If the last check (Mark month done) is checked, show a celebratory message
  if (idx === 5 && state[key][idx]) {
    showToast(`Month ${month} officially completed! Milestone reached.`, "🏆");
  }
}

function removeStock(symbol) {
  if (
    confirm(`Are you sure you want to remove ${symbol} from your portfolio?`)
  ) {
    PORTFOLIO = PORTFOLIO.filter((s) => s.symbol !== symbol);
    savePortfolio();
    showToast(`${symbol} removed from portfolio.`, "🗑️");
  }
}

document.addEventListener("DOMContentLoaded", () => {
  init();
  fetchLivePrices();
});

// ── BIOMETRIC AUTHENTICATION ──────────────────────────────────────────────────
const bufferToBase64 = (buf) => {
  const bytes = new Uint8Array(buf);
  let binary = "";
  for (let i = 0; i < bytes.byteLength; i++)
    binary += String.fromCharCode(bytes[i]);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
};
const base64ToBuffer = (base64) => {
  const binary = atob(base64.replace(/-/g, "+").replace(/_/g, "/"));
  return Uint8Array.from(binary, (c) => c.charCodeAt(0));
};

async function setupBiometrics() {
  if (!window.PublicKeyCredential)
    return showToast("Biometrics not supported.", "❌");
  try {
    // Clear any old/broken data first
    localStorage.removeItem("PSX_BIOMETRIC");

    const challenge = new Uint8Array(32);
    window.crypto.getRandomValues(challenge);
    const createOptions = {
      publicKey: {
        challenge,
        rp: { name: "PSX Dividend Machine" },
        user: {
          id: Uint8Array.from("PSX_USER", (c) => c.charCodeAt(0)),
          name: "investor@psx",
          displayName: "PSX Investor",
        },
        pubKeyCredParams: [
          { alg: -7, type: "public-key" },
          { alg: -257, type: "public-key" },
        ],
        authenticatorSelection: {
          authenticatorAttachment: "platform",
          userVerification: "required",
        },
        timeout: 60000,
        attestation: "none",
      },
    };
    const credential = await navigator.credentials.create(createOptions);
    if (credential) {
      const credId = bufferToBase64(credential.rawId);
      localStorage.setItem("PSX_BIOMETRIC_ID", credId);
      showToast("Biometrics linked successfully!", "✅");
      renderSettings();
    }
  } catch (err) {
    console.error("Setup error:", err);
    showToast("Setup failed. Please try again.", "❌");
  }
}

async function authenticateBiometrics() {
  const credId = localStorage.getItem("PSX_BIOMETRIC_ID");
  if (!credId || window.biometricRunning) return;

  window.biometricRunning = true;
  try {
    const challenge = new Uint8Array(32);
    window.crypto.getRandomValues(challenge);
    const options = {
      publicKey: {
        challenge,
        timeout: 60000,
        userVerification: "required",
        allowCredentials: [
          {
            id: base64ToBuffer(credId),
            type: "public-key",
          },
        ],
      },
    };
    const assertion = await navigator.credentials.get(options);
    if (assertion) {
      unlockVault();
      showToast("Identity verified.", "🧬");
    }
  } catch (err) {
    console.warn("Auth error:", err);
    if (err.name === "NotAllowedError") {
      // User cancelled or no match
    } else {
      showToast("Biometric verification failed.", "⚠️");
    }
  } finally {
    window.biometricRunning = false;
  }
}

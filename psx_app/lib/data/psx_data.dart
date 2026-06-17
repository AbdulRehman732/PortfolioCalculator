import '../models/stock.dart';

class PsxData {
  static final List<Stock> defaultPortfolio = [
    Stock(symbol: "FFC", name: "Fauji Fertilizer Co", tier: "core", price: 504.27, dpshist: 55, sector: "Fertilizer", sharesOverride: 27, avgBuyOverride: 520.99),
    Stock(symbol: "BIPL", name: "BankIslami Pakistan", tier: "small", price: 24.98, dpshist: 1.5, sector: "Banking", sharesOverride: 100, avgBuyOverride: 26.74),
    Stock(symbol: "HUBC", name: "Hub Power Company", tier: "core", price: 220.49, dpshist: 20, sector: "Energy", sharesOverride: 31, avgBuyOverride: 219.51),
    Stock(symbol: "NATF", name: "National Foods Limited", tier: "small", price: 370.08, dpshist: 18, sector: "Food", sharesOverride: 15, avgBuyOverride: 379.38),
    Stock(symbol: "OGDC", name: "Oil & Gas Dev Co", tier: "secondary", price: 303.17, dpshist: 22, sector: "Energy", sharesOverride: 19, avgBuyOverride: 309.77),
    Stock(symbol: "EFERT", name: "Engro Fertilizers", tier: "core", price: 198.83, dpshist: 20, sector: "Fertilizer", sharesOverride: 63, avgBuyOverride: 204.57),
    Stock(symbol: "FATIMA", name: "Fatima Fertilizer Co", tier: "small", price: 130.29, dpshist: 12, sector: "Fertilizer", sharesOverride: 21, avgBuyOverride: 141.86),
    Stock(symbol: "MEBL", name: "Meezan Bank", tier: "small", price: 492.34, dpshist: 15, sector: "Banking", sharesOverride: 10, avgBuyOverride: 477.60),
    Stock(symbol: "PPL", name: "Pakistan Petroleum Ltd", tier: "secondary", price: 206.64, dpshist: 17, sector: "Energy", sharesOverride: 7, avgBuyOverride: 204.99),
  ];

  static final List<ValueRatio> ratios = [
    ValueRatio(symbol: "FFC", de: 0.8, icr: 12.1, netDebtEbitda: 0.5, pfcf: 9.2, fcfYield: 10.8, ocfRatio: 1.4, assetTurnover: 1.1, invTurnover: 8.2, score: 82, verdict: "Strong"),
    ValueRatio(symbol: "EFERT", de: 0.6, icr: 15.3, netDebtEbitda: 0.3, pfcf: 8.1, fcfYield: 12.3, ocfRatio: 1.6, assetTurnover: 1.3, invTurnover: 9.1, score: 88, verdict: "Excellent"),
    ValueRatio(symbol: "HUBC", de: 1.2, icr: 6.8, netDebtEbitda: 1.8, pfcf: 11.4, fcfYield: 8.8, ocfRatio: 1.2, assetTurnover: 0.7, score: 75, verdict: "Good"),
    ValueRatio(symbol: "OGDC", de: 0.1, icr: 28.5, netDebtEbitda: -0.2, pfcf: 7.3, fcfYield: 13.7, ocfRatio: 2.1, assetTurnover: 0.5, score: 91, verdict: "Excellent"),
    ValueRatio(symbol: "PPL", de: 0.2, icr: 22.1, netDebtEbitda: 0.1, pfcf: 8.8, fcfYield: 11.4, ocfRatio: 1.8, assetTurnover: 0.6, score: 87, verdict: "Strong"),
    ValueRatio(symbol: "FATIMA", de: 0.9, icr: 8.2, netDebtEbitda: 1.1, pfcf: 10.2, fcfYield: 11.8, ocfRatio: 1.3, assetTurnover: 1.0, invTurnover: 7.4, score: 74, verdict: "Good"),
    ValueRatio(symbol: "MEBL", pfcf: 13.1, fcfYield: 7.7, ocfRatio: 1.1, assetTurnover: 0.1, score: 72, verdict: "Good"),
    ValueRatio(symbol: "BIPL", pfcf: 7.8, fcfYield: 9.2, ocfRatio: 0.9, assetTurnover: 0.08, score: 61, verdict: "Caution"),
    ValueRatio(symbol: "NATF", de: 0.7, icr: 6.4, netDebtEbitda: 1.9, pfcf: 16.3, fcfYield: 6.1, ocfRatio: 0.8, assetTurnover: 1.6, invTurnover: 6.8, score: 58, verdict: "Caution"),
    ValueRatio(symbol: "ENGRO", de: 0.8, icr: 8.5, netDebtEbitda: 0.8, pfcf: 10.5, fcfYield: 11.2, ocfRatio: 1.3, assetTurnover: 0.9, invTurnover: 6.5, score: 80, verdict: "Strong"),
    ValueRatio(symbol: "LUCK", de: 0.4, icr: 12.5, netDebtEbitda: 0.2, pfcf: 14.2, fcfYield: 8.5, ocfRatio: 1.5, assetTurnover: 1.1, invTurnover: 7.2, score: 71, verdict: "Good"),
    ValueRatio(symbol: "SYS", de: 0.1, icr: 25.4, netDebtEbitda: 0.05, pfcf: 22.4, fcfYield: 6.8, ocfRatio: 1.2, assetTurnover: 1.4, score: 68, verdict: "Good"),
    ValueRatio(symbol: "PSO", de: 1.1, icr: 4.2, netDebtEbitda: 1.4, pfcf: 8.5, fcfYield: 9.4, ocfRatio: 1.1, assetTurnover: 2.1, invTurnover: 12.4, score: 73, verdict: "Good"),
    ValueRatio(symbol: "MCB", pfcf: 8.2, fcfYield: 9.1, ocfRatio: 1.1, score: 79, verdict: "Strong"),
    ValueRatio(symbol: "HBL", pfcf: 9.1, fcfYield: 8.4, ocfRatio: 1.0, score: 70, verdict: "Good"),
    ValueRatio(symbol: "FFBL", de: 1.3, icr: 4.8, netDebtEbitda: 1.9, pfcf: 7.9, fcfYield: 10.1, ocfRatio: 1.1, assetTurnover: 1.2, invTurnover: 8.5, score: 72, verdict: "Good"),
    ValueRatio(symbol: "SEARL", de: 0.8, icr: 3.2, netDebtEbitda: 2.2, pfcf: 18.4, fcfYield: 5.2, ocfRatio: 0.9, assetTurnover: 0.8, invTurnover: 4.2, score: 54, verdict: "Caution"),
    ValueRatio(symbol: "MARI", de: 0.15, icr: 32.4, netDebtEbitda: -0.1, pfcf: 9.8, fcfYield: 12.1, ocfRatio: 2.3, assetTurnover: 0.8, score: 89, verdict: "Excellent"),
    ValueRatio(symbol: "TRG", de: 1.8, icr: 1.2, netDebtEbitda: 4.2, pfcf: 45.0, fcfYield: 2.1, ocfRatio: 0.4, assetTurnover: 0.4, score: 35, verdict: "Avoid"),
  ];

  static final List<Map<String, dynamic>> roadmapParts = [
    {
      "part": 1, "label": "PART 1 — Correction + Foundation",
      "months": "Month 6 → 12", "icon": "🔥",
      "theme": "Build the base. Average down FFC & EFERT. Lock in HUBC.",
      "monthRange": [6, 12], "budget": 10000,
      "allocs": [
        { "s": "HUBC", "amt": 3000, "note": "Top priority always" },
        { "s": "FFC", "amt": 2000, "note": "Average down — still S-tier" },
        { "s": "EFERT", "amt": 2000, "note": "Average down — highest yield" },
        { "s": "OGDC", "amt": 1500, "note": "Energy foundation" },
        { "s": "PPL", "amt": 1500, "note": "Energy support" },
      ],
      "special": "Every 2nd month: replace OGDC or PPL slot with FATIMA or MEBL (Rs1,500)",
      "divTarget": "~Rs10,000–12,000/year by Month 12",
      "rule": "Never skip. Price correction = gift. Buy more."
    },
    {
      "part": 2, "label": "PART 2 — Aggressive Growth",
      "months": "Month 13 → 24", "icon": "🚀",
      "theme": "Scale up Core. Dividend income starts showing.",
      "monthRange": [13, 24], "budget": 10000,
      "allocs": [
        { "s": "HUBC", "amt": 3500, "note": "Increase position aggressively" },
        { "s": "FFC", "amt": 2500, "note": "FFC now at lower avg buy" },
        { "s": "EFERT", "amt": 2000, "note": "Strong dividend contributor" },
        { "s": "OGDC", "amt": 1000, "note": "Steady energy hold" },
        { "s": "PPL", "amt": 1000, "note": "Steady energy hold" },
      ],
      "special": "Every 3rd month: add Rs0 to above, buy FATIMA or MEBL or NATF separately from any extra cash",
      "divTarget": "~Rs25,000–35,000/year by Month 24",
      "rule": "If stock is expensive (yield <7%), redirect to HUBC or FFC."
    },
    {
      "part": 3, "label": "PART 3 — Dividend Build Phase",
      "months": "Month 25 → 36", "icon": "⚡",
      "theme": "Dividends now significant. Reinvest every single payout.",
      "monthRange": [25, 36], "budget": 10000,
      "allocs": [
        { "s": "HUBC", "amt": 3000, "note": "Core — never stop adding" },
        { "s": "FFC", "amt": 2500, "note": "Fertilizer king dividend" },
        { "s": "EFERT", "amt": 2000, "note": "High yield compounder" },
        { "s": "OGDC", "amt": 1500, "note": "Government-backed safety" },
        { "s": "PPL", "amt": 1000, "note": "Steady income" },
      ],
      "special": "Reinvest ALL dividends → back into HUBC or FFC only",
      "divTarget": "~Rs50,000/year by Month 36",
      "rule": "Every dividend received must be reinvested within 5 days."
    },
    {
      "part": 4, "label": "PART 4 — Acceleration Phase",
      "months": "Month 37 → 48", "icon": "📈",
      "theme": "Compounding visibly accelerates. Stay the course.",
      "monthRange": [37, 48], "budget": 10000,
      "allocs": [
        { "s": "HUBC", "amt": 3000, "note": "Dominant core position" },
        { "s": "FFC", "amt": 2500, "note": "Largest dividend contributor" },
        { "s": "EFERT", "amt": 2000, "note": "Consistent payer" },
        { "s": "OGDC", "amt": 1500, "note": "Energy backbone" },
        { "s": "PPL", "amt": 1000, "note": "Steady secondary" },
      ],
      "special": "Every 4th month: add FATIMA or MEBL from dividend reinvestment",
      "divTarget": "~Rs1,00,000/year by Month 48",
      "rule": "No new stocks. No deviations. Stick to the list."
    },
    {
      "part": 5, "label": "PART 5 — Power Phase",
      "months": "Month 49 → 60", "icon": "💰",
      "theme": "Dividend income is now serious money. Full reinvestment.",
      "monthRange": [49, 60], "budget": 10000,
      "allocs": [
        { "s": "HUBC", "amt": 2800, "note": "Still #1 income driver" },
        { "s": "FFC", "amt": 2500, "note": "Top fertilizer dividend" },
        { "s": "EFERT", "amt": 2200, "note": "High yield maintained" },
        { "s": "OGDC", "amt": 1500, "note": "Government-backed income" },
        { "s": "PPL", "amt": 1000, "note": "Reliable secondary" },
      ],
      "special": "ALL dividends fully reinvested — prefer HUBC + FFC",
      "divTarget": "~Rs1,20,000–1,40,000/year by Month 60",
      "rule": "Treat dividends as more shares, not as spending money."
    },
    {
      "part": 6, "label": "PART 6 — Income Build Phase",
      "months": "Month 61 → 72", "icon": "🔥",
      "theme": "Income stream clearly visible. Small diversification added.",
      "monthRange": [61, 72], "budget": 10000,
      "allocs": [
        { "s": "HUBC", "amt": 2500, "note": "Core income engine" },
        { "s": "FFC", "amt": 2500, "note": "Largest fertilizer payer" },
        { "s": "EFERT", "amt": 2000, "note": "Consistent yielder" },
        { "s": "OGDC", "amt": 1500, "note": "Energy pillar" },
        { "s": "PPL", "amt": 1000, "note": "Secondary energy" },
        { "s": "MEBL", "amt": 500, "note": "OR FATIMA — alternate each month" },
      ],
      "special": "Alternate MEBL and FATIMA each month for the Rs500 slot",
      "divTarget": "~Rs1,60,000–1,80,000/year by Month 72",
      "rule": "Price check every month. Expensive = shift to HUBC/FFC."
    },
    {
      "part": 7, "label": "PART 7 — Goal Phase",
      "months": "Month 73 → 84", "icon": "🎯",
      "theme": "You are near the Rs2 Lakh/year target. Final push.",
      "monthRange": [73, 84], "budget": 10000,
      "allocs": [
        { "s": "HUBC", "amt": 2500, "note": "Core — final accumulation" },
        { "s": "FFC", "amt": 2500, "note": "Fertilizer dividend machine" },
        { "s": "EFERT", "amt": 2000, "note": "Final high-yield build" },
        { "s": "OGDC", "amt": 1500, "note": "Government income" },
        { "s": "PPL", "amt": 1000, "note": "Energy support" },
        { "s": "ANY", "amt": 500, "note": "Any small stock from your list" },
      ],
      "special": "Rs500 can go to any of: FATIMA, MEBL, NATF, BIPL",
      "divTarget": "~Rs2,00,000+/year by Month 84 ✅",
      "rule": "You made it. Keep reinvesting. Never stop the SIP."
    },
  ];

  static final List<Map<String, dynamic>> projection = [
    { "year": 1, "label": "Year 1", "invested": 57200 + 7 * 10000, "portfolioVal": 142000, "annualDiv": 12000, "monthly": 1000, "milestone": "" },
    { "year": 2, "label": "Year 2", "invested": 177200, "portfolioVal": 230000, "annualDiv": 30000, "monthly": 2500, "milestone": "" },
    { "year": 3, "label": "Year 3", "invested": 297200, "portfolioVal": 370000, "annualDiv": 50000, "monthly": 4167, "milestone": "🎯 50k/yr milestone!" },
    { "year": 4, "label": "Year 4", "invested": 417200, "portfolioVal": 560000, "annualDiv": 100000, "monthly": 8333, "milestone": "🚀 1 Lakh/yr milestone!" },
    { "year": 5, "label": "Year 5", "invested": 537200, "portfolioVal": 810000, "annualDiv": 130000, "monthly": 10833, "milestone": "" },
    { "year": 6, "label": "Year 6", "invested": 657200, "portfolioVal": 1120000, "annualDiv": 165000, "monthly": 13750, "milestone": "" },
    { "year": 7, "label": "Year 7", "invested": 777200, "portfolioVal": 1520000, "annualDiv": 210000, "monthly": 17500, "milestone": "🏆 2 Lakh/yr — GOAL!" },
  ];

  static final List<Map<String, dynamic>> tiers = [
    {
      "tier": "S", "label": "Best — Use These", "color": 0xFF22C55E,
      "items": [
        { "name": "SIP (Systematic Investment Plan)", "youUse": true, "why": "Removes emotion from investing. Auto-buy more shares when prices fall." },
        { "name": "Value Investing", "youUse": true, "why": "Buying a great company at a fair price beats every other strategy long-term." },
        { "name": "Business Recorder", "youUse": true, "why": "Daily profit/loss announcements, financial ratios, macro news." },
      ]
    },
    {
      "tier": "A", "label": "Excellent — Complement Your Strategy", "color": 0xFF3B82F6,
      "items": [
        { "name": "Portfolio Rebalancing", "youUse": false, "why": "Shift weight from overvalued positions into undervalued ones." },
      ]
    },
    {
      "tier": "B", "label": "Good — Situational Use", "color": 0xFFA855F7,
      "items": [
        { "name": "Lump Sum Investing", "youUse": false, "why": "Works well during market crashes (PSX -20% days)." },
        { "name": "ETFs", "youUse": false, "why": "Gives instant diversification, but ETF dividends are lower." },
      ]
    },
    {
      "tier": "C", "label": "Average — Use With Caution", "color": 0xFFF59E0B,
      "items": [
        { "name": "Mutual Funds", "youUse": false, "why": "Fund managers charge 2-3% management fee. Most underperform." },
        { "name": "Sector/Industry Focus", "youUse": false, "why": "Concentrating on one sector increases risk." },
      ]
    },
    {
      "tier": "D", "label": "Avoid — Destroys Wealth", "color": 0xFFEF4444,
      "items": [
        { "name": "Viral/Hype Stocks", "youUse": false, "why": "Pumped on WhatsApp/social media. Guaranteed losses." },
        { "name": "TPS (Trading/Pure Speculation)", "youUse": false, "why": "95% of day traders lose money within 1 year." },
      ]
    },
  ];

  static final List<Map<String, dynamic>> universalRules = [
    { "icon": "📊", "title": "Rule 1 — Price Check Every Month", "body": "Before buying, check if the stock's dividend yield is still above 7%. If price ran up and yield dropped below 7%, shift that money to HUBC, FFC, or EFERT instead." },
    { "icon": "🚫", "title": "Rule 2 — No New Stocks", "body": "Stick exactly to your 9 stocks. No matter what you read on social media, WhatsApp, or financial news — do not add new stocks. Every rupee goes into your existing list only." },
    { "icon": "🔄", "title": "Rule 3 — Reinvest Every Dividend", "body": "When dividends arrive (FFC/EFERT in Feb–Mar, HUBC/OGDC in Apr–Jun, MEBL in Aug), reinvest within 5 days. This single rule doubles your income over 7 years." },
    { "icon": "📅", "title": "Rule 4 — Never Skip a Month", "body": "SIP works through compounding. One skipped month = 3 months of delayed progress. If you can't invest Rs10,000, invest Rs5,000. But never skip completely." },
    { "icon": "📰", "title": "Rule 5 — Read B.R. Daily", "body": "Open brecorder.com every morning. Takes 10 minutes. Check: company results, SBP rate decisions, rupee movement. This is your only free edge over other investors." },
  ];
}

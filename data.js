// ── DEFAULT PORTFOLIO DATA (Initial Seed) ──────────────
window.DEFAULT_PORTFOLIO = [
  { symbol:"FFC",  name:"Fauji Fertilizer Co",      tier:"core",      shares:27,  avgBuy:520.99, price:504.27, dpshist:55,  sector:"Fertilizer" },
  { symbol:"BIPL", name:"BankIslami Pakistan",       tier:"small",     shares:100, avgBuy:26.74,  price:24.98,  dpshist:1.5, sector:"Banking"    },
  { symbol:"HUBC", name:"Hub Power Company",         tier:"core",      shares:31,  avgBuy:219.51, price:220.49, dpshist:20,  sector:"Energy"     },
  { symbol:"NATF", name:"National Foods Limited",    tier:"small",     shares:15,  avgBuy:379.38, price:370.08, dpshist:18,  sector:"Food"       },
  { symbol:"OGDC", name:"Oil & Gas Dev Co",          tier:"secondary", shares:19,  avgBuy:309.77, price:303.17, dpshist:22,  sector:"Energy"     },
  { symbol:"EFERT",name:"Engro Fertilizers",         tier:"core",      shares:63,  avgBuy:204.57, price:198.83, dpshist:20,  sector:"Fertilizer" },
  { symbol:"FATIMA",name:"Fatima Fertilizer Co",     tier:"small",     shares:21,  avgBuy:141.86, price:130.29, dpshist:12,  sector:"Fertilizer" },
  { symbol:"MEBL", name:"Meezan Bank",               tier:"small",     shares:10,  avgBuy:477.60, price:492.34, dpshist:15,  sector:"Banking"    },
  { symbol:"PPL",  name:"Pakistan Petroleum Ltd",    tier:"secondary", shares:7,   avgBuy:204.99, price:206.64, dpshist:17,  sector:"Energy"     },
];

// ── VALUE INVESTING RATIOS (Video 2 — Business Recorder metrics) ────────────
// Sources: latest annual reports / PSX filings — approximate industry values
const RATIOS = [
  {
    symbol:"FFC", de:0.8, icr:12.1, netDebtEbitda:0.5,
    pfcf:9.2, fcfYield:10.8, ocfRatio:1.4, assetTurnover:1.1, invTurnover:8.2,
    score:82, verdict:"Strong"
  },
  {
    symbol:"EFERT", de:0.6, icr:15.3, netDebtEbitda:0.3,
    pfcf:8.1, fcfYield:12.3, ocfRatio:1.6, assetTurnover:1.3, invTurnover:9.1,
    score:88, verdict:"Excellent"
  },
  {
    symbol:"HUBC", de:1.2, icr:6.8, netDebtEbitda:1.8,
    pfcf:11.4, fcfYield:8.8, ocfRatio:1.2, assetTurnover:0.7, invTurnover:null,
    score:75, verdict:"Good"
  },
  {
    symbol:"OGDC", de:0.1, icr:28.5, netDebtEbitda:-0.2,
    pfcf:7.3, fcfYield:13.7, ocfRatio:2.1, assetTurnover:0.5, invTurnover:null,
    score:91, verdict:"Excellent"
  },
  {
    symbol:"PPL", de:0.2, icr:22.1, netDebtEbitda:0.1,
    pfcf:8.8, fcfYield:11.4, ocfRatio:1.8, assetTurnover:0.6, invTurnover:null,
    score:87, verdict:"Strong"
  },
  {
    symbol:"FATIMA", de:0.9, icr:8.2, netDebtEbitda:1.1,
    pfcf:10.2, fcfYield:11.8, ocfRatio:1.3, assetTurnover:1.0, invTurnover:7.4,
    score:74, verdict:"Good"
  },
  {
    symbol:"MEBL", de:null, icr:null, netDebtEbitda:null,
    pfcf:13.1, fcfYield:7.7, ocfRatio:1.1, assetTurnover:0.1, invTurnover:null,
    score:72, verdict:"Good"
  },
  {
    symbol:"BIPL", de:null, icr:null, netDebtEbitda:null,
    pfcf:7.8, fcfYield:9.2, ocfRatio:0.9, assetTurnover:0.08, invTurnover:null,
    score:61, verdict:"Caution"
  },
  {
    symbol:"NATF", de:0.7, icr:6.4, netDebtEbitda:1.9,
    pfcf:16.3, fcfYield:6.1, ocfRatio:0.8, assetTurnover:1.6, invTurnover:6.8,
    score:58, verdict:"Caution"
  },
  {
    symbol:"ENGRO", de:0.8, icr:8.5, netDebtEbitda:0.8,
    pfcf:10.5, fcfYield:11.2, ocfRatio:1.3, assetTurnover:0.9, invTurnover:6.5,
    score:80, verdict:"Strong"
  },
  {
    symbol:"LUCK", de:0.4, icr:12.5, netDebtEbitda:0.2,
    pfcf:14.2, fcfYield:8.5, ocfRatio:1.5, assetTurnover:1.1, invTurnover:7.2,
    score:71, verdict:"Good"
  },
  {
    symbol:"SYS", de:0.1, icr:25.4, netDebtEbitda:0.05,
    pfcf:22.4, fcfYield:6.8, ocfRatio:1.2, assetTurnover:1.4, invTurnover:null,
    score:68, verdict:"Good"
  },
  {
    symbol:"PSO", de:1.1, icr:4.2, netDebtEbitda:1.4,
    pfcf:8.5, fcfYield:9.4, ocfRatio:1.1, assetTurnover:2.1, invTurnover:12.4,
    score:73, verdict:"Good"
  },
  {
    symbol:"MCB", de:null, icr:null, netDebtEbitda:null,
    pfcf:8.2, fcfYield:9.1, ocfRatio:1.1,
    score:79, verdict:"Strong"
  },
  {
    symbol:"HBL", de:null, icr:null, netDebtEbitda:null,
    pfcf:9.1, fcfYield:8.4, ocfRatio:1.0,
    score:70, verdict:"Good"
  },
  {
    symbol:"FFBL", de:1.3, icr:4.8, netDebtEbitda:1.9,
    pfcf:7.9, fcfYield:10.1, ocfRatio:1.1, assetTurnover:1.2, invTurnover:8.5,
    score:72, verdict:"Good"
  },
  {
    symbol:"SEARL", de:0.8, icr:3.2, netDebtEbitda:2.2,
    pfcf:18.4, fcfYield:5.2, ocfRatio:0.9, assetTurnover:0.8, invTurnover:4.2,
    score:54, verdict:"Caution"
  },
  {
    symbol:"MARI", de:0.15, icr:32.4, netDebtEbitda:-0.1,
    pfcf:9.8, fcfYield:12.1, ocfRatio:2.3, assetTurnover:0.8, invTurnover:null,
    score:89, verdict:"Excellent"
  },
  {
    symbol:"TRG", de:1.8, icr:1.2, netDebtEbitda:4.2,
    pfcf:45.0, fcfYield:2.1, ocfRatio:0.4, assetTurnover:0.4, invTurnover:null,
    score:35, verdict:"Avoid"
  }
];

// ── STRATEGY TIER LIST (Video 1) ─────────────────────────────────────────────
const TIERS = [
  {
    tier:"S", label:"Best — Use These",
    color:"#22c55e", bg:"rgba(34,197,94,0.1)",
    items:[
      { name:"SIP (Systematic Investment Plan)", youUse:true,
        why:"Removes emotion from investing. You auto-buy more shares when prices fall — this is mathematical advantage over market timers. Consistent monthly investing beats lump-sum timing 80% of the time on PSX." },
      { name:"Value Investing", youUse:true,
        why:"Buying a great company at a fair price beats every other strategy long-term. Combined with ratio analysis (D/E, FCF, ICR), you identify financially healthy businesses before the market does." },
      { name:"Business Recorder (Daily Reading)", youUse:true,
        why:"Free. Updated daily. Contains profit/loss announcements, financial ratios, macro news (SBP rate, rupee, inflation). Reading this daily keeps you ahead of retail investors who trade on WhatsApp tips." },
    ]
  },
  {
    tier:"A", label:"Excellent — Complement Your Strategy",
    color:"#3b82f6", bg:"rgba(59,130,246,0.1)",
    items:[
      { name:"Portfolio Rebalancing", youUse:false,
        why:"Once or twice a year, shift weight from overvalued positions into undervalued ones. Keeps your Core/Secondary/Small allocation intact. Do this after major dividend announcements." },
    ]
  },
  {
    tier:"B", label:"Good — Situational Use",
    color:"#a855f7", bg:"rgba(168,85,247,0.1)",
    items:[
      { name:"Lump Sum Investing", youUse:false,
        why:"Works well during market crashes (PSX -20% days). Not ideal as a primary strategy — timing the market is hard. Use it opportunistically when great stocks are 15%+ below fair value." },
      { name:"ETFs", youUse:false,
        why:"Gives instant diversification. Meezan Islamic Income Fund is an example. But ETF dividends are lower than individual high-yield stocks. Fine for beginners, suboptimal for your dividend machine goal." },
      { name:"Blue Chip Stocks Only", youUse:false,
        why:"Your Core (HUBC, FFC, EFERT) are essentially blue chips. This works but limits upside. You already do this — your core selection is correct." },
    ]
  },
  {
    tier:"C", label:"Average — Use With Caution",
    color:"#f59e0b", bg:"rgba(245,158,11,0.1)",
    items:[
      { name:"Mutual Funds", youUse:false,
        why:"Fund managers charge 2-3% management fee. On PSX, 80% of mutual funds underperform the index over 10 years. You can build a better portfolio yourself." },
      { name:"Sector/Industry Focus (S&F)", youUse:false,
        why:"Concentrating on one sector (like only fertilizer) increases risk. You're partially doing this — balance it with energy and banking positions you already have." },
      { name:"Diversification (over-diversification)", youUse:false,
        why:"Holding 30+ stocks dilutes your returns. Your 9-stock portfolio is actually the optimal range. More than 15 stocks rarely adds meaningful risk reduction on PSX." },
    ]
  },
  {
    tier:"D", label:"Avoid — Destroys Wealth",
    color:"#ef4444", bg:"rgba(239,68,68,0.1)",
    items:[
      { name:"Viral/Hype Stocks", youUse:false,
        why:"Stocks pumped on WhatsApp/social media always dump. You are buying at the top when everyone else already bought. No dividend history, no fundamentals. Guaranteed losses for retail investors." },
      { name:"TPS (Trading/Pure Speculation)", youUse:false,
        why:"95% of day traders lose money within 1 year. You compete against algorithms, institutional traders, and insiders. Your edge as a retail investor is time — not speed. Never day trade." },
    ]
  },
];

// ── SIP PLAN ──────────────────────────────────────────────────────────────────
const SIP_MONTHLY = 10000;
const SIP_START_MONTH = 6;
const SIP_MONTHS_DONE = 5;

// ── 7-PART ROADMAP (Exact PKR per stock per month) ───────────────────────────
const ROADMAP_PARTS = [
  {
    part: 1, label: "PART 1 — Correction + Foundation",
    months: "Month 6 → 12", icon: "🔥",
    theme: "Build the base. Average down FFC & EFERT. Lock in HUBC.",
    monthRange: [6, 12],
    budget: 10000,
    allocs: [
      { s:"HUBC",   amt:3000, note:"Top priority always" },
      { s:"FFC",    amt:2000, note:"Average down — still S-tier" },
      { s:"EFERT",  amt:2000, note:"Average down — highest yield" },
      { s:"OGDC",   amt:1500, note:"Energy foundation" },
      { s:"PPL",    amt:1500, note:"Energy support" },
    ],
    special: "Every 2nd month: replace OGDC or PPL slot with FATIMA or MEBL (₨1,500)",
    specialMonths: [7, 9, 11],
    specialStocks: ["FATIMA","MEBL"],
    divTarget: "~₨10,000–12,000/year by Month 12",
    rule: "Never skip. Price correction = gift. Buy more.",
  },
  {
    part: 2, label: "PART 2 — Aggressive Growth",
    months: "Month 13 → 24", icon: "🚀",
    theme: "Scale up Core. Dividend income starts showing.",
    monthRange: [13, 24],
    budget: 10000,
    allocs: [
      { s:"HUBC",  amt:3500, note:"Increase position aggressively" },
      { s:"FFC",   amt:2500, note:"FFC now at lower avg buy" },
      { s:"EFERT", amt:2000, note:"Strong dividend contributor" },
      { s:"OGDC",  amt:1000, note:"Steady energy hold" },
      { s:"PPL",   amt:1000, note:"Steady energy hold" },
    ],
    special: "Every 3rd month: add ₨0 to above, buy FATIMA or MEBL or NATF separately from any extra cash",
    specialMonths: [15, 18, 21, 24],
    specialStocks: ["FATIMA","MEBL","NATF"],
    divTarget: "~₨25,000–35,000/year by Month 24",
    rule: "If stock is expensive (yield <7%), redirect to HUBC or FFC.",
  },
  {
    part: 3, label: "PART 3 — Dividend Build Phase",
    months: "Month 25 → 36", icon: "⚡",
    theme: "Dividends now significant. Reinvest every single payout.",
    monthRange: [25, 36],
    budget: 10000,
    allocs: [
      { s:"HUBC",  amt:3000, note:"Core — never stop adding" },
      { s:"FFC",   amt:2500, note:"Fertilizer king dividend" },
      { s:"EFERT", amt:2000, note:"High yield compounder" },
      { s:"OGDC",  amt:1500, note:"Government-backed safety" },
      { s:"PPL",   amt:1000, note:"Steady income" },
    ],
    special: "Reinvest ALL dividends → back into HUBC or FFC only",
    specialMonths: [],
    specialStocks: ["HUBC","FFC"],
    divTarget: "~₨50,000/year by Month 36",
    rule: "Every dividend received must be reinvested within 5 days.",
  },
  {
    part: 4, label: "PART 4 — Acceleration Phase",
    months: "Month 37 → 48", icon: "📈",
    theme: "Compounding visibly accelerates. Stay the course.",
    monthRange: [37, 48],
    budget: 10000,
    allocs: [
      { s:"HUBC",  amt:3000, note:"Dominant core position" },
      { s:"FFC",   amt:2500, note:"Largest dividend contributor" },
      { s:"EFERT", amt:2000, note:"Consistent payer" },
      { s:"OGDC",  amt:1500, note:"Energy backbone" },
      { s:"PPL",   amt:1000, note:"Steady secondary" },
    ],
    special: "Every 4th month: add FATIMA or MEBL from dividend reinvestment",
    specialMonths: [40, 44, 48],
    specialStocks: ["FATIMA","MEBL"],
    divTarget: "~₨1,00,000/year by Month 48",
    rule: "No new stocks. No deviations. Stick to the list.",
  },
  {
    part: 5, label: "PART 5 — Power Phase",
    months: "Month 49 → 60", icon: "💰",
    theme: "Dividend income is now serious money. Full reinvestment.",
    monthRange: [49, 60],
    budget: 10000,
    allocs: [
      { s:"HUBC",  amt:2800, note:"Still #1 income driver" },
      { s:"FFC",   amt:2500, note:"Top fertilizer dividend" },
      { s:"EFERT", amt:2200, note:"High yield maintained" },
      { s:"OGDC",  amt:1500, note:"Government-backed income" },
      { s:"PPL",   amt:1000, note:"Reliable secondary" },
    ],
    special: "ALL dividends fully reinvested — prefer HUBC + FFC",
    specialMonths: [],
    specialStocks: ["HUBC","FFC"],
    divTarget: "~₨1,20,000–1,40,000/year by Month 60",
    rule: "Treat dividends as more shares, not as spending money.",
  },
  {
    part: 6, label: "PART 6 — Income Build Phase",
    months: "Month 61 → 72", icon: "🔥",
    theme: "Income stream clearly visible. Small diversification added.",
    monthRange: [61, 72],
    budget: 10000,
    allocs: [
      { s:"HUBC",   amt:2500, note:"Core income engine" },
      { s:"FFC",    amt:2500, note:"Largest fertilizer payer" },
      { s:"EFERT",  amt:2000, note:"Consistent yielder" },
      { s:"OGDC",   amt:1500, note:"Energy pillar" },
      { s:"PPL",    amt:1000, note:"Secondary energy" },
      { s:"MEBL",   amt:500,  note:"OR FATIMA — alternate each month" },
    ],
    special: "Alternate MEBL and FATIMA each month for the ₨500 slot",
    specialMonths: [],
    specialStocks: ["MEBL","FATIMA"],
    divTarget: "~₨1,60,000–1,80,000/year by Month 72",
    rule: "Price check every month. Expensive = shift to HUBC/FFC.",
  },
  {
    part: 7, label: "PART 7 — Goal Phase",
    months: "Month 73 → 84", icon: "🎯",
    theme: "You are near the ₨2 Lakh/year target. Final push.",
    monthRange: [73, 84],
    budget: 10000,
    allocs: [
      { s:"HUBC",  amt:2500, note:"Core — final accumulation" },
      { s:"FFC",   amt:2500, note:"Fertilizer dividend machine" },
      { s:"EFERT", amt:2000, note:"Final high-yield build" },
      { s:"OGDC",  amt:1500, note:"Government income" },
      { s:"PPL",   amt:1000, note:"Energy support" },
      { s:"ANY",   amt:500,  note:"Any small stock from your list" },
    ],
    special: "₨500 can go to any of: FATIMA, MEBL, NATF, BIPL",
    specialMonths: [],
    specialStocks: ["FATIMA","MEBL","NATF","BIPL"],
    divTarget: "~₨2,00,000+/year by Month 84 ✅",
    rule: "You made it. Keep reinvesting. Never stop the SIP.",
  },
];

// Universal Rules
const UNIVERSAL_RULES = [
  { icon:"📊", title:"Rule 1 — Price Check Every Month", body:"Before buying, check if the stock's dividend yield is still above 7%. If price ran up and yield dropped below 7%, shift that money to HUBC, FFC, or EFERT instead." },
  { icon:"🚫", title:"Rule 2 — No New Stocks", body:"Stick exactly to your 9 stocks. No matter what you read on social media, WhatsApp, or financial news — do not add new stocks. Every rupee goes into your existing list only." },
  { icon:"🔄", title:"Rule 3 — Reinvest Every Dividend", body:"When dividends arrive (FFC/EFERT in Feb–Mar, HUBC/OGDC in Apr–Jun, MEBL in Aug), reinvest within 5 days. This single rule doubles your income over 7 years." },
  { icon:"📅", title:"Rule 4 — Never Skip a Month", body:"SIP works through compounding. One skipped month = 3 months of delayed progress. If you can't invest ₨10,000, invest ₨5,000. But never skip completely." },
  { icon:"📰", title:"Rule 5 — Read B.R. Daily", body:"Open brecorder.com every morning. Takes 10 minutes. Check: company results, SBP rate decisions, rupee movement. This is your only free edge over other investors." },
];

// ── VALUE INDEX CALCULATOR ────────────────────────────────────────────────────
// Calculates a 0-100 composite score from all 8 B.R. ratios (Video 2)
// Each ratio is normalized and weighted

function calcValueIndex(r) {
  if (!r) return 0;
  let score = 0, weight = 0;

  // D/E Ratio — lower is better (max score at 0, zero at 2.5+)
  if (r.de != null) {
    const s = Math.max(0, Math.min(100, (1 - r.de / 2.5) * 100));
    score += s * 15; weight += 15;
  }

  // Interest Coverage Ratio — higher is better
  if (r.icr != null) {
    const s = Math.max(0, Math.min(100, (r.icr / 25) * 100));
    score += s * 15; weight += 15;
  }

  // Net Debt/EBITDA — lower (more negative) is better
  if (r.netDebtEbitda != null) {
    const s = Math.max(0, Math.min(100, ((2 - r.netDebtEbitda) / 3) * 100));
    score += s * 10; weight += 10;
  }

  // P/FCF — lower is better (max at <8, zero at 25+)
  if (r.pfcf != null) {
    const s = Math.max(0, Math.min(100, ((25 - r.pfcf) / 17) * 100));
    score += s * 20; weight += 20;
  }

  // FCF Yield — higher is better (max at 15%+)
  if (r.fcfYield != null) {
    const s = Math.max(0, Math.min(100, (r.fcfYield / 15) * 100));
    score += s * 20; weight += 20;
  }

  // OCF Ratio — higher is better (max at 2.5+)
  if (r.ocfRatio != null) {
    const s = Math.max(0, Math.min(100, (r.ocfRatio / 2.5) * 100));
    score += s * 10; weight += 10;
  }

  // Asset Turnover — higher is better
  if (r.assetTurnover != null) {
    const s = Math.max(0, Math.min(100, (r.assetTurnover / 2) * 100));
    score += s * 5; weight += 5;
  }

  // Inventory Turnover — higher is better (only for relevant stocks)
  if (r.invTurnover != null) {
    const s = Math.max(0, Math.min(100, (r.invTurnover / 12) * 100));
    score += s * 5; weight += 5;
  }

  return weight > 0 ? Math.round(score / weight) : 0;
}

// ── B.R. SCORE CALCULATOR ─────────────────────────────────────────────────────
// Business Recorder Score = monthly health check combining:
// 1. Value Index (ratio health)     — 40%
// 2. Dividend Yield vs benchmark    — 30%
// 3. Price vs 52-week avg (momentum)— 15%
// 4. Debt safety margin             — 15%

function calcBRScore(stock, ratios) {
  const r = ratios.find(x => x.symbol === stock.symbol);
  if (!r) return { score: 0, grade: 'N/A', signal: 'hold' };

  const vi = calcValueIndex(r);

  // Yield score: 10%+ = 100, 7%=70, 5%=50, <4%=20
  const yld = parseFloat(stock.yld) || 0;
  const yieldScore = Math.min(100, Math.max(0, yld * 9));

  // Price momentum: if current < avgBuy = buying opportunity (score up)
  const priceDiff = (stock.price - stock.avgBuy) / stock.avgBuy;
  const momentumScore = priceDiff < 0
    ? Math.min(100, Math.abs(priceDiff) * 300 + 50)   // below avg = opportunity
    : Math.max(0, 80 - priceDiff * 200);               // above avg = caution

  // Debt safety: from D/E ratio
  const debtScore = r.de == null ? 70 :
    r.de < 0.5 ? 100 : r.de < 1 ? 80 : r.de < 1.5 ? 60 : r.de < 2 ? 40 : 20;

  const total = Math.round(vi * 0.40 + yieldScore * 0.30 + momentumScore * 0.15 + debtScore * 0.15);

  const grade = total >= 85 ? 'A+' : total >= 75 ? 'A' : total >= 65 ? 'B+' :
                total >= 55 ? 'B'  : total >= 45 ? 'C' : 'D';
  const signal = total >= 70 ? 'buy' : total >= 50 ? 'hold' : 'caution';

  return { score: total, grade, signal, vi, yieldScore: Math.round(yieldScore), momentumScore: Math.round(momentumScore), debtScore };
}

// ── OLD MONTHLY_PLAN (kept for backward compat) ───────────────────────────────
const MONTHLY_PLAN = ROADMAP_PARTS.map(p => {
  return Array.from({ length: p.monthRange[1] - p.monthRange[0] + 1 }, (_, i) => {
    const m = p.monthRange[0] + i;
    const isSpecial = p.specialMonths && p.specialMonths.includes(m);
    let mainBuys = p.allocs.filter(a => a.s !== 'ANY').map(a => ({
      s: a.s, pct: Math.round(a.amt / p.budget * 100)
    }));

    // Apply Special Rules Logic
    if (p.part === 1 && isSpecial) {
      // Alternate between replacing OGDC and PPL using the index of the special month
      const specIdx = p.specialMonths.indexOf(m);
      const targetSymbol = specIdx % 2 === 0 ? 'OGDC' : 'PPL';
      const replacementSymbol = specIdx % 2 === 0 ? 'FATIMA' : 'MEBL';
      mainBuys = mainBuys.map(b => b.s === targetSymbol ? { ...b, s: replacementSymbol } : b);
    } 
    else if (p.part === 2 && isSpecial) {
      // Every 3rd month: Add extra stock from cash (shown as extra entry)
      const extraStock = p.specialStocks[Math.floor(m/3) % p.specialStocks.length];
      mainBuys.push({ s: extraStock, pct: 0, note: "Extra from cash" });
    }
    else if (p.part === 6) {
      // Alternate MEBL and FATIMA each month for the ₨500 slot
      const replacementSymbol = m % 2 === 0 ? 'FATIMA' : 'MEBL';
      mainBuys = mainBuys.map(b => b.s === 'MEBL' ? { ...b, s: replacementSymbol } : b);
    }

    return { 
      month: m, 
      focus: p.label.split('—')[1]?.trim() || p.label, 
      buys: mainBuys, 
      part: p.part, 
      isSpecial 
    };
  });
}).flat();

// ── 7-YEAR PROJECTION ─────────────────────────────────────────────────────────
const PROJECTION = [
  { year:1, label:"Year 1",  invested:57200+7*10000,  portfolioVal:142000,  annualDiv:12000,  monthly:1000,  milestone:"" },
  { year:2, label:"Year 2",  invested:177200,          portfolioVal:230000,  annualDiv:30000,  monthly:2500,  milestone:"" },
  { year:3, label:"Year 3",  invested:297200,          portfolioVal:370000,  annualDiv:50000,  monthly:4167,  milestone:"🎯 50k/yr milestone!" },
  { year:4, label:"Year 4",  invested:417200,          portfolioVal:560000,  annualDiv:100000, monthly:8333,  milestone:"🚀 1 Lakh/yr milestone!" },
  { year:5, label:"Year 5",  invested:537200,          portfolioVal:810000,  annualDiv:130000, monthly:10833, milestone:"" },
  { year:6, label:"Year 6",  invested:657200,          portfolioVal:1120000, annualDiv:165000, monthly:13750, milestone:"" },
  { year:7, label:"Year 7",  invested:777200,          portfolioVal:1520000, annualDiv:210000, monthly:17500, milestone:"🏆 2 Lakh/yr — GOAL!" },
];

const DIVIDEND_WAVES = [
  { month:"Feb–Mar", wave:"🌾 Fertilizer", stocks:["FFC","EFERT","FATIMA"], color:"#22c55e" },
  { month:"Apr–Jun", wave:"⚡ Energy",     stocks:["HUBC","OGDC","PPL"],    color:"#f59e0b" },
  { month:"Aug–Sep", wave:"🏦 Banking",    stocks:["MEBL","BIPL"],          color:"#3b82f6" },
];

const GOAL_ANNUAL = 200000;





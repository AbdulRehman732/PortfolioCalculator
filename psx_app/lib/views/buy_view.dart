import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../models/stock.dart';
import '../data/psx_data.dart';

class BuyView extends StatefulWidget {
  const BuyView({super.key});

  @override
  State<BuyView> createState() => _BuyViewState();
}

class _BuyViewState extends State<BuyView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // All symbols that have ratio/score data
  static final List<String> _allRatioSymbols =
      PsxData.ratios.map((r) => r.symbol).toList();

  /// Build a minimal Stock for a symbol that isn't in the portfolio
  Stock _stubStock(String symbol) {
    final fromDb = PsxData.defaultPortfolio
        .where((s) => s.symbol == symbol)
        .toList();
    if (fromDb.isNotEmpty) return fromDb.first;

    final ratio = PsxData.ratios.firstWhere((r) => r.symbol == symbol,
        orElse: () => ValueRatio(symbol: symbol, score: 0, verdict: 'N/A'));
    return Stock(
      symbol: symbol,
      name: symbol,
      tier: 'secondary',
      price: 0,
      dpshist: ratio.fcfYield ?? 0,
      sector: '',
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PsxService>(context);

    // Default list: all portfolio stocks
    final portfolioSymbols = service.portfolio.map((s) => s.symbol).toSet();

    // Filtered results when searching
    List<String> displaySymbols;
    if (_query.isEmpty) {
      displaySymbols = service.portfolio.map((s) => s.symbol).toList();
    } else {
      final q = _query.toUpperCase();
      displaySymbols = _allRatioSymbols
          .where((sym) => sym.contains(q))
          .toList();
    }

    return Column(
      children: [
        // ── Search bar ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Search stock symbol (e.g. OGDC)…',
              hintStyle: const TextStyle(color: Color(0xFF64748b)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748b)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear, color: Color(0xFF64748b)),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF111827),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF10b981), width: 2),
              ),
            ),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        // ── List ──────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (only when not searching)
                if (_query.isEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Monthly Buy Tool — Month 5 Decision',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 13, color: Colors.white70, height: 1.5),
                      children: [
                        TextSpan(
                            text:
                                'S-Tier system: SIP Rs10,000 this month. Focus: '),
                        TextSpan(
                            text: 'Correction + Foundation. ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        TextSpan(
                            text:
                                'Check ratios + BR news before buying.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (displaySymbols.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_outlined,
                              size: 48,
                              color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 12),
                          Text('No stock found for "$_query"',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  )
                else
                  ...displaySymbols.map((symbol) {
                    // Prefer live portfolio stock (has real shares/avgBuy)
                    final portfolioStock = service.portfolio
                        .where((s) => s.symbol == symbol)
                        .toList();
                    final stock = portfolioStock.isNotEmpty
                        ? portfolioStock.first
                        : _stubStock(symbol);
                    final inPortfolio = portfolioSymbols.contains(symbol);
                    return _buildDecisionCard(stock, service, inPortfolio);
                  }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionCard(
      Stock stock, PsxService service, bool inPortfolio) {
    final brData = service.calcBRScore(stock);
    final signal = brData['signal'] == 'BUY' ? 'BUY' : 'HOLD';
    final isBuy = signal == 'BUY';

    final shares5k =
        stock.price > 0 ? (5000 / stock.price).floor() : 0;
    final shares10k =
        stock.price > 0 ? (10000 / stock.price).floor() : 0;

    final pnlPct = stock.profitLossPct;
    final pnlColor =
        pnlPct >= 0 ? const Color(0xFF10b981) : const Color(0xFFef4444);
    final pnlStr = pnlPct >= 0
        ? '+${pnlPct.toStringAsFixed(1)}%'
        : '${pnlPct.toStringAsFixed(1)}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0f1218),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBuy
                ? const Color(0xFF10b981).withOpacity(0.35)
                : Colors.white12,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ── Header row ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.symbol,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(stock.name,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white54)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isBuy
                        ? const Color(0xFF10b981).withOpacity(0.18)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    signal,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isBuy
                          ? const Color(0xFF10b981)
                          : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Stats ────────────────────────────────────────────────
            _row('Current Price',
                stock.price > 0
                    ? 'Rs ${stock.price.toStringAsFixed(2)}'
                    : '—'),
            _row('Yield',
                stock.price > 0
                    ? '${stock.yld.toStringAsFixed(1)}%'
                    : '—',
                valueColor: const Color(0xFF10b981)),
            _row('Screener Score', "${brData['score']}/100"),
            _row('Shares per Rs5k',
                stock.price > 0 ? '$shares5k shares' : '—'),
            _row('Shares per Rs10k',
                stock.price > 0 ? '$shares10k shares' : '—'),

            // Avg Buy — only show if stock is in portfolio
            if (inPortfolio && stock.avgBuy > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your Avg Buy',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 14)),
                    Text(
                      'Rs ${stock.avgBuy.toStringAsFixed(2)} ($pnlStr)',
                      style: TextStyle(
                          color: pnlColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {Color valueColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

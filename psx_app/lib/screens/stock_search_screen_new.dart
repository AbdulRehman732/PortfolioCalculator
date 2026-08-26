import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../models/stock.dart';
import '../data/psx_stock_database.dart';
import '../data/psx_data.dart';

class StockSearchScreen extends StatefulWidget {
  const StockSearchScreen({super.key});

  @override
  State<StockSearchScreen> createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  final Map<String, double?> _priceCache = {};
  final Map<String, Map<String, dynamic>> _scoreCache = {};
  bool _isSearchingBackend = false;
  Map<String, dynamic>? _customSymbolResult;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchStocks(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _searchResults = [];
        _customSymbolResult = null;
      });
      return;
    }

    // 1. Search local database
    final results = PsxStockDatabase.searchStocks(clean);

    setState(() {
      _searchResults = results;
      _customSymbolResult = null;
    });

    // 2. Fetch prices & signals for top local matches
    _fetchDataForResults(results);

    // 3. If query looks like a ticker and not in local results, check backend live
    final upper = clean.toUpperCase();
    if (results.isEmpty && upper.length >= 2 && RegExp(r'^[A-Z0-9]+$').hasMatch(upper)) {
      _searchBackend(upper);
    }
  }

  Future<void> _searchBackend(String symbol) async {
    setState(() => _isSearchingBackend = true);
    final service = Provider.of<PsxService>(context, listen: false);

    final scoreData = await service.fetchStockScore(symbol);
    if (mounted) {
      setState(() {
        _isSearchingBackend = false;
        if (scoreData != null && scoreData['price'] != null) {
          _customSymbolResult = scoreData;
          _priceCache[symbol] = (scoreData['price'] as num?)?.toDouble();
          _scoreCache[symbol] = scoreData;
        }
      });
    }
  }

  Future<void> _fetchDataForResults(List<Map<String, String>> results) async {
    final service = Provider.of<PsxService>(context, listen: false);
    for (var stock in results.take(8)) {
      final symbol = stock['symbol']!;

      if (!_priceCache.containsKey(symbol)) {
        final price = await service.fetchLivePrice(symbol);
        if (mounted) {
          setState(() {
            _priceCache[symbol] = price;
          });
        }
      }

      if (!_scoreCache.containsKey(symbol)) {
        final score = await service.fetchStockScore(symbol);
        if (mounted && score != null) {
          setState(() {
            _scoreCache[symbol] = score;
          });
        }
      }
    }
  }

  Future<void> _addStockToPortfolio(Map<String, dynamic> stockData) async {
    final service = Provider.of<PsxService>(context, listen: false);
    final symbol = (stockData['symbol'] as String).toUpperCase();

    // Check if already in portfolio
    if (service.portfolio.any((s) => s.symbol == symbol)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$symbol is already in your portfolio'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final price = _priceCache[symbol] ?? (stockData['price'] as num?)?.toDouble() ?? 100.0;
    double dpshist = 0.0;

    // Check default portfolio first
    final defaultMatch = PsxData.defaultPortfolio.where((s) => s.symbol == symbol).toList();
    if (defaultMatch.isNotEmpty) {
      dpshist = defaultMatch.first.dpshist;
    } else {
      // Fetch live dividend from backend
      final liveDps = await service.fetchDividend(symbol);
      if (liveDps != null && liveDps > 0) {
        dpshist = liveDps;
      } else {
        final ratioMatch = PsxData.ratios.where((r) => r.symbol == symbol).toList();
        if (ratioMatch.isNotEmpty) {
          dpshist = ratioMatch.first.fcfYield ?? 0.0;
        }
      }
    }

    final newStock = Stock(
      symbol: symbol,
      name: stockData['name'] ?? symbol,
      sector: stockData['sector'] ?? 'Other',
      price: price,
      tier: 'secondary',
      dpshist: dpshist,
    );

    service.addStock(newStock);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Added $symbol to portfolio with live analysis!'),
          backgroundColor: const Color(0xFF10b981),
          duration: const Duration(seconds: 2),
        ),
      );

      _searchController.clear();
      setState(() {
        _searchResults = [];
        _customSymbolResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text('Add & Analyze PSX Stocks', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              controller: _searchController,
              onChanged: _searchStocks,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Search any PSX stock (e.g. ENGRO, MEBL, SYS)…',
                hintStyle: const TextStyle(color: Color(0xFF64748b)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748b)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF64748b)),
                        onPressed: () {
                          _searchController.clear();
                          _searchStocks('');
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
                  borderSide: const BorderSide(color: Color(0xFF10b981), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isSearchingBackend)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10b981)),
                    ),
                    SizedBox(width: 10),
                    Text('Checking live PSX ticker data…', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),

            // Custom live backend result (if searched symbol wasn't in static database)
            if (_customSymbolResult != null) ...[
              const Text('Live PSX Match', style: TextStyle(color: Color(0xFF10b981), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              _buildStockCard({
                'symbol': _customSymbolResult!['symbol'],
                'name': _customSymbolResult!['name'] ?? _customSymbolResult!['symbol'],
                'sector': _customSymbolResult!['sector'] ?? 'PSX Listed',
                'price': _customSymbolResult!['price'],
              }),
              const SizedBox(height: 16),
            ],

            // Local Search results
            if (_searchResults.isNotEmpty) ...[
              Text(
                'Found ${_searchResults.length} stocks',
                style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
              ),
              const SizedBox(height: 12),
              ..._searchResults.map((stock) => _buildStockCard(stock)),
            ],

            // Empty state
            if (_searchResults.isEmpty &&
                _customSymbolResult == null &&
                !_isSearchingBackend &&
                _searchController.text.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_outlined, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No stock found for "${_searchController.text}"',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15)),
                      const SizedBox(height: 6),
                      const Text('Type a valid PSX ticker symbol (e.g. LUCK, MCB, PSO)',
                          style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ),

            // Initial Guide
            if (_searchController.text.isEmpty && _searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.analytics_outlined, size: 54, color: const Color(0xFF10b981).withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        'Search Any Stock on PSX',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Type any ticker or company name. The app dynamically fetches live price, calculates dividend yield, and outputs a real-time BUY or HOLD recommendation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    final symbol = (stock['symbol'] as String?) ?? 'N/A';
    final name = (stock['name'] as String?) ?? symbol;
    final sector = (stock['sector'] as String?) ?? 'PSX';
    final price = _priceCache[symbol] ?? (stock['price'] as num?)?.toDouble() ?? 0.0;
    final isPriceLoaded = _priceCache.containsKey(symbol) || stock['price'] != null;

    final scoreData = _scoreCache[symbol];
    final signal = scoreData?['signal'] ?? (price > 0 ? 'CALCULATING' : 'HOLD');
    final isBuy = signal.contains('BUY');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border.all(
          color: isBuy ? const Color(0xFF10b981).withValues(alpha: 0.3) : const Color(0xFF334155),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          symbol,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        if (scoreData != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isBuy ? const Color(0xFF10b981).withValues(alpha: 0.2) : Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              signal,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isBuy ? const Color(0xFF10b981) : Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _addStockToPortfolio(stock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sector,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748b)),
              ),
              Text(
                isPriceLoaded && price > 0 ? 'Rs ${price.toStringAsFixed(2)}' : 'Fetching price…',
                style: TextStyle(
                  fontSize: 14,
                  color: isPriceLoaded && price > 0 ? const Color(0xFF10b981) : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (scoreData != null && scoreData['reason'] != null) ...[
            const SizedBox(height: 6),
            Text(
              scoreData['reason'],
              style: const TextStyle(fontSize: 11, color: Colors.white54, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
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
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, double?> _priceCache = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchStocks(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    // Use local database for search (instant, no network needed)
    final results = PsxStockDatabase.searchStocks(query);
    
    setState(() {
      _searchResults = results;
      _errorMessage = null;
    });

    // Fetch live prices for results in background
    _fetchPricesForResults(results);
  }

  Future<void> _fetchPricesForResults(List<Map<String, String>> results) async {
    for (var stock in results) {
      final symbol = stock['symbol']!;
      
      // Skip if already cached
      if (_priceCache.containsKey(symbol)) continue;

      try {
        final response = await http
            .get(Uri.parse('https://dps.psx.com.pk/company/$symbol'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final regex = RegExp(
              r'<div class="quote__close">\s*(?:Rs\.)?([\d,]+\.?\d*)\s*</div>');
          final match = regex.firstMatch(response.body);
          if (match != null) {
            String priceStr = match.group(1)!.replaceAll(',', '');
            double livePrice = double.tryParse(priceStr) ?? 0;
            
            if (mounted) {
              setState(() {
                _priceCache[symbol] = livePrice;
              });
            }
          }
        }
      } catch (e) {
        // Silently fail - show default price
        if (mounted) {
          setState(() {
            _priceCache[symbol] = null;
          });
        }
      }
    }
  }

  void _addStockToPortfolio(Map<String, String> stockData) {
    final service = Provider.of<PsxService>(context, listen: false);
    final symbol = stockData['symbol']!.toUpperCase();
    
    // Check if already in portfolio
    if (service.portfolio.any((s) => s.symbol == symbol)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$symbol already in portfolio'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final price = _priceCache[symbol] ?? 100.0;
    
    double dpshist = 0.0;
    final defaultMatch = PsxData.defaultPortfolio.where((s) => s.symbol == symbol).toList();
    if (defaultMatch.isNotEmpty) {
      dpshist = defaultMatch.first.dpshist;
    } else {
      final ratioMatch = PsxData.ratios.where((r) => r.symbol == symbol).toList();
      if (ratioMatch.isNotEmpty) {
        dpshist = ratioMatch.first.fcfYield ?? 0.0;
      }
    }
    
    final newStock = Stock(
      symbol: symbol,
      name: stockData['name'] ?? 'Unknown Stock',
      sector: stockData['sector'] ?? 'Other',
      price: price,
      tier: 'secondary',
      dpshist: dpshist,
    );

    service.addStock(newStock);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$symbol added to portfolio'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Clear search
    _searchController.clear();
    setState(() => _searchResults = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text('Search Stocks'),
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
              decoration: InputDecoration(
                hintText: 'Search by symbol or company name...',
                hintStyle: const TextStyle(color: Color(0xFF64748b)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748b)),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF10b981), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Search results
            if (_searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Found ${_searchResults.length} stocks',
                    style: const TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._searchResults.map((stock) => _buildStockCard(stock)).toList(),
                ],
              ),

            // Empty state
            if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 48,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No stocks found',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Help text
            if (_searchController.text.isEmpty && _searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Search for any PSX stock\nby symbol or company name',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${PsxStockDatabase.allStocks.length} stocks available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
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

  Widget _buildStockCard(Map<String, String> stock) {
    final symbol = stock['symbol'] ?? 'N/A';
    final name = stock['name'] ?? 'Unknown';
    final price = _priceCache[symbol] ?? 100.0;
    final sector = stock['sector'] ?? 'Other';
    final isPriceLoaded = _priceCache.containsKey(symbol);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border.all(color: const Color(0xFF334155)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94a3b8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sector,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748b),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPriceLoaded && price > 0 
                      ? 'Rs ${price.toStringAsFixed(2)}' 
                      : isPriceLoaded ? 'Rs --' : 'Loading...',
                  style: TextStyle(
                    fontSize: 14,
                    color: isPriceLoaded && price > 0 
                        ? const Color(0xFF10b981) 
                        : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _addStockToPortfolio(stock),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

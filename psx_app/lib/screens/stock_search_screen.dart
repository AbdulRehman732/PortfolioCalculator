import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/psx_service.dart';
import '../models/stock.dart';

class StockSearchScreen extends StatefulWidget {
  const StockSearchScreen({super.key});

  @override
  State<StockSearchScreen> createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(
              'http://localhost:3001/api/stocks/search?query=${Uri.encodeComponent(query)}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        // Fetch details for each result
        List<Map<String, dynamic>> detailedResults = [];
        for (var result in results) {
          final symbol = result['symbol'];
          try {
            final detailResponse = await http
                .get(Uri.parse(
                    'http://localhost:3001/api/stock/$symbol/details'))
                .timeout(const Duration(seconds: 5));

            if (detailResponse.statusCode == 200) {
              final detail = jsonDecode(detailResponse.body);
              detailedResults.add(detail);
            } else {
              detailedResults.add({'symbol': symbol, 'name': symbol});
            }
          } catch (e) {
            detailedResults.add({'symbol': symbol, 'name': symbol});
          }
        }

        setState(() {
          _searchResults = detailedResults;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to search stocks';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _addStockToPortfolio(Map<String, dynamic> stockData) {
    final service = Provider.of<PsxService>(context, listen: false);

    final price = (stockData['price'] ?? 100.toDouble()).toDouble();
    final yld = (stockData['yield'] ?? 0.0).toDouble();

    final newStock = Stock(
      symbol: stockData['symbol']?.toUpperCase() ?? 'UNKNOWN',
      name: stockData['name'] ?? 'Unknown Stock',
      sector: stockData['sector'] ?? 'Other',
      price: price,
      tier: 'secondary',
      dpshist: price * (yld / 100),
    );

    service.addStock(newStock);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newStock.symbol} added to portfolio'),
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
                  borderSide:
                      const BorderSide(color: Color(0xFF10b981), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10b981)),
                ),
              ),

            // Search results
            if (!_isLoading && _searchResults.isNotEmpty)
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
                  ..._searchResults
                      .map((stock) => _buildStockCard(stock))
                      .toList(),
                ],
              ),

            // Empty state
            if (!_isLoading &&
                _searchResults.isEmpty &&
                _searchController.text.isNotEmpty)
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
                        'Search for any PSX stock by symbol\nor company name',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
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
    final symbol = stock['symbol'] ?? 'N/A';
    final name = stock['name'] ?? 'Unknown';
    final price = stock['price'] ?? 0;
    final yield_ = stock['yield'] ?? 0;

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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rs ${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF10b981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10b981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${yield_.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10b981),
                        ),
                      ),
                    ),
                  ],
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

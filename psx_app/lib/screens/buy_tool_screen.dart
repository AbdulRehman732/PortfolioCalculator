import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class BuyToolScreen extends StatefulWidget {
  const BuyToolScreen({super.key});

  @override
  State<BuyToolScreen> createState() => _BuyToolScreenState();
}

class _BuyToolScreenState extends State<BuyToolScreen> {
  final _controller = TextEditingController();
  Stock? _stock;
  String? _statusMessage;
  bool _loading = false;
  NewsAnalysis? _newsAnalysis;

  Future<void> _searchSymbol() async {
    final symbol = _controller.text.trim().toUpperCase();
    if (symbol.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a stock symbol.';
        _stock = null;
        _newsAnalysis = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = null;
      _newsAnalysis = null;
    });

    final appState = context.read<AppState>();
    final stock = await appState.fetchStockDetails(symbol);
    setState(() {
      _stock = stock;
      _statusMessage =
          stock == null ? 'No results found for that symbol.' : null;
      _loading = false;
    });
  }

  Future<void> _loadNews() async {
    if (_stock == null) return;
    setState(() {
      _loading = true;
    });
    final analysis =
        await context.read<AppState>().fetchNewsAnalysis(_stock!.symbol);
    setState(() {
      _newsAnalysis = analysis;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppState>().favorites;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buy tool',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Find a stock to view analysis (uses local data if offline).',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      labelText: 'Symbol', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                  onPressed: _searchSymbol, child: const Text('Search')),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: favorites.map((symbol) {
              return ActionChip(
                label: Text(symbol),
                onPressed: () {
                  _controller.text = symbol;
                  _searchSymbol();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_statusMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_statusMessage!,
                  style: const TextStyle(color: Colors.orange)),
            ),
          if (_stock != null) ...[
            _StockCard(stock: _stock!),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.newspaper),
              label: const Text('Get news summary'),
              onPressed: _loadNews,
            ),
            if (_newsAnalysis != null) ...[
              const SizedBox(height: 16),
              _NewsCard(analysis: _newsAnalysis!),
            ],
          ],
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final Stock stock;

  const _StockCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${stock.symbol} • ${stock.name}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(stock.sector, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatChip(
                    label: 'Price',
                    value: '₨${stock.price.toStringAsFixed(2)}'),
                _StatChip(
                    label: 'Yield',
                    value:
                        '${stock.dividendYield?.toStringAsFixed(1) ?? '—'}%'),
                _StatChip(
                    label: 'BR Score', value: stock.brScore?.toString() ?? '—'),
                _StatChip(label: 'Verdict', value: stock.verdict),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade400)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsAnalysis analysis;

  const _NewsCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('News summary',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Overall sentiment: ${analysis.overallSentiment}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(analysis.impactExplanation,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (analysis.articles.isNotEmpty) ...[
              const Text('Sample Headlines',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: analysis.articles.map((article) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(article.summary,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text(article.sentiment)),
                            Text(article.pubDate,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

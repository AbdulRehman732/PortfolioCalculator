import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final transactions = appState.transactions;
    final dividends = appState.dividends;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Review your buys, sells and dividend entries.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: [
                _SectionCard(
                  title: 'Recent Transactions',
                  child: transactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                              'No transactions yet — record your first trade.'),
                        )
                      : Column(
                          children: transactions.map((entry) {
                            final icon = entry.type == 'sell'
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline;
                            final color = entry.type == 'sell'
                                ? Colors.red
                                : Colors.green;
                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundColor: color.withAlpha(51),
                                  child: Icon(icon, color: color)),
                              title: Text(
                                  '${entry.symbol} • ${entry.type.toUpperCase()}'),
                              subtitle: Text(
                                  '${entry.date} • ${entry.shares} shares'),
                              trailing: Text(
                                  '₨${entry.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Dividend Records',
                  child: dividends.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No dividends recorded yet.'),
                        )
                      : Column(
                          children: dividends.map((entry) {
                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundColor: Colors.green.withAlpha(38),
                                  child: const Icon(Icons.attach_money,
                                      color: Colors.green)),
                              title: Text(entry.symbol),
                              subtitle: Text(
                                  '${entry.date}${entry.note.isNotEmpty ? ' • ${entry.note}' : ''}'),
                              trailing: Text(
                                  appState.formatCurrency(entry.amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final holdings = appState.portfolio;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portfolio',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Manage holdings, log buys, sells and dividends.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Record purchase'),
                onPressed: () => _showBuyDialog(context),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.remove),
                label: const Text('Record sale'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
                onPressed: () => _showSellDialog(context),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_money),
                label: const Text('Record dividend'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700),
                onPressed: () => _showDividendDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: holdings.isEmpty
                ? const Center(
                    child: Text(
                        'No holdings yet — record a purchase to get started.'))
                : ListView.separated(
                    itemCount: holdings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = holdings[index];
                      final stock = appState.getStock(item.symbol);
                      final currentPrice = stock.price;
                      final currentValue = item.shares * currentPrice;
                      final cost = item.shares * item.avgBuy;
                      final pnl = currentValue - cost;
                      final pnlPct = cost > 0
                          ? (pnl / cost * 100).toStringAsFixed(1)
                          : '0.0';
                      final annualDividend = item.shares * item.dpshist;
                      return Card(
                        color: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.symbol} • ${item.name}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(item.tier.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.greenAccent)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _DataChip(
                                      label: 'Shares',
                                      value: item.shares.toString()),
                                  _DataChip(
                                      label: 'Avg Buy',
                                      value:
                                          '₨${item.avgBuy.toStringAsFixed(2)}'),
                                  _DataChip(
                                      label: 'Current',
                                      value:
                                          '₨${currentPrice.toStringAsFixed(2)}'),
                                  _DataChip(
                                      label: 'P&L',
                                      value: pnl >= 0
                                          ? '+₨${pnl.toStringAsFixed(0)}'
                                          : '₨${pnl.toStringAsFixed(0)}',
                                      valueColor:
                                          pnl >= 0 ? Colors.green : Colors.red),
                                  _DataChip(
                                      label: 'Yield',
                                      value:
                                          '${item.dpshist.toStringAsFixed(1)}/sh'),
                                  _DataChip(
                                      label: 'Ann Div',
                                      value:
                                          '₨${annualDividend.toStringAsFixed(0)}'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Market value: ${appState.formatCurrency(currentValue)}'),
                                  Text('$pnlPct%',
                                      style: TextStyle(
                                          color: pnl >= 0
                                              ? Colors.green
                                              : Colors.red)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBuyDialog(BuildContext context) async {
    final symbolController = TextEditingController();
    final sharesController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Purchase'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: symbolController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Stock Symbol'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Symbol required'
                      : null,
                ),
                TextFormField(
                  controller: sharesController,
                  decoration: const InputDecoration(labelText: 'Shares Bought'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    return number == null || number <= 0
                        ? 'Enter valid shares'
                        : null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Price per Share (₨)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final number = double.tryParse(value ?? '');
                    return number == null || number <= 0
                        ? 'Enter valid price'
                        : null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final symbol = symbolController.text.trim().toUpperCase();
                  final shares = int.parse(sharesController.text.trim());
                  final price = double.parse(priceController.text.trim());
                  context
                      .read<AppState>()
                      .addBuy(symbol: symbol, shares: shares, price: price);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Record'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSellDialog(BuildContext context) async {
    final symbolController = TextEditingController();
    final sharesController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Sale'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: symbolController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Stock Symbol'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Symbol required'
                      : null,
                ),
                TextFormField(
                  controller: sharesController,
                  decoration: const InputDecoration(labelText: 'Shares Sold'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    return number == null || number <= 0
                        ? 'Enter valid shares'
                        : null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Sale Price (₨)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final number = double.tryParse(value ?? '');
                    return number == null || number <= 0
                        ? 'Enter valid price'
                        : null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final symbol = symbolController.text.trim().toUpperCase();
                  final shares = int.parse(sharesController.text.trim());
                  final price = double.parse(priceController.text.trim());
                  context
                      .read<AppState>()
                      .addSell(symbol: symbol, shares: shares, price: price);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Record'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDividendDialog(BuildContext context) async {
    final symbolController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Dividend'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: symbolController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Stock Symbol'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Symbol required'
                      : null,
                ),
                TextFormField(
                  controller: amountController,
                  decoration:
                      const InputDecoration(labelText: 'Amount Received (₨)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final number = double.tryParse(value ?? '');
                    return number == null || number <= 0
                        ? 'Enter valid amount'
                        : null;
                  },
                ),
                TextFormField(
                  controller: noteController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final symbol = symbolController.text.trim().toUpperCase();
                  final amount = double.parse(amountController.text.trim());
                  final note = noteController.text.trim();
                  context
                      .read<AppState>()
                      .addDividend(symbol: symbol, amount: amount, note: note);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Record'),
            ),
          ],
        );
      },
    );
  }
}

class _DataChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DataChip({required this.label, required this.value, this.valueColor});

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
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }
}

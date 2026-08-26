import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../models/stock.dart';
import '../models/transaction.dart';
import '../widgets/glass_card.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PsxService>(context);
    final portfolio = service.portfolio;

    if (portfolio.isEmpty) {
      return const Center(
        child: Text('Your portfolio is empty.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Holdings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Tap a stock to log transactions. Swipe to remove.',
              style: TextStyle(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 8),
          if (service.isLoadingLivePrices)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10b981).withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF10b981),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Fetching live prices…',
                    style: TextStyle(color: Color(0xFF10b981), fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF10b981),
              backgroundColor: const Color(0xFF1e293b),
              onRefresh: () => service.refreshPrices(),
              child: ListView.builder(
                itemCount: portfolio.length,
                itemBuilder: (context, index) {
                  final stock = portfolio[index];
                  return Dismissible(
                    key: Key(stock.symbol),
                    direction: DismissDirection.horizontal,
                    background: _dismissBg(Alignment.centerLeft),
                    secondaryBackground: _dismissBg(Alignment.centerRight),
                    onDismissed: (_) {
                      service.removeStock(stock.symbol);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${stock.symbol} removed from portfolio'),
                        backgroundColor: const Color(0xFFef4444),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => _showStockDetail(context, stock, service),
                        child: _StockCard(stock: stock),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dismissBg(AlignmentGeometry alignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFef4444),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  void _showStockDetail(
      BuildContext context, Stock stock, PsxService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StockDetailSheet(stock: stock, service: service),
    );
  }
}

// ─── Stock Card ───────────────────────────────────────────────────────────────

class _StockCard extends StatelessWidget {
  final Stock stock;
  const _StockCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    final plColor =
        stock.profitLossPct >= 0 ? const Color(0xFF10b981) : const Color(0xFFef4444);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stock.symbol,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10b981))),
                  Text(stock.name,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white54)),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stock.tier == 'core'
                          ? Colors.blueAccent.withOpacity(0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(stock.tier.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: Colors.white30, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _col('Shares', '${stock.shares}'),
              _col('Avg Buy', 'Rs ${stock.avgBuy.toStringAsFixed(2)}'),
              _col('Current', 'Rs ${stock.price.toStringAsFixed(2)}'),
              _col(
                'P/L',
                '${stock.profitLossPct >= 0 ? '+' : ''}${stock.profitLossPct.toStringAsFixed(1)}%',
                color: plColor,
              ),
              _col('Yield', '${stock.yld.toStringAsFixed(1)}%',
                  color: const Color(0xFF10b981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _col(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }
}

// ─── Stock Detail Sheet ───────────────────────────────────────────────────────

class _StockDetailSheet extends StatefulWidget {
  final Stock stock;
  final PsxService service;
  const _StockDetailSheet({required this.stock, required this.service});

  @override
  State<_StockDetailSheet> createState() => _StockDetailSheetState();
}

class _StockDetailSheetState extends State<_StockDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PsxService>(builder: (ctx, service, _) {
      final stock =
          service.portfolio.firstWhere((s) => s.symbol == widget.stock.symbol,
              orElse: () => widget.stock);

      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0f172a),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stock.symbol,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10b981))),
                          Text(stock.name,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddTransactionDialog(context, stock),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Log'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10b981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Summary cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _summaryTile('Shares', '${stock.shares}'),
                    _summaryTile('Avg Buy', 'Rs ${stock.avgBuy.toStringAsFixed(2)}'),
                    _summaryTile('Yield', '${stock.yld.toStringAsFixed(1)}%',
                        accent: true),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _summaryTile('Invested',
                        'Rs ${stock.totalInvested.toStringAsFixed(0)}'),
                    _summaryTile('Market Val',
                        'Rs ${stock.totalValue.toStringAsFixed(0)}'),
                    _summaryTile(
                      'P/L',
                      '${stock.profitLossPct >= 0 ? '+' : ''}${stock.profitLossPct.toStringAsFixed(1)}%',
                      isNeg: stock.profitLossPct < 0,
                      accent: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Tabs
              TabBar(
                controller: _tabs,
                indicatorColor: const Color(0xFF10b981),
                labelColor: const Color(0xFF10b981),
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'Transactions'),
                  Tab(text: 'Dividends'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _TransactionList(
                        stock: stock, service: service, type: null),
                    _TransactionList(
                        stock: stock,
                        service: service,
                        type: TransactionType.dividend),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _summaryTile(String label, String value,
      {bool accent = false, bool isNeg = false}) {
    final Color c = isNeg
        ? const Color(0xFFef4444)
        : accent
            ? const Color(0xFF10b981)
            : Colors.white;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13, color: c)),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext ctx, Stock stock) {
    showDialog(
      context: ctx,
      builder: (_) => _AddTransactionDialog(
          stock: stock, service: widget.service),
    );
  }
}

// ─── Transaction List ─────────────────────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  final Stock stock;
  final PsxService service;
  final TransactionType? type; // null = buy+sell, dividend = dividend only

  const _TransactionList(
      {required this.stock, required this.service, required this.type});

  @override
  Widget build(BuildContext context) {
    final txs = stock.transactions
        .where((t) =>
            type == null
                ? t.type != TransactionType.dividend
                : t.type == TransactionType.dividend)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (txs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 40, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 10),
            Text(
              type == null
                  ? 'No buy/sell transactions yet.\nTap LOG to add one.'
                  : 'No dividends logged yet.\nTap LOG to add one.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: txs.length,
      itemBuilder: (ctx, i) {
        final tx = txs[i];
        final isBuy = tx.type == TransactionType.buy;
        final isDiv = tx.type == TransactionType.dividend;
        final color = isDiv
            ? const Color(0xFFf59e0b)
            : isBuy
                ? const Color(0xFF10b981)
                : const Color(0xFFef4444);
        final label = isDiv ? 'DIV' : isBuy ? 'BUY' : 'SELL';
        final subtitle = isDiv
            ? 'Rs ${tx.amount.toStringAsFixed(2)} received'
            : '${tx.shares} shares @ Rs ${tx.price.toStringAsFixed(2)}';

        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: const Color(0xFFef4444).withOpacity(0.2),
            child: const Icon(Icons.delete, color: Color(0xFFef4444)),
          ),
          onDismissed: (_) => service.deleteTransaction(stock.symbol, tx.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  isDiv
                      ? '+Rs ${tx.amount.toStringAsFixed(0)}'
                      : 'Rs ${tx.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Add Transaction Dialog ───────────────────────────────────────────────────

class _AddTransactionDialog extends StatefulWidget {
  final Stock stock;
  final PsxService service;
  const _AddTransactionDialog({required this.stock, required this.service});

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  TransactionType _type = TransactionType.buy;
  final _sharesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _sharesCtrl.dispose();
    _priceCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF10b981),
            onPrimary: Colors.white,
            surface: Color(0xFF1e293b),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (_type == TransactionType.dividend) {
      final amount = double.tryParse(_amountCtrl.text.trim());
      if (amount == null || amount <= 0) return;
      final tx = StockTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.dividend,
        date: _date,
        shares: 0,
        price: 0,
        amount: amount,
      );
      widget.service.addTransaction(widget.stock.symbol, tx);
    } else {
      final shares = int.tryParse(_sharesCtrl.text.trim());
      final price = double.tryParse(_priceCtrl.text.trim());
      if (shares == null || shares <= 0 || price == null || price <= 0) return;
      final tx = StockTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _type,
        date: _date,
        shares: shares,
        price: price,
        amount: shares * price,
      );
      widget.service.addTransaction(widget.stock.symbol, tx);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDiv = _type == TransactionType.dividend;

    return Dialog(
      backgroundColor: const Color(0xFF0f172a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Transaction — ${widget.stock.symbol}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),

            // Type selector
            Row(
              children: [
                _typeBtn(TransactionType.buy, 'Buy', const Color(0xFF10b981)),
                const SizedBox(width: 8),
                _typeBtn(
                    TransactionType.sell, 'Sell', const Color(0xFFef4444)),
                const SizedBox(width: 8),
                _typeBtn(TransactionType.dividend, 'Dividend',
                    const Color(0xFFf59e0b)),
              ],
            ),
            const SizedBox(height: 20),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.white54),
                    const SizedBox(width: 10),
                    Text(
                      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (!isDiv) ...[
              _field('Number of Shares', _sharesCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _field('Price per Share (Rs)', _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true)),
            ] else ...[
              _field('Total Dividend Received (Rs)', _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Transaction',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(TransactionType t, String label, Color color) {
    final selected = _type == t;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? color : Colors.white12,
                width: selected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: selected ? color : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF10b981), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

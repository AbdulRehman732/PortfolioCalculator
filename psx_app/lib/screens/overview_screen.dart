import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final invested = appState.totalInvested;
    final value = appState.marketValue;
    final annual = appState.totalAnnualDividend;
    final cash = appState.totalCashReceived;
    final goalPercent = ((annual / 200000) * 100).clamp(0.0, 100.0);
    final profit = value - invested;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your portfolio',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
              'A quick snapshot of invested capital, market value, dividends and cash you\'ve received.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                  title: 'Total Invested',
                  value: appState.formatCurrency(invested)),
              _MetricCard(
                  title: 'Market Value', value: appState.formatCurrency(value)),
              _MetricCard(
                  title: 'Annual Dividend',
                  value: appState.formatCurrency(annual),
                  accent: Colors.green),
              _MetricCard(
                  title: 'Cash Received',
                  value: appState.formatCurrency(cash),
                  accent: Colors.blue),
            ],
          ),
          const SizedBox(height: 24),
          _ProgressCard(
              progress: goalPercent,
              label: 'Progress toward goal',
              subtitle: '${goalPercent.toStringAsFixed(1)}% of ₨200,000/year'),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Current Performance'),
          const SizedBox(height: 12),
          Row(
            children: [
              _SmallMetric(
                  title: 'P&L',
                  value: appState.formatCurrency(profit),
                  valueColor: profit >= 0 ? Colors.green : Colors.red),
              const SizedBox(width: 12),
              _SmallMetric(
                  title: 'Portfolio Month',
                  value: 'Month ${appState.monthNumber}'),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Top Holdings'),
          const SizedBox(height: 12),
          Column(
            children: appState.portfolio.take(5).map((item) {
              final stock = appState.getStock(item.symbol);
              final currentValue = item.shares * stock.price;
              final pnl = currentValue - item.shares * item.avgBuy;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                title: Text('${item.symbol} • ${item.name}'),
                subtitle: Text(
                    '${item.shares} shares • Yield ${item.dpshist.toStringAsFixed(1)} / share'),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appState.formatCurrency(currentValue),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        pnl >= 0
                            ? '+${appState.formatCurrency(pnl)}'
                            : appState.formatCurrency(pnl),
                        style: TextStyle(
                            color: pnl >= 0 ? Colors.green : Colors.red)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Suggested actions'),
          const SizedBox(height: 12),
          const _RuleCard(
              color: Colors.green,
              icon: '💎',
              title: 'Reinvest dividends',
              description:
                  'Consider using dividend cash to add to core positions.'),
          const SizedBox(height: 10),
          const _RuleCard(
              color: Colors.blue,
              icon: '📰',
              title: 'Read local business news',
              description:
                  'Scan company headlines before making new purchases.'),
          const SizedBox(height: 10),
          const _RuleCard(
              color: Colors.orange,
              icon: '📅',
              title: 'Stay Consistent',
              description:
                  'SIP every month. Missing one month weakens the compounding engine.'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _SmallMetric({
    required this.title,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade400)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor)),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _MetricCard(
      {required this.title, required this.value, this.accent = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width >= 640 ? 300 : double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade400)),
          const SizedBox(height: 10),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: accent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double progress;
  final String label;
  final String subtitle;

  const _ProgressCard({
    required this.progress,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
              value: progress / 100,
              color: Colors.green,
              backgroundColor: Colors.white10,
              minHeight: 10),
          const SizedBox(height: 12),
          Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _RuleCard extends StatelessWidget {
  final Color color;
  final String icon;
  final String title;
  final String description;

  const _RuleCard(
      {required this.color,
      required this.icon,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade300)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

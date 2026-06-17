import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../widgets/glass_card.dart';

class OverviewView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PsxService>(context);
    final portfolio = service.portfolio;

    double totalValue = portfolio.fold(0, (sum, item) => sum + item.totalValue);
    double totalInvested = portfolio.fold(0, (sum, item) => sum + item.totalInvested);
    double annualDiv = portfolio.fold(0, (sum, item) => sum + item.annualDividend);
    double pnl = totalValue - totalInvested;
    double pnlPct = totalInvested > 0 ? (pnl / totalInvested) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('Total Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Rs ${totalValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10b981))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('Invested', 'Rs ${totalInvested.toStringAsFixed(2)}'),
                    _buildStat('P/L', '${pnl >= 0 ? '+' : ''}${pnl.toStringAsFixed(2)} (${pnlPct.toStringAsFixed(2)}%)',
                      color: pnl >= 0 ? Colors.greenAccent : Colors.redAccent),
                  ],
                ),
                const Divider(color: Colors.white24, height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('Annual Dividend', 'Rs ${annualDiv.toStringAsFixed(2)}', color: Colors.amber),
                    _buildStat('Avg Yield', '${((annualDiv / totalValue) * 100).toStringAsFixed(1)}%'),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color ?? Colors.white)),
      ],
    );
  }
}

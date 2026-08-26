import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../widgets/glass_card.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PsxService>(context);

    final totalValue = service.totalValue;
    final totalInvested = service.totalInvested;
    final annualDiv = service.annualDividend;
    final pnl = service.totalPnl;
    final pnlPct = service.totalPnlPct;
    final goalPct = service.goalProgressPct;
    final yld = service.portfolioYield;
    final sipMonth = service.currentSipMonth;
    final divReceived = service.totalDividendsReceived;

    return RefreshIndicator(
      color: const Color(0xFF10b981),
      backgroundColor: const Color(0xFF1e293b),
      onRefresh: () => service.refreshPrices(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              // Backend status indicator
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: service.isBackendReachable
                          ? const Color(0xFF10b981)
                          : const Color(0xFFef4444),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    service.isLoadingLivePrices
                        ? 'Updating…'
                        : service.isBackendReachable
                            ? 'Live'
                            : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: service.isBackendReachable
                          ? const Color(0xFF10b981)
                          : const Color(0xFFef4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'SIP Month $sipMonth of 84',
            style: const TextStyle(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 20),

          // ── Main Portfolio Card ───────────────────────────────────────────
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Total Portfolio Value',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${_fmt(totalValue)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10b981),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _stat('Invested', 'Rs ${_fmt(totalInvested)}'),
                    _stat(
                      'P/L',
                      '${pnl >= 0 ? '+' : ''}Rs ${_fmt(pnl.abs())} (${pnlPct.toStringAsFixed(1)}%)',
                      color: pnl >= 0 ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Dividend Cards ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Annual Dividend',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rs ${_fmt(annualDiv)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Yield ${yld.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cash Received',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rs ${_fmt(divReceived)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF60a5fa),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Dividends logged',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Goal Progress ─────────────────────────────────────────────────
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '7-Year Goal Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${goalPct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Color(0xFF10b981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goalPct / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10b981),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current: Rs ${_fmt(annualDiv)}/yr',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const Text(
                      'Target: Rs 2,00,000/yr',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Holdings List ─────────────────────────────────────────────────
          const Text(
            'Top Holdings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...service.portfolio.take(5).map((stock) {
            final pnlColor = stock.profitLossPct >= 0
                ? const Color(0xFF10b981)
                : const Color(0xFFef4444);
            final sign = stock.profitLossPct >= 0 ? '+' : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.symbol,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${stock.shares} shares • ${stock.yld.toStringAsFixed(1)}% yield',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs ${_fmt(stock.totalValue)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$sign${stock.profitLossPct.toStringAsFixed(1)}%',
                          style: TextStyle(color: pnlColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(1)}L';
    } else if (v >= 1000) {
      return v.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return v.toStringAsFixed(2);
  }
}

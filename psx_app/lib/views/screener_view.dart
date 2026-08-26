import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../data/psx_data.dart';
import '../widgets/glass_card.dart';

class ScreenerView extends StatelessWidget {
  const ScreenerView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PsxService>(context, listen: false);
    final currentPartIdx = service.currentRoadmapPartIndex;
    final sipMonth = service.currentSipMonth;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: const Color(0xFF000000),
            child: const TabBar(
              indicatorColor: Color(0xFF10b981),
              labelColor: Color(0xFF10b981),
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'Roadmap'),
                Tab(text: 'Projection'),
                Tab(text: 'Strategies'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // ── Tab 1: Roadmap ─────────────────────────────────────────
                _RoadmapTab(
                    currentPartIdx: currentPartIdx, sipMonth: sipMonth),
                // ── Tab 2: Projection ──────────────────────────────────────
                _ProjectionTab(service: service),
                // ── Tab 3: Strategies ──────────────────────────────────────
                _StrategiesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Roadmap Tab ──────────────────────────────────────────────────────────────

class _RoadmapTab extends StatelessWidget {
  final int currentPartIdx;
  final int sipMonth;

  const _RoadmapTab(
      {required this.currentPartIdx, required this.sipMonth});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('7-Year Roadmap',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF10b981).withOpacity(0.3)),
              ),
              child: Text(
                'Month $sipMonth',
                style: const TextStyle(
                  color: Color(0xFF10b981),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'SIP Rs10,000/month → ₨2 Lakh/year target in 84 months',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Part cards
        ...PsxData.roadmapParts.asMap().entries.map((entry) {
          final idx = entry.key;
          final part = entry.value;
          final isCurrent = idx == currentPartIdx;
          final isPast = idx < currentPartIdx;
          final borderColor = isCurrent
              ? const Color(0xFF10b981)
              : isPast
                  ? Colors.white12
                  : Colors.white.withOpacity(0.06);
          final bgColor = isCurrent
              ? const Color(0xFF10b981).withOpacity(0.06)
              : const Color(0xFF0f1218);

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: isCurrent ? 1.5 : 1),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Part header
                  Row(
                    children: [
                      Text(part['icon'] ?? '',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          part['label'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? const Color(0xFF10b981)
                                : Colors.white,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10b981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                                color: Color(0xFF10b981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (isPast)
                        const Icon(Icons.check_circle,
                            color: Colors.white24, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    part['months'] ?? '',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    part['theme'] ?? '',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Allocations
                  ...((part['allocs'] as List<dynamic>? ?? [])).map((a) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xFF10b981).withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${a['s']}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? const Color(0xFF10b981)
                                      : Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Rs ${a['amt']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${a['note']}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Dividend target
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('🎯',
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            part['divTarget'] ?? '',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),

        // Universal rules
        const Text('The 5 Universal Rules',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...PsxData.universalRules.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['icon'] ?? '',
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r['body'] ?? '',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Projection Tab ───────────────────────────────────────────────────────────

class _ProjectionTab extends StatelessWidget {
  final PsxService service;
  const _ProjectionTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final projection = PsxData.projection;
    final annualDiv = service.annualDividend;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('7-Year Projection',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
          'Investing Rs10,000/month + reinvesting all dividends',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 20),
        ...projection.map((p) {
          final isCurrent = p['year'] == _currentYear();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF10b981).withOpacity(0.06)
                    : const Color(0xFF0f1218),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFF10b981).withOpacity(0.4)
                      : Colors.white.withOpacity(0.06),
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p['label'] ?? 'Year ${p['year']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isCurrent
                              ? const Color(0xFF10b981)
                              : Colors.white,
                        ),
                      ),
                      if ((p['milestone'] as String).isNotEmpty)
                        Text(p['milestone']!,
                            style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _projStat('Portfolio',
                          'Rs ${_fmtK(p['portfolioVal'])}'),
                      _projStat('Annual Div',
                          'Rs ${_fmtK(p['annualDiv'])}',
                          color: Colors.amber),
                      _projStat(
                          'Monthly',
                          'Rs ${_fmtK(p['monthly'])}',
                          color: const Color(0xFF10b981)),
                    ],
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value:
                          (annualDiv / (p['annualDiv'] as num).toDouble())
                              .clamp(0, 1),
                      color: const Color(0xFF10b981),
                      backgroundColor: Colors.white10,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your actual: Rs ${annualDiv.toStringAsFixed(0)}/yr vs target Rs ${_fmtK(p['annualDiv'])}/yr',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  int _currentYear() {
    final start = DateTime(2026, 1, 1);
    final now = DateTime.now();
    final months =
        (now.year - start.year) * 12 + (now.month - start.month) + 1;
    return ((months - 1) ~/ 12) + 1;
  }

  Widget _projStat(String label, String value, {Color color = Colors.white}) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        ],
      ),
    );
  }

  String _fmtK(dynamic val) {
    final v = (val as num).toDouble();
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ─── Strategies Tab ───────────────────────────────────────────────────────────

class _StrategiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Strategy Tier List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
          'Rated from S-tier (best) to D-tier (avoid)',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 20),
        ...PsxData.tiers.map((tier) {
          final color = Color(tier['color'] as int);
          final items = tier['items'] as List<dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              color: color.withOpacity(0.05),
              border:
                  Border.all(color: color.withOpacity(0.3), width: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            tier['tier'] as String,
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tier['label'] as String,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  item['youUse'] == true
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color: item['youUse'] == true
                                      ? Colors.green
                                      : Colors.white38,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: Text(
                                item['why'] as String,
                                style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }
}

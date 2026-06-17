import 'package:flutter/material.dart';
import '../data/psx_data.dart';
import '../widgets/glass_card.dart';

class ScreenerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Strategy Tiers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: PsxData.tiers.length,
              itemBuilder: (context, index) {
                final tier = PsxData.tiers[index];
                final color = Color(tier['color']);
                final items = tier['items'] as List<dynamic>;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GlassCard(
                    color: color.withOpacity(0.05),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text(tier['tier'], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(tier['label'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(item['youUse'] ? Icons.check_circle : Icons.info_outline, 
                                    color: item['youUse'] ? Colors.green : Colors.white54, size: 16),
                                  const SizedBox(width: 8),
                                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 24.0),
                                child: Text(item['why'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              )
                            ],
                          ),
                        )).toList()
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

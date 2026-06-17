import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Consumer<PsxService>(
      builder: (context, service, child) {
        final portfolio = service.portfolio;
        double totalInvested = portfolio.fold(0, (sum, item) => sum + item.totalInvested);
        double annualDiv = portfolio.fold(0, (sum, item) => sum + item.annualDividend);
        double goalPct = (annualDiv / 200000) * 100; // Rs 2 Lakh goal

        return Container(
          color: Colors.black, // Dark background from screenshot
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Icon(Icons.trending_up, color: Color(0xFF10b981), size: 24),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PSX', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                      const Text('Dividend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                      Row(
                        children: [
                          const Text('Machine', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                          if (service.isLoadingLivePrices) ...
                            [const SizedBox(width: 6), const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF10b981)))],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              // Month 5 Current
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Month', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  Text('5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Current', style: TextStyle(fontSize: 10, color: Colors.white54)),
                ],
              ),
              
              // Invested
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Rs ${totalInvested.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Invested', style: TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
              
              // Goal
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${goalPct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10b981))),
                  const Text('Goal', style: TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

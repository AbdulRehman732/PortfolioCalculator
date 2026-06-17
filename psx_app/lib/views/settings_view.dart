import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../data/psx_data.dart';
import '../widgets/glass_card.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rules = PsxData.universalRules;
    return Consumer<PsxService>(
      builder: (context, service, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Settings & Rules',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // ── PIN ──────────────────────────────────────────────────
                GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.lock, color: Color(0xFF10b981)),
                    title: const Text('Change App PIN',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Secure your portfolio'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                    onTap: () => _showSetPinDialog(context, service),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Auto-lock ────────────────────────────────────────────
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Color(0xFF10b981)),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Auto-Lock',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Lock screen after inactivity',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        DropdownButton<int>(
                          value: service.autoLockMinutes,
                          dropdownColor: const Color(0xFF1e293b),
                          underline: const SizedBox(),
                          style: const TextStyle(
                              color: Color(0xFF10b981),
                              fontWeight: FontWeight.bold),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1 min')),
                            DropdownMenuItem(value: 2, child: Text('2 min')),
                            DropdownMenuItem(value: 5, child: Text('5 min')),
                            DropdownMenuItem(value: 10, child: Text('10 min')),
                            DropdownMenuItem(value: 0, child: Text('Never')),
                          ],
                          onChanged: (val) {
                            if (val != null) service.setAutoLockMinutes(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Rules ────────────────────────────────────────────────
                const Text('The 5 Universal Rules',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
                const SizedBox(height: 16),
                ...rules.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(r['icon'],
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(r['title'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(r['body'],
                                style: const TextStyle(
                                    color: Colors.white70, height: 1.4)),
                          ],
                        ),
                      ),
                    ))
                    .toList()
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSetPinDialog(BuildContext context, PsxService service) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Set New 4-Digit PIN'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter new PIN',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981)),
            onPressed: () {
              if (ctrl.text.length == 4) {
                service.setPin(ctrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('PIN updated successfully'),
                    backgroundColor: Colors.green));
              }
            },
            child:
                const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

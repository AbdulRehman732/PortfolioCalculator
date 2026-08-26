import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psx_service.dart';
import '../widgets/glass_card.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PsxService>(
      builder: (context, service, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // ── Security ─────────────────────────────────────────────────
              const _SectionLabel('Security'),
              const SizedBox(height: 10),

              GlassCard(
                child: ListTile(
                  leading:
                      const Icon(Icons.lock, color: Color(0xFF10b981)),
                  title: const Text('Change App PIN',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Secure your portfolio',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.white54),
                  onTap: () => _showSetPinDialog(context, service),
                ),
              ),
              const SizedBox(height: 10),

              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Color(0xFF10b981)),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auto-Lock',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('Lock after inactivity',
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
                          DropdownMenuItem(
                              value: 10, child: Text('10 min')),
                          DropdownMenuItem(
                              value: 0, child: Text('Never')),
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

              // ── Backend ───────────────────────────────────────────────────
              const _SectionLabel('Backend Connection'),
              const SizedBox(height: 10),

              _BackendConfigCard(service: service),
              const SizedBox(height: 24),

              // ── Data Management ───────────────────────────────────────────
              const _SectionLabel('Data'),
              const SizedBox(height: 10),

              GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.refresh,
                      color: Color(0xFFef4444)),
                  title: const Text('Reset Portfolio',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFef4444))),
                  subtitle: const Text(
                      'Reset to default portfolio and clear all data',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.white54),
                  onTap: () => _showResetDialog(context, service),
                ),
              ),
              const SizedBox(height: 24),

              // ── Rules ─────────────────────────────────────────────────────
              const _SectionLabel('The 5 Universal Rules'),
              const SizedBox(height: 10),
              ...const [
                _RuleCard(
                  icon: '📊',
                  title: 'Rule 1 — Price Check Every Month',
                  body:
                      'Before buying, check if the stock\'s dividend yield is still above 7%. If price ran up and yield dropped below 7%, shift that money to HUBC, FFC, or EFERT instead.',
                ),
                _RuleCard(
                  icon: '🚫',
                  title: 'Rule 2 — No New Stocks',
                  body:
                      'Stick exactly to your 9 stocks. No matter what you read on social media, WhatsApp, or financial news — do not add new stocks.',
                ),
                _RuleCard(
                  icon: '🔄',
                  title: 'Rule 3 — Reinvest Every Dividend',
                  body:
                      'When dividends arrive, reinvest within 5 days. This single rule doubles your income over 7 years.',
                ),
                _RuleCard(
                  icon: '📅',
                  title: 'Rule 4 — Never Skip a Month',
                  body:
                      'SIP works through compounding. One skipped month = 3 months of delayed progress.',
                ),
                _RuleCard(
                  icon: '📰',
                  title: 'Rule 5 — Read B.R. Daily',
                  body:
                      'Open brecorder.com every morning. Takes 10 minutes. Check company results, SBP decisions, rupee movement.',
                ),
              ],
              const SizedBox(height: 40),
            ],
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
          decoration: const InputDecoration(hintText: 'Enter new PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981)),
            onPressed: () {
              if (ctrl.text.length == 4) {
                service.setPin(ctrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, PsxService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Reset Portfolio Data',
            style:
                TextStyle(color: Color(0xFFef4444), fontWeight: FontWeight.bold)),
        content: const Text(
          'This will reset your portfolio to the default holdings and clear all transactions and dividend records. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFef4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              await service.resetData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Portfolio reset to defaults'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Reset',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Backend Config Card ──────────────────────────────────────────────────────

class _BackendConfigCard extends StatefulWidget {
  final PsxService service;
  const _BackendConfigCard({required this.service});

  @override
  State<_BackendConfigCard> createState() => _BackendConfigCardState();
}

class _BackendConfigCardState extends State<_BackendConfigCard> {
  late TextEditingController _urlCtrl;
  late TextEditingController _keyCtrl;
  bool _testing = false;
  bool? _testResult;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: widget.service.backendUrl);
    _keyCtrl = TextEditingController(text: widget.service.apiKey);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final ok = await widget.service.testConnection(
      _urlCtrl.text.trim(),
      _keyCtrl.text.trim(),
    );
    if (mounted) {
      setState(() {
        _testing = false;
        _testResult = ok;
      });
    }
  }

  Future<void> _saveConfig() async {
    await widget.service.updateBackendUrl(_urlCtrl.text.trim());
    await widget.service.updateApiKey(_keyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend connection & API Key saved!'),
          backgroundColor: Color(0xFF10b981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReachable = widget.service.isBackendReachable;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isReachable
                      ? const Color(0xFF10b981)
                      : const Color(0xFFef4444),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isReachable ? 'Connected & Verified' : 'Not reachable / Offline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isReachable
                      ? const Color(0xFF10b981)
                      : const Color(0xFFef4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Text(
            'Render Backend URL',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _urlCtrl,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'https://your-backend.onrender.com',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF10b981), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Secret API Key (X-Api-Key)',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _keyCtrl,
            obscureText: _obscureKey,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter secret API key',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.white38,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF10b981), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testing ? null : _testConnection,
                  icon: _testing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF10b981)),
                        )
                      : Icon(
                          _testResult == null
                              ? Icons.wifi_find
                              : _testResult!
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                          size: 16,
                          color: _testResult == null
                              ? Colors.white54
                              : _testResult!
                                  ? const Color(0xFF10b981)
                                  : const Color(0xFFef4444),
                        ),
                  label: Text(
                    _testing
                        ? 'Testing…'
                        : _testResult == null
                            ? 'Test Connection'
                            : _testResult!
                                ? 'Reachable ✓'
                                : 'Failed ✗',
                    style: TextStyle(
                      fontSize: 13,
                      color: _testResult == false
                          ? const Color(0xFFef4444)
                          : const Color(0xFF10b981),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _testResult == false
                          ? const Color(0xFFef4444)
                          : const Color(0xFF10b981).withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_testResult == false)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Make sure your backend is running and the URL and API Key are valid.',
                style: TextStyle(color: Color(0xFFef4444), fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.white54,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String body;
  const _RuleCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                body,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

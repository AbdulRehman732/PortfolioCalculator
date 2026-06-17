import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _backendController;
  late final TextEditingController _pinController;
  String? _message;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _backendController = TextEditingController(text: appState.backendHost);
    _pinController = TextEditingController(text: appState.appPin);
  }

  @override
  void dispose() {
    _backendController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Configure PIN locking and app reset options.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.smartphone, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Offline Mode: All data stored locally',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _pinController,
            decoration: const InputDecoration(
                labelText: 'App PIN', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    appState.setPin(_pinController.text.trim());
                    setState(() {
                      _message = 'PIN saved locally.';
                    });
                  },
                  child: const Text('Set PIN'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  appState.clearPin();
                  _pinController.clear();
                  setState(() {
                    _message = 'PIN cleared.';
                  });
                },
                child: const Text('Clear PIN'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset App Data'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => _confirmReset(context),
          ),
          if (_message != null) ...[
            const SizedBox(height: 20),
            Text(_message!, style: const TextStyle(color: Colors.greenAccent)),
          ],
          const SizedBox(height: 30),
          Text('Usage Notes',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            '• App runs entirely offline - no server required\n'
            '• All data (portfolio, transactions, dividends) saved locally\n'
            '• PIN locking is stored locally and is optional.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final appState = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset App Data'),
          content: const Text(
              'This will restore the default portfolio and remove transactions, dividends and PIN settings. Continue?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset')),
          ],
        );
      },
    );

    if (confirmed == true) {
      appState.resetData();
      _backendController.text = appState.backendHost;
      _pinController.text = appState.appPin;
      setState(() {
        _message = 'App data restored to defaults.';
      });
    }
  }
}

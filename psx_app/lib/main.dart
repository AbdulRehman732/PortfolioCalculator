import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/psx_service.dart';
import 'views/overview_view.dart';
import 'views/portfolio_view.dart';
import 'views/screener_view.dart'; // Used as Roadmap now
import 'views/buy_view.dart';
import 'views/settings_view.dart';
import 'screens/stock_search_screen_new.dart';
import 'widgets/custom_app_bar.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PsxService()),
      ],
      child: const DividendMachineApp(),
    ),
  );
}

class DividendMachineApp extends StatelessWidget {
  const DividendMachineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSX Dividend Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF0a0a0a), // Pitch black background from screenshot
        primaryColor: const Color(0xFF10b981),
        cardColor: const Color(0xFF111827), // darker slate
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFFf8fafc),
          displayColor: const Color(0xFFf8fafc),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF000000), // Pure black nav bar
          selectedItemColor: Color(0xFF10b981),
          unselectedItemColor: Color(0xFF94a3b8),
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final service = Provider.of<PsxService>(context, listen: false);
      service.checkAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PsxService>(
      builder: (context, service, child) {
        if (!service.isUnlocked) {
          return PinLockScreen();
        }
        // Wrap in Listener to reset inactivity timer on any touch
        return Listener(
          onPointerDown: (_) => service.resetInactivityTimer(),
          child: const MainTabView(),
        );
      },
    );
  }
}

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  _PinLockScreenState createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = '';

  void _onKeyPress(String val) {
    if (_pin.length < 4) {
      setState(() {
        _pin += val;
      });
      if (_pin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _submitPin() async {
    final service = Provider.of<PsxService>(context, listen: false);
    bool success = await service.unlock(_pin);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Incorrect PIN'), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Color(0xFF10b981)),
            const SizedBox(height: 24),
            const Text('Enter PIN',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? const Color(0xFF10b981)
                        : Colors.transparent,
                    border:
                        Border.all(color: const Color(0xFF10b981), width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9']
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((btn) => _buildNumpadButton(btn)).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumpadButton(''),
            _buildNumpadButton('0'),
            _buildNumpadButton('<', isDelete: true),
          ],
        )
      ],
    );
  }

  Widget _buildNumpadButton(String label, {bool isDelete = false}) {
    if (label.isEmpty) return const SizedBox(width: 80, height: 80);
    return Container(
      margin: const EdgeInsets.all(8),
      width: 64,
      height: 64,
      child: Material(
        color: Colors.white.withOpacity(0.05),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            if (isDelete)
              _onDelete();
            else
              _onKeyPress(label);
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: isDelete
                ? const Icon(Icons.backspace_outlined)
                : Text(label,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 3; // Default to Buy Tab to match screenshot

  final List<Widget> _views = [
    OverviewView(),
    PortfolioView(),
    ScreenerView(), // Roadmap
    BuyView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      floatingActionButton: _currentIndex == 3
          ? Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10b981).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const StockSearchScreen()),
                  );
                },
                backgroundColor: const Color(0xFF10b981),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            )
          : Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10b981).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const StockSearchScreen()),
                  );
                },
                backgroundColor: const Color(0xFF10b981),
                child: const Icon(Icons.search, color: Colors.white, size: 32),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.business_center_outlined),
                activeIcon: Icon(Icons.business_center),
                label: 'Portfolio'),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: 'Roadmap'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Buy'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

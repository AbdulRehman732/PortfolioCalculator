import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/transaction.dart';
import '../data/psx_data.dart';

class PsxService with ChangeNotifier {
  List<Stock> _portfolio = [];
  List<Stock> get portfolio => _portfolio;

  List<String> _favorites = [];
  List<String> get favorites => _favorites;

  bool _isUnlocked = false;
  bool get isUnlocked => _isUnlocked;

  bool _pinSetupRequired = false;
  bool get pinSetupRequired => _pinSetupRequired;

  bool _isLoadingLivePrices = false;
  bool get isLoadingLivePrices => _isLoadingLivePrices;

  // Auto-lock: timeout in minutes (0 = never)
  int _autoLockMinutes = 5;
  int get autoLockMinutes => _autoLockMinutes;
  Timer? _inactivityTimer;
  DateTime _lastInteractionTime = DateTime.now();
  Timer? _priceRefreshTimer;

  PsxService() {
    _init();
  }

  Future<void> _init() async {
    await _initPrefs();
    _fetchLivePrices();
    // Refresh prices every 5 minutes
    _priceRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _fetchLivePrices();
    });
  }

  /// Call this manually to force an immediate price refresh
  Future<void> refreshPrices() => _fetchLivePrices();

  Future<void> _savePortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _portfolio.map((stock) => stock.toJson()).toList(),
    );
    await prefs.setString('saved_portfolio', encodedData);
  }

  Future<double?> _fetchDividendFromYahoo(String symbol) async {
    try {
      final url = 'https://query1.finance.yahoo.com/v8/finance/chart/$symbol.KA?range=1y&interval=1d&events=div';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = json['chart']['result'];
        if (result != null && result.isNotEmpty) {
          final events = result[0]['events'];
          if (events != null && events['dividends'] != null) {
            final dividends = events['dividends'] as Map;
            double totalDiv = 0.0;
            dividends.forEach((key, value) {
              totalDiv += (value['amount'] as num).toDouble();
            });
            return totalDiv;
          }
        }
      }
    } catch (e) {
      debugPrint('Yahoo dividend fetch failed for $symbol: $e');
    }
    return null;
  }

  Future<void> _fetchLivePrices() async {
    _isLoadingLivePrices = true;
    notifyListeners();

    // Fetch live prices and dividends
    for (int i = 0; i < _portfolio.length; i++) {
      final symbol = _portfolio[i].symbol;
      double livePrice = _portfolio[i].price;
      
      try {
        final response = await http
            .get(Uri.parse('https://dps.psx.com.pk/company/$symbol'))
            .timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final regex = RegExp(
              r'<div class="quote__close">\s*(?:Rs\.)?([\d,]+\.?\d*)\s*</div>');
          final match = regex.firstMatch(response.body);
          if (match != null) {
            String priceStr = match.group(1)!.replaceAll(',', '');
            livePrice = double.tryParse(priceStr) ?? livePrice;
          }
        }
      } catch (e) {
        debugPrint('Failed to fetch live price for $symbol: $e');
      }

      double dpshist = _portfolio[i].dpshist;
      final fetchedDiv = await _fetchDividendFromYahoo(symbol);
      if (fetchedDiv != null && fetchedDiv > 0) {
        dpshist = fetchedDiv;
      }
      
      if (livePrice != _portfolio[i].price || dpshist != _portfolio[i].dpshist) {
        _portfolio[i] = _portfolio[i].copyWith(price: livePrice, dpshist: dpshist);
      }
    }

    _savePortfolio();
    _isLoadingLivePrices = false;
    notifyListeners();
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedPortfolio = prefs.getString('saved_portfolio');
    if (savedPortfolio != null && savedPortfolio.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(savedPortfolio);
        _portfolio = decoded.map((item) => Stock.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Failed to load portfolio: $e');
        _portfolio = List.from(PsxData.defaultPortfolio);
      }
    } else {
      _portfolio = List.from(PsxData.defaultPortfolio);
    }

    _favorites = prefs.getStringList('favorites') ?? [];
    _autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 5;
    final pin = prefs.getString('app_pin');
    if (pin == null || pin.isEmpty) {
      _pinSetupRequired = true;
      _isUnlocked = true; // No PIN set yet
    }
    notifyListeners();
  }

  Future<bool> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', newPin);
    _pinSetupRequired = false;
    _isUnlocked = true;
    notifyListeners();
    return true;
  }

  Future<bool> unlock(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('app_pin');
    if (pin == enteredPin) {
      _isUnlocked = true;
      notifyListeners();
      resetInactivityTimer();
      return true;
    }
    return false;
  }

  void lock() {
    if (!_pinSetupRequired) {
      _inactivityTimer?.cancel();
      _isUnlocked = false;
      notifyListeners();
    }
  }

  /// Call this on any user interaction to reset the inactivity countdown.
  void resetInactivityTimer() {
    _lastInteractionTime = DateTime.now();
    if (_autoLockMinutes == 0 || _pinSetupRequired) return;
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(minutes: _autoLockMinutes), () {
      lock();
    });
  }

  void checkAppResumed() {
    if (_autoLockMinutes == 0 || _pinSetupRequired || !_isUnlocked) return;
    final elapsed = DateTime.now().difference(_lastInteractionTime);
    if (elapsed.inMinutes >= _autoLockMinutes) {
      lock();
    } else {
      // resume the timer with remaining time
      _inactivityTimer?.cancel();
      _inactivityTimer = Timer(Duration(minutes: _autoLockMinutes) - elapsed, () {
        lock();
      });
    }
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    _autoLockMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auto_lock_minutes', minutes);
    resetInactivityTimer();
    notifyListeners();
  }

  Future<void> toggleFavorite(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorites.contains(symbol)) {
      _favorites.remove(symbol);
    } else {
      _favorites.add(symbol);
    }
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  bool isFavorite(String symbol) => _favorites.contains(symbol);

  // Local Search
  List<Stock> searchStocks(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return PsxData.defaultPortfolio
        .where((s) =>
            s.symbol.toLowerCase().contains(q) ||
            s.name.toLowerCase().contains(q))
        .toList();
  }

  // Portfolio Management
  void removeStock(String symbol) {
    _portfolio.removeWhere((s) => s.symbol == symbol);
    _savePortfolio();
    notifyListeners();
  }

  void addStock(Stock stock) {
    if (!_portfolio.any((s) => s.symbol == stock.symbol)) {
      _portfolio.add(stock);
      _savePortfolio();
      notifyListeners();
    }
  }

  void addTransaction(String symbol, StockTransaction tx) {
    final idx = _portfolio.indexWhere((s) => s.symbol == symbol);
    if (idx == -1) return;
    final updated = _portfolio[idx].copyWith(
      transactions: [..._portfolio[idx].transactions, tx],
    );
    _portfolio[idx] = updated;
    _savePortfolio();
    notifyListeners();
  }

  void deleteTransaction(String symbol, String txId) {
    final idx = _portfolio.indexWhere((s) => s.symbol == symbol);
    if (idx == -1) return;
    final updatedTxs = _portfolio[idx].transactions.where((t) => t.id != txId).toList();
    _portfolio[idx] = _portfolio[idx].copyWith(transactions: updatedTxs);
    _savePortfolio();
    notifyListeners();
  }

  // --- BR SCORE CALCULATOR LOGIC ---

  int calcValueIndex(ValueRatio r) {
    double score = 0;
    double weight = 0;

    if (r.de != null) {
      double s = (1 - r.de! / 2.5) * 100;
      s = s.clamp(0, 100);
      score += s * 15;
      weight += 15;
    }
    if (r.icr != null) {
      double s = (r.icr! / 25) * 100;
      s = s.clamp(0, 100);
      score += s * 15;
      weight += 15;
    }
    if (r.netDebtEbitda != null) {
      double s = ((2 - r.netDebtEbitda!) / 3) * 100;
      s = s.clamp(0, 100);
      score += s * 10;
      weight += 10;
    }
    if (r.pfcf != null) {
      double s = ((25 - r.pfcf!) / 17) * 100;
      s = s.clamp(0, 100);
      score += s * 20;
      weight += 20;
    }
    if (r.fcfYield != null) {
      double s = (r.fcfYield! / 15) * 100;
      s = s.clamp(0, 100);
      score += s * 20;
      weight += 20;
    }
    if (r.ocfRatio != null) {
      double s = (r.ocfRatio! / 2.5) * 100;
      s = s.clamp(0, 100);
      score += s * 10;
      weight += 10;
    }
    if (r.assetTurnover != null) {
      double s = (r.assetTurnover! / 2) * 100;
      s = s.clamp(0, 100);
      score += s * 5;
      weight += 5;
    }
    if (r.invTurnover != null) {
      double s = (r.invTurnover! / 12) * 100;
      s = s.clamp(0, 100);
      score += s * 5;
      weight += 5;
    }

    return weight > 0 ? (score / weight).round() : 0;
  }

  Map<String, dynamic> calcBRScore(Stock stock) {
    final r = PsxData.ratios.firstWhere((x) => x.symbol == stock.symbol,
        orElse: () =>
            ValueRatio(symbol: stock.symbol, score: 0, verdict: 'N/A'));

    if (r.verdict == 'N/A') {
      return {
        'score': 0,
        'grade': 'N/A',
        'signal': 'hold',
        'vi': 0,
        'yieldScore': 0,
        'momentumScore': 0,
        'debtScore': 0
      };
    }

    final vi = calcValueIndex(r);
    final yieldScore = (stock.yld * 9).clamp(0.0, 100.0).round();

    final priceDiff =
        stock.avgBuy > 0 ? (stock.price - stock.avgBuy) / stock.avgBuy : 0;
    int momentumScore;
    if (priceDiff < 0) {
      momentumScore = (priceDiff.abs() * 300 + 50).clamp(0.0, 100.0).round();
    } else {
      momentumScore = (80 - priceDiff * 200).clamp(0.0, 100.0).round();
    }

    int debtScore = 70;
    if (r.de != null) {
      if (r.de! < 0.5)
        debtScore = 100;
      else if (r.de! < 1)
        debtScore = 80;
      else if (r.de! < 1.5)
        debtScore = 60;
      else if (r.de! < 2)
        debtScore = 40;
      else
        debtScore = 20;
    }

    final total = (vi * 0.40 +
            yieldScore * 0.30 +
            momentumScore * 0.15 +
            debtScore * 0.15)
        .round();

    String grade = 'D';
    if (total >= 85)
      grade = 'A+';
    else if (total >= 75)
      grade = 'A';
    else if (total >= 65)
      grade = 'B+';
    else if (total >= 55)
      grade = 'B';
    else if (total >= 45) grade = 'C';

    String signal = 'HOLD';
    if (total >= 70) signal = 'BUY';

    return {
      'score': total,
      'grade': grade,
      'signal': signal,
      'vi': vi,
      'yieldScore': yieldScore,
      'momentumScore': momentumScore,
      'debtScore': debtScore
    };
  }
}

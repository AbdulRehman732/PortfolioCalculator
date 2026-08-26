import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/transaction.dart';
import '../data/psx_data.dart';

/// Default backend URL and API Key for local development.
/// Users can override these in the Settings tab.
const String kDefaultBackendUrl = 'https://psx-dividend-backend.onrender.com';
const String kDefaultApiKey = 'psx-local-dev-key';

class PsxService with ChangeNotifier {
  // ─── Portfolio ────────────────────────────────────────────────────────────
  List<Stock> _portfolio = [];
  List<Stock> get portfolio => _portfolio;

  // ─── Favorites ────────────────────────────────────────────────────────────
  List<String> _favorites = [];
  List<String> get favorites => _favorites;

  // ─── Auth / Lock ──────────────────────────────────────────────────────────
  bool _isUnlocked = false;
  bool get isUnlocked => _isUnlocked;

  bool _pinSetupRequired = false;
  bool get pinSetupRequired => _pinSetupRequired;

  // ─── Backend & Security ───────────────────────────────────────────────────
  String _backendUrl = kDefaultBackendUrl;
  String get backendUrl => _backendUrl;

  String _apiKey = kDefaultApiKey;
  String get apiKey => _apiKey;

  bool _isBackendReachable = false;
  bool get isBackendReachable => _isBackendReachable;

  bool _isLoadingLivePrices = false;
  bool get isLoadingLivePrices => _isLoadingLivePrices;

  // ─── Auto-lock ────────────────────────────────────────────────────────────
  int _autoLockMinutes = 5;
  int get autoLockMinutes => _autoLockMinutes;
  Timer? _inactivityTimer;
  DateTime _lastInteractionTime = DateTime.now();
  Timer? _priceRefreshTimer;

  // Cache for dynamic stock scores
  final Map<String, Map<String, dynamic>> _scoreCache = {};

  // ─── Request Headers ──────────────────────────────────────────────────────
  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'X-Api-Key': _apiKey,
      };

  // ─── Init ─────────────────────────────────────────────────────────────────
  PsxService() {
    _init();
  }

  Future<void> _init() async {
    await _initPrefs();
    await _checkHealth();
    await _fetchLivePrices();

    // Refresh prices every 5 minutes
    _priceRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _checkHealth();
      await _fetchLivePrices();
    });
  }

  @override
  void dispose() {
    _priceRefreshTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // ─── Backend Health & Test ────────────────────────────────────────────────

  /// Checks if the backend is reachable. Updates [isBackendReachable].
  Future<bool> _checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_backendUrl/api/health'))
          .timeout(const Duration(seconds: 8));
      _isBackendReachable = response.statusCode == 200;
    } catch (_) {
      _isBackendReachable = false;
    }
    notifyListeners();
    return _isBackendReachable;
  }

  /// Public method to test connection and API key with a given URL (used in Settings).
  Future<bool> testConnection(String url, [String? keyToTest]) async {
    try {
      final baseUrl = url.trim().trimRight();
      final sanitizedUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final key = keyToTest ?? _apiKey;

      final response = await http
          .get(
            Uri.parse('$sanitizedUrl/api/health'),
            headers: {'X-Api-Key': key},
          )
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Live Data Fetching ───────────────────────────────────────────────────

  /// Fetch a single stock's live price from the backend.
  Future<double?> fetchLivePrice(String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_backendUrl/api/stock/${symbol.toUpperCase()}/price'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['price'] as num?)?.toDouble();
      }
    } catch (e) {
      debugPrint('[PsxService] fetchLivePrice failed for $symbol: $e');
    }
    return null;
  }

  /// Fetch annual dividend per share (DPS) for a stock from backend.
  Future<double?> fetchDividend(String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_backendUrl/api/stock/${symbol.toUpperCase()}/dividend'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['dpshist'] as num?)?.toDouble();
      }
    } catch (e) {
      debugPrint('[PsxService] fetchDividend failed for $symbol: $e');
    }
    return null;
  }

  /// Fetch dynamic stock recommendation and score for any stock.
  Future<Map<String, dynamic>?> fetchStockScore(String symbol) async {
    final sym = symbol.toUpperCase();
    if (_scoreCache.containsKey(sym)) {
      return _scoreCache[sym];
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_backendUrl/api/stock/$sym/score'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _scoreCache[sym] = data;
        return data;
      }
    } catch (e) {
      debugPrint('[PsxService] fetchStockScore failed for $sym: $e');
    }
    return null;
  }

  /// Validate any PSX symbol on backend.
  Future<Map<String, dynamic>?> validateSymbol(String symbol) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/validate/symbol'),
            headers: _authHeaders,
            body: jsonEncode({'symbol': symbol.toUpperCase()}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[PsxService] validateSymbol failed: $e');
    }
    return null;
  }

  /// Bulk fetch prices for all portfolio stocks using the backend.
  Future<void> _fetchLivePrices() async {
    if (_portfolio.isEmpty) return;

    _isLoadingLivePrices = true;
    notifyListeners();

    final symbols = _portfolio.map((s) => s.symbol).toList();

    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/stocks/prices'),
            headers: _authHeaders,
            body: jsonEncode({'symbols': symbols}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = data['prices'] as Map<String, dynamic>? ?? {};

        for (int i = 0; i < _portfolio.length; i++) {
          final sym = _portfolio[i].symbol;
          if (prices.containsKey(sym)) {
            final livePrice = (prices[sym] as num).toDouble();
            if (livePrice != _portfolio[i].price) {
              _portfolio[i] = _portfolio[i].copyWith(price: livePrice);
            }
          }
        }

        _isBackendReachable = true;
        await _savePortfolio();
      }
    } catch (e) {
      debugPrint('[PsxService] _fetchLivePrices failed: $e');
      _isBackendReachable = false;
    }

    _isLoadingLivePrices = false;
    notifyListeners();
  }

  /// Public method to force an immediate price refresh (pull-to-refresh).
  Future<void> refreshPrices() async {
    await _checkHealth();
    await _fetchLivePrices();
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  Future<void> _savePortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_portfolio.map((s) => s.toJson()).toList());
    await prefs.setString('saved_portfolio', encoded);
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Load backend URL & API Key
    _backendUrl = prefs.getString('backend_url') ?? kDefaultBackendUrl;
    _apiKey = prefs.getString('api_key') ?? kDefaultApiKey;

    // Load portfolio
    final savedPortfolio = prefs.getString('saved_portfolio');
    if (savedPortfolio != null && savedPortfolio.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(savedPortfolio);
        _portfolio = decoded.map((item) => Stock.fromJson(item)).toList();
      } catch (e) {
        debugPrint('[PsxService] Failed to load portfolio: $e');
        _portfolio = List.from(PsxData.defaultPortfolio);
      }
    } else {
      _portfolio = List.from(PsxData.defaultPortfolio);
    }

    // Load favorites
    _favorites = prefs.getStringList('favorites') ?? [];

    // Load auto-lock setting
    _autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 5;

    // Load PIN state
    final pin = prefs.getString('app_pin');
    if (pin == null || pin.isEmpty) {
      _pinSetupRequired = true;
      _isUnlocked = true; // No PIN set — unlock immediately
    }

    notifyListeners();
  }

  // ─── Backend URL & API Key Management ─────────────────────────────────────

  Future<void> updateBackendUrl(String url) async {
    final trimmed = url.trim().trimRight();
    if (trimmed.isEmpty) return;
    _backendUrl = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_url', _backendUrl);
    notifyListeners();
    await _checkHealth();
  }

  Future<void> updateApiKey(String key) async {
    _apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', _apiKey);
    notifyListeners();
    await _checkHealth();
  }

  // ─── PIN / Auth ───────────────────────────────────────────────────────────

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

  // ─── Inactivity Timer ─────────────────────────────────────────────────────

  void resetInactivityTimer() {
    _lastInteractionTime = DateTime.now();
    if (_autoLockMinutes == 0 || _pinSetupRequired) return;
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(minutes: _autoLockMinutes), lock);
  }

  void checkAppResumed() {
    if (_autoLockMinutes == 0 || _pinSetupRequired || !_isUnlocked) return;
    final elapsed = DateTime.now().difference(_lastInteractionTime);
    if (elapsed.inMinutes >= _autoLockMinutes) {
      lock();
    } else {
      _inactivityTimer?.cancel();
      _inactivityTimer = Timer(
        Duration(minutes: _autoLockMinutes) - elapsed,
        lock,
      );
    }
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    _autoLockMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auto_lock_minutes', minutes);
    resetInactivityTimer();
    notifyListeners();
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

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

  // ─── Stock Search (local) ─────────────────────────────────────────────────

  List<Stock> searchStocks(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return PsxData.defaultPortfolio
        .where((s) =>
            s.symbol.toLowerCase().contains(q) ||
            s.name.toLowerCase().contains(q))
        .toList();
  }

  // ─── Portfolio Management ─────────────────────────────────────────────────

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
    final updatedTxs =
        _portfolio[idx].transactions.where((t) => t.id != txId).toList();
    _portfolio[idx] = _portfolio[idx].copyWith(transactions: updatedTxs);
    _savePortfolio();
    notifyListeners();
  }

  /// Reset portfolio to defaults and clear all saved data.
  Future<void> resetData() async {
    _portfolio = List.from(PsxData.defaultPortfolio);
    _favorites = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_portfolio');
    await prefs.remove('favorites');
    notifyListeners();
    await _fetchLivePrices();
  }

  // ─── Portfolio Calculations ───────────────────────────────────────────────

  double get totalValue =>
      _portfolio.fold(0.0, (sum, s) => sum + s.totalValue);

  double get totalInvested =>
      _portfolio.fold(0.0, (sum, s) => sum + s.totalInvested);

  double get totalPnl => totalValue - totalInvested;

  double get totalPnlPct =>
      totalInvested > 0 ? (totalPnl / totalInvested) * 100 : 0;

  double get annualDividend =>
      _portfolio.fold(0.0, (sum, s) => sum + s.annualDividend);

  double get portfolioYield =>
      totalValue > 0 ? (annualDividend / totalValue) * 100 : 0;

  double get totalDividendsReceived =>
      _portfolio.fold(0.0, (sum, s) => sum + s.totalDividendsReceived);

  /// Returns goal progress (0–100) toward ₨200,000/year dividend target.
  double get goalProgressPct => (annualDividend / 200000 * 100).clamp(0, 100);

  /// Months elapsed since SIP start date (January 2026, Month 1).
  int get currentSipMonth {
    final start = DateTime(2026, 1, 1);
    final now = DateTime.now();
    final diff = (now.year - start.year) * 12 + (now.month - start.month);
    return (diff + 1).clamp(1, 84);
  }

  /// Returns the roadmap part index (0-based) for the current SIP month.
  int get currentRoadmapPartIndex {
    final month = currentSipMonth;
    for (int i = 0; i < PsxData.roadmapParts.length; i++) {
      final range = PsxData.roadmapParts[i]['monthRange'] as List;
      if (month >= range[0] && month <= range[1]) return i;
    }
    return PsxData.roadmapParts.length - 1;
  }

  Map<String, dynamic> get currentRoadmapPart =>
      PsxData.roadmapParts[currentRoadmapPartIndex];

  // ─── BR Score & BUY/HOLD Calculator ───────────────────────────────────────

  int _calcValueIndex(ValueRatio r) {
    double score = 0;
    double weight = 0;

    void add(double? val, double w, double Function(double) scoreOf) {
      if (val == null) return;
      score += scoreOf(val).clamp(0, 100) * w;
      weight += w;
    }

    add(r.de, 15, (v) => (1 - v / 2.5) * 100);
    add(r.icr, 15, (v) => (v / 25) * 100);
    add(r.netDebtEbitda, 10, (v) => ((2 - v) / 3) * 100);
    add(r.pfcf, 20, (v) => ((25 - v) / 17) * 100);
    add(r.fcfYield, 20, (v) => (v / 15) * 100);
    add(r.ocfRatio, 10, (v) => (v / 2.5) * 100);
    add(r.assetTurnover, 5, (v) => (v / 2) * 100);
    add(r.invTurnover, 5, (v) => (v / 12) * 100);

    return weight > 0 ? (score / weight).round() : 0;
  }

  /// Calculates BUY / HOLD / AVOID score and recommendation for ANY stock.
  /// Uses detailed fundamentals if in PsxData.ratios, or dynamic yield/price logic for any custom stock.
  Map<String, dynamic> calcBRScore(Stock stock) {
    final r = PsxData.ratios.firstWhere(
      (x) => x.symbol == stock.symbol,
      orElse: () => ValueRatio(symbol: stock.symbol, score: 0, verdict: 'N/A'),
    );

    // ── Case A: Stock has full ValueRatio data (Standard PSX watchlist) ─────
    if (r.verdict != 'N/A') {
      final vi = _calcValueIndex(r);
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
        if (r.de! < 0.5) debtScore = 100;
        else if (r.de! < 1) debtScore = 80;
        else if (r.de! < 1.5) debtScore = 60;
        else if (r.de! < 2) debtScore = 40;
        else debtScore = 20;
      }

      final total =
          (vi * 0.40 + yieldScore * 0.30 + momentumScore * 0.15 + debtScore * 0.15)
              .round();

      String grade = 'D';
      if (total >= 85) grade = 'A+';
      else if (total >= 75) grade = 'A';
      else if (total >= 65) grade = 'B+';
      else if (total >= 55) grade = 'B';
      else if (total >= 45) grade = 'C';

      final signal = total >= 70 ? 'BUY' : 'HOLD';

      return {
        'score': total,
        'grade': grade,
        'signal': signal,
        'vi': vi,
        'yieldScore': yieldScore,
        'momentumScore': momentumScore,
        'debtScore': debtScore,
        'reason': signal == 'BUY' ? 'Fundamentals & yield qualify for SIP.' : 'Below 70 score threshold.',
      };
    }

    // ── Case B: Dynamic stock added by user (not in static watchlist) ───────
    final yld = stock.yld;
    int dynamicScore;
    String dynamicSignal;
    String dynamicGrade;
    String reason;

    if (yld >= 9.0) {
      dynamicSignal = 'BUY';
      dynamicGrade = 'A+';
      dynamicScore = 90 + ((yld - 9.0) * 2).clamp(0.0, 10.0).round();
      reason = 'High yield of ${yld.toStringAsFixed(1)}% (exceeds 7% SIP target). Strong candidate.';
    } else if (yld >= 7.0) {
      dynamicSignal = 'BUY';
      dynamicGrade = 'A';
      dynamicScore = 75 + ((yld - 7.0) * 7.5).clamp(0.0, 14.0).round();
      reason = 'Solid yield of ${yld.toStringAsFixed(1)}% meets 7% SIP requirement.';
    } else if (yld >= 5.0) {
      dynamicSignal = 'HOLD';
      dynamicGrade = 'B';
      dynamicScore = 55 + ((yld - 5.0) * 10).clamp(0.0, 18.0).round();
      reason = 'Yield ${yld.toStringAsFixed(1)}% is below 7% SIP minimum. Hold existing shares.';
    } else if (yld > 0) {
      dynamicSignal = 'AVOID';
      dynamicGrade = 'D';
      dynamicScore = (yld * 8).clamp(10.0, 45.0).round();
      reason = 'Low dividend yield (${yld.toStringAsFixed(1)}%). Focus capital on higher yield stocks.';
    } else {
      dynamicSignal = 'HOLD';
      dynamicGrade = 'C';
      dynamicScore = 50;
      reason = 'Yield not yet verified. Check recent dividend announcements.';
    }

    return {
      'score': dynamicScore,
      'grade': dynamicGrade,
      'signal': dynamicSignal,
      'vi': dynamicScore,
      'yieldScore': (yld * 10).clamp(0.0, 100.0).round(),
      'momentumScore': 50,
      'debtScore': 50,
      'reason': reason,
    };
  }
}

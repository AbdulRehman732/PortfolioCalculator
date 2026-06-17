import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;

  List<Stock> stocks = stockDb;
  List<PortfolioItem> portfolio = [];
  List<TransactionEntry> transactions = [];
  List<DividendEntry> dividends = [];
  List<String> favorites = defaultFavorites;
  String backendHost = defaultBackendHost;
  String appPin = '';
  bool isReady = false;

  AppState._(this.prefs) {
    _load();
  }

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppState._(prefs);
  }

  void _load() {
    portfolio = _decodeList<PortfolioItem>(
      prefs.getString('portfolio'),
      (json) => PortfolioItem.fromJson(json),
    );
    if (portfolio.isEmpty) {
      portfolio = defaultPortfolio
          .map(
            (item) => PortfolioItem(
              symbol: item.symbol,
              name: item.name,
              sector: item.sector,
              tier: item.tier,
              shares: item.shares,
              avgBuy: item.avgBuy,
              dpshist: item.dpshist,
            ),
          )
          .toList();
    }

    transactions = _decodeList<TransactionEntry>(
      prefs.getString('transactions'),
      (json) => TransactionEntry.fromJson(json),
    );
    dividends = _decodeList<DividendEntry>(
      prefs.getString('dividends'),
      (json) => DividendEntry.fromJson(json),
    );
    favorites = _decodeListString(prefs.getString('favorites'));
    if (favorites.isEmpty) {
      favorites = defaultFavorites;
    }

    backendHost = prefs.getString('backendHost') ?? defaultBackendHost;
    appPin = prefs.getString('appPin') ?? '';
    isReady = true;
    notifyListeners();
  }

  void _save() {
    prefs.setString(
      'portfolio',
      jsonEncode(portfolio.map((item) => item.toJson()).toList()),
    );
    prefs.setString(
      'transactions',
      jsonEncode(transactions.map((item) => item.toJson()).toList()),
    );
    prefs.setString(
      'dividends',
      jsonEncode(dividends.map((item) => item.toJson()).toList()),
    );
    prefs.setString('favorites', jsonEncode(favorites));
    prefs.setString('backendHost', backendHost);
    prefs.setString('appPin', appPin);
  }

  List<T> _decodeList<T>(
    String? jsonString,
    T Function(Map<String, dynamic>) builder,
  ) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final items = jsonDecode(jsonString) as List<dynamic>;
      return items.whereType<Map<String, dynamic>>().map(builder).toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _decodeListString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final items = jsonDecode(jsonString) as List<dynamic>;
      return items.whereType<String>().toList();
    } catch (_) {
      return [];
    }
  }

  Stock getStock(String symbol) {
    final normalized = symbol.toUpperCase();
    return stocks.firstWhere(
      (stock) => stock.symbol == normalized,
      orElse: () => Stock(
        symbol: normalized,
        name: normalized,
        sector: 'Unknown',
        price: 0.0,
      ),
    );
  }

  PortfolioItem? findPortfolio(String symbol) {
    final normalized = symbol.toUpperCase();
    for (final item in portfolio) {
      if (item.symbol == normalized) return item;
    }
    return null;
  }

  double get totalInvested =>
      portfolio.fold(0.0, (sum, item) => sum + item.shares * item.avgBuy);

  double get marketValue => portfolio.fold(0.0, (sum, item) {
        final stock = stocks.firstWhere(
          (s) => s.symbol == item.symbol,
          orElse: () => Stock(
            symbol: item.symbol,
            name: item.name,
            sector: item.sector,
            price: item.avgBuy,
          ),
        );
        return sum + item.shares * stock.price;
      });

  double get totalAnnualDividend =>
      portfolio.fold(0.0, (sum, item) => sum + item.shares * item.dpshist);

  double get totalCashReceived =>
      dividends.fold(0.0, (sum, entry) => sum + entry.amount);

  int get monthNumber {
    final start = DateTime(2026, 1, 1);
    final now = DateTime.now();
    final diff = (now.year - start.year) * 12 + now.month - start.month;
    return diff + 1;
  }

  void addBuy({
    required String symbol,
    required int shares,
    required double price,
  }) {
    final normalized = symbol.toUpperCase();
    if (shares <= 0 || price <= 0) return;

    final existing =
        portfolio.where((item) => item.symbol == normalized).toList();
    if (existing.isNotEmpty) {
      final item = existing.first;
      final totalCost = item.avgBuy * item.shares + price * shares;
      item.shares += shares;
      item.avgBuy = totalCost / item.shares;
    } else {
      final stock = getStock(normalized);
      portfolio.add(
        PortfolioItem(
          symbol: normalized,
          name: stock.name,
          sector: stock.sector,
          tier: 'small',
          shares: shares,
          avgBuy: price,
          dpshist:
              stock.dividendYield != null ? stock.dividendYield! * 0.1 : 0.0,
        ),
      );
    }

    transactions.insert(
      0,
      TransactionEntry(
        symbol: normalized,
        type: 'buy',
        shares: shares,
        price: price,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
    _save();
    notifyListeners();
  }

  void addSell({
    required String symbol,
    required int shares,
    required double price,
  }) {
    final normalized = symbol.toUpperCase();
    final item = findPortfolio(normalized);
    if (item == null || shares <= 0) return;
    if (shares >= item.shares) {
      portfolio.removeWhere((entry) => entry.symbol == normalized);
    } else {
      item.shares -= shares;
    }

    transactions.insert(
      0,
      TransactionEntry(
        symbol: normalized,
        type: 'sell',
        shares: shares,
        price: price,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
    _save();
    notifyListeners();
  }

  void addDividend({
    required String symbol,
    required double amount,
    String note = '',
  }) {
    final normalized = symbol.toUpperCase();
    dividends.insert(
      0,
      DividendEntry(
        symbol: normalized,
        amount: amount,
        note: note,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
    _save();
    notifyListeners();
  }

  void updateBackendHost(String host) {
    if (host.isEmpty) return;
    backendHost = host;
    _save();
    notifyListeners();
  }

  void setPin(String pin) {
    appPin = pin;
    prefs.setString('appPin', appPin);
    notifyListeners();
  }

  void clearPin() {
    appPin = '';
    prefs.remove('appPin');
    notifyListeners();
  }

  void resetData() {
    portfolio = defaultPortfolio
        .map((item) => PortfolioItem(
              symbol: item.symbol,
              name: item.name,
              sector: item.sector,
              tier: item.tier,
              shares: item.shares,
              avgBuy: item.avgBuy,
              dpshist: item.dpshist,
            ))
        .toList();
    transactions = [];
    dividends = [];
    favorites = defaultFavorites;
    backendHost = defaultBackendHost;
    appPin = '';
    _save();
    notifyListeners();
  }

  Future<Stock?> fetchStockDetails(String symbol) async {
    final normalized = symbol.toUpperCase();
    // Offline mode: use local data only
    final local = stocks.firstWhere(
      (s) => s.symbol == normalized,
      orElse: () => Stock(
        symbol: normalized,
        name: normalized,
        sector: 'Unknown',
        price: 0.0,
      ),
    );
    return local;
  }

  Future<NewsAnalysis> fetchNewsAnalysis(String symbol) async {
    final normalized = symbol.toUpperCase();
    // Offline mode: use local analysis only
    final stock = getStock(normalized);
    return NewsAnalysis(
      symbol: normalized,
      overallSentiment: 'Neutral',
      impactExplanation: 'App running in offline mode. All data is local.',
      articles: [
        NewsArticle(
          title: '${stock.name} - Local Analysis',
          pubDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          sentiment: 'Neutral',
          score: 0,
          summary: 'Using local cached data. No external connections needed.',
          link: '',
        ),
      ],
    );
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_PK',
      symbol: '₨',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}

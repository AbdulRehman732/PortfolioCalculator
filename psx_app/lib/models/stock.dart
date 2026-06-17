import 'transaction.dart';

class Stock {
  final String symbol;
  final String name;
  final String tier;
  final double price;
  final double dpshist;
  final String sector;
  final List<StockTransaction> transactions;

  // Optionally overridden; if null, derived from transactions
  final int? _sharesOverride;
  final double? _avgBuyOverride;

  Stock({
    required this.symbol,
    required this.name,
    required this.tier,
    required this.price,
    required this.dpshist,
    required this.sector,
    List<StockTransaction>? transactions,
    int? sharesOverride,
    double? avgBuyOverride,
  })  : transactions = transactions ?? [],
        _sharesOverride = sharesOverride,
        _avgBuyOverride = avgBuyOverride;

  // Derive shares from transactions
  int get shares {
    if (_sharesOverride != null) return _sharesOverride!;
    int total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.buy) total += t.shares;
      if (t.type == TransactionType.sell) total -= t.shares;
    }
    return total < 0 ? 0 : total;
  }

  // Derive average buy price from transactions (FIFO-weighted average)
  double get avgBuy {
    if (_avgBuyOverride != null) return _avgBuyOverride!;
    double totalCost = 0;
    int totalShares = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.buy) {
        totalCost += t.shares * t.price;
        totalShares += t.shares;
      }
    }
    return totalShares > 0 ? totalCost / totalShares : 0;
  }

  double get totalValue => shares * price;
  double get totalInvested => shares * avgBuy;
  double get profitLoss => totalValue - totalInvested;
  double get profitLossPct => totalInvested > 0 ? (profitLoss / totalInvested) * 100 : 0;
  double get yld => price > 0 ? (dpshist / price) * 100 : 0;
  double get annualDividend => shares * dpshist;

  // Total dividends actually received (from logged dividend transactions)
  double get totalDividendsReceived =>
      transactions.where((t) => t.type == TransactionType.dividend).fold(0.0, (sum, t) => sum + t.amount);

  Stock copyWith({
    String? symbol,
    String? name,
    String? tier,
    double? price,
    double? dpshist,
    String? sector,
    List<StockTransaction>? transactions,
    int? sharesOverride,
    double? avgBuyOverride,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      tier: tier ?? this.tier,
      price: price ?? this.price,
      dpshist: dpshist ?? this.dpshist,
      sector: sector ?? this.sector,
      transactions: transactions ?? List.from(this.transactions),
      sharesOverride: sharesOverride,
      avgBuyOverride: avgBuyOverride,
    );
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    final txList = (json['transactions'] as List<dynamic>?)
        ?.map((e) => StockTransaction.fromJson(e as Map<String, dynamic>))
        .toList();

    // Legacy support: if no transactions, use override fields from old saves
    return Stock(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      tier: json['tier'] ?? 'secondary',
      price: (json['price'] ?? 0).toDouble(),
      dpshist: (json['dpshist'] ?? 0).toDouble(),
      sector: json['sector'] ?? '',
      transactions: txList ?? [],
      sharesOverride: txList == null || txList.isEmpty ? json['shares'] as int? : null,
      avgBuyOverride: txList == null || txList.isEmpty ? (json['avgBuy'] as num?)?.toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'tier': tier,
      'price': price,
      'dpshist': dpshist,
      'sector': sector,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}

class ValueRatio {
  final String symbol;
  final double? de;
  final double? icr;
  final double? netDebtEbitda;
  final double? pfcf;
  final double? fcfYield;
  final double? ocfRatio;
  final double? assetTurnover;
  final double? invTurnover;
  final int score;
  final String verdict;

  ValueRatio({
    required this.symbol,
    this.de,
    this.icr,
    this.netDebtEbitda,
    this.pfcf,
    this.fcfYield,
    this.ocfRatio,
    this.assetTurnover,
    this.invTurnover,
    required this.score,
    required this.verdict,
  });
}

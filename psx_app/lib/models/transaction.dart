enum TransactionType { buy, sell, dividend }

class StockTransaction {
  final String id;
  final TransactionType type;
  final DateTime date;
  final int shares;       // number of shares (0 for dividend)
  final double price;     // price per share for buy/sell, total payout for dividend
  final double amount;    // total cash amount

  StockTransaction({
    required this.id,
    required this.type,
    required this.date,
    required this.shares,
    required this.price,
    required this.amount,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.buy,
      ),
      date: DateTime.parse(json['date']),
      shares: json['shares'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'shares': shares,
      'price': price,
      'amount': amount,
    };
  }
}

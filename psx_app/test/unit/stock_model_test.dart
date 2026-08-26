import 'package:flutter_test/flutter_test.dart';
import 'package:psx_dividend_machine/models/stock.dart';
import 'package:psx_dividend_machine/models/transaction.dart';

void main() {
  group('Stock Model Tests', () {
    test('Calculates totalValue, totalInvested, and PnL correctly', () {
      final stock = Stock(
        symbol: 'FFC',
        name: 'Fauji Fertilizer Co',
        sector: 'Fertilizer',
        price: 500.0,
        tier: 'primary',
        dpshist: 45.0,
        transactions: [
          StockTransaction(
            id: '1',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 1),
            shares: 10,
            price: 400.0,
            amount: 4000.0,
          ),
          StockTransaction(
            id: '2',
            type: TransactionType.buy,
            date: DateTime(2026, 2, 1),
            shares: 10,
            price: 450.0,
            amount: 4500.0,
          ),
        ],
      );

      // Total Shares: 20
      expect(stock.shares, 20);
      // Total Invested: (10*400) + (10*450) = 4000 + 4500 = 8500
      expect(stock.totalInvested, 8500.0);
      // Average Buy Price: 8500 / 20 = 425.0
      expect(stock.avgBuy, 425.0);
      // Current Value: 20 * 500.0 = 10000.0
      expect(stock.totalValue, 10000.0);
      // Profit / Loss: 10000 - 8500 = +1500.0
      expect(stock.profitLoss, 1500.0);
      // PnL %: (1500 / 8500) * 100 = 17.647%
      expect(stock.profitLossPct, closeTo(17.65, 0.05));
      // Annual Dividend: 20 * 45.0 = 900.0
      expect(stock.annualDividend, 900.0);
      // Dividend Yield %: (45 / 500) * 100 = 9.0%
      expect(stock.yld, 9.0);
    });

    test('Handles zero shares safely without division by zero', () {
      final stock = Stock(
        symbol: 'HUBC',
        name: 'Hub Power Company',
        sector: 'Energy',
        price: 200.0,
        tier: 'primary',
        dpshist: 20.0,
        transactions: [],
      );

      expect(stock.shares, 0);
      expect(stock.totalInvested, 0.0);
      expect(stock.avgBuy, 0.0);
      expect(stock.totalValue, 0.0);
      expect(stock.profitLoss, 0.0);
      expect(stock.profitLossPct, 0.0);
      expect(stock.annualDividend, 0.0);
      expect(stock.yld, 10.0); // (20 / 200) * 100 = 10%
    });

    test('Serializes to JSON and deserializes accurately', () {
      final original = Stock(
        symbol: 'OGDC',
        name: 'Oil & Gas Dev Co',
        sector: 'Energy',
        price: 300.0,
        tier: 'primary',
        dpshist: 25.0,
      );

      final json = original.toJson();
      final restored = Stock.fromJson(json);

      expect(restored.symbol, original.symbol);
      expect(restored.name, original.name);
      expect(restored.sector, original.sector);
      expect(restored.price, original.price);
      expect(restored.dpshist, original.dpshist);
      expect(restored.tier, original.tier);
    });
  });
}

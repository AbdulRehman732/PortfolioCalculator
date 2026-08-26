import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psx_dividend_machine/services/psx_service.dart';
import 'package:psx_dividend_machine/models/stock.dart';
import 'package:psx_dividend_machine/data/psx_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PsxService Tests', () {
    test('PsxData has default portfolio and ratio entries', () {
      expect(PsxData.defaultPortfolio.isNotEmpty, true);
      expect(PsxData.ratios.isNotEmpty, true);
      expect(PsxData.roadmapParts.length, 8);
    });

    test('calcBRScore evaluates high-yield stocks as BUY', () {
      final service = PsxService();
      final stock = Stock(
        symbol: 'FFC',
        name: 'Fauji Fertilizer Co',
        sector: 'Fertilizer',
        price: 540.0,
        tier: 'primary',
        dpshist: 55.0,
      );

      final result = service.calcBRScore(stock);
      expect(result['score'], greaterThanOrEqualTo(70));
      expect(result['signal'], 'BUY');
    });

    test('calcBRScore handles custom added dynamic stocks accurately', () {
      final service = PsxService();

      // Case 1: High yield custom stock (>9%) -> BUY (A+)
      final customStockA = Stock(
        symbol: 'CUSTOM1',
        name: 'Custom High Yield',
        sector: 'Energy',
        price: 100.0,
        tier: 'secondary',
        dpshist: 10.0, // 10% yield
      );
      final scoreA = service.calcBRScore(customStockA);
      expect(scoreA['signal'], 'BUY');
      expect(scoreA['grade'], 'A+');

      // Case 2: Moderate yield custom stock (5-7%) -> HOLD (B)
      final customStockB = Stock(
        symbol: 'CUSTOM2',
        name: 'Custom Moderate Yield',
        sector: 'Textile',
        price: 100.0,
        tier: 'secondary',
        dpshist: 6.0, // 6% yield
      );
      final scoreB = service.calcBRScore(customStockB);
      expect(scoreB['signal'], 'HOLD');

      // Case 3: Low yield custom stock (<5%) -> AVOID (D)
      final customStockC = Stock(
        symbol: 'CUSTOM3',
        name: 'Custom Low Yield',
        sector: 'Tech',
        price: 100.0,
        tier: 'secondary',
        dpshist: 2.0, // 2% yield
      );
      final scoreC = service.calcBRScore(customStockC);
      expect(scoreC['signal'], 'AVOID');
    });

    test('Roadmap part index and SIP month calculate valid values', () {
      final service = PsxService();
      expect(service.currentSipMonth, greaterThanOrEqualTo(1));
      expect(service.currentRoadmapPartIndex, inInclusiveRange(0, 7));
      expect(service.currentRoadmapPart, isNotNull);
    });
  });
}

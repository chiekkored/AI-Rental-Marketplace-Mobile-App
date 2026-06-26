import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/rates.model.dart';

void main() {
  group('Rates', () {
    test('serializes full pricing model', () {
      final rates = Rates(
        daily: 100,
        weekly: 650,
        monthly: 2500,
        annually: 25000,
      );

      expect(rates.toMap(), {
        'daily': 100,
        'weekly': 650,
        'monthly': 2500,
        'annually': 25000,
        'notes': null,
        'currency': null,
      });
    });

    test('deserializes optional rates and currency independently', () {
      final rates = Rates.fromMap({
        'daily': 100,
        'weekly': null,
        'monthly': 2500,
        'annually': null,
        'notes': null,
        'currency': 'PHP',
      });

      expect(rates.daily, 100);
      expect(rates.weekly, isNull);
      expect(rates.monthly, 2500);
      expect(rates.annually, isNull);
      expect(rates.currency, 'PHP');
    });
  });
}

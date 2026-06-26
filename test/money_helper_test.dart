import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

void main() {
  group('LNDMoney', () {
    test('formats explicit currency codes', () {
      expect(LNDMoney.format(1500, currencyCode: 'USD'), 'USD 1,500');
    });

    test('formats rates with stored currency', () {
      expect(LNDMoney.formatRate(1500, Rates(currency: 'JPY')), 'JPY 1,500');
    });

    test('falls back to PHP when no country preference is registered', () {
      expect(LNDMoney.format(1500), 'PHP 1,500');
    });
  });
}

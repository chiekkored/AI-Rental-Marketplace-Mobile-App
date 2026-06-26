import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/utilities/helpers/currency.helper.dart';

class LNDMoney {
  LNDMoney._();

  static String currentCurrencyCode() {
    if (Get.isRegistered<CountryPreferenceController>()) {
      final code =
          CountryPreferenceController
              .instance
              .currencyCountry
              .value
              .currencyCode
              .trim();
      if (code.isNotEmpty) return code;
    }
    return LNDCurrency.fallbackCurrencyCode;
  }

  static String currencyCodeFromRates(Rates? rates) {
    final code = rates?.currency?.trim();
    return code?.isNotEmpty == true ? code! : currentCurrencyCode();
  }

  static String format(num? amount, {String? currencyCode}) {
    if (amount == null) return '';
    final code =
        currencyCode?.trim().isNotEmpty == true
            ? currencyCode!.trim()
            : currentCurrencyCode();
    return '$code ${NumberFormat('#,##0.00').format(amount)}';
  }

  static String formatRate(num? amount, Rates? rates) {
    return format(amount, currencyCode: currencyCodeFromRates(rates));
  }
}

import 'package:get/get.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/utilities/helpers/country_data.helper.dart';

class LNDCurrency {
  LNDCurrency._();

  static const String fallbackCurrencyCode = 'PHP';
  static const String paymongoFixedFeeCurrencyCode = 'PHP';

  static String fromLocation(Location? location) {
    final code =
        LNDCountryData.countryFromLocation(location).currencyCode.trim();
    return code.isEmpty ? fallbackCurrencyCode : code;
  }

  static String selectedDisplayCurrency() {
    if (!Get.isRegistered<CountryPreferenceController>()) {
      return fallbackCurrencyCode;
    }
    final code =
        CountryPreferenceController.instance.currencyCountry.value.currencyCode
            .trim();
    return code.isEmpty ? fallbackCurrencyCode : code;
  }

  static bool hasMismatchWithSelectedCurrency(Location? location) {
    return fromLocation(location) != selectedDisplayCurrency();
  }
}

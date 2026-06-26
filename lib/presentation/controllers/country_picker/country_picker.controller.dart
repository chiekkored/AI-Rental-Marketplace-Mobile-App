import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/country_option.model.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/utilities/helpers/country_data.helper.dart';

enum CountryPickerMode { phoneIdd, currency }

class CountryPickerPageArgs {
  final CountryPickerMode mode;

  const CountryPickerPageArgs({required this.mode});
}

class CountryPickerController extends GetxController {
  final searchController = TextEditingController();
  final RxString query = ''.obs;

  CountryPickerPageArgs get args =>
      Get.arguments as CountryPickerPageArgs? ??
      const CountryPickerPageArgs(mode: CountryPickerMode.phoneIdd);

  CountryPickerMode get mode => args.mode;
  bool get isCurrencyMode => mode == CountryPickerMode.currency;
  String get title => isCurrencyMode ? 'Currency' : 'Phone country code';
  String get searchHint =>
      isCurrencyMode ? 'Search country or currency' : 'Search country or code';

  List<CountryOption> get filteredCountries =>
      LNDCountryData.search(query: query.value, currencyOnly: isCurrencyMode);

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => query.value = searchController.text);
  }

  @override
  void onClose() {
    searchController.dispose();
    query.close();
    super.onClose();
  }

  Future<void> selectCountry(CountryOption option) async {
    if (isCurrencyMode) {
      await CountryPreferenceController.instance.setCurrencyCountry(option);
    } else {
      await CountryPreferenceController.instance.setIddCountry(option);
    }
    Get.back(result: option);
  }
}

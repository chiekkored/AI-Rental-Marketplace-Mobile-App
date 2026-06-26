import 'package:get/get.dart';
import 'package:lend/core/models/country_option.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/country_data.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class CountryPreferenceController extends GetxController {
  static CountryPreferenceController get instance =>
      Get.find<CountryPreferenceController>();

  final Rx<CountryOption> iddCountry = LNDCountryData.fallbackCountry.obs;
  final Rx<CountryOption> currencyCountry = LNDCountryData.fallbackCountry.obs;
  final RxBool _isCurrencyCountryLoading = true.obs;

  bool _hasIddOverride = false;
  bool _hasCurrencyOverride = false;

  bool get isCurrencyCountryLoading => _isCurrencyCountryLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadStoredPreferences();
  }

  @override
  void onClose() {
    iddCountry.close();
    currencyCountry.close();
    _isCurrencyCountryLoading.close();
    super.onClose();
  }

  void _loadStoredPreferences() {
    try {
      final iddCode = LNDStorageService.read<String>(
        LNDStorageConstants.selectedIddCountryCode,
      );
      final currencyCountryCode = LNDStorageService.read<String>(
        LNDStorageConstants.selectedCurrencyCountryCode,
      );

      _hasIddOverride = iddCode?.trim().isNotEmpty == true;
      _hasCurrencyOverride = currencyCountryCode?.trim().isNotEmpty == true;

      if (_hasIddOverride) {
        iddCountry.value = LNDCountryData.countryFromCode(iddCode);
      }
      if (_hasCurrencyOverride) {
        currencyCountry.value = LNDCountryData.countryFromCode(
          currencyCountryCode,
        );
      }
    } finally {
      _isCurrencyCountryLoading.value = false;
    }
  }

  void maybeAutoDetectFromLocation(Location? location) {
    final detected =
        location == null
            ? LNDCountryData.fallbackCountry
            : LNDCountryData.countryFromLocation(location);

    if (!_hasIddOverride) iddCountry.value = detected;
    if (!_hasCurrencyOverride) currencyCountry.value = detected;
  }

  Future<void> syncHomeLocation(Location? location) async {
    _isCurrencyCountryLoading.value = true;
    try {
      final detected =
          location == null
              ? LNDCountryData.fallbackCountry
              : LNDCountryData.countryFromLocation(location);

      if (!_hasIddOverride) iddCountry.value = detected;
      if (!_hasCurrencyOverride) {
        await _saveCurrencyCountry(detected, markOverride: false);
      }
    } finally {
      _isCurrencyCountryLoading.value = false;
    }
  }

  Future<void> setIddCountry(CountryOption option) async {
    _hasIddOverride = true;
    iddCountry.value = option;
    await LNDStorageService.write(
      LNDStorageConstants.selectedIddCountryCode,
      option.countryCode,
    );
  }

  Future<void> setCurrencyCountry(CountryOption option) async {
    await _saveCurrencyCountry(option);
  }

  Future<void> _saveCurrencyCountry(
    CountryOption option, {
    bool markOverride = true,
  }) async {
    if (markOverride) _hasCurrencyOverride = true;
    currencyCountry.value = option;
    await Future.wait([
      LNDStorageService.write(
        LNDStorageConstants.selectedCurrencyCountryCode,
        option.countryCode,
      ),
      LNDStorageService.write(
        LNDStorageConstants.selectedCurrencyCode,
        option.currencyCode,
      ),
    ]);
  }

  Future<void> openIddPicker() async {
    await LNDNavigate.toCountryIddPickerPage();
  }

  Future<void> openCurrencyPicker() async {
    await LNDNavigate.toCountryCurrencyPickerPage();
  }
}

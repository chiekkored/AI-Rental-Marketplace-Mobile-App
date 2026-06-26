import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return '.';
          }
          return null;
        });
  });

  setUp(() async {
    Get.testMode = true;
    await GetStorage.init();
    await LNDStorageService.clear();
  });

  tearDown(() async {
    await LNDStorageService.clear();
    Get.reset();
  });

  group('CountryPreferenceController', () {
    test('home location overwrites saved currency preference', () async {
      await LNDStorageService.write(
        LNDStorageConstants.selectedCurrencyCountryCode,
        'JP',
      );
      await LNDStorageService.write(
        LNDStorageConstants.selectedCurrencyCode,
        'JPY',
      );

      final controller = Get.put(CountryPreferenceController());

      expect(controller.currencyCountry.value.currencyCode, 'JPY');

      await controller.syncHomeLocation(
        Location(country: 'United States', countryShortName: 'US'),
      );

      expect(controller.currencyCountry.value.countryCode, 'US');
      expect(controller.currencyCountry.value.currencyCode, 'USD');
      expect(
        LNDStorageService.read<String>(
          LNDStorageConstants.selectedCurrencyCountryCode,
        ),
        'US',
      );
      expect(
        LNDStorageService.read<String>(
          LNDStorageConstants.selectedCurrencyCode,
        ),
        'USD',
      );
    });

    test('home location keeps saved IDD preference', () async {
      await LNDStorageService.write(
        LNDStorageConstants.selectedIddCountryCode,
        'JP',
      );

      final controller = Get.put(CountryPreferenceController());

      await controller.syncHomeLocation(
        Location(country: 'United States', countryShortName: 'US'),
      );

      expect(controller.iddCountry.value.countryCode, 'JP');
      expect(controller.currencyCountry.value.currencyCode, 'USD');
    });
  });
}

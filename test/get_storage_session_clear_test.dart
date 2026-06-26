import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lend/core/services/get_storage.service.dart';
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
    await GetStorage.init();
    await LNDStorageService.clear();
  });

  tearDown(() async {
    await LNDStorageService.clear();
  });

  test('clearSessionData preserves biometrics and app preferences', () async {
    await LNDStorageService.write(LNDStorageConstants.themeMode, 'dark');
    await LNDStorageService.write(LNDStorageConstants.enableBiometrics, true);
    await LNDStorageService.write(
      LNDStorageConstants.selectedIddCountryCode,
      'US',
    );
    await LNDStorageService.write(
      LNDStorageConstants.selectedCurrencyCountryCode,
      'US',
    );
    await LNDStorageService.write(
      LNDStorageConstants.selectedCurrencyCode,
      'USD',
    );
    await LNDStorageService.write(
      LNDStorageConstants.hideQrTransactionReminder,
      true,
    );
    await LNDStorageService.write(LNDStorageConstants.onboardingComplete, true);

    await LNDStorageService.write(LNDStorageConstants.assets, ['asset']);
    await LNDStorageService.write(LNDStorageConstants.recentlyViewedAssets, [
      'recent',
    ]);
    await LNDStorageService.write(LNDStorageConstants.searchHistory, [
      'camera',
    ]);
    await LNDStorageService.write(
      '${LNDStorageConstants.createListingDraft}_uid',
      {'draft': true},
    );
    await LNDStorageService.write(
      '${LNDStorageConstants.homeRecommendationRailCachePrefix}:uid',
      {'cachedAt': 1, 'assets': []},
    );

    await LNDStorageService.clearSessionData();

    expect(
      LNDStorageService.read<String>(LNDStorageConstants.themeMode),
      'dark',
    );
    expect(
      LNDStorageService.read<bool>(LNDStorageConstants.enableBiometrics),
      true,
    );
    expect(
      LNDStorageService.read<String>(
        LNDStorageConstants.selectedIddCountryCode,
      ),
      'US',
    );
    expect(
      LNDStorageService.read<String>(
        LNDStorageConstants.selectedCurrencyCountryCode,
      ),
      'US',
    );
    expect(
      LNDStorageService.read<String>(LNDStorageConstants.selectedCurrencyCode),
      'USD',
    );
    expect(
      LNDStorageService.read<bool>(
        LNDStorageConstants.hideQrTransactionReminder,
      ),
      true,
    );
    expect(
      LNDStorageService.read<bool>(LNDStorageConstants.onboardingComplete),
      true,
    );

    expect(LNDStorageService.read(LNDStorageConstants.assets), isNull);
    expect(
      LNDStorageService.read(LNDStorageConstants.recentlyViewedAssets),
      isNull,
    );
    expect(LNDStorageService.read(LNDStorageConstants.searchHistory), isNull);
    expect(
      LNDStorageService.read('${LNDStorageConstants.createListingDraft}_uid'),
      isNull,
    );
    expect(
      LNDStorageService.read(
        '${LNDStorageConstants.homeRecommendationRailCachePrefix}:uid',
      ),
      isNull,
    );
  });
}

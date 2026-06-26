import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/recommendation.service.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';

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

  group('LNDRecommendationService rail cache', () {
    test('returns fresh cached assets', () async {
      final location = _location();
      final asset = _asset('asset-1');

      await LNDRecommendationService.writeCachedRail(
        rail: HomeRecommendationRail.recommended,
        userId: 'user-1',
        location: location,
        currencyCode: 'PHP',
        assets: [asset],
      );

      final cached = LNDRecommendationService.readCachedRail(
        rail: HomeRecommendationRail.recommended,
        userId: 'user-1',
        location: location,
        currencyCode: 'PHP',
      );

      expect(cached, isNotNull);
      expect(cached!.assets, hasLength(1));
      expect(cached.assets.single.id, asset.id);
    });

    test('returns fresh empty cache entries', () async {
      final location = _location();

      await LNDRecommendationService.writeCachedRail(
        rail: HomeRecommendationRail.recommended,
        userId: 'user-1',
        location: location,
        currencyCode: 'PHP',
        assets: [],
      );

      final cached = LNDRecommendationService.readCachedRail(
        rail: HomeRecommendationRail.recommended,
        userId: 'user-1',
        location: location,
        currencyCode: 'PHP',
      );

      expect(cached, isNotNull);
      expect(cached!.assets, isEmpty);
    });

    test('treats expired cache entries as missing', () async {
      final location = _location();
      final asset = _asset('asset-1');

      await LNDRecommendationService.writeCachedRail(
        rail: HomeRecommendationRail.popular,
        userId: 'user-1',
        location: location,
        currencyCode: 'PHP',
        assets: [asset],
      );
      final cacheKey = _singleRecommendationCacheKey();
      await LNDStorageService.write(cacheKey, {
        'cachedAt':
            DateTime.now()
                .subtract(const Duration(days: 2))
                .millisecondsSinceEpoch,
        'assets': [asset.toJson()],
      });

      final cached = LNDRecommendationService.readCachedRail(
        rail: HomeRecommendationRail.popular,
        userId: 'user-1',
        location: location,
        currencyCode: 'PHP',
      );

      expect(cached, isNull);
    });

    test('scopes cache by user, location, and currency', () async {
      final location = _location();

      await LNDRecommendationService.writeCachedRail(
        rail: HomeRecommendationRail.popular,
        userId: 'user-1',
        location: location,
        currencyCode: 'PHP',
        assets: [_asset('asset-1')],
      );

      expect(
        LNDRecommendationService.readCachedRail(
          rail: HomeRecommendationRail.popular,
          userId: 'user-2',
          location: location,
          currencyCode: 'PHP',
        ),
        isNull,
      );
      expect(
        LNDRecommendationService.readCachedRail(
          rail: HomeRecommendationRail.popular,
          userId: 'user-1',
          location: location.copyWith(locality: 'Cebu'),
          currencyCode: 'PHP',
        ),
        isNull,
      );
      expect(
        LNDRecommendationService.readCachedRail(
          rail: HomeRecommendationRail.popular,
          userId: 'user-1',
          location: location,
          currencyCode: 'USD',
        ),
        isNull,
      );
    });
  });
}

Location _location() {
  return Location(
    country: 'Philippines',
    locality: 'Makati',
    lat: 14.55,
    lng: 121.02,
  );
}

Asset _asset(String id) {
  return Asset(
    id: id,
    ownerId: 'owner-1',
    title: 'Camera',
    status: Availability.available.label,
  );
}

String _singleRecommendationCacheKey() {
  final keys =
      LNDStorageService.keys()
          .where(
            (key) => key.startsWith(
              LNDStorageConstants.homeRecommendationRailCachePrefix,
            ),
          )
          .toList();
  expect(keys, hasLength(1));
  return keys.single;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_either/dart_either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class HomeRecommendations {
  const HomeRecommendations({required this.recommended, required this.popular});

  final List<Asset> recommended;
  final List<Asset> popular;
}

class HomeRecommendationCacheEntry {
  const HomeRecommendationCacheEntry({
    required this.assets,
    required this.cachedAt,
  });

  final List<Asset> assets;
  final DateTime cachedAt;

  bool get isFresh =>
      DateTime.now().difference(cachedAt) <
      (kDebugMode ? const Duration(minutes: 2) : const Duration(days: 1));
}

enum HomeRecommendationRail {
  recommended,
  popular;

  String get functionName {
    switch (this) {
      case HomeRecommendationRail.recommended:
        return LNDFunctions.getHomeRecommended;
      case HomeRecommendationRail.popular:
        return LNDFunctions.getHomePopular;
    }
  }
}

class LNDRecommendationService {
  LNDRecommendationService._();

  static Future<Either<HomeRecommendations, String>> getHomeRecommendations({
    required Location? location,
    required String currencyCode,
    List<String> categoryHints = const [],
  }) async {
    final recommendedResult = await getRecommendedAssets(
      location: location,
      currencyCode: currencyCode,
      categoryHints: categoryHints,
    );
    final popularResult = await getPopularAssets(
      location: location,
      currencyCode: currencyCode,
    );

    final recommended = recommendedResult.fold(
      ifLeft: (assets) => assets,
      ifRight: (_) => <Asset>[],
    );
    final popular = popularResult.fold(
      ifLeft: (assets) => assets,
      ifRight: (_) => <Asset>[],
    );
    final error = recommendedResult.fold(
      ifLeft: (_) => null,
      ifRight: (message) => message,
    );
    final popularError = popularResult.fold(
      ifLeft: (_) => null,
      ifRight: (message) => message,
    );

    if (recommended.isEmpty &&
        popular.isEmpty &&
        (error ?? popularError) != null) {
      return Right(error ?? popularError!);
    }

    return Left(
      HomeRecommendations(recommended: recommended, popular: popular),
    );
  }

  static Future<Either<List<Asset>, String>> getRecommendedAssets({
    required Location? location,
    required String currencyCode,
    List<String> categoryHints = const [],
  }) {
    return _getHomeRail(
      rail: HomeRecommendationRail.recommended,
      location: location,
      currencyCode: currencyCode,
    );
  }

  static Future<Either<List<Asset>, String>> getPopularAssets({
    required Location? location,
    required String currencyCode,
  }) {
    return _getHomeRail(
      rail: HomeRecommendationRail.popular,
      location: location,
      currencyCode: currencyCode,
    );
  }

  static HomeRecommendationCacheEntry? readCachedRail({
    required HomeRecommendationRail rail,
    required String userId,
    required Location? location,
    required String currencyCode,
  }) {
    final raw = LNDStorageService.read<dynamic>(
      _cacheKey(
        rail: rail,
        userId: userId,
        location: location,
        currencyCode: currencyCode,
      ),
    );
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);
    final cachedAtMs = map['cachedAt'];
    final rawAssets = map['assets'];
    if (cachedAtMs is! int || rawAssets is! List) return null;

    try {
      final assets =
          rawAssets
              .whereType<String>()
              .map(Asset.fromJson)
              .where(_isPublicRecommendationAsset)
              .toList();
      final cacheEntry = HomeRecommendationCacheEntry(
        assets: assets,
        cachedAt: DateTime.fromMillisecondsSinceEpoch(cachedAtMs),
      );
      if (!cacheEntry.isFresh) return null;
      return cacheEntry;
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      return null;
    }
  }

  static Future<void> writeCachedRail({
    required HomeRecommendationRail rail,
    required String userId,
    required Location? location,
    required String currencyCode,
    required List<Asset> assets,
  }) async {
    await LNDStorageService.write(
      _cacheKey(
        rail: rail,
        userId: userId,
        location: location,
        currencyCode: currencyCode,
      ),
      {
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'assets': assets.map((asset) => asset.toJson()).toList(),
      },
    );
  }

  static Future<Either<List<Asset>, String>> _getHomeRail({
    required HomeRecommendationRail rail,
    required Location? location,
    required String currencyCode,
    List<String> categoryHints = const [],
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Right('User must be authenticated');
      }
      await user.getIdToken();

      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        rail.functionName,
      );

      final result = await callable.call({
        'location': {
          'country': location?.country,
          'locality': location?.locality,
          'lat': location?.lat,
          'lng': location?.lng,
          'geohash': location?.geohash,
        }..removeWhere((_, value) => value == null),
        'currencyCode': currencyCode,
        if (rail == HomeRecommendationRail.popular)
          'categoryHints': categoryHints,
        'limitPerRail': 12,
      });

      final data = Map<String, dynamic>.from(result.data);
      final assets = _assetListFromData(
        data['items'],
      ).where(_isPublicRecommendationAsset).toList(growable: false);

      return Left(assets);
    } on FirebaseFunctionsException catch (e, st) {
      if (e.code == 'unauthenticated') {
        return Right(e.message ?? 'User must be authenticated');
      }
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      return Right(e.message ?? 'Failed to load recommendations');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-token-expired' || e.code == 'user-disabled') {
        return Right(e.message ?? 'User must be authenticated');
      }
      return Right(e.message ?? 'Failed to authenticate recommendations');
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      return Right(e.toString());
    }
  }

  static Future<void> recordSavedAsset({required String assetId}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.getIdToken();

      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.recordRecommendationEvent,
      );
      await callable.call({'assetId': assetId, 'eventType': 'savedAsset'});
    } on FirebaseFunctionsException catch (e, st) {
      if (e.code == 'unauthenticated') return;
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  static String _cacheKey({
    required HomeRecommendationRail rail,
    required String userId,
    required Location? location,
    required String currencyCode,
  }) {
    return [
      LNDStorageConstants.homeRecommendationRailCachePrefix,
      userId,
      rail.name,
      currencyCode.trim().isEmpty ? 'PHP' : currencyCode.trim(),
      _normalizedLocationKey(location),
    ].join(':');
  }

  static String _normalizedLocationKey(Location? location) {
    final country = _normalizeLocationPart(location?.country);
    final locality = _normalizeLocationPart(location?.locality);
    final lat = location?.lat;
    final lng = location?.lng;
    final coordinateKey =
        lat == null || lng == null
            ? ''
            : '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';

    return [
      country,
      locality,
      coordinateKey,
    ].where((part) => part.trim().isNotEmpty).join('|');
  }

  static String _normalizeLocationPart(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  static Iterable<Asset> _assetListFromData(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) => _assetFromMap(Map<String, dynamic>.from(item)))
        .where((asset) => asset.id.isNotEmpty);
  }

  static bool _isPublicRecommendationAsset(Asset asset) {
    return asset.id.isNotEmpty &&
        !asset.isDeleted &&
        (asset.status == Availability.available.label ||
            asset.status == Availability.underMaintenance.label);
  }

  static Asset _assetFromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'] as String? ?? '',
      ownerId: map['ownerId'] as String?,
      title: map['title'] as String?,
      categoryId: map['categoryId'] as String?,
      categoryName: map['categoryName'] as String?,
      subcategoryId: map['subcategoryId'] as String?,
      subcategoryName: map['subcategoryName'] as String?,
      rates:
          map['rates'] is Map
              ? Rates.fromMap(Map<String, dynamic>.from(map['rates'] as Map))
              : null,
      location:
          map['location'] is Map
              ? Location.fromMap(
                Map<String, dynamic>.from(map['location'] as Map),
              )
              : null,
      images:
          map['images'] is List ? List<String>.from(map['images'] as List) : [],
      createdAt: _timestampFromValue(map['createdAt']),
      status: map['status'] as String?,
      isDeleted: map['isDeleted'] == true,
      averageRating:
          map['averageRating'] is num
              ? (map['averageRating'] as num).toDouble()
              : null,
      reviewCount:
          map['reviewCount'] is num
              ? (map['reviewCount'] as num).toInt()
              : null,
    );
  }

  static Timestamp? _timestampFromValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final seconds = map['_seconds'] ?? map['seconds'];
      final nanoseconds = map['_nanoseconds'] ?? map['nanoseconds'] ?? 0;
      if (seconds is int && nanoseconds is int) {
        return Timestamp(seconds, nanoseconds);
      }
    }
    return null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/scroll.mixin.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/category.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/recommendation.service.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/presentation/controllers/location_picker/location_picker.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/category/category.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/currency.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController with LNDScrollMixin {
  static final instance = Get.find<HomeController>();

  final RxBool _isLoading = false.obs;
  final RxBool _isRecommendedLoading = false.obs;
  final RxBool _isPopularLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;
  final RxBool _locationPermissionDenied = false.obs;
  final RxString _browseLocationError = ''.obs;

  final RxList<Asset> _assets = <Asset>[].obs;
  final RxList<Asset> _recommendedAssets = <Asset>[].obs;
  final RxList<Asset> _popularAssets = <Asset>[].obs;
  final RxList<SimpleAsset> _recentlyViewedAssets = <SimpleAsset>[].obs;
  final Rxn<Location> _customBrowseLocation = Rxn<Location>();
  final Rxn<Location> _currentBrowseLocation = Rxn<Location>();
  bool _hasStartedInitialLoad = false;

  // Pagination
  List<Asset> _exploreAssetsCache = <Asset>[];
  int _paginationGeneration = 0;
  static const int _pageSize = 12;
  static const int _maxExploreAssets = 36;
  static const double _loadMoreThreshold = 240.0;

  bool get isLoading => _isLoading.value;
  bool get isRecommendedLoading => _isRecommendedLoading.value;
  bool get isPopularLoading => _isPopularLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value;
  bool get locationPermissionDenied => _locationPermissionDenied.value;
  String get browseLocationError => _browseLocationError.value;
  List<Asset> get assets => _assets;
  List<SimpleAsset> get recentlyViewedAssets => _recentlyViewedAssets;
  List<Asset> get recommendedAssets => _recommendedAssets;
  List<Asset> get popularAssets => _popularAssets;
  List<LNDCategory> get visibleCategories =>
      CategoryController.instance.parentCategories;
  Location? get activeBrowseLocation =>
      _customBrowseLocation.value ??
      ProfileController.instance.user?.location ??
      _currentBrowseLocation.value;
  String get activeLocationCurrencyCode =>
      LNDCurrency.fromLocation(activeBrowseLocation);
  bool get hasCurrencyMismatch =>
      Get.isRegistered<CountryPreferenceController>() &&
      !CountryPreferenceController.instance.isCurrencyCountryLoading &&
      LNDCurrency.hasMismatchWithSelectedCurrency(activeBrowseLocation);
  String get selectedCurrencyCode => LNDCurrency.selectedDisplayCurrency();

  @override
  void onReady() {
    scrollController.addListener(_onScroll);
    if (LNDStorageService.read<bool>(LNDStorageConstants.onboardingComplete) ==
        true) {
      startInitialLoad();
    }

    super.onReady();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _assets.close();
    _recommendedAssets.close();
    _popularAssets.close();
    _recentlyViewedAssets.close();
    _isLoading.close();
    _isRecommendedLoading.close();
    _isPopularLoading.close();
    _isLoadingMore.close();
    _hasMore.close();
    _locationPermissionDenied.close();
    _browseLocationError.close();
    _customBrowseLocation.close();
    _currentBrowseLocation.close();

    super.onClose();
  }

  void init() {}

  void startInitialLoad() {
    if (_hasStartedInitialLoad) return;
    _hasStartedInitialLoad = true;
    loadRecentlyViewedAssets();
    getAssets();
  }

  Future<void> getAssets({bool force = false}) async {
    if (_isLoading.value && !force) return;

    _isLoading.value = true;
    _isLoadingMore.value = false;
    final generation = ++_paginationGeneration;
    // Reset pagination
    _hasMore.value = true;
    _locationPermissionDenied.value = false;
    _browseLocationError.value = '';

    try {
      final hasBrowseLocation = await ensureBrowseLocation();

      if (!hasBrowseLocation) {
        _clearHomeFeeds();
        _hasMore.value = false;
        return;
      }
      await _syncCountryPreferences();

      if (activeBrowseLocation?.lat == null &&
          activeBrowseLocation?.country?.trim().isNotEmpty != true) {
        _browseLocationError.value =
            "We couldn't detect your location. Try again.";
        _clearHomeFeeds();
        _hasMore.value = false;
        return;
      }

      final result = await _getInitialExploreAssets();
      if (generation != _paginationGeneration) return;

      _assets.value = result.assets;
      _hasMore.value =
          _assets.length < _exploreAssetsCache.length &&
          _assets.length < _maxExploreAssets;

      if (AuthController.instance.isAuthenticated) {
        loadAuthenticatedHomeRails(forceRefresh: force);
      } else {
        clearFeed();
      }
    } catch (e, st) {
      if (generation != _paginationGeneration) return;

      _clearHomeFeeds();
      _hasMore.value = false;
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      if (generation == _paginationGeneration) {
        _isLoading.value = false;
      }
    }
  }

  void clearFeed() {
    _recentlyViewedAssets.value = [];
    _recommendedAssets.value = [];
    _popularAssets.value = [];
    _isRecommendedLoading.value = false;
    _isPopularLoading.value = false;
  }

  Future<void> loadAuthenticatedHomeRails({bool forceRefresh = false}) async {
    if (!AuthController.instance.isAuthenticated) {
      clearFeed();
      return;
    }

    await Future.wait([
      _loadHomeRail(
        HomeRecommendationRail.recommended,
        forceRefresh: forceRefresh,
      ),
      _loadHomeRail(HomeRecommendationRail.popular, forceRefresh: forceRefresh),
    ]);
  }

  Future<void> _loadHomeRail(
    HomeRecommendationRail rail, {
    required bool forceRefresh,
  }) async {
    final userId = AuthController.instance.uid;
    if (userId == null) {
      _setRailAssets(rail, []);
      _setRailLoading(rail, false);
      return;
    }

    final generation = _paginationGeneration;
    final location = activeBrowseLocation;
    final currencyCode = activeLocationCurrencyCode;
    final cached =
        forceRefresh
            ? null
            : LNDRecommendationService.readCachedRail(
              rail: rail,
              userId: userId,
              location: location,
              currencyCode: currencyCode,
            );

    if (cached != null) {
      _setRailAssets(rail, cached.assets);
      _setRailLoading(rail, false);
      _debugPrintRailSource(rail, 'Cache');
      return;
    }

    _debugPrintRailSource(rail, 'Internet');
    _setRailLoading(rail, true);
    try {
      final result =
          rail == HomeRecommendationRail.recommended
              ? await LNDRecommendationService.getRecommendedAssets(
                location: location,
                currencyCode: currencyCode,
              )
              : await LNDRecommendationService.getPopularAssets(
                location: location,
                currencyCode: currencyCode,
              );

      if (generation != _paginationGeneration) return;

      result.fold(
        ifLeft: (assets) {
          _setRailAssets(rail, assets);
          LNDRecommendationService.writeCachedRail(
            rail: rail,
            userId: userId,
            location: location,
            currencyCode: currencyCode,
            assets: assets,
          );
        },
        ifRight: (_) {},
      );
    } catch (e, st) {
      if (generation != _paginationGeneration) return;
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      if (generation == _paginationGeneration) {
        _setRailLoading(rail, false);
      }
    }
  }

  void _setRailAssets(HomeRecommendationRail rail, List<Asset> assets) {
    final filtered = _filterExcludedAssets(assets);
    switch (rail) {
      case HomeRecommendationRail.recommended:
        _recommendedAssets.value = filtered;
        break;
      case HomeRecommendationRail.popular:
        _popularAssets.value = filtered;
        break;
    }
  }

  List<Asset> _filterExcludedAssets(Iterable<Asset> assets) {
    if (!Get.isRegistered<UserBlockController>()) return assets.toList();
    return assets
        .where(
          (asset) => !UserBlockController.instance.isExcluded(asset.ownerId),
        )
        .toList();
  }

  void removeExcludedOwners(Set<String> ownerIds) {
    _assets.removeWhere((asset) => ownerIds.contains(asset.ownerId));
    _recommendedAssets.removeWhere((asset) => ownerIds.contains(asset.ownerId));
    _popularAssets.removeWhere((asset) => ownerIds.contains(asset.ownerId));
    _recentlyViewedAssets.removeWhere(
      (asset) => ownerIds.contains(asset.owner?.uid),
    );
    _exploreAssetsCache.removeWhere(
      (asset) => ownerIds.contains(asset.ownerId),
    );
  }

  void _setRailLoading(HomeRecommendationRail rail, bool isLoading) {
    switch (rail) {
      case HomeRecommendationRail.recommended:
        _isRecommendedLoading.value = isLoading;
        break;
      case HomeRecommendationRail.popular:
        _isPopularLoading.value = isLoading;
        break;
    }
  }

  void _debugPrintRailSource(HomeRecommendationRail rail, String source) {
    if (!kDebugMode) return;
    LNDLogger.dNoStack('${rail.name.toUpperCase()} Source: $source');
  }

  /// Load more assets for infinite scroll
  Future<void> loadMoreAssets() async {
    if (_isLoading.value || _isLoadingMore.value || !_hasMore.value) return;
    if (_assets.length >= _maxExploreAssets) {
      _hasMore.value = false;
      return;
    }

    _isLoadingMore.value = true;
    final generation = _paginationGeneration;
    final remainingAssets = _maxExploreAssets - _assets.length;
    final limit = remainingAssets < _pageSize ? remainingAssets : _pageSize;

    try {
      final nextAssets =
          _exploreAssetsCache.skip(_assets.length).take(limit).toList();

      if (generation != _paginationGeneration) return;

      if (nextAssets.isNotEmpty) {
        _assets.addAll(nextAssets);
        _hasMore.value =
            _assets.length < _exploreAssetsCache.length &&
            _assets.length < _maxExploreAssets;
      } else {
        _hasMore.value = false;
      }
    } catch (e, st) {
      if (generation != _paginationGeneration) return;

      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      if (generation == _paginationGeneration) {
        _isLoadingMore.value = false;
      }
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    final distanceToBottom = position.maxScrollExtent - position.pixels;

    if (distanceToBottom <= _loadMoreThreshold) {
      loadMoreAssets();
    }
  }

  Future<bool> ensureBrowseLocation() async {
    final activeLocation = activeBrowseLocation;
    if (activeLocation?.lat != null && activeLocation?.lng != null) return true;
    if (activeLocation?.country?.trim().isNotEmpty == true) return true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _browseLocationError.value =
            'Location services are off. Enable location services to see listings around you.';
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationPermissionDenied.value = true;
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      final country = placemark?.country?.trim() ?? '';
      final locality = _localityFromPlacemark(placemark);

      if (country.isEmpty) {
        _browseLocationError.value =
            "We couldn't detect your location. Try again.";
        return false;
      }

      _currentBrowseLocation.value = Location(
        formattedAddress: _descriptionFromPlacemark(placemark),
        country: country,
        countryShortName: placemark?.isoCountryCode?.trim(),
        locality: locality,
        administrativeAreaLevel2: placemark?.subAdministrativeArea?.trim(),
        administrativeAreaLevel1: placemark?.administrativeArea?.trim(),
        postalCode: placemark?.postalCode?.trim(),
        lat: position.latitude,
        lng: position.longitude,
      );
      await _syncCountryPreferences();
      return true;
    } catch (e, st) {
      _browseLocationError.value =
          "We couldn't detect your location. Try again.";
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      return false;
    }
  }

  String _localityFromPlacemark(Placemark? placemark) {
    return [
      placemark?.administrativeArea,
      placemark?.locality,
      placemark?.subAdministrativeArea,
    ].whereType<String>().firstWhere(
      (value) => value.trim().isNotEmpty,
      orElse: () => '',
    );
  }

  String _descriptionFromPlacemark(Placemark? placemark) {
    final parts =
        [
              placemark?.locality,
              placemark?.subAdministrativeArea,
              placemark?.administrativeArea,
              placemark?.country,
            ]
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .toList();

    if (parts.isEmpty) return '';
    return parts.toSet().join(', ');
  }

  void _clearHomeFeeds() {
    _assets.value = [];
    _recommendedAssets.value = [];
    _popularAssets.value = [];
    _exploreAssetsCache = <Asset>[];
  }

  Future<void> retryBrowseLocation() => getAssets();

  Future<void> openLocationSettings() async {
    await openAppSettings();
  }

  Future<void> openBrowseLocationPicker() async {
    final location = activeBrowseLocation;
    final result = await LNDNavigate.toPickLocationPage(
      args: LocationCallbackModel(
        useSpecificLocation: location?.useSpecificLocation ?? true,
        location: location ?? Location(),
      ),
    );
    if (result == null) return;

    _customBrowseLocation.value = result.location;
    await _syncCountryPreferences();
    _clearHomeFeeds();
    _hasMore.value = true;
    _locationPermissionDenied.value = false;
    _browseLocationError.value = '';
    await getAssets(force: true);
  }

  Future<void> _syncCountryPreferences() async {
    if (!Get.isRegistered<CountryPreferenceController>()) return;
    await CountryPreferenceController.instance.syncHomeLocation(
      activeBrowseLocation,
    );
  }

  Future<({List<Asset> assets, DocumentSnapshot? lastDocument})>
  _getInitialExploreAssets() async {
    _exploreAssetsCache = await _buildExploreAssets();
    return (
      assets: _exploreAssetsCache.take(_pageSize).toList(),
      lastDocument: null,
    );
  }

  Future<List<Asset>> _buildExploreAssets() async {
    final location = activeBrowseLocation;
    final excludeOwnerId = AuthController.instance.uid;
    final currencyCode = activeLocationCurrencyCode;
    final nearbyAssets = await LNDAssetService.getNearbyAssets(
      location: location,
      limit: _maxExploreAssets,
      excludeOwnerId: excludeOwnerId,
      currencyCode: currencyCode,
    );
    final assetsById = <String, Asset>{
      for (final asset in nearbyAssets)
        if (asset.id.isNotEmpty) asset.id: asset,
    };

    if (assetsById.length >= _pageSize) {
      return assetsById.values.take(_maxExploreAssets).toList();
    }

    if (location?.locality?.trim().isNotEmpty == true ||
        location?.country?.trim().isNotEmpty == true) {
      final localityResult = await LNDAssetService.getAssetsPaginated(
        limit: _maxExploreAssets,
        location: location,
        excludeOwnerId: excludeOwnerId,
        currencyCode: currencyCode,
      );
      for (final asset in localityResult.assets) {
        if (asset.id.isNotEmpty) assetsById[asset.id] = asset;
      }
    }

    if (assetsById.length < _pageSize &&
        location?.country?.trim().isNotEmpty == true) {
      final countryLocation = location?.copyWith(locality: '');
      final countryResult = await LNDAssetService.getAssetsPaginated(
        limit: _maxExploreAssets,
        location: countryLocation,
        excludeOwnerId: excludeOwnerId,
        currencyCode: currencyCode,
      );
      for (final asset in countryResult.assets) {
        if (asset.id.isNotEmpty) assetsById[asset.id] = asset;
      }
    }

    return _filterExcludedAssets(
      assetsById.values,
    ).take(_maxExploreAssets).toList();
  }

  void loadRecentlyViewedAssets() {
    final rawList = LNDStorageService.readList(
      LNDStorageConstants.recentlyViewedAssets,
    );

    if (rawList == null) {
      _recentlyViewedAssets.value = [];
      return;
    }

    _recentlyViewedAssets.value =
        rawList
            .whereType<String>()
            .map(SimpleAsset.fromJson)
            .where(
              (asset) =>
                  !UserBlockController.instance.isExcluded(asset.owner?.uid) &&
                  !asset.isDeleted &&
                  (asset.status == Availability.available.label ||
                      asset.status == Availability.underMaintenance.label),
            )
            .toList();
  }

  Future<void> saveRecentlyViewedAsset(Asset asset) async {
    if (asset.ownerId == AuthController.instance.uid) return;
    if (UserBlockController.instance.isExcluded(asset.ownerId)) return;
    if (asset.isDeleted ||
        (asset.status != Availability.available.label &&
            asset.status != Availability.underMaintenance.label)) {
      return;
    }

    if (_recentlyViewedAssets.isEmpty) {
      loadRecentlyViewedAssets();
    }

    final simpleAsset = SimpleAsset.fromMap(asset.toMap());
    final nextAssets =
        [
          simpleAsset,
          ..._recentlyViewedAssets.where((item) => item.id != simpleAsset.id),
        ].take(10).toList();

    _recentlyViewedAssets.value = nextAssets;
    await LNDStorageService.writeList(
      LNDStorageConstants.recentlyViewedAssets,
      nextAssets.map((item) => item.toJson()).toList(),
    );
  }

  bool removeLocalAsset(String assetId) {
    try {
      _assets.removeWhere((asset) => asset.id == assetId);
      _assets.refresh();
      return true;
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      return false;
    }
  }

  // void _writeToCache() {
  //   LNDStorageService.writeList(
  //     _cacheKey,
  //     assets.map((a) => a.toJson()).toList(),
  //   );
  // }

  // List<dynamic>? _readCache() {
  //   return LNDStorageService.readList(_cacheKey);
  // }

  void postAssets() async {
    final assetsCollection = FirebaseFirestore.instance.collection(
      LNDCollections.assets.name,
    );
    final batch = FirebaseFirestore.instance.batch();
    for (var asset in sampleAssets) {
      batch.set(assetsCollection.doc(), asset.toMap());
    }
    await batch.commit();
    Get.snackbar('Success', 'Add Success');
    getAssets();
  }

  void openAssetPage(Asset asset) {
    saveRecentlyViewedAsset(asset);
    LNDNavigate.toAssetPage(args: asset);
  }

  void openRecentlyViewedAsset(SimpleAsset asset) {
    LNDNavigate.toAssetPage(args: Asset.fromMap(asset.toMap()));
  }

  void goToCreateListing() {
    if (ProfileController.instance.hasPendingFullVerification) {
      LNDSnackbar.showInfo(
        'Listing changes are blocked while verification is pending.',
      );
      return;
    }
    if (!ProfileController.instance.canList) return;
    LNDNavigate.toCreateListing(args: null);
  }

  void goToSearchPage() {
    LNDNavigate.toSearchPage();
  }

  void updateAsset(Asset newAsset) {
    final assetIndex = assets.indexWhere((asset) => asset.id == newAsset.id);
    if (assetIndex != -1) {
      _assets[assetIndex] = newAsset;
      _assets.refresh();
    }
    _replaceAsset(_recommendedAssets, newAsset);
    _replaceAsset(_popularAssets, newAsset);
  }

  void _replaceAsset(RxList<Asset> assets, Asset newAsset) {
    final assetIndex = assets.indexWhere((asset) => asset.id == newAsset.id);
    if (assetIndex == -1) return;

    assets[assetIndex] = newAsset;
    assets.refresh();
  }

  List<Asset> sampleAssets = [
    Asset(
      id: '1',
      ownerId: 'wvBJK1u8UkJOXABCtiKy',
      title: 'Canon EOS R5 Camera',
      description:
          'High-resolution mirrorless camera perfect for professional photography.',
      categoryId: 'electronics',
      categoryName: 'Electronics',
      inclusions: ["3 Batteries", "Hard Case", "128 gb SD Card", "Tripod"],
      rates: Rates(daily: 1500, monthly: 0, annually: 0, notes: 'Just a note'),
      // availability: [
      // Timestamp.fromDate(DateTime(2025, 3, 20)),
      // Timestamp.fromDate(DateTime(2025, 3, 21)),
      // Timestamp.fromDate(DateTime(2025, 3, 22)),
      // ],
      location: Location(
        formattedAddress: '123 Main St, Springfield, USA',
        lat: 37.7749,
        lng: -122.4194,
      ),
      images: [
        'https://www.the-digital-picture.com/Images/Review/Canon-EOS-R5.jpg',
        'https://www.dpreview.com/files/p/articles/7757595702/20200709-Canon-EOS-R5-Product-Images-1.jpeg',
      ],
      showcase: [
        "https://www.cnet.com/a/img/resize/887fea6895d3592aa884920a4eea1b6ae44c9bff/hub/2022/09/13/5806fde3-a856-4cbb-8a78-ce2f9501df6b/gopro-hero-11-black-05.jpg?auto=webp&width=1200",
        "https://i.insider.com/632169ece8b5000018511e0e?width=700",
        "https://cdn.outsideonline.com/wp-content/uploads/2022/09/gopro-hero-11-black_s.jpeg",
        "https://www.henryscameraphoto.com/image/cache/catalog/GoPro/Hero11/creator/hero11creator-1-800x800.jpeg"
            "https://s3.amazonaws.com/images.gearjunkie.com/uploads/2022/09/Field-Testing-the-GoPro-Hero-11-Black.jpg",
        "https://fdn.gsmarena.com/imgroot/news/22/09/gopro-hero-11-series-ofic/inline/-1200/gsmarena_004.jpg",
        "https://cdn.fstoppers.com/styles/full/s3/media/2022/10/23/gopro-hero-11-black-in-my-hand.jpg",
        "https://static.gopro.com/assets/blta2b8522e5372af40/bltcb0e4a7ab8f7a32e/62ecefc75b080e77825d9efa/pdp-h11b-water-repelling-1920-2x.png",
      ],
      createdAt: Timestamp(0, 0),
      status: 'Available',
    ),
  ];
}

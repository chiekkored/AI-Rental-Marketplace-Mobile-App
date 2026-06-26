import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class CategoryListingPageArgs {
  final String categoryId;
  final String categoryName;

  const CategoryListingPageArgs({
    required this.categoryId,
    required this.categoryName,
  });
}

class CategoryListingController extends GetxController {
  final CategoryListingPageArgs args = Get.arguments as CategoryListingPageArgs;

  static const int _pageSize = 12;
  static const int _maxCategoryAssets = 36;

  final RxList<Asset> _assets = <Asset>[].obs;
  final RxBool _isLoading = true.obs;

  String get categoryId => args.categoryId;
  String get categoryName => args.categoryName;
  List<Asset> get assets => _assets;
  bool get isLoading => _isLoading.value;

  @override
  void onReady() {
    getAssets();
    super.onReady();
  }

  @override
  void onClose() {
    _assets.close();
    _isLoading.close();
    super.onClose();
  }

  Future<void> getAssets() async {
    _isLoading.value = true;

    try {
      _assets.value = await _buildCategoryAssets();
    } catch (e, st) {
      _assets.clear();
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }

    _isLoading.value = false;
  }

  void openAssetPage(Asset asset) {
    HomeController.instance.openAssetPage(asset);
  }

  Future<List<Asset>> _buildCategoryAssets() async {
    final location = HomeController.instance.activeBrowseLocation;
    final excludeOwnerId = AuthController.instance.uid;
    final nearbyAssets = await LNDAssetService.getNearbyAssets(
      location: location,
      categoryId: categoryId,
      limit: _maxCategoryAssets,
      excludeOwnerId: excludeOwnerId,
    );
    final assetsById = <String, Asset>{
      for (final asset in nearbyAssets)
        if (asset.id.isNotEmpty) asset.id: asset,
    };

    if (assetsById.length >= _pageSize) {
      return assetsById.values.take(_maxCategoryAssets).toList();
    }

    if (location?.locality?.trim().isNotEmpty == true ||
        location?.country?.trim().isNotEmpty == true) {
      final localityResult = await LNDAssetService.getAssetsPaginated(
        limit: _maxCategoryAssets,
        categoryId: categoryId,
        location: location,
        excludeOwnerId: excludeOwnerId,
      );
      for (final asset in localityResult.assets) {
        if (asset.id.isNotEmpty) assetsById[asset.id] = asset;
      }
    }

    if (assetsById.length < _pageSize &&
        location?.country?.trim().isNotEmpty == true) {
      final countryLocation = location?.copyWith(locality: '');
      final countryResult = await LNDAssetService.getAssetsPaginated(
        limit: _maxCategoryAssets,
        categoryId: categoryId,
        location: countryLocation,
        excludeOwnerId: excludeOwnerId,
      );
      for (final asset in countryResult.assets) {
        if (asset.id.isNotEmpty) assetsById[asset.id] = asset;
      }
    }

    return assetsById.values.take(_maxCategoryAssets).toList();
  }
}

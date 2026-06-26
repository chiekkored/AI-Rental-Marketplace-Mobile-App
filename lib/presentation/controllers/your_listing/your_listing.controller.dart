import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class YourListingArgs {
  final bool withNavbar;

  YourListingArgs({required this.withNavbar});
}

class YourListingController extends GetxController with AuthMixin {
  static YourListingController get instance =>
      Get.find<YourListingController>();

  static const int listingPageSize = 10;

  final RxBool _isMyAssetsLoading = false.obs;
  bool get isMyAssetsLoading => _isMyAssetsLoading.value;

  final RxList<SimpleAsset> _myAssets = <SimpleAsset>[].obs;
  List<SimpleAsset> get myAssets => _myAssets;

  final Rx<Availability> _selectedFilter = Availability.available.obs;
  Availability get selectedFilter => _selectedFilter.value;

  StreamSubscription<List<SimpleAsset>>? _myAssetsSubscription;
  String? _listeningUserId;

  late final PagingController<int, SimpleAsset> pagingController =
      PagingController<int, SimpleAsset>(
        getNextPageKey: _getNextPageKey,
        fetchPage: fetchListingPage,
      );

  List<SimpleAsset> get filteredAssets => filteredAssetsFor(selectedFilter);

  List<SimpleAsset> filteredAssetsFor(Availability status) =>
      _myAssets.where((asset) => asset.status == status.label).toList();

  String get availableAssets =>
      _myAssets
          .where((asset) => asset.status == Availability.available.label)
          .length
          .toString();
  String get underMaintenanceAssets =>
      _myAssets
          .where((asset) => asset.status == Availability.underMaintenance.label)
          .length
          .toString();
  String get hiddenAssets =>
      _myAssets
          .where((asset) => asset.status == Availability.hidden.label)
          .length
          .toString();

  @override
  void onClose() {
    cancelMyAssetsSubscription();
    pagingController.dispose();
    _isMyAssetsLoading.close();
    _myAssets.close();
    _selectedFilter.close();

    super.onClose();
  }

  void listenToMyAssets({String? userId}) {
    final ownerId = userId ?? AuthController.instance.uid;

    if (ownerId == null || ownerId.isEmpty) {
      cancelMyAssetsSubscription();
      clearMyAssets();
      return;
    }

    if (_listeningUserId == ownerId && _myAssetsSubscription != null) return;

    cancelMyAssetsSubscription(clearAssets: false);
    _listeningUserId = ownerId;
    _isMyAssetsLoading.value = _myAssets.isEmpty;

    _myAssetsSubscription = LNDAssetService.watchOwnerAssets(ownerId).listen(
      (assets) {
        _myAssets.assignAll(assets.where(_hasSupportedStatus));
        pagingController.refresh();
        _isMyAssetsLoading.value = false;
      },
      onError: (e, st) {
        _isMyAssetsLoading.value = false;
        LNDLogger.e('Error listening to my assets', error: e, stackTrace: st);
      },
    );
  }

  Future<void> getMyAssets({bool forceRefresh = false}) {
    if (forceRefresh) {
      return refreshMyAssets();
    }

    listenToMyAssets();
    return Future.value();
  }

  Future<void> refreshMyAssets() async {
    final ownerId = AuthController.instance.uid;
    cancelMyAssetsSubscription(clearAssets: false);
    listenToMyAssets(userId: ownerId);
  }

  void setFilter(Availability status) {
    _selectedFilter.value = status;
    _myAssets.refresh();
    pagingController.refresh();
  }

  @visibleForTesting
  void setLocalAssetsForTesting(List<SimpleAsset> assets) {
    _myAssets.assignAll(assets);
    pagingController.refresh();
  }

  @visibleForTesting
  List<SimpleAsset> fetchListingPage(int pageKey) {
    final assets = filteredAssets;
    final startIndex = (pageKey - 1) * listingPageSize;
    if (startIndex >= assets.length) return <SimpleAsset>[];

    final endIndex = (startIndex + listingPageSize).clamp(0, assets.length);
    return assets.sublist(startIndex, endIndex);
  }

  void goToAssetPage(SimpleAsset asset) {
    LNDNavigate.toAssetPage(
      args: Asset.fromMap(asset.toMap()),
      source: AssetPageSource.owner,
    );
  }

  bool _hasSupportedStatus(SimpleAsset asset) {
    return Availability.values.any((status) => status.label == asset.status);
  }

  void removeLocalAsset(String assetId) {
    _myAssets.removeWhere((asset) => asset.id == assetId);
    _myAssets.refresh();
  }

  void invalidateCache() {
    refreshMyAssets();
  }

  void cancelMyAssetsSubscription({bool clearAssets = true}) {
    _myAssetsSubscription?.cancel();
    _myAssetsSubscription = null;
    _listeningUserId = null;
    _isMyAssetsLoading.value = false;
    if (clearAssets) clearMyAssets();
  }

  void clearMyAssets() {
    _myAssets.clear();
    pagingController.refresh();
  }

  void goToCreateListing() {
    if (ProfileController.instance.hasPendingFullVerification) {
      LNDSnackbar.showInfo(
        'Listing changes are blocked while verification is pending.',
      );
      return;
    }
    LNDNavigate.toCreateListing(args: null);
  }

  int? _getNextPageKey(PagingState<int, SimpleAsset> state) {
    final loadedItemCount = state.items?.length ?? 0;
    if (loadedItemCount >= filteredAssets.length) return null;
    return state.nextIntPageKey;
  }
}

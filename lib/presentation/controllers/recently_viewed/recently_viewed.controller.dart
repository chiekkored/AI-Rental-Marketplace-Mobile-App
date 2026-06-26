import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class RecentlyViewedController extends GetxController {
  static RecentlyViewedController get instance =>
      Get.find<RecentlyViewedController>();

  final RxBool _isLoading = false.obs;
  final RxList<SimpleAsset> _assets = <SimpleAsset>[].obs;

  bool get isLoading => _isLoading.value;
  List<SimpleAsset> get assets => _assets;

  @override
  void onInit() {
    super.onInit();
    loadRecentlyViewedAssets();
  }

  @override
  void onClose() {
    _isLoading.close();
    _assets.close();
    super.onClose();
  }

  Future<void> loadRecentlyViewedAssets() async {
    try {
      _isLoading.value = true;
      _assets.value = _readRecentlyViewedAssets();
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to load recently viewed listings.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> removeRecentlyViewedAsset(String assetId) async {
    try {
      final nextAssets = _assets.where((asset) => asset.id != assetId).toList();

      _assets.value = nextAssets;
      await LNDStorageService.writeList(
        LNDStorageConstants.recentlyViewedAssets,
        nextAssets.map((item) => item.toJson()).toList(),
      );
      if (Get.isRegistered<HomeController>()) {
        HomeController.instance.loadRecentlyViewedAssets();
      }
      LNDSnackbar.showInfo('Removed from recently viewed');
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to remove recently viewed listing.');
    }
  }

  void openAssetPage(SimpleAsset asset) {
    LNDNavigate.toAssetPage(args: Asset.fromMap(asset.toMap()));
  }

  void showOptions(String assetId) async {
    final String? result = await LNDShow.menuBottomSheetVertical(
      items: [
        LNDMenuItem(
          label: 'Remove',
          value: 'remove',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onTap: (value) => value,
        ),
      ],
    );

    if (result == 'remove') {
      removeRecentlyViewedAsset(assetId);
    }
  }

  List<SimpleAsset> _readRecentlyViewedAssets() {
    final rawList = LNDStorageService.readList(
      LNDStorageConstants.recentlyViewedAssets,
    );

    if (rawList == null) return [];

    return rawList
        .whereType<String>()
        .map(SimpleAsset.fromJson)
        .where(
          (asset) =>
              !asset.isDeleted &&
              !UserBlockController.instance.isExcluded(asset.owner?.uid) &&
              (asset.status == Availability.available.label ||
                  asset.status == Availability.underMaintenance.label),
        )
        .toList();
  }
}

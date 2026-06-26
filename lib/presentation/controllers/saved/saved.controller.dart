import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/saved.service.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class SavedController extends GetxController {
  static SavedController get instance => Get.find<SavedController>();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxList<SimpleAsset> _savedAssets = <SimpleAsset>[].obs;
  List<SimpleAsset> get savedAssets => _savedAssets;

  @override
  void onClose() {
    _isLoading.close();
    clearSaved();
    super.onClose();
  }

  Future<void> addSaved(Asset asset) async {
    if (!AuthController.instance.isAuthenticated) return;
    if (UserBlockController.instance.isExcluded(asset.ownerId)) return;

    try {
      final result = await LNDSavedService.saveUserAsset(asset);

      result.fold(
        ifLeft: (_) {
          _savedAssets.add(SimpleAsset.fromMap(asset.toMap()));

          LNDSnackbar.showInfo('Added to saved bookmarks');
        },
        ifRight: (error) => LNDSnackbar.showError(error),
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  void removeSaved(String assetId) async {
    if (!AuthController.instance.isAuthenticated) return;

    try {
      final result = await LNDSavedService.removeSavedUserAsset(assetId);

      result.fold(
        ifLeft: (_) {
          _savedAssets.removeWhere((a) => a.id == assetId);
          LNDSnackbar.showInfo('Removed from saved bookmarks');
        },
        ifRight: (error) => LNDSnackbar.showError(error),
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  Future<void> getSaved() async {
    try {
      _isLoading.value = true;

      final result = await LNDSavedService.getUserSavedAssets();

      result.fold(
        ifLeft: (data) {
          _savedAssets.value =
              data
                  .where(
                    (asset) =>
                        !UserBlockController.instance.isExcluded(
                          asset.owner?.uid,
                        ),
                  )
                  .toList();
        },
        ifRight: (error) => LNDSnackbar.showError(error),
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      _isLoading.value = false;
    }
  }

  bool checkIsSaved(String? assetId) {
    if (assetId == null) return false;

    return savedAssets.where((a) => a.id == assetId).isNotEmpty;
  }

  void openAssetPage(SimpleAsset asset) {
    LNDNavigate.toAssetPage(
      args: Asset.fromMap(asset.toMap()),
      source: AssetPageSource.saved,
    );
  }

  void clearSaved() {
    _savedAssets.clear();
  }

  void removeExcludedOwners(Set<String> ownerIds) {
    _savedAssets.removeWhere((asset) => ownerIds.contains(asset.owner?.uid));
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
      removeSaved(assetId);
    }
  }
}

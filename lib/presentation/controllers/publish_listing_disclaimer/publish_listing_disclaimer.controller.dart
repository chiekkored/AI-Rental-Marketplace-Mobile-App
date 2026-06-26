import 'package:get/get.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class PublishListingDisclaimerController extends GetxController {
  final RxBool dontShowAgain = true.obs;

  Future<void> openTermsAndConditions() {
    return LNDLegalLinks.openTermsAndConditions();
  }

  Future<void> openPrivacyPolicy() {
    return LNDLegalLinks.openPrivacyPolicy();
  }

  void toggleDontShowAgain(bool? value) {
    dontShowAgain.value = value ?? false;
  }

  Future<void> confirm() async {
    try {
      if (dontShowAgain.value) {
        final uid = AuthController.instance.uid;
        if (uid != null && uid.isNotEmpty) {
          await LNDStorageService.write(
            LNDStorageConstants.publishListingDisclaimerAcknowledgedKey(uid),
            true,
          );
        }
      }
      Get.back(result: true);
    } catch (e, st) {
      LNDLogger.e(
        'Failed to save publish listing disclaimer acknowledgement',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to save this preference.');
      Get.back(result: true);
    }
  }

  void cancel() {
    Get.back(result: false);
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/eligibility/eligibility.page.dart';

class ListingEligibleMiddleware extends GetMiddleware {
  @visibleForTesting
  static bool shouldRedirect({
    required bool hasPendingFullVerification,
    required bool canList,
  }) {
    return hasPendingFullVerification || !canList;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (ProfileController.instance.hasPendingFullVerification) {
      LNDSnackbar.showInfo(
        'Listing changes are blocked while verification is pending.',
      );
      return GetPage(
        name: EligibilityPage.routeName,
        page: () => const EligibilityPage(),
        fullscreenDialog: true,
      );
    }

    if (shouldRedirect(
      hasPendingFullVerification:
          ProfileController.instance.hasPendingFullVerification,
      canList: ProfileController.instance.canList,
    )) {
      return GetPage(
        name: EligibilityPage.routeName,
        page: () => const EligibilityPage(),
        fullscreenDialog: true,
      );
    }
    return super.onPageCalled(page);
  }
}

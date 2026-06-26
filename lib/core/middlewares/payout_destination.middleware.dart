import 'package:get/get.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/pages/owner_payout_destination/owner_payout_destination.page.dart';

class PayoutDestinationMiddleware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) {
    final missingDestinations =
        OwnerPayoutDestinationController
            .instance
            .shouldShowMissingPayoutDestinationBanner;
    if (missingDestinations) {
      LNDSnackbar.showWarning(
        'Please set up your payout destination before creating a listing.',
      );
      return GetPage(
        name: OwnerPayoutDestinationPage.routeName,
        page: () => const OwnerPayoutDestinationPage(),
        fullscreenDialog: true,
      );
    }
    return super.onPageCalled(page);
  }
}

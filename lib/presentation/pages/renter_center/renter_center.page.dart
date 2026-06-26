import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/controllers/renter_center/renter_center.controller.dart';
import 'package:lend/presentation/pages/renter_center/widgets/renter_center_item.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class RenterCenterPage extends GetView<RenterCenterController> {
  static const routeName = '/renter-center';

  const RenterCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: 'Renter Center', fontSize: 18.0),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            Obx(() {
              final payoutController =
                  OwnerPayoutDestinationController.instance;
              if (!payoutController
                  .shouldShowMissingDepositReturnDestinationWarning) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: LNDWarningBanner(
                  content: LNDText.regular(
                    text:
                        'You have not submitted your deposit return destination yet.',
                    overflow: TextOverflow.visible,
                  ),
                  onTap: controller.openDepositReturnDestination,
                ),
              );
            }),
            RenterCenterItem(
              icon: Icons.history_rounded,
              title: 'Rental History',
              onTap: controller.openRentalHistory,
            ),
            const SizedBox(height: 12.0),
            RenterCenterItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Deposit Return Destination',
              onTap: controller.openDepositReturnDestination,
            ),
          ],
        ),
      ),
    );
  }
}

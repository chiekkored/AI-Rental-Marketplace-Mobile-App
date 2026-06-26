import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/presentation/controllers/owner_center/owner_center.controller.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/pages/owner_center/widgets/owner_listing_card.widget.dart';
import 'package:lend/presentation/pages/owner_center/widgets/owner_metric_card.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class OwnerCenterPage extends GetView<OwnerCenterController> {
  static const String routeName = '/owner-center';

  const OwnerCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(
          onPressed: canPop ? () => Navigator.of(context).pop() : null,
        ),
        title: LNDText.bold(text: 'Owner Center', fontSize: 18.0),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Obx(() {
                final payoutController =
                    OwnerPayoutDestinationController.instance;
                if (!payoutController
                    .shouldShowMissingPayoutDestinationWarning) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: LNDWarningBanner(
                    content: LNDText.regular(
                      text:
                          'You have not submitted your payout destination yet.',
                      overflow: TextOverflow.visible,
                    ),
                    onTap: controller.openPayoutDestination,
                  ),
                );
              }),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: OwnerMetricCard(
                          icon: Icons.payments_outlined,
                          label: 'Payout total',
                          value: LNDMoney.format(
                            controller.ownerPayoutTotal,
                            currencyCode: controller.ownerPayoutCurrency,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: OwnerMetricCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Outstanding deduction',
                          value: LNDMoney.format(
                            controller.outstandingBalanceTotal,
                            currencyCode: controller.outstandingBalanceCurrency,
                          ),
                          danger: true,
                          onTap:
                              controller.outstandingBalanceTotal > 0
                                  ? controller.openOutstandingBalances
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                child: Obx(
                  () => OwnerListingCard(
                    availableCount: controller.availableListingCount,
                    hiddenCount: controller.hiddenListingCount,
                    onCreateListing: controller.goToCreateListing,
                    onOpenListings: controller.openOwnListings,
                    underMaintenanceCount:
                        controller.underMaintenanceListingCount,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 24.0),
                child: Obx(
                  () => Column(
                    children: [
                      if (controller.shouldShowBusinessRegistration) ...[
                        _OwnerCenterActionItem(
                          icon: Icons.business_center_outlined,
                          title: 'Business Registration',
                          onTap: controller.openBusinessRegistration,
                        ),
                        const SizedBox(height: 12.0),
                      ],
                      _OwnerCenterActionItem(
                        icon: Icons.account_balance_outlined,
                        title: 'Payout Destination',
                        onTap: controller.openPayoutDestination,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerCenterActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _OwnerCenterActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: colors.textPrimary),
              const SizedBox(width: 12.0),
              Expanded(
                child: LNDText.semibold(text: title, color: colors.textPrimary),
              ),
              SizedBox(
                height: 32.0,
                width: 32.0,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

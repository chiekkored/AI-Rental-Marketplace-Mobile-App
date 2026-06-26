import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/shimmer.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class AssetBottomNav extends GetView<AssetController> {
  const AssetBottomNav({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    if (controller.isBookingSnapshot) {
      return ColoredBox(
        color: colors.primary,
        child: SafeArea(
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LNDText.regular(
                  text: 'This is a property snapshot.',
                  color: Colors.white,
                ),
                LNDButton.text(
                  text: 'View live',
                  enabled: true,
                  onPressed: controller.viewLiveListing,
                  color: Colors.white,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        child: Container(
          height: kBottomNavigationBarHeight + 28.0,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outline, width: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  final rates = controller.asset?.rates;
                  final dailyRate = rates?.daily;
                  final hasOtherRates =
                      BookingPriceBreakdown.enabledRates(
                        rates,
                        includeDaily: false,
                      ).isNotEmpty;
                  if (controller.isAssetLoading || dailyRate == null) {
                    return const LNDShimmer(
                      child: LNDShimmerBox(height: 25.0, width: 100.0),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LNDText.bold(
                        text: LNDMoney.formatRate(dailyRate, rates),
                        fontSize: 18.0,
                        textParts: [
                          LNDText.regular(
                            text: ' daily',
                            color: colors.textMuted,
                            fontSize: 16.0,
                          ),
                        ],
                      ),
                      if (hasOtherRates)
                        LNDButton.text(
                          text: 'Other rates',
                          enabled: true,
                          onPressed: controller.openAllPrices,
                          hasPadding: false,
                          size: 12.0,
                          isBold: true,
                        ),
                    ],
                  );
                }),
                Obx(() {
                  if (controller.isAssetLoading) {
                    return const LNDShimmer(
                      child: LNDShimmerBox(height: 40.0, width: 100.0),
                    );
                  }
                  if (AuthController.instance.uid !=
                          controller.asset?.owner?.uid &&
                      ProfileController.instance.canRent) {
                    return SizedBox(
                      height: 50.0,
                      child: LNDButton.primary(
                        text: 'Reserve',
                        enabled:
                            !controller.isAssetLoading &&
                            controller.isAssetAvailableToBook,
                        onPressed: controller.goToCalendarPicker,
                      ),
                    );
                  } else if (AuthController.instance.uid ==
                          controller.asset?.owner?.uid &&
                      ProfileController.instance.canList) {
                    return Row(
                      spacing: 8.0,
                      children: [
                        Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.outline,
                          ),
                          child: Obx(
                            () => Badge.count(
                              count: controller.pendingBookingDates.length,
                              isLabelVisible:
                                  controller.pendingBookingDates.isNotEmpty,
                              child: Center(
                                child: LNDButton.icon(
                                  icon: Icons.calendar_month_rounded,
                                  size: 25.0,
                                  onPressed: controller.goToCalendarBookings,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.outline,
                          ),
                          child: Center(
                            child: LNDButton.icon(
                              icon: Icons.more_horiz_rounded,
                              size: 25.0,
                              onPressed: controller.showAssetOptionsBottomSheet,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

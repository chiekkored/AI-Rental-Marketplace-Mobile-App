import 'package:flutter/material.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_fee_calculator_sheet.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PricingFeeCalculatorBanner extends StatelessWidget {
  final CreateListingController controller;

  const PricingFeeCalculatorBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          LNDText.regular(
            text: 'Want to know how fees are calculated?',
            fontSize: 12,
            color: colors.textMuted,
          ),
          GestureDetector(
            onTap:
                () => LNDShow.bottomSheet(
                  PricingFeeCalculatorSheet(
                    initialDailyRate: controller.dailyPriceController.text,
                    initialWeeklyRate: controller.weeklyPriceController.text,
                    initialMonthlyRate: controller.monthlyPriceController.text,
                    initialYearlyRate: controller.annualPriceController.text,
                    initialDeposit:
                        controller.securityDepositEnabled.value
                            ? controller.securityDepositController.text
                            : '',
                  ),
                ),
            child: LNDText.medium(
              text: 'Try calculator now',
              fontSize: 12,
              color: colors.primary,
              textDecoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

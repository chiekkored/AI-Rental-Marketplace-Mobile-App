import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_fee_calculator_banner.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_fee_helpers.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_rate_field.dart';

class PricingRatesSection extends GetWidget<CreateListingController> {
  const PricingRatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final walletTransferFeeLabel = pricingWalletTransferFeeLabel();
    return CreateListingSection(
      title: 'Rates',
      required: true,
      description:
          'Set the daily rental price and optional longer-term rates for your item.',
      child: Obx(
        () => Column(
          children: [
            PricingFeeCalculatorBanner(controller: controller),
            const SizedBox(height: 12),
            PricingRateField(
              label: 'Daily rate',
              controller: controller.dailyPriceController,
            ),
            const SizedBox(height: 12),
            _OptionalRateToggleField(
              label: 'Weekly rate',
              enabled: controller.weeklyRateEnabled.value,
              onChanged: controller.setWeeklyRateEnabled,
              controller: controller.weeklyPriceController,
            ),
            const SizedBox(height: 12),
            _OptionalRateToggleField(
              label: 'Monthly rate',
              enabled: controller.monthlyRateEnabled.value,
              onChanged: controller.setMonthlyRateEnabled,
              controller: controller.monthlyPriceController,
            ),
            const SizedBox(height: 12),
            _OptionalRateToggleField(
              label: 'Annual rate',
              enabled: controller.annualRateEnabled.value,
              onChanged: controller.setAnnualRateEnabled,
              controller: controller.annualPriceController,
            ),
            const SizedBox(height: 12),
            PricingFeeWarningBanner(
              text:
                  '$walletTransferFeeLabel wallet transfer fee is deducted from your rental earnings when payout is sent.',
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionalRateToggleField extends StatelessWidget {
  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final TextEditingController controller;

  const _OptionalRateToggleField({
    required this.label,
    required this.enabled,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!enabled),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: LNDText.medium(text: label)),
                Switch.adaptive(
                  value: enabled,
                  onChanged: onChanged,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ],
            ),
          ),
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          PricingRateField(label: label, controller: controller),
        ],
      ],
    );
  }
}

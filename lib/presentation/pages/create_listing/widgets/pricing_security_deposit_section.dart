import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_fee_helpers.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_rate_field.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class PricingSecurityDepositSection extends GetWidget<CreateListingController> {
  const PricingSecurityDepositSection({super.key});

  @override
  Widget build(BuildContext context) {
    final walletTransferFeeLabel = pricingWalletTransferFeeLabel();
    return CreateListingSection(
      title: 'Security deposit',
      description:
          'Require a refundable deposit before renters can book this item.',
      child: Obx(
        () => Column(
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: controller.securityDepositEnabled.value,
              onChanged:
                  (value) => controller.securityDepositEnabled.value = value,
              title: LNDText.medium(text: 'Require deposit'),
            ),
            if (controller.securityDepositEnabled.value) ...[
              const SizedBox(height: 8),
              PricingRateField(
                label: 'Security deposit amount',
                controller: controller.securityDepositController,
              ),
              const SizedBox(height: 12),
              PricingFeeWarningBanner(
                text:
                    'Owners shoulder the payment fee for collecting this deposit. Another $walletTransferFeeLabel wallet transfer fee is deducted when returning the security deposit to the renter.',
              ),
              const SizedBox(height: 12),
              _SecurityDepositPaymentFeeEstimates(controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecurityDepositPaymentFeeEstimates extends StatefulWidget {
  final CreateListingController controller;

  const _SecurityDepositPaymentFeeEstimates({required this.controller});

  @override
  State<_SecurityDepositPaymentFeeEstimates> createState() =>
      _SecurityDepositPaymentFeeEstimatesState();
}

class _SecurityDepositPaymentFeeEstimatesState
    extends State<_SecurityDepositPaymentFeeEstimates> {
  @override
  void initState() {
    super.initState();
    widget.controller.securityDepositController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.securityDepositController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final amount =
        num.tryParse(
          widget.controller.securityDepositController.text
              .replaceAll(',', '')
              .trim(),
        ) ??
        0;
    final estimates = pricingDepositPaymentFeeEstimates(amount);
    if (estimates.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.medium(text: 'Owner-paid deposit fee estimates'),
          const SizedBox(height: 8),
          for (final estimate in estimates)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: LNDText.regular(
                      text: estimate.label,
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                  LNDText.medium(
                    text: LNDMoney.format(estimate.amount),
                    fontSize: 12,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

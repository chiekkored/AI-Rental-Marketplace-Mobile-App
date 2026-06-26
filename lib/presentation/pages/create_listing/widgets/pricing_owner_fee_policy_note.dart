import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_fee_helpers.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PricingOwnerFeePolicyNote extends GetWidget<CreateListingController> {
  const PricingOwnerFeePolicyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final policy = LNDRemoteConfigService.pricingPolicy;
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
          LNDText.medium(text: 'Owner settlement fees'),
          const SizedBox(height: 6),
          LNDText.regular(
            text: 'Wallet transfer: ${pricingWalletTransferFeeLabel()}',
            fontSize: 12,
            color: colors.textMuted,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 4),
          LNDText.regular(
            text: 'Platform fee: ${pricingFeeBasisLabel(policy.platformFee)}',
            fontSize: 12,
            color: colors.textMuted,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}

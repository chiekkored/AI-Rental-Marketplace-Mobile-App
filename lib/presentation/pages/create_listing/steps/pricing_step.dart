import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_rates_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_security_deposit_section.dart';

class PricingStep extends GetView<CreateListingController> {
  const PricingStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: controller.pricingStepIndex,
        title: 'Rates and security deposit',
        description:
            'Let renters know how much your item costs and whether a refundable deposit is required.',
        secondaryText: 'Back',
        secondaryAction:
            () => controller.goToStep(controller.inclusionsStepIndex),
        primaryText: 'Continue',
        primaryAction: controller.continueFromPricing,
        primaryEnabled: controller.canContinuePricing.value,
        child: Form(
          key: controller.pricingFormKey,
          child: const Column(
            children: [
              PricingRatesSection(),
              // SizedBox(height: 16),
              // PricingOwnerFeePolicyNote(),
              SizedBox(height: 16),
              PricingSecurityDepositSection(),
            ],
          ),
        ),
      ),
    );
  }
}

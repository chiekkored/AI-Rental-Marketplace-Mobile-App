import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_availability_section.dart';

class AvailabilityStep extends GetView<CreateListingController> {
  const AvailabilityStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: controller.availabilityStepIndex,
        title: 'Set availability',
        description:
            'Choose the listing status renters should see after this listing is saved.',
        secondaryText: 'Back',
        secondaryAction:
            () => controller.goToStep(controller.ownerInstructionsStepIndex),
        primaryText:
            controller.isEditing.value ? 'Update Listing' : 'Publish Listing',
        primaryAction: controller.publishListing,
        primaryEnabled: !controller.isSaving.value,
        primaryLoading: controller.isSaving.value,
        child: const PricingAvailabilitySection(),
      ),
    );
  }
}

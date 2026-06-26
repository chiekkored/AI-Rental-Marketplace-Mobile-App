import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';

class OwnerInstructionsStep extends GetView<CreateListingController> {
  const OwnerInstructionsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return CreateListingStepScaffold(
      stepIndex: controller.ownerInstructionsStepIndex,
      title: 'Owner instructions',
      description:
          'Add optional instructions renters should review after their payment is successful.',
      secondaryText: 'Back',
      secondaryAction:
          () => controller.goToStep(controller.endDateRuleStepIndex),
      primaryText: 'Continue',
      primaryAction: controller.continueFromOwnerInstructions,
      child: CreateListingSection(
        title: 'Listing Instructions',
        description:
            'These instructions will only be shown after successful payment and inside booking details. Not in the public listing.',
        child: LNDTextField.textBox(
          controller: controller.ownerInstructionsController,
          hintText:
              'Add pickup reminders, setup notes, return expectations, usage limits, or care instructions.',
          borderRadius: 12,
          maxLines: 8,
          maxLength: 1000,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class InclusionsStep extends GetView<CreateListingController> {
  const InclusionsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: controller.inclusionsStepIndex,
        title: 'What is included?',
        description:
            'List the items, accessories, or add-ons included with this rental.',
        secondaryText: 'Back',
        secondaryAction:
            () => controller.goToStep(controller.lastDynamicDetailsStepIndex),
        primaryText: 'Continue',
        primaryAction: controller.continueFromInclusions,
        child: CreateListingSection(
          title: 'Inclusions',
          description:
              'Add anything renters should expect to receive with the property.',
          child: CreateListingTappableField(
            label: 'Inclusions',
            value: controller.inclusions.join(', '),
            icon: Icons.checklist_rounded,
            placeholder: 'Add included items, accessories, or extras.',
            count:
                controller.inclusions.isEmpty
                    ? null
                    : controller.inclusions.length.toString(),
            onTap: LNDNavigate.toAddInclusionsPage,
          ),
        ),
      ),
    );
  }
}

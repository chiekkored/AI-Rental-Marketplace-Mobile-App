import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/steps/availability_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/category_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/details_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/dynamic_details_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/end_date_rule_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/inclusions_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/location_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/owner_instructions_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/photos_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/pricing_step.dart';
import 'package:lend/presentation/pages/create_listing/steps/subcategory_step.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingPage extends GetView<CreateListingController> {
  static const routeName = '/create-listing';
  const CreateListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: colors.background,
          leading: LNDButton.icon(
            icon: Icons.close_rounded,
            size: 24,
            onPressed: controller.closeListing,
          ),
          title: Obx(
            () => LNDText.bold(
              text:
                  controller.isEditing.value
                      ? 'Edit Listing'
                      : 'Create Listing',
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actionsPadding: const EdgeInsets.only(right: 24),
          actions: [
            Obx(
              () =>
                  controller.currentStep.value == controller.pricingStepIndex
                      ? LNDButton.icon(
                        icon: Icons.info_outline_rounded,
                        size: 25,
                        onPressed: controller.openPricingInfo,
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
        body: Obx(() {
          return IndexedStack(
            index: controller.currentStep.value,
            children: [
              const CategoryStep(),
              const SubcategoryStep(),
              const DetailsStep(),
              for (
                var index = 0;
                index < controller.dynamicDetailsStepCount;
                index++
              )
                DynamicDetailsStep(dynamicStepIndex: index),
              const InclusionsStep(),
              const PricingStep(),
              const LocationStep(),
              const PhotosStep(),
              const EndDateRuleStep(),
              const OwnerInstructionsStep(),
              const AvailabilityStep(),
            ],
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';

class DetailsStep extends GetView<CreateListingController> {
  const DetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    String hintText(String listingKind) {
      switch (listingKind) {
        case 'stay':
          return 'e.g., Cozy Studio Apartment in Downtown';
        case 'space':
          return 'e.g., A Space Near City Hall';
        case 'vehicle':
        case 'vehicles':
          return 'e.g., 2018 Tesla Model 3';
        case 'clothing':
          return 'e.g., Men\'s Large Leather Jacket';
        default:
          return 'e.g., Random Item From My Drawer';
      }
    }

    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: 2,
        title: 'Title and description',
        description:
            'Give your listing a clear title and helpful details renters can review before booking.',
        secondaryText: 'Back',
        secondaryAction:
            () => controller.goToStep(controller.requiresSubcategory ? 1 : 0),
        primaryText: 'Continue',
        primaryAction: controller.continueFromDetails,
        primaryEnabled: controller.canContinueDetails.value,
        child: Form(
          key: controller.detailsFormKey,
          child: Column(
            children: [
              CreateListingSection(
                title: 'Listing Title',
                required: true,
                description:
                    'Use a clear, descriptive title to help renters find your property.',
                child: LNDTextField.regular(
                  controller: controller.titleController,
                  hintText: hintText(controller.listingKind.value),
                  required: true,
                  maxLength: 80,
                  borderRadius: 12,
                  textCapitalization: TextCapitalization.words,
                  validator:
                      (value) => controller.validateField(
                        value,
                        label: 'Listing Title',
                      ),
                ),
              ),
              const SizedBox(height: 16),
              CreateListingSection(
                title: 'Description',
                description:
                    'Add details that help renters understand what makes your property useful and reliable.',
                child: LNDTextField.textBox(
                  controller: controller.descriptionController,
                  hintText:
                      'Describe your item, important details, and anything renters should know.',
                  borderRadius: 12,
                  maxLines: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

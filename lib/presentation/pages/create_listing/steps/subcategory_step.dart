import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';

class SubcategoryStep extends GetView<CreateListingController> {
  const SubcategoryStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: 1,
        title: 'Choose a subcategory',
        description:
            'Select the specific type that best describes your listing.',
        secondaryText: 'Back',
        secondaryAction: () => controller.goToStep(0),
        primaryText: 'Continue',
        primaryAction: controller.continueFromSubcategory,
        primaryEnabled:
            !controller.requiresSubcategory ||
            controller.selectedSubcategory.value != null,
        child: CreateListingSection(
          title: 'Subcategory',
          required: controller.requiresSubcategory,
          description:
              'Subcategories help show the right details and filters for your listing.',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              for (final category in controller.availableSubcategories)
                CreateListingCategoryCard(
                  category: category,
                  selected:
                      controller.selectedSubcategory.value?.id == category.id,
                  onTap: () => controller.selectSubcategory(category),
                  showIcon: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

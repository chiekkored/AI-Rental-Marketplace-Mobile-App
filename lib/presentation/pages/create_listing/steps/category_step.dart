import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/category/category.controller.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CategoryStep extends GetView<CreateListingController> {
  const CategoryStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final categoryController = CategoryController.instance;
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: 0,
        title: 'Choose a category',
        description:
            'Select the category that best matches what you want to rent out.',
        secondaryText: controller.isEditing.value ? 'Cancel' : 'Save Draft',
        secondaryAction:
            controller.isEditing.value
                ? controller.closeListing
                : () => controller.saveDraft(exitAfterSave: true),
        primaryText: 'Continue',
        primaryAction: controller.continueFromCategory,
        primaryEnabled: controller.canContinueCategory.value,
        showDummyButton: controller.showPostDummyDataButton,
        dummyAction: controller.postDummyListings,
        child: CreateListingSection(
          title: 'Category',
          required: true,
          description:
              'This helps renters find your listing in search and filters.',
          child:
              categoryController.isLoading.value &&
                      categoryController.parentCategories.isEmpty
                  ? Center(child: LNDSpinner(color: colors.textPrimary))
                  : categoryController.parentCategories.isEmpty
                  ? _CategoryUnavailable(
                    message:
                        categoryController.errorMessage.value.isNotEmpty
                            ? categoryController.errorMessage.value
                            : 'No categories available right now.',
                    onRetry: categoryController.refresh,
                  )
                  : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.8,
                    children: [
                      for (final category
                          in categoryController.parentCategories)
                        CreateListingCategoryCard(
                          category: category,
                          selected:
                              controller.selectedCategory.value?.id ==
                              category.id,
                          onTap: () => controller.selectCategory(category),
                        ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _CategoryUnavailable extends StatelessWidget {
  const _CategoryUnavailable({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LNDText.regular(
          text: message,
          color: colors.textMuted,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        LNDButton.outlined(
          text: 'Retry',
          enabled: true,
          onPressed: () => onRetry(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/category_listing/category_listing.controller.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/asset_list_tile.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CategoryListingPage extends GetView<CategoryListingController> {
  static const routeName = '/category-listing';

  const CategoryListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: controller.categoryName, fontSize: 18.0),
      ),
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator.adaptive(
            onRefresh: controller.getAssets,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (controller.isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LNDSpinner(color: colors.textPrimary)),
                  )
                else if (controller.assets.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: LNDText.regular(
                        text: 'No listings found',
                        color: colors.textMuted,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    sliver: SliverList.builder(
                      itemCount: controller.assets.length,
                      itemBuilder: (_, index) {
                        final asset = controller.assets[index];
                        return AssetListTile(
                          asset: asset,
                          onTap: () => controller.openAssetPage(asset),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

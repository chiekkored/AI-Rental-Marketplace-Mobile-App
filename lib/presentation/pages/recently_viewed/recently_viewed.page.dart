import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/recently_viewed/recently_viewed.controller.dart';
import 'package:lend/presentation/pages/recently_viewed/widgets/recently_viewed_empty_view.widget.dart';
import 'package:lend/presentation/pages/saved/widgets/saved_asset_card.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class RecentlyViewedPage extends GetView<RecentlyViewedController> {
  static const routeName = '/recently-viewed';

  const RecentlyViewedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(
          onPressed: canPop ? () => Navigator.of(context).pop() : null,
        ),
        title: LNDText.bold(text: 'Recently Viewed', fontSize: 18.0),
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: controller.loadRecentlyViewedAssets,
          child: Obx(() {
            if (controller.isLoading) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LNDSpinner(color: colors.textPrimary)),
                  ),
                ],
              );
            }

            if (controller.assets.isEmpty) {
              return const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: RecentlyViewedEmptyView(),
                  ),
                ],
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(12.0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((_, index) {
                      final asset = controller.assets[index];
                      return SavedAssetCard(
                        key: Key(asset.id),
                        asset: asset,
                        onTap: () => controller.openAssetPage(asset),
                        onOptionsTap: () => controller.showOptions(asset.id),
                      );
                    }, childCount: controller.assets.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.82,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

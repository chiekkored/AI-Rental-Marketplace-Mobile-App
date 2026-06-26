import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/saved/saved.controller.dart';
import 'package:lend/presentation/pages/saved/widgets/saved_asset_card.widget.dart';
import 'package:lend/presentation/pages/saved/widgets/saved_empty_view.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class SavedPage extends GetView<SavedController> {
  static const routeName = '/saved';
  const SavedPage({super.key, this.isTab = true});

  final bool isTab;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar:
          !isTab
              ? AppBar(
                surfaceTintColor: colors.surface,
                backgroundColor: colors.surface,
                leading: LNDButton.back(
                  onPressed: canPop ? () => Navigator.of(context).pop() : null,
                ),
                title: LNDText.bold(text: 'Saved', fontSize: 18.0),
                actions: [
                  LNDButton.icon(
                    icon: Icons.history_rounded,
                    size: 25.0,
                    onPressed: () => LNDNavigate.toRecentlyViewedPage(),
                  ),
                  const SizedBox(width: 8.0),
                ],
              )
              : null,
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.getSaved(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (isTab)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: LNDText.bold(text: 'Saved', fontSize: 32.0),
                        ),
                        LNDButton.icon(
                          icon: Icons.history_rounded,
                          size: 25.0,
                          onPressed: () => LNDNavigate.toRecentlyViewedPage(),
                        ),
                      ],
                    ),
                  ),
                ),
              Obx(() {
                if (controller.isLoading) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LNDSpinner(color: colors.textPrimary)),
                  );
                }

                if (controller.savedAssets.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: SavedEmptyView(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(12.0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((_, index) {
                      final asset = controller.savedAssets[index];
                      return SavedAssetCard(
                        key: Key(asset.id),
                        asset: asset,
                        onTap: () => controller.openAssetPage(asset),
                        onOptionsTap: () => controller.showOptions(asset.id),
                      );
                    }, childCount: controller.savedAssets.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.82,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

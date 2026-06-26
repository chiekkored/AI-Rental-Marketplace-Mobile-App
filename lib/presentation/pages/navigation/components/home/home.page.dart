import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/currency_mismatch_banner.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/asset_rail.widget.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/category_grid.widget.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/category_listing_section.widget.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/discover_header.widget.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/empty_state.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.getAssets(force: true),
          child: Obx(
            () => CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: DiscoverHeader()),
                if (controller.hasCurrencyMismatch)
                  SliverToBoxAdapter(
                    child: LNDCurrencyMismatchBanner(
                      activeCurrencyCode: controller.activeLocationCurrencyCode,
                      selectedCurrencyCode: controller.selectedCurrencyCode,
                    ),
                  ),
                if (AuthController.instance.isAuthenticated) ...[
                  SliverToBoxAdapter(
                    child: AssetRail(
                      title: 'Recommended',
                      assets: controller.recommendedAssets,
                      controller: controller,
                      isLoading: controller.isRecommendedLoading,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AssetRail(
                      title: 'Popular',
                      assets: controller.popularAssets,
                      controller: controller,
                      isLoading: controller.isPopularLoading,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: CategoryGrid()),
                if (controller.isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LNDSpinner(color: colors.textPrimary)),
                  )
                else if (controller.assets.isNotEmpty)
                  SliverToBoxAdapter(
                    child: AssetListingSection(
                      title: 'Explore',
                      assets: controller.assets,
                      controller: controller,
                    ),
                  )
                else
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeEmptyState(),
                  ),
                if (controller.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: LNDSpinner(color: colors.textPrimary),
                      ),
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

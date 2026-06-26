import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';
import 'package:lend/presentation/pages/your_listing/widgets/listing_status_filter_sheet.widget.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class YourListingPage extends GetView<YourListingController> {
  static const String routeName = '/your-listing';
  const YourListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(onPressed: () => Navigator.of(context).pop()),
        title: LNDText.bold(text: 'Your listing', fontSize: 18.0),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshMyAssets,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  height: 100.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => _buildStatusIndicator(
                          icon: Icons.check_circle,
                          label: 'Available',
                          color: colors.info,
                          value: controller.availableAssets,
                          selected: Availability.available,
                        ),
                      ),
                      Obx(
                        () => _buildStatusIndicator(
                          icon: Icons.build,
                          label: 'Under Maintenance',
                          color: colors.warning,
                          value: controller.underMaintenanceAssets,
                          selected: Availability.underMaintenance,
                        ),
                      ),
                      Obx(
                        () => _buildStatusIndicator(
                          icon: Icons.visibility_off,
                          label: 'Hidden',
                          color: colors.textMuted,
                          value: controller.hiddenAssets,
                          selected: Availability.hidden,
                        ),
                      ),
                    ],
                  ).withSpacing(12.0),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(
                    () => TextButton.icon(
                      onPressed: _showStatusFilterSheet,
                      iconAlignment: IconAlignment.end,
                      label: LNDText.bold(
                        text: controller.selectedFilter.label,
                        color: colors.textMuted,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (controller.isMyAssetsLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: LNDSpinner(color: colors.textPrimary)),
                );
              }

              final selectedFilter = controller.selectedFilter;
              if (controller.filteredAssetsFor(selectedFilter).isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: LNDText.regular(
                      text: 'No ${selectedFilter.label.toLowerCase()} listings',
                      color: colors.textMuted,
                    ),
                  ),
                );
              }

              return PagingListener<int, SimpleAsset>(
                controller: controller.pagingController,
                builder:
                    (
                      context,
                      state,
                      fetchNextPage,
                    ) => PagedSliverList<int, SimpleAsset>(
                      key: ValueKey(selectedFilter),
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<SimpleAsset>(
                        firstPageProgressIndicatorBuilder:
                            (_) => Center(
                              child: LNDSpinner(color: colors.textPrimary),
                            ),
                        newPageProgressIndicatorBuilder:
                            (_) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Center(
                                child: LNDSpinner(color: colors.textPrimary),
                              ),
                            ),
                        noItemsFoundIndicatorBuilder:
                            (_) => Center(
                              child: LNDText.regular(
                                text:
                                    'No ${selectedFilter.label.toLowerCase()} listings',
                                color: colors.textMuted,
                              ),
                            ),
                        noMoreItemsIndicatorBuilder:
                            (_) => const SizedBox.shrink(),
                        itemBuilder:
                            (_, asset, __) => _ListingTile(
                              key: ValueKey(
                                '${selectedFilter.label}-${asset.id}',
                              ),
                              asset: asset,
                            ),
                      ),
                    ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusFilterSheet() async {
    final selected = await LNDShow.bottomSheet<Availability>(
      ListingStatusFilterSheet(selected: controller.selectedFilter),
    );
    if (selected == null) return;
    controller.setFilter(selected);
  }

  /// Creates a status indicator with an icon, color and label
  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required Color color,
    required String value,
    required Availability selected,
  }) {
    final colors = Get.context!.lndTheme;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilter(selected),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  LNDText.medium(text: value),
                ],
              ).withSpacing(8.0),
              LNDText.regular(
                text: label,
                fontSize: 10.0,
                textAlign: TextAlign.start,
                overflow: TextOverflow.visible,
              ),
            ],
          ).withSpacing(8.0),
        ),
      ),
    );
  }
}

class _ListingTile extends GetWidget<YourListingController> {
  const _ListingTile({super.key, required this.asset});

  final SimpleAsset asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ListTile(
      tileColor: colors.surface,
      onTap: () => controller.goToAssetPage(asset),
      leading: LNDImage.square(imageUrl: asset.images.firstImageUrl),
      title: LNDText.regular(text: asset.title ?? ''),
      subtitle: Row(
        children: [
          Icon(
            _statusIcon(asset.status),
            color: _statusColor(colors, asset.status),
            size: 16.0,
          ),
          LNDText.regular(
            text: asset.categoryName ?? '',
            color: colors.textMuted,
          ),
        ],
      ).withSpacing(4.0),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (asset.pendingBookingCount > 0)
            Badge.count(count: asset.pendingBookingCount),
          Icon(Icons.chevron_right_rounded, color: colors.textMuted),
        ],
      ),
    );
  }
}

IconData _statusIcon(String? status) {
  if (status == Availability.available.label) return Icons.check_circle;
  if (status == Availability.underMaintenance.label) return Icons.build;
  return Icons.visibility_off;
}

Color _statusColor(dynamic colors, String? status) {
  if (status == Availability.available.label) return colors.info;
  if (status == Availability.underMaintenance.label) return colors.warning;
  return colors.textMuted;
}

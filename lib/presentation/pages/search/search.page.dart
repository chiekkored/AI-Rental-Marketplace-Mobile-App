import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset_search_filter.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/currency_mismatch_banner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/category/category.controller.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';
import 'package:lend/presentation/pages/search/components/search_body.component.dart';
import 'package:lend/presentation/pages/search/components/search_field.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SearchPage extends GetView<AssetSearchController> {
  static const routeName = '/search';
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: SearchFieldComponent.outerPadding,
              child: Row(
                children: [
                  LNDButton.back(),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: SearchFieldComponent(
                      controller: controller.searchController,
                      // focusNode: controller.focusNode,
                      autofocus: true,
                      showClearButton: true,
                      onClear: controller.clearSearch,
                      onFieldSubmitted: controller.submitSearch,
                    ),
                  ),
                  Obx(
                    () =>
                        controller.hasSubmittedQuery
                            ? Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: _SearchFilterButton(
                                showBadge: controller.hasActivePriceFilter,
                                onPressed: controller.showFilters,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Obx(
              () =>
                  controller.hasCurrencyMismatch
                      ? LNDCurrencyMismatchBanner(
                        activeCurrencyCode: controller.activeCurrencyCode,
                        selectedCurrencyCode: controller.selectedCurrencyCode,
                      )
                      : const SizedBox.shrink(),
            ),
            Obx(
              () =>
                  controller.hasSubmittedQuery
                      ? _SearchCategoryChips(
                        facets: controller.categoryFacets.toList(),
                        selectedCategories:
                            controller.selectedCategories.toList(),
                        onSelected: controller.selectCategoryFacet,
                      )
                      : const SizedBox.shrink(),
            ),
            const Expanded(child: SearchBodyComponent()),
          ],
        ),
      ),
    );
  }
}

class _SearchCategoryChips extends StatelessWidget {
  const _SearchCategoryChips({
    required this.facets,
    required this.selectedCategories,
    required this.onSelected,
  });

  final List<AssetSearchFacetOption> facets;
  final List<String> selectedCategories;
  final Future<void> Function(String? categoryId) onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedCategoryId =
        selectedCategories.isEmpty ? null : selectedCategories.first;
    final facetCounts = {for (final facet in facets) facet.value: facet.count};
    final categories =
        CategoryController.instance.parentCategories.toList()..sort((a, b) {
          final countA = facetCounts[a.id] ?? 0;
          final countB = facetCounts[b.id] ?? 0;
          final countCompare = countB.compareTo(countA);
          if (countCompare != 0) return countCompare;
          return a.sortOrder.compareTo(b.sortOrder);
        });

    return SizedBox(
      height: 44.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SearchCategoryChip(
              label: 'All',
              count: null,
              selected: selectedCategoryId == null,
              onTap: () => onSelected(null),
            );
          }

          final category = categories[index - 1];

          return _SearchCategoryChip(
            label: category.name,
            count:
                (facetCounts[category.id] ?? 0) > 0
                    ? facetCounts[category.id]
                    : null,
            selected: selectedCategoryId == category.id,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _SearchCategoryChip extends StatelessWidget {
  const _SearchCategoryChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return ChoiceChip(
      showCheckmark: false,
      selected: selected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LNDText.regular(
            text: label,
            color: selected ? colors.onPrimary : colors.textPrimary,
          ),
          if (count != null) ...[
            const SizedBox(width: 6.0),
            Container(
              height: 15.0,
              constraints: const BoxConstraints(minWidth: 15.0),
              // padding: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                color: selected ? colors.onPrimary : colors.primary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: LNDText.medium(
                  text: count.toString(),
                  color: selected ? colors.primary : colors.onPrimary,
                  fontSize: 8.0,
                ),
              ),
            ),
          ],
        ],
      ),
      selectedColor: colors.primary,
      backgroundColor: colors.surfaceMuted,
      side: BorderSide(color: selected ? colors.primary : colors.outline),
    );
  }
}

class _SearchFilterButton extends StatelessWidget {
  const _SearchFilterButton({required this.showBadge, required this.onPressed});

  final bool showBadge;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        LNDButton.icon(
          icon: Icons.tune_rounded,
          onPressed: onPressed,
          color: colors.textPrimary,
          size: 24.0,
        ),
        if (showBadge)
          Positioned(
            top: -5.0,
            right: -5.0,
            child: Container(
              height: 10.0,
              width: 10.0,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

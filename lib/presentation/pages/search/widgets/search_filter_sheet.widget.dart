import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset_search_filter.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  final AssetSearchController _controller = Get.find<AssetSearchController>();

  late AssetSearchPriceRange _priceRange;

  @override
  void initState() {
    super.initState();
    _priceRange =
        _controller.selectedPriceRange ??
        AssetSearchController.priceRanges.first;
  }

  Future<void> _apply() async {
    Get.back();
    await _controller.applyFilters(
      categories: _controller.selectedCategories,
      priceRange: _priceRange,
    );
  }

  Future<void> _reset() async {
    Get.back();
    await _controller.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: LNDText.semibold(text: 'Filters', fontSize: 18.0),
                  ),
                  LNDButton.text(
                    text: 'Reset',
                    onPressed: _reset,
                    enabled: true,
                    color: colors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              LNDText.medium(text: 'Daily price', fontSize: 14.0),
              const SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children:
                      AssetSearchController.priceRanges
                          .map(
                            (range) => InkWell(
                              onTap: () => setState(() => _priceRange = range),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _priceRange == range
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color:
                                          _priceRange == range
                                              ? colors.primary
                                              : colors.textMuted,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: LNDText.regular(
                                        text: range.label,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 20.0),
              LNDButton.primary(
                text: 'Apply filters',
                enabled: true,
                onPressed: _apply,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

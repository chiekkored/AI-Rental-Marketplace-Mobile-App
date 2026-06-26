import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';
import 'package:lend/presentation/pages/search/widgets/search_history_item.widget.dart';
import 'package:lend/presentation/pages/search/widgets/search_result_card.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SearchBodyComponent extends GetView<AssetSearchController> {
  const SearchBodyComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Obx(() {
      if (!controller.hasSubmittedQuery) {
        if (controller.searchHistory.isEmpty) {
          return Center(
            child: LNDText.regular(
              text: 'No recent searches',
              color: colors.textMuted,
            ),
          );
        }

        return ListView.separated(
          itemBuilder:
              (_, index) =>
                  SearchHistoryItem(query: controller.searchHistory[index]),
          separatorBuilder: (_, __) => Divider(color: colors.outline),
          itemCount: controller.searchHistory.length,
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
            child: LNDText.regular(
              text: 'Results for "${controller.submittedQuery}"',
              color: colors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: _buildResults(context)),
        ],
      );
    });
  }

  Widget _buildResults(BuildContext context) {
    final colors = context.lndTheme;

    if (controller.isLoading) {
      return Center(child: LNDSpinner(color: colors.textPrimary));
    }

    if (controller.results.isEmpty) {
      return Center(
        child: LNDText.regular(
          text: 'No listings found',
          color: colors.textMuted,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 12.0,
        childAspectRatio: 0.66,
      ),
      itemCount: controller.results.length,
      itemBuilder:
          (_, index) => SearchResultCard(result: controller.results[index]),
    );
  }
}

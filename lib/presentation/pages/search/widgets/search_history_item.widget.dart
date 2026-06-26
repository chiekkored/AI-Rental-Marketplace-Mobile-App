import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SearchHistoryItem extends GetWidget<AssetSearchController> {
  const SearchHistoryItem({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: () => controller.selectHistoryItem(query),
      trailing: Icon(Icons.north_west_rounded, color: colors.textMuted),
      dense: true,
      title: LNDText.regular(
        text: query,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

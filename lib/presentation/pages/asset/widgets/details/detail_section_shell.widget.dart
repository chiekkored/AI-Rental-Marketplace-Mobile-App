import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class AssetDetailSectionShell extends StatelessWidget {
  const AssetDetailSectionShell({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LNDText.semibold(text: title, fontSize: 18.0),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ).withSpacing(16.0),
        ],
      ).withSpacing(18.0),
    );
  }
}

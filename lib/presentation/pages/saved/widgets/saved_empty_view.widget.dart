import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SavedEmptyView extends StatelessWidget {
  const SavedEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Center(
      child: LNDText.regular(
        text: 'No saved listings yet',
        color: colors.textMuted,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class EmptySavedCards extends StatelessWidget {
  const EmptySavedCards({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LNDText.regular(
        text: 'No saved cards yet.',
        color: colors.textMuted,
      ),
    );
  }
}

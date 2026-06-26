import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class EmptyNowSection extends StatelessWidget {
  const EmptyNowSection({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: LNDText.regular(
        text: text,
        color: colors.textMuted,
        textAlign: TextAlign.center,
      ),
    );
  }
}

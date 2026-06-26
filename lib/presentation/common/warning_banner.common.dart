import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class LNDWarningBanner extends StatelessWidget {
  final LNDText content;
  final VoidCallback? onTap;
  const LNDWarningBanner({required this.content, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.warningSoft,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, color: colors.warning),
              const SizedBox(width: 10.0),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}

class LNDInfoBanner extends StatelessWidget {
  final LNDText content;
  final VoidCallback? onTap;
  const LNDInfoBanner({required this.content, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: colors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, color: colors.info),
              const SizedBox(width: 10.0),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    this.label,
    this.children = const [],
    this.child,
  });

  final String? label;
  final List<Widget> children;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
              child: LNDText.semibold(
                text: label!,
                fontSize: 12.0,
                color: colors.textMuted,
              ),
            ),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: child ?? Column(children: children),
          ),
        ],
      ),
    );
  }
}

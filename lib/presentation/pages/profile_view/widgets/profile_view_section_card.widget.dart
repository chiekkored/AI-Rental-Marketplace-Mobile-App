import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ProfileViewSectionCard extends StatelessWidget {
  const ProfileViewSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(text: title, fontSize: 16.0),
            const SizedBox(height: 16.0),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ProfileViewInfoRow extends StatelessWidget {
  const ProfileViewInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final resolvedValue =
        value == null || value!.trim().isEmpty ? 'N/A' : value!.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.medium(text: label, color: colors.textMuted, fontSize: 12.0),
          const SizedBox(height: 4.0),
          LNDText.regular(text: resolvedValue, overflow: TextOverflow.visible),
        ],
      ),
    );
  }
}

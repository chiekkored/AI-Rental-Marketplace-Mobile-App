import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class AssetDetailItem extends StatelessWidget {
  const AssetDetailItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(child: FaIcon(icon, color: colors.textPrimary, size: 20.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDText.medium(
                text: title,
                overflow: TextOverflow.visible,
                isSelectable: true,
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                LNDText.regular(
                  text: subtitle!,
                  color: colors.textMuted,
                  overflow: TextOverflow.visible,
                  isSelectable: true,
                ),
            ],
          ).withSpacing(4.0),
        ),
      ],
    ).withSpacing(12.0);
  }
}

class AssetDetailFlag extends StatelessWidget {
  const AssetDetailFlag({super.key, required this.enabled, required this.text});

  final bool enabled;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AssetDetailItem(
      icon:
          enabled ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark,
      title: text,
      subtitle: enabled ? 'Available' : 'Not available',
    );
  }
}

class AssetDetailNote extends StatelessWidget {
  const AssetDetailNote({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return AssetDetailItem(icon: icon, title: title, subtitle: text);
  }
}

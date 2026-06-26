import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SettingsItemW extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showTrailing;
  final Color? color;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;

  const SettingsItemW({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    this.subtitle,
    this.subtitleWidget,
    this.trailingWidget,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = context.lndTheme;
    final textPrimary = color ?? themeColor.textPrimary;
    return ListTile(
      dense: true,
      leading: icon != null ? Icon(icon, color: textPrimary) : null,
      onTap: onTap,
      splashColor: Colors.transparent,
      title: LNDText.regular(text: label, color: textPrimary),
      subtitle:
          subtitleWidget ??
          (subtitle != null
              ? LNDText.regular(
                text: subtitle!,
                color: themeColor.textSecondary,
                fontSize: 12,
              )
              : null),
      trailing:
          showTrailing
              ? trailingWidget ??
                  Icon(Icons.chevron_right_rounded, color: textPrimary)
              : null,
    );
  }
}

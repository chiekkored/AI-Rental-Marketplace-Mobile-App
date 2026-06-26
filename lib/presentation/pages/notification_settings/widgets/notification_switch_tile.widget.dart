import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class NotificationSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double? iconSize;

  const NotificationSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final enabled = onChanged != null;
    final textColor = enabled ? colors.textPrimary : colors.textMuted;

    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: textColor, size: iconSize),
      title: LNDText.regular(
        text: title,
        color: textColor,
        overflow: TextOverflow.visible,
      ),
      subtitle: LNDText.regular(
        text: subtitle,
        color: colors.textMuted,
        fontSize: 12.0,
        overflow: TextOverflow.visible,
      ),
    );
  }
}

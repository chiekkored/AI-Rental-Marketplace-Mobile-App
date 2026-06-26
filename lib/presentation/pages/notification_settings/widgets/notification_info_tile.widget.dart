import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class NotificationInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailingText;

  const NotificationInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return ListTile(
      leading: Icon(icon, color: colors.textPrimary),
      title: LNDText.regular(
        text: title,
        color: colors.textPrimary,
        overflow: TextOverflow.visible,
      ),
      subtitle: LNDText.regular(
        text: subtitle,
        color: colors.textMuted,
        fontSize: 12.0,
        overflow: TextOverflow.visible,
      ),
      trailing: LNDText.medium(
        text: trailingText,
        color: colors.textMuted,
        fontSize: 12.0,
      ),
    );
  }
}

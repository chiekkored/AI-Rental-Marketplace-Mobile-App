import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class RenterCenterItem extends StatelessWidget {
  const RenterCenterItem({
    super.key,
    required this.icon,
    required this.onTap,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: colors.textPrimary),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LNDText.semibold(text: title, color: colors.textPrimary),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4.0),
                      LNDText.regular(
                        text: subtitle!,
                        color: colors.textMuted,
                        fontSize: 12.0,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                height: 32.0,
                width: 32.0,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

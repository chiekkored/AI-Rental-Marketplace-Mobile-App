import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class OwnerMetricCard extends StatelessWidget {
  const OwnerMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final foreground = danger ? colors.danger : colors.textPrimary;
    final muted = danger ? colors.danger : colors.textMuted;
    final background = danger ? colors.dangerSoft : colors.surface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 116.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: foreground, size: 22.0),
              const SizedBox(height: 24.0),
              LNDText.regular(
                text: label,
                color: muted,
                fontSize: 12.0,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 4.0),
              LNDText.bold(
                text: value,
                color: foreground,
                fontSize: 16.0,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

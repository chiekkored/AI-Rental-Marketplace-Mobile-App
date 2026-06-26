import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_logo.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? logoAsset;
  final Widget? leading;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.logoAsset,
    this.leading,
    this.isSelected = false,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color:
            enabled
                ? colors.surfaceMuted
                : colors.surfaceMuted.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                leading ?? PaymentLogo(fallbackIcon: icon, asset: logoAsset),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LNDText.medium(
                        text: label,
                        color: enabled ? colors.textPrimary : colors.textMuted,
                      ),
                      if (subtitle != null || !enabled)
                        LNDText.regular(
                          text: enabled ? subtitle! : 'Unavailable',
                          color: colors.textMuted,
                          fontSize: 12.0,
                          overflow: TextOverflow.visible,
                        ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : enabled
                      ? Icons.chevron_right_rounded
                      : Icons.block_rounded,
                  color: isSelected ? colors.primary : colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

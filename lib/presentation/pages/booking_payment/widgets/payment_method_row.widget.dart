import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingPaymentMethodRow extends StatelessWidget {
  final String label;
  final Widget? leading;
  final VoidCallback onTap;
  final String? subtitle;

  const BookingPaymentMethodRow({
    required this.label,
    required this.onTap,
    this.leading,
    this.subtitle,
    super.key,
  });

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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              leading ??
                  Icon(Icons.payments_outlined, color: colors.textPrimary),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LNDText.medium(text: label, overflow: TextOverflow.visible),
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
              Icon(Icons.chevron_right_rounded, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

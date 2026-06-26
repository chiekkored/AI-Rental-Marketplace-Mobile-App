import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/damage_fee_request/damage_fee_request.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class DamageFeeReasonTile extends StatelessWidget {
  final DamageFeeReason reason;
  final bool selected;
  final VoidCallback onTap;

  const DamageFeeReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color:
                selected
                    ? colors.primary.withValues(alpha: 0.08)
                    : colors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? colors.primary : colors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(child: LNDText.regular(text: reason.label)),
              if (reason.requiresSupportReview)
                Icon(
                  Icons.support_agent_rounded,
                  size: 18,
                  color: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingTappableField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;
  final String placeholder;
  final String? count;
  final bool required;

  const CreateListingTappableField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.placeholder,
    this.count,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outline),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDText.bold(text: label, fontSize: 12, required: required),
                  const SizedBox(height: 4),
                  LNDText.regular(
                    text: (value?.isNotEmpty ?? false) ? value! : placeholder,
                    color:
                        (value?.isNotEmpty ?? false)
                            ? colors.textPrimary
                            : colors.textMuted,
                    fontSize: 12,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              LNDText.medium(text: count!, color: colors.primary),
            ],
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

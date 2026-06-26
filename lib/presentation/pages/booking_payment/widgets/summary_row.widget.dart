import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onValueTap;
  final bool isTotal;

  const BookingSummaryRow({
    required this.label,
    required this.value,
    this.onValueTap,
    this.isTotal = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LNDText.regular(
              text: label,
              color: colors.textMuted,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: GestureDetector(
              onTap: onValueTap,
              behavior:
                  onValueTap == null
                      ? HitTestBehavior.deferToChild
                      : HitTestBehavior.opaque,
              child:
                  isTotal
                      ? LNDText.bold(
                        text: value,
                        fontSize: 16.0,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.visible,
                      )
                      : LNDText.regular(
                        text: value,
                        color: onValueTap == null ? null : colors.primary,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.visible,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

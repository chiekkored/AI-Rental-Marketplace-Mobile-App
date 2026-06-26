import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class DeletedListingReason extends StatelessWidget {
  final String reason;

  const DeletedListingReason({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final displayReason =
        reason.trim().isEmpty
            ? 'This listing violated Lend terms and policies.'
            : reason.trim();

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(
              text: 'Reason',
              color: colors.textPrimary,
              fontSize: 16.0,
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.danger,
                  size: 18.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: LNDText.regular(
                    text: displayReason,
                    color: colors.textPrimary,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum BlockUserSheetAction { block, report, cancel }

class BlockUserSheet extends StatelessWidget {
  const BlockUserSheet({
    required this.displayName,
    required this.bookingRequiresCoordination,
    super.key,
  });

  final String displayName;
  final bool Function() bookingRequiresCoordination;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final name = displayName.trim().isEmpty ? 'this user' : displayName.trim();
    return Obx(() {
      final requiresCoordination = bookingRequiresCoordination();
      final messages = [
        'Their listings will be hidden from you.',
        'You won’t be able to start new bookings with each other.',
        if (requiresCoordination) ...[
          'Your current booking and chat will stay available until the booking is resolved.',
          'After it is resolved, you won’t be able to contact each other.',
        ] else ...[
          'You won’t be able to contact each other.',
          'This chat will be archived.',
        ],
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LNDText.bold(text: 'Block $name?', fontSize: 18),
                const SizedBox(height: 16),
                for (final text in messages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LNDText.regular(
                            text: text,
                            color: colors.textSecondary,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                LNDText.regular(
                  text:
                      'Blocking does not send a report to Lend. If this user violated our rules or created a safety concern, report them.',
                  color: colors.textSecondary,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.center,
                  child: LNDButton.text(
                    text: 'Report user',
                    enabled: true,
                    hasPadding: false,
                    color: colors.primary,
                    onPressed:
                        () => Get.back(result: BlockUserSheetAction.report),
                  ),
                ),
                const SizedBox(height: 24),
                LNDButton.primary(
                  text: 'Block',
                  enabled: true,
                  color: colors.danger,
                  onPressed: () => Get.back(result: BlockUserSheetAction.block),
                ),
                const SizedBox(height: 8),
                LNDButton.outlined(
                  text: 'Cancel',
                  textColor: colors.textPrimary,
                  enabled: true,
                  onPressed:
                      () => Get.back(result: BlockUserSheetAction.cancel),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

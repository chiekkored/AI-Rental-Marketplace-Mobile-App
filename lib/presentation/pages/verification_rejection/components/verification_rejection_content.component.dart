import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/verification_rejection/verification_rejection.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class VerificationRejectionContent
    extends GetView<VerificationRejectionController> {
  const VerificationRejectionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = context.lndTheme;
      final reviewedDateText = controller.reviewedDateText;

      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDText.bold(
                    text: 'Verification was rejected',
                    color: colors.textPrimary,
                    fontSize: 18.0,
                  ),
                  const SizedBox(height: 8.0),
                  LNDText.regular(
                    text:
                        reviewedDateText == null
                            ? 'Your verification request was reviewed.'
                            : 'Reviewed on $reviewedDateText.',
                    color: colors.textMuted,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Material(
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
                          text: controller.rejectionReason,
                          color: colors.textPrimary,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          LNDButton.primary(
            text: 'Review and resubmit',
            enabled: true,
            onPressed: controller.retryVerification,
          ),
        ],
      );
    });
  }
}

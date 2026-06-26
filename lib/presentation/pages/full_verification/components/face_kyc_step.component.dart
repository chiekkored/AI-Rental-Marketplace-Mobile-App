import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class FaceKycStepComponent extends GetView<FullVerificationController> {
  const FaceKycStepComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LNDText.bold(text: 'ID and face verification', fontSize: 26.0),
          const SizedBox(height: 8.0),
          LNDText.regular(
            text:
                'We will open Didit to verify your government ID and confirm your face matches the document. This helps keep Lend safe for renters and owners.',
            color: colors.textMuted,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 24.0),
          Expanded(
            child: ListView(
              children: const [
                _VerificationChecklistItem(
                  text: 'Use a valid, unexpired government-issued ID.',
                ),
                _VerificationChecklistItem(
                  text:
                      'Take a clear photo of the original ID, not a screenshot or photocopy.',
                ),
                _VerificationChecklistItem(
                  text:
                      'Keep your face visible and remove sunglasses, masks, or heavy glare.',
                ),
                _VerificationChecklistItem(
                  text:
                      'Find steady lighting and hold the camera still while it focuses.',
                ),
                SizedBox(height: 20.0),
                _DiditFinePrint(),
              ],
            ),
          ),
          Obx(
            () => LNDButton.primary(
              text: 'Proceed',
              enabled: true,
              isLoading: controller.diditLoading,
              borderRadius: 12.0,
              onPressed: controller.startDiditVerification,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationChecklistItem extends StatelessWidget {
  final String text;

  const _VerificationChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: colors.success, size: 20.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: LNDText.regular(
              text: text,
              color: colors.textPrimary,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiditFinePrint extends GetView<FullVerificationController> {
  const _DiditFinePrint();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.regular(
            text:
                'Lend uses Didit, a third-party identity verification provider, to process ID, liveness, and face-match checks. By proceeding, you will continue under the Didit Terms and Verification Privacy Notice.',
            color: colors.textMuted,
            fontSize: 12.0,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 14.0,
            runSpacing: 6.0,
            children: [
              LNDButton.text(
                text: 'Terms',
                enabled: true,
                hasPadding: false,
                isBold: true,
                size: 12.0,
                onPressed: controller.openDiditTerms,
              ),
              LNDButton.text(
                text: 'Verification Privacy Notice',
                enabled: true,
                hasPadding: false,
                isBold: true,
                size: 12.0,
                onPressed: controller.openDiditPrivacyNotice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

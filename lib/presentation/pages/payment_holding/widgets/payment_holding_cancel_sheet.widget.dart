import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentHoldingCancelSheet extends StatelessWidget {
  const PaymentHoldingCancelSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(text: 'Stop waiting?', fontSize: 18.0),
            const SizedBox(height: 8.0),
            LNDText.regular(
              text:
                  'Cancelling will stop this checkout and release the reserved dates. If you already approved payment, keep waiting for confirmation.',
              color: colors.textMuted,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 20.0),
            LNDButton.primary(
              text: 'Keep waiting',
              enabled: true,
              onPressed: () => Get.back(result: false),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: LNDButton.text(
                text: 'Continue cancelling',
                enabled: true,
                color: colors.danger,
                isBold: true,
                onPressed: () => Get.back(result: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

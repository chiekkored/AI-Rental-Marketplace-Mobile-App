import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/payment_holding/payment_holding.controller.dart';
import 'package:lend/presentation/pages/payment_holding/components/payment_holding_visual.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentHoldingPage extends GetView<PaymentHoldingController> {
  static const routeName = '/payment-holding';

  const PaymentHoldingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => controller.requestClose(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          automaticallyImplyLeading: false,
          title: LNDText.bold(text: 'Payment', fontSize: 18.0),
          actions: [
            Obx(
              () => LNDButton.icon(
                icon: Icons.close_rounded,
                color: colors.textPrimary,
                size: 24.0,
                isLoading: controller.isCancelling.value,
                onPressed: controller.requestClose,
              ),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 24.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(
                            () => PaymentHoldingVisual(
                              isSuccess: controller.isSuccess.value,
                              qrImageUrl: controller.qrImageUrl,
                            ),
                          ),
                          const SizedBox(height: 28.0),
                          Obx(
                            () => LNDText.bold(
                              text:
                                  controller.isSuccess.value
                                      ? 'Payment confirmed'
                                      : controller.title,
                              fontSize: 22.0,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          LNDText.regular(
                            text: controller.subtitle,
                            color: colors.textMuted,
                            fontSize: 14.0,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (controller.hasExternalPayment)
                  Obx(
                    () =>
                        controller.isSuccess.value
                            ? const SizedBox.shrink()
                            : LNDButton.primary(
                              text: 'Open payment page',
                              enabled: true,
                              isLoading:
                                  controller.isLaunchingExternalPayment.value,
                              onPressed: controller.openExternalPayment,
                            ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

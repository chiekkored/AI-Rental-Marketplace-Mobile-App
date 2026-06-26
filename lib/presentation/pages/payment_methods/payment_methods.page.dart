import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/pages/payment_methods/components/banking_payment_section.component.dart';
import 'package:lend/presentation/pages/payment_methods/components/card_payment_section.component.dart';
import 'package:lend/presentation/pages/payment_methods/components/wallet_payment_section.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentMethodsPage extends GetView<PaymentMethodsController> {
  static const routeName = '/payment-methods';

  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: 'Payment Method', fontSize: 18.0),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          children: [
            if (controller.recurringBillingOnly) ...[
              LNDText.regular(
                text:
                    'Recurring bookings show subscription payment methods enabled by Lend.',
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 12.0),
            ],
            const CardPaymentSection(),
            const SizedBox(height: 12.0),
            const WalletPaymentSection(),
            if (!controller.recurringBillingOnly) ...[
              const SizedBox(height: 12.0),
              const BankingPaymentSection(),
            ],
          ],
        ),
      ),
    );
  }
}

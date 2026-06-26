import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/outstanding_damage_balance.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/outstanding_damage_balances/outstanding_damage_balances.controller.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/payment_section.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/summary_row.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class OutstandingDamageBalancesPage
    extends GetView<OutstandingDamageBalancesController> {
  static const routeName = '/outstanding-damage-balances';

  const OutstandingDamageBalancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        leading: LNDButton.back(onPressed: Get.back),
        title: LNDText.bold(text: 'Damage payment', fontSize: 18.0),
      ),
      body: SafeArea(
        child: Obx(() {
          final balances = controller.balances;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            children: [
              BookingPaymentSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LNDText.bold(text: 'Outstanding balances'),
                    const SizedBox(height: 6.0),
                    LNDText.regular(
                      text:
                          'These balances are from previous listing penalties.',
                      color: colors.textMuted,
                      overflow: TextOverflow.visible,
                    ),
                    const Divider(height: 28.0),
                    if (balances.isEmpty)
                      LNDText.regular(
                        text: 'No outstanding balance found.',
                        color: colors.textMuted,
                      )
                    else
                      for (final balance in balances) ...[
                        _OutstandingBalanceTile(balance: balance),
                        if (balance != balances.last)
                          const Divider(height: 24.0),
                      ],
                    if (balances.isNotEmpty) ...[
                      const Divider(height: 28.0),
                      BookingSummaryRow(
                        label: 'Total outstanding',
                        value: LNDMoney.format(
                          controller.total,
                          currencyCode: controller.currency,
                        ),
                        isTotal: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OutstandingBalanceTile
    extends GetWidget<OutstandingDamageBalancesController> {
  const _OutstandingBalanceTile({required this.balance});

  final OutstandingDamageBalance balance;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDText.semibold(
                text: balance.listingTitle,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 4.0),
              LNDText.regular(
                text: LNDMoney.format(
                  balance.amount,
                  currencyCode: balance.currency,
                ),
                color: colors.danger,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12.0),
        LNDButton.text(
          text: 'Pay',
          enabled: balance.canPay,
          color: colors.primary,
          onPressed: () => controller.pay(balance),
        ),
      ],
    );
  }
}

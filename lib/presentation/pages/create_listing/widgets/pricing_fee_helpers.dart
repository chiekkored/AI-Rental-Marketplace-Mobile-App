import 'package:flutter/material.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/currency.helper.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

String pricingFeeBasisLabel(LNDFeeRule rule) {
  final fixedAmount = rule.fixedAmount;
  final fixedLabel =
      fixedAmount > 0
          ? LNDMoney.format(
            fixedAmount,
            currencyCode: LNDCurrency.paymongoFixedFeeCurrencyCode,
          )
          : '';
  return switch (rule.calculation) {
    'rate_only' => rule.percentLabel,
    'fixed_only' => fixedLabel,
    'max_rate_or_fixed' => '${rule.percentLabel} or $fixedLabel',
    _ =>
      fixedAmount > 0
          ? '${rule.percentLabel} + $fixedLabel'
          : rule.percentLabel,
  };
}

String pricingWalletTransferFeeLabel() {
  final fee = LNDRemoteConfigService.pricingPolicy.walletTransferFee;
  if (fee.providerFee.calculation == 'fixed_only' &&
      fee.lendMarkup.calculation == 'fixed_only') {
    return LNDMoney.format(
      fee.fixedAmount,
      currencyCode: LNDCurrency.paymongoFixedFeeCurrencyCode,
    );
  }
  final providerLabel = pricingFeeBasisLabel(fee.providerFee);
  final markupLabel = pricingFeeBasisLabel(fee.lendMarkup);
  return fee.lendMarkup.calculate(10000) > 0
      ? '$providerLabel + $markupLabel'
      : providerLabel;
}

double pricingEstimatedPaymentMethodFee({
  required num amount,
  required String method,
  Map<String, dynamic> details = const {},
}) {
  final policy = LNDRemoteConfigService.pricingPolicy;
  final resolved = policy.resolvePaymentMethodFee(
    method: method,
    details: details,
  );
  return policy.calculatePaymentMethodFee(amount, resolved.rule);
}

List<PricingPaymentFeeEstimate> pricingDepositPaymentFeeEstimates(num amount) {
  if (amount <= 0) return const [];
  return [
    PricingPaymentFeeEstimate(
      label: 'Card estimate',
      amount: pricingEstimatedPaymentMethodFee(amount: amount, method: 'card'),
    ),
    PricingPaymentFeeEstimate(
      label: 'E-wallet estimate',
      amount: pricingEstimatedPaymentMethodFee(amount: amount, method: 'gcash'),
    ),
    PricingPaymentFeeEstimate(
      label: 'Bank transfer estimate',
      amount: pricingEstimatedPaymentMethodFee(amount: amount, method: 'dob'),
    ),
  ];
}

class PricingPaymentFeeEstimate {
  final String label;
  final double amount;

  const PricingPaymentFeeEstimate({required this.label, required this.amount});
}

class PricingFeeWarningBanner extends StatelessWidget {
  final String text;

  const PricingFeeWarningBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: LNDText.regular(
              text: text,
              fontSize: 12,
              color: colors.textPrimary,
              textAlign: TextAlign.start,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

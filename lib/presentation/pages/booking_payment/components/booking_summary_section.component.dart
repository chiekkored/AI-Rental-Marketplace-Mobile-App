import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_payment/booking_payment.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_payment_due_today.helper.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/payment_section.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/summary_row.widget.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class BookingSummarySection extends GetView<BookingPaymentController> {
  const BookingSummarySection({super.key});

  int get _numDays =>
      controller.endDate.difference(controller.startDate).inDays;

  @override
  Widget build(BuildContext context) {
    final asset = controller.asset;
    final colors = context.lndTheme;
    final initialDueToday = BookingPaymentDueTodayHelper.calculate(
      asset: asset,
      startDate: controller.startDate,
      endDate: controller.endDate,
      totalPrice: controller.totalPrice,
      policy: LNDRemoteConfigService.pricingPolicy,
      selectedPaymentMethod: null,
      payerCountryShortName:
          ProfileController.instance.user?.location?.countryShortName,
    );
    final priceLines = initialDueToday.priceLines;
    final hasRecurringBilling = initialDueToday.hasRecurringBilling;
    final durationLabel = BookingPriceBreakdown.normalizedDurationLabel(
      priceLines,
      fallbackDays: _numDays,
    );

    return BookingPaymentSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 84.0,
                  width: 84.0,
                  child: LNDImage.custom(
                    imageUrl: asset.images.firstImageUrl,
                    height: 84.0,
                    width: 84.0,
                    borderRadius: 8.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LNDText.bold(
                            text: asset.title ?? 'Booking',
                            fontSize: 18.0,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (asset.categoryName?.trim().isNotEmpty == true)
                            LNDText.regular(
                              text: asset.categoryName!.trim(),
                              color: colors.textMuted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),

                      if (asset.averageRating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4.0,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: colors.warning,
                              size: 16.0,
                            ),
                            LNDText.regular(
                              text: LNDUtils.ratingLabel(asset.averageRating!),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 28.0),
          BookingSummaryRow(
            label: 'Dates',
            value: LNDUtils.getDateRange(
              start: controller.startDate,
              end: controller.endDate,
            ),
          ),
          BookingSummaryRow(label: 'Duration', value: durationLabel),
          if (priceLines.isNotEmpty) ...[
            const Divider(height: 28.0),
            LNDText.semibold(text: 'Price Breakdown'),
            const SizedBox(height: 6.0),
            if (asset.rates?.daily != null)
              BookingSummaryRow(
                label: 'Daily rate',
                value: LNDMoney.formatRate(asset.rates!.daily, asset.rates),
              ),
            ...[
              const SizedBox(height: 8.0),
              for (final line in priceLines)
                BookingSummaryRow(
                  label:
                      '${line.count} ${line.unitLabel} x '
                      '${LNDMoney.formatRate(line.rate, asset.rates)}',
                  value: LNDMoney.formatRate(line.amount, asset.rates),
                ),
            ],
          ],
          if (asset.securityDeposit.enabled) ...[
            BookingSummaryRow(
              label: 'Security deposit',
              value: LNDMoney.formatRate(
                asset.securityDeposit.amount,
                controller.asset.rates,
              ),
            ),
          ],
          const Divider(height: 28.0),
          Obx(() {
            final selectedMethod = controller.selectedPaymentMethod.value;
            final policy = LNDRemoteConfigService.pricingPolicy;
            final dueToday = BookingPaymentDueTodayHelper.calculate(
              asset: asset,
              startDate: controller.startDate,
              endDate: controller.endDate,
              totalPrice: controller.totalPrice,
              policy: policy,
              selectedPaymentMethod: selectedMethod,
              payerCountryShortName:
                  ProfileController.instance.user?.location?.countryShortName,
            );
            final resolvedFee = dueToday.resolvedFee;
            final hasNextBilling =
                dueToday.hasRecurringBilling &&
                dueToday.subscriptionSplit.nextBillingDate != null &&
                dueToday.subscriptionSplit.nextBillingAmount != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LNDText.semibold(text: 'Payment'),
                const SizedBox(height: 6.0),
                if (hasRecurringBilling) ...[
                  for (final line in dueToday.subscriptionSplit.upfrontLines)
                    BookingSummaryRow(
                      label: line.label,
                      value: LNDMoney.formatRate(
                        line.amount,
                        controller.asset.rates,
                      ),
                    ),
                  BookingSummaryRow(
                    label: 'Due today rental',
                    value: LNDMoney.formatRate(
                      dueToday.dueNowRentalSubtotal,
                      controller.asset.rates,
                    ),
                  ),
                  if (asset.securityDeposit.enabled) ...[
                    BookingSummaryRow(
                      label: 'Security deposit',
                      value: LNDMoney.formatRate(
                        asset.securityDeposit.amount,
                        controller.asset.rates,
                      ),
                    ),
                  ],
                ],
                BookingSummaryRow(
                  label:
                      hasRecurringBilling
                          ? 'Due today before fees'
                          : 'Total before fees',
                  value: LNDMoney.formatRate(
                    dueToday.amountBeforeFees,
                    controller.asset.rates,
                  ),
                ),
                if (selectedMethod != null) ...[
                  BookingSummaryRow(
                    label: 'Processing fee',
                    value: LNDMoney.formatRate(
                      dueToday.processingFee,
                      controller.asset.rates,
                    ),
                    onValueTap:
                        () => _showFeeBasisInfo(
                          rule: resolvedFee!.rule,
                          methodLabel: _debugPaymentMethodLabel(
                            selectedMethod.methodType,
                            resolvedFee.label,
                          ),
                          rentalSubtotal: dueToday.dueNowRentalSubtotal,
                          securityDeposit: dueToday.securityDeposit,
                          platformFee: dueToday.platformFee,
                          processingBaseAmount: dueToday.processingBaseAmount,
                          processingBaseFee: dueToday.processingBaseFee,
                          paymentMethodProcessingFee:
                              dueToday.paymentMethodProcessingFee,
                          processingFee: dueToday.processingFee,
                          totalDue: dueToday.totalDue,
                          vatRateBps: policy.paymentMethodFeeVatRateBps,
                        ),
                  ),
                ],
                selectedMethod != null
                    ? BookingSummaryRow(
                      label: hasRecurringBilling ? 'Due today' : 'Total',
                      value: dueToday.totalDueLabel,
                      isTotal: true,
                    )
                    : const SizedBox.shrink(),
                if (selectedMethod != null && hasNextBilling) ...[
                  const Divider(height: 28.0),
                  BookingSummaryRow(
                    label: _nextBillingLabel(
                      date: dueToday.subscriptionSplit.nextBillingDate!,
                    ),
                    value: LNDMoney.formatRate(
                      dueToday.subscriptionSplit.nextBillingAmount!,
                      controller.asset.rates,
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  String _nextBillingLabel({required DateTime date}) {
    return 'Next billing (2nd cycle) on ${DateFormat('MMM d, y').format(date)}';
  }

  void _showFeeBasisInfo({
    required LNDFeeRule rule,
    required String methodLabel,
    required num rentalSubtotal,
    required num securityDeposit,
    required num platformFee,
    required num processingBaseAmount,
    required num processingBaseFee,
    required num paymentMethodProcessingFee,
    required num processingFee,
    required num totalDue,
    required num vatRateBps,
  }) {
    final vatMultiplier = 1 + vatRateBps / 10000;
    LNDShow.bottomSheetInfo([
      LNDText.regular(
        text:
            'Processing fees help cover payment method charges, VAT, platform costs, and secure payment handling for the booking.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'The final amount can vary based on the selected payment method and payment confirmation.',
        overflow: TextOverflow.visible,
      ),
      if (kDebugMode) ...[
        LNDText.semibold(
          text: 'Debug calculations',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text: 'Rental subtotal: ${debugCurrencyAmount(rentalSubtotal)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text: 'Security deposit: ${debugCurrencyAmount(securityDeposit)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text: 'Platform fee: ${debugCurrencyAmount(platformFee)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text:
              '$methodLabel processing base: '
              '${debugFormulaAmount(rentalSubtotal)} + '
              '${debugFormulaAmount(platformFee)} = '
              '${debugCurrencyAmount(processingBaseAmount)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text:
              '$methodLabel base fee: '
              '${debugFeeFormula(processingBaseAmount, rule)} = '
              '${debugFormulaAmount(processingBaseFee)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text:
              'VAT: ${debugPercentFromBps(vatRateBps)} of '
              '${methodLabel.toLowerCase()} base fee',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text:
              '$methodLabel fee with VAT: '
              '${debugFormulaAmount(processingBaseFee)} * '
              '${debugFormulaAmount(vatMultiplier)} = '
              '${debugCurrencyAmount(paymentMethodProcessingFee)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text:
              'Processing fee: ${debugFormulaAmount(platformFee)} + '
              '${debugFormulaAmount(paymentMethodProcessingFee)} = '
              '${debugCurrencyAmount(processingFee)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text:
              'Total due: ${debugFormulaAmount(rentalSubtotal)} + '
              '${debugFormulaAmount(securityDeposit)} + '
              '${debugFormulaAmount(processingFee)} = '
              '${debugCurrencyAmount(totalDue)}',
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
      ],
    ], title: 'Processing fee');
  }

  String _debugPaymentMethodLabel(String method, String resolvedLabel) {
    if (method == 'card') return 'Card';
    final label = resolvedLabel.trim();
    if (label.isNotEmpty) return label;
    return method;
  }
}

@visibleForTesting
String debugCurrencyAmount(num amount) => amount.toStringAsFixed(2);

@visibleForTesting
String debugFormulaAmount(num amount) {
  var value = amount.toStringAsFixed(4);
  value = value.replaceFirst(RegExp(r'0+$'), '');
  return value.replaceFirst(RegExp(r'\.$'), '');
}

@visibleForTesting
String debugPercentFromBps(num bps) {
  var value = (bps / 100).toStringAsFixed(4);
  value = value.replaceFirst(RegExp(r'0+$'), '');
  return '${value.replaceFirst(RegExp(r'\.$'), '')}%';
}

@visibleForTesting
String debugFeeFormula(num baseAmount, LNDFeeRule rule) {
  final base = debugFormulaAmount(baseAmount);
  final rate = debugPercentFromBps(rule.rateBps);
  final fixed = debugFormulaAmount(rule.fixedAmount);

  return switch (rule.calculation) {
    'rate_only' => '($base * $rate)',
    'fixed_only' => fixed,
    'max_rate_or_fixed' => 'max($base * $rate, $fixed)',
    _ => rule.fixedAmount > 0 ? '($base * $rate) + $fixed' : '($base * $rate)',
  };
}

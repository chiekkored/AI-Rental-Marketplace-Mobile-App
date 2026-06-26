import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';
import 'package:lend/utilities/helpers/currency.helper.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class BookingPaymentDueToday {
  final List<BookingPriceBreakdownLine> priceLines;
  final BookingSubscriptionSplit subscriptionSplit;
  final LNDResolvedPaymentFee? resolvedFee;
  final num dueNowRentalSubtotal;
  final num securityDeposit;
  final num platformFee;
  final num processingBaseAmount;
  final num processingBaseFee;
  final num paymentMethodProcessingFee;
  final num processingFee;
  final num amountBeforeFees;
  final num totalDue;
  final String totalDueLabel;
  final bool hasRecurringBilling;

  const BookingPaymentDueToday({
    required this.priceLines,
    required this.subscriptionSplit,
    required this.resolvedFee,
    required this.dueNowRentalSubtotal,
    required this.securityDeposit,
    required this.platformFee,
    required this.processingBaseAmount,
    required this.processingBaseFee,
    required this.paymentMethodProcessingFee,
    required this.processingFee,
    required this.amountBeforeFees,
    required this.totalDue,
    required this.totalDueLabel,
    required this.hasRecurringBilling,
  });
}

class BookingPaymentDueTodayHelper {
  BookingPaymentDueTodayHelper._();

  static BookingPaymentDueToday calculate({
    required Asset asset,
    required DateTime startDate,
    required DateTime endDate,
    required int totalPrice,
    required LNDPricingPolicy policy,
    required LNDSelectedPaymentMethod? selectedPaymentMethod,
    required String? payerCountryShortName,
  }) {
    final priceLines = BookingPriceBreakdown.calculate(
      rates: asset.rates,
      startDate: startDate,
      endDate: endDate,
    );
    final subscriptionSplit = BookingPriceBreakdown.subscriptionSplit(
      priceLines,
    );
    final dueNowRentalSubtotal =
        priceLines.isEmpty
            ? totalPrice
            : subscriptionSplit.dueTodayRentalSubtotal;
    final resolvedFee =
        selectedPaymentMethod == null
            ? null
            : policy.resolvePaymentMethodFee(
              method: selectedPaymentMethod.methodType,
              details: selectedPaymentMethod.details,
              payerCountryShortName: payerCountryShortName,
            );
    final platformFee = policy.platformFee.calculate(dueNowRentalSubtotal);
    final processingBaseAmount = dueNowRentalSubtotal + platformFee;
    final paymentMethodProcessingFee =
        resolvedFee == null
            ? 0
            : policy.calculatePaymentMethodFee(
              processingBaseAmount,
              resolvedFee.rule,
            );
    final processingBaseFee =
        resolvedFee == null
            ? 0
            : resolvedFee.rule.calculate(processingBaseAmount);
    final processingFee = platformFee + paymentMethodProcessingFee;
    final securityDeposit =
        asset.securityDeposit.enabled ? asset.securityDeposit.amount : 0;
    final amountBeforeFees = dueNowRentalSubtotal + securityDeposit;
    final listingCurrency =
        asset.rates?.currency?.trim().isNotEmpty == true
            ? asset.rates!.currency!.trim()
            : LNDMoney.currentCurrencyCode();
    final isPhpListing =
        listingCurrency == LNDCurrency.paymongoFixedFeeCurrencyCode;
    final totalDue =
        isPhpListing ? amountBeforeFees + processingFee : amountBeforeFees;
    final totalDueLabel =
        isPhpListing
            ? LNDMoney.formatRate(totalDue, asset.rates)
            : '${LNDMoney.formatRate(totalDue, asset.rates)} + fees';

    return BookingPaymentDueToday(
      priceLines: priceLines,
      subscriptionSplit: subscriptionSplit,
      resolvedFee: resolvedFee,
      dueNowRentalSubtotal: dueNowRentalSubtotal,
      securityDeposit: securityDeposit,
      platformFee: platformFee,
      processingBaseAmount: processingBaseAmount,
      processingBaseFee: processingBaseFee,
      paymentMethodProcessingFee: paymentMethodProcessingFee,
      processingFee: processingFee,
      amountBeforeFees: amountBeforeFees,
      totalDue: totalDue,
      totalDueLabel: totalDueLabel,
      hasRecurringBilling: subscriptionSplit.hasRecurringBilling,
    );
  }
}

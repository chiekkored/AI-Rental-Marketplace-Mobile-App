import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_info_section.widget.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_receipt.widget.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class BookingDetailsPaymentSummarySection
    extends GetView<BookingDetailsController> {
  const BookingDetailsPaymentSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BookingDetailsPaymentSummaryCard(
      booking: controller.booking,
      isOwner: controller.isOwner,
    );
  }
}

class BookingDetailsPaymentSummaryCard extends StatelessWidget {
  const BookingDetailsPaymentSummaryCard({
    required this.booking,
    required this.isOwner,
    super.key,
  });

  final Booking booking;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final payment = booking.paymentFlow;
    final priceBreakdown = booking.priceBreakdown;
    final rentalSubtotal = priceBreakdown.rentalSubtotal ?? booking.totalPrice;
    final securityDepositAmount =
        priceBreakdown.securityDepositAmount ??
        booking.depositFlow?.amount ??
        (booking.securityDeposit.enabled
            ? booking.securityDeposit.amount
            : null);
    final paymentAmount = priceBreakdown.paymentAmount ?? payment?.amount;
    final ownerPayoutAmount = _baseOwnerPayoutAmount();
    final ownerPenaltyDeductionAmount = _ownerPenaltyDeductionAmount();
    final ownerFinalPayoutAmount = _ownerFinalPayoutAmount(
      ownerPayoutAmount,
      ownerPenaltyDeductionAmount,
    );
    final ownerPayoutStatus = _ownerPayoutStatus();
    final renterCombinedProcessingFee = _positiveSum([
      priceBreakdown.renterPlatformFee,
      priceBreakdown.renterProcessingFee,
    ]);
    final ownerCombinedProcessingFee = priceBreakdown.ownerProcessingFee;
    final fallbackTotal = paymentAmount ?? booking.totalPrice;
    final hasPaymentDetails =
        payment?.method?.trim().isNotEmpty == true ||
        payment?.status?.trim().isNotEmpty == true ||
        ownerPayoutStatus?.trim().isNotEmpty == true ||
        payment?.transactionId?.trim().isNotEmpty == true ||
        payment?.checkoutId?.trim().isNotEmpty == true;
    final hasAmountBreakdown =
        rentalSubtotal != null ||
        _hasPositiveAmount(securityDepositAmount) ||
        _hasPositiveAmount(renterCombinedProcessingFee) ||
        _hasPositiveAmount(ownerCombinedProcessingFee) ||
        _hasPositiveAmount(ownerPenaltyDeductionAmount) ||
        fallbackTotal != null ||
        ownerFinalPayoutAmount != null;

    return BookingDetailsInfoSection(
      title: 'Payment summary',
      child: Column(
        children: [
          if (payment?.method?.trim().isNotEmpty == true)
            BookingDetailsReceiptRow(
              label: 'Payment method',
              value: _formatStatus(payment!.method!),
            ),
          if (payment?.status?.trim().isNotEmpty == true)
            BookingDetailsReceiptRow(
              label: 'Payment status',
              value: _formatStatus(payment!.status!),
            ),
          if (isOwner && ownerPayoutStatus?.trim().isNotEmpty == true)
            BookingDetailsReceiptRow(
              label: 'Payout status',
              value: _formatStatus(ownerPayoutStatus!),
            ),
          if (payment?.transactionId?.trim().isNotEmpty == true)
            BookingDetailsReceiptRow(
              label: 'Transaction ID',
              value: payment!.transactionId!,
            ),
          if (payment?.checkoutId?.trim().isNotEmpty == true)
            BookingDetailsReceiptRow(
              label: 'Checkout ID',
              value: payment!.checkoutId!,
            ),
          if (hasPaymentDetails && hasAmountBreakdown)
            const BookingDetailsReceiptDivider(),
          if (isOwner) ...[
            if (_hasPositiveAmount(securityDepositAmount))
              BookingDetailsReceiptRow(
                label: 'Security deposit',
                value: _formatMoney(securityDepositAmount),
              ),
            if (rentalSubtotal != null)
              BookingDetailsReceiptRow(
                label: 'Rental subtotal',
                value: _formatMoney(rentalSubtotal),
              ),
            if (_hasPositiveAmount(ownerCombinedProcessingFee))
              BookingDetailsReceiptRow(
                label: 'Processing fee',
                value: '-${_formatMoney(ownerCombinedProcessingFee)}',
              ),
            if (_hasPositiveAmount(ownerPenaltyDeductionAmount))
              BookingDetailsReceiptRow(
                label: 'Previous cancellation deduction',
                value: '-${_formatMoney(ownerPenaltyDeductionAmount)}',
              ),
            BookingDetailsReceiptRow(
              label:
                  ownerFinalPayoutAmount == null
                      ? 'Booking total'
                      : 'Your payout',
              value: _formatMoney(ownerFinalPayoutAmount ?? fallbackTotal),
              isTotal: true,
            ),
          ] else ...[
            if (rentalSubtotal != null)
              BookingDetailsReceiptRow(
                label: 'Rental subtotal',
                value: _formatMoney(rentalSubtotal),
              ),
            if (_hasPositiveAmount(securityDepositAmount))
              BookingDetailsReceiptRow(
                label: 'Security deposit',
                value: _formatMoney(securityDepositAmount),
              ),
            if (_hasPositiveAmount(renterCombinedProcessingFee))
              BookingDetailsReceiptRow(
                label: 'Processing fee',
                value: _formatMoney(renterCombinedProcessingFee),
              ),
            BookingDetailsReceiptRow(
              label: paymentAmount == null ? 'Booking total' : 'Total paid',
              value: _formatMoney(fallbackTotal),
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }

  bool _hasPositiveAmount(num? amount) => amount != null && amount > 0;

  num? _baseOwnerPayoutAmount() {
    final pricingBreakdown = booking.payment?.pricingBreakdown;
    return booking.payoutFlow?.ownerPayoutAmountBeforePenalty ??
        booking.priceBreakdown.ownerPayoutAmount ??
        _numValue(pricingBreakdown, 'ownerPayoutAmount') ??
        booking.payment?.ownerPayoutAmount;
  }

  num? _ownerPenaltyDeductionAmount() {
    final amount = booking.payoutFlow?.ownerPenaltyDeductionAmount;
    return _hasPositiveAmount(amount) ? amount : null;
  }

  num? _ownerFinalPayoutAmount(num? baseAmount, num? penaltyDeductionAmount) {
    if (!_hasPositiveAmount(penaltyDeductionAmount)) return baseAmount;

    final payoutAmount = booking.payoutFlow?.ownerPayoutAmount;
    if (payoutAmount != null) return payoutAmount;
    if (baseAmount != null) {
      final amount = baseAmount - penaltyDeductionAmount!;
      return amount > 0 ? amount : 0;
    }
    return null;
  }

  String? _ownerPayoutStatus() {
    final status = booking.payoutFlow?.ownerPayoutStatus;
    if (status?.trim().isNotEmpty == true) return status;
    return _isCancelledFullRefund() ? 'cancelled' : null;
  }

  bool _isCancelledFullRefund() {
    if (!isOwner || booking.status != BookingStatus.cancelled) return false;
    if (_retainedOwnerAmount() > 0) return false;
    return booking.paymentFlow?.refundType == 'full' ||
        booking.cancellationRequest?.renterPenalty?['refundType'] == 'full' ||
        booking.cancellationRequest?.ownerPenalty != null;
  }

  num _retainedOwnerAmount() {
    final retained =
        booking.cancellationRequest?.renterPenalty?['retainedOwnerAmount'];
    if (retained is num) return retained;
    return 0;
  }

  num? _numValue(Map<String, dynamic>? map, String key) {
    final value = map?[key];
    return value is num ? value : null;
  }

  num _positiveSum(Iterable<num?> amounts) {
    return amounts.fold<num>(
      0,
      (sum, amount) => amount == null || amount <= 0 ? sum : sum + amount,
    );
  }

  String _formatMoney(num? amount) {
    final currency =
        booking.paymentFlow?.currency?.trim() ??
        booking.priceBreakdown.currency?.trim();
    if (currency?.isNotEmpty == true) {
      return LNDMoney.format(amount, currencyCode: currency!.toUpperCase());
    }
    return LNDMoney.formatRate(amount, booking.asset?.rates);
  }

  String _formatStatus(String value) {
    return value
        .trim()
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

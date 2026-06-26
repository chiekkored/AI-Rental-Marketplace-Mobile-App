import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_info_section.widget.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_receipt.widget.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class BookingDetailsCancellationSummarySection
    extends GetView<BookingDetailsController> {
  const BookingDetailsCancellationSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = controller.booking;
    if (!BookingDetailsCancellationSummaryCard.shouldShow(
      booking,
      isOwner: controller.isOwner,
    )) {
      return const SizedBox.shrink();
    }

    return const Column(
      children: [_ConnectedCancellationSummaryCard(), SizedBox(height: 16.0)],
    );
  }
}

class _ConnectedCancellationSummaryCard
    extends GetView<BookingDetailsController> {
  const _ConnectedCancellationSummaryCard();

  @override
  Widget build(BuildContext context) {
    return BookingDetailsCancellationSummaryCard(
      booking: controller.booking,
      isOwner: controller.isOwner,
    );
  }
}

class BookingDetailsCancellationSummaryCard extends StatelessWidget {
  const BookingDetailsCancellationSummaryCard({
    required this.booking,
    required this.isOwner,
    super.key,
  });

  final Booking booking;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    if (!shouldShow(booking, isOwner: isOwner)) {
      return const SizedBox.shrink();
    }

    final request = booking.cancellationRequest;
    final refundAmount = _refundAmount();
    final retainedOwnerAmount = _retainedOwnerAmount();
    final securityDepositRefundAmount = _securityDepositRefundAmount();
    final manualSecurityDepositRefundAmount =
        _manualSecurityDepositRefundAmount();
    final ownerPenaltyAmount = _ownerPenaltyAmount();
    final ownerPayoutTransferFee = _ownerPayoutTransferFee();
    final finalPayoutAmount = _finalPayoutAmount(retainedOwnerAmount);
    final finalRefundAmount = _finalRefundAmount(
      refundAmount,
      manualSecurityDepositRefundAmount,
    );

    return BookingDetailsInfoSection(
      title: 'Cancellation summary',
      child: Column(
        children: [
          if (_firstText([request?.status, booking.status?.label])
              case final status?)
            BookingDetailsReceiptRow(
              label: 'Cancellation status',
              value: _formatStatus(status),
            ),
          if (_firstText([request?.requestedByRole]) case final role?)
            BookingDetailsReceiptRow(
              label: 'Requested by',
              value: _requestedByLabel(role),
            ),
          if (_firstText([request?.reason]) case final reason?)
            BookingDetailsReceiptRow(label: 'Reason', value: reason),
          if (_firstText([booking.paymentFlow?.refundType]) case final type?)
            BookingDetailsReceiptRow(
              label: 'Refund type',
              value: _formatStatus(type),
            ),
          // if (_firstText([
          //       request?.refundStatus,
          //       booking.paymentFlow?.refundStatus,
          //     ])
          //     case final refundStatus?)
          //   BookingDetailsReceiptRow(
          //     label: 'Refund status',
          //     value: _formatStatus(refundStatus),
          //   ),
          if (refundAmount != null)
            BookingDetailsReceiptRow(
              label: isOwner ? 'Renter refund' : 'Your refund',
              value: _formatMoney(refundAmount),
            ),
          if (!isOwner && _hasPositiveAmount(securityDepositRefundAmount))
            BookingDetailsReceiptRow(
              label: 'Security deposit refund',
              value: _formatMoney(securityDepositRefundAmount),
            ),
          if (!isOwner && _hasPositiveAmount(manualSecurityDepositRefundAmount))
            BookingDetailsReceiptRow(
              label: 'Manual security deposit refund',
              value: _formatMoney(manualSecurityDepositRefundAmount),
            ),
          if (isOwner) ...[
            if (_hasPositiveAmount(retainedOwnerAmount))
              BookingDetailsReceiptRow(
                label: 'Owner retained amount',
                value: _formatMoney(retainedOwnerAmount),
              ),
            if (_hasPositiveAmount(ownerPayoutTransferFee))
              BookingDetailsReceiptRow(
                label: 'Payout fee',
                value: '-${_formatMoney(ownerPayoutTransferFee)}',
              ),
            if (_hasPositiveAmount(ownerPenaltyAmount))
              BookingDetailsReceiptRow(
                label: 'Owner cancellation penalty',
                value: _formatMoney(ownerPenaltyAmount),
              ),
          ] else if (_hasPositiveAmount(retainedOwnerAmount))
            BookingDetailsReceiptRow(
              label: 'Non-refundable amount',
              value: _formatMoney(retainedOwnerAmount),
            ),
          const BookingDetailsReceiptDivider(),
          BookingDetailsReceiptRow(
            label: isOwner ? 'Final payout' : 'Final refund',
            value: _formatMoney(
              isOwner ? finalPayoutAmount : finalRefundAmount,
            ),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  static bool shouldShow(Booking booking, {required bool isOwner}) {
    return booking.status == BookingStatus.cancelled;
  }

  num? _refundAmount() {
    final renterPenaltyRefund =
        booking.cancellationRequest?.renterPenalty?['refundAmount'];
    if (renterPenaltyRefund is num) return renterPenaltyRefund;
    return booking.paymentFlow?.refundAmount;
  }

  num? _retainedOwnerAmount() {
    final retained =
        booking.cancellationRequest?.renterPenalty?['retainedOwnerAmount'];
    if (retained is num) return retained;
    return null;
  }

  num? _securityDepositRefundAmount() {
    final amount =
        booking
            .cancellationRequest
            ?.renterPenalty?['securityDepositRefundAmount'];
    return amount is num ? amount : null;
  }

  num? _manualSecurityDepositRefundAmount() {
    final amount =
        booking
            .cancellationRequest
            ?.renterPenalty?['manualSecurityDepositRefundAmount'];
    return amount is num ? amount : null;
  }

  num? _ownerPenaltyAmount() {
    final penalty = booking.cancellationRequest?.ownerPenalty?['penaltyAmount'];
    return penalty is num ? penalty : null;
  }

  num? _ownerPayoutTransferFee() {
    return booking.payoutFlow?.ownerPayoutTransferFee;
  }

  num _finalPayoutAmount(num? retainedOwnerAmount) {
    if (_hasPositiveAmount(retainedOwnerAmount)) {
      return booking.payoutFlow?.ownerPayoutAmount ?? retainedOwnerAmount!;
    }
    return booking.payoutFlow?.ownerPayoutAmount ?? 0;
  }

  num _finalRefundAmount(
    num? refundAmount,
    num? manualSecurityDepositRefundAmount,
  ) {
    return (refundAmount ?? 0) + (manualSecurityDepositRefundAmount ?? 0);
  }

  bool _hasPositiveAmount(num? amount) => amount != null && amount > 0;

  String? _firstText(Iterable<String?> values) {
    for (final value in values) {
      if (value?.trim().isNotEmpty == true) return value!.trim();
    }
    return null;
  }

  String _requestedByLabel(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized == 'renter') return isOwner ? 'Renter' : 'You';
    if (normalized == 'owner') return isOwner ? 'You' : 'Owner';
    return _formatStatus(role);
  }

  String _formatMoney(num? amount) {
    final currency =
        booking.paymentFlow?.currency?.trim() ??
        booking.priceBreakdown.currency?.trim() ??
        booking.payment?.currency?.trim();
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

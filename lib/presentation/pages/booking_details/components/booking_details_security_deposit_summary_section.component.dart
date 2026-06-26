import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_info_section.widget.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_receipt.widget.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/extensions/timestamp.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class BookingDetailsSecurityDepositSummarySection
    extends GetView<BookingDetailsController> {
  const BookingDetailsSecurityDepositSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = controller.booking;
    if (!BookingDetailsSecurityDepositSummaryCard.shouldShow(
      booking,
      isOwner: controller.isOwner,
    )) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        BookingDetailsSecurityDepositSummaryCard(
          booking: booking,
          isOwner: controller.isOwner,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

class BookingDetailsSecurityDepositSummaryCard extends StatelessWidget {
  const BookingDetailsSecurityDepositSummaryCard({
    required this.booking,
    required this.isOwner,
    super.key,
  });

  final Booking booking;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    if (!shouldShow(booking, isOwner: isOwner)) return const SizedBox.shrink();

    final depositAmount = _securityDepositAmount()!;
    final usedAmount = _depositUsedAmount();
    final returnedAmount = _depositReturnAmount(depositAmount, usedAmount);
    final returnStatus =
        booking.payoutFlow?.depositReturnStatus ??
        booking.settlement?.depositReturnStatus;
    final sentAt =
        returnedAmount != null && returnedAmount > 0
            ? _depositReturnSentAt()
            : null;

    return BookingDetailsInfoSection(
      title: 'Security deposit summary',
      child: Column(
        children: [
          BookingDetailsReceiptRow(
            label: 'Security deposit',
            value: _formatMoney(depositAmount),
          ),
          if (usedAmount != null && usedAmount > 0)
            BookingDetailsReceiptRow(
              label: 'Used for damage',
              value: _formatMoney(usedAmount),
            ),
          if (returnedAmount != null)
            BookingDetailsReceiptRow(
              label: 'Returned amount',
              value: _formatMoney(returnedAmount),
              isTotal: true,
            ),
          if (_hasText(returnStatus))
            BookingDetailsReceiptRow(
              label: 'Return status',
              value: _formatStatus(returnStatus!),
            ),
          if (sentAt != null)
            BookingDetailsReceiptRow(
              label: 'Sent on',
              value: sentAt.toFormattedStringWithTime(),
            ),
        ],
      ),
    );
  }

  static bool shouldShow(Booking booking, {required bool isOwner}) {
    if (isOwner || !booking.isCompleted) return false;
    final amount = _firstPositiveAmount([
      booking.depositFlow?.amount,
      booking.priceBreakdown.securityDepositAmount,
      booking.securityDeposit.enabled ? booking.securityDeposit.amount : null,
    ]);
    return amount != null && amount > 0;
  }

  num? _securityDepositAmount() {
    return _firstPositiveAmount([
      booking.depositFlow?.amount,
      booking.priceBreakdown.securityDepositAmount,
      booking.securityDeposit.enabled ? booking.securityDeposit.amount : null,
    ]);
  }

  num? _depositUsedAmount() {
    final amount = _firstAmount([
      booking.depositFlow?.depositCoveredAmount,
      booking.disputeFlow?.depositCoveredAmount,
      booking.settlement?.depositCoveredDamageAmount,
      booking.damageDeductionRequest?.depositCoveredAmount,
      booking.depositFlow?.approvedDeductionAmount,
    ]);
    if (amount == null || amount <= 0) return null;

    final depositAmount = _securityDepositAmount();
    if (depositAmount != null && amount > depositAmount) return depositAmount;
    return amount;
  }

  num? _depositReturnAmount(num depositAmount, num? usedAmount) {
    final amount = _firstAmount([
      booking.depositFlow?.depositReturnAmount,
      booking.payoutFlow?.depositReturnAmount,
      booking.settlement?.depositReturnAmount,
      booking.disputeFlow?.remainingSecurityDeposit,
    ]);
    if (amount != null) return amount < 0 ? 0 : amount;
    if (usedAmount != null && usedAmount >= depositAmount) return 0;
    return null;
  }

  Timestamp? _depositReturnSentAt() {
    final movement = _asStringMap(
      booking.payoutFlow?.movements?['deposit_return'],
    );
    return _timestampFromValue(movement?['createdAt']) ??
        _timestampFromValue(movement?['updatedAt']);
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

  static Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static Timestamp? _timestampFromValue(dynamic value) {
    if (value is Timestamp) return value;
    if (value is Map) {
      final seconds = value['_seconds'] ?? value['seconds'];
      final nanoseconds = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
      if (seconds is int && nanoseconds is int) {
        return Timestamp(seconds, nanoseconds);
      }
    }
    return null;
  }

  static num? _firstPositiveAmount(Iterable<num?> values) {
    for (final value in values) {
      if (value != null && value > 0) return value;
    }
    return null;
  }

  static num? _firstAmount(Iterable<num?> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  static bool _hasText(String? value) => value?.trim().isNotEmpty == true;

  static String _formatStatus(String value) {
    return value
        .trim()
        .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

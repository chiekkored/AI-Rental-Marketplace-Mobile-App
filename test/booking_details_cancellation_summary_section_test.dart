import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_cancellation_summary_section.component.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  testWidgets('owner sees cancellation summary with zero final payout', (
    tester,
  ) async {
    final booking = _booking(
      paymentFlow: const BookingPaymentFlow(
        amount: 1600,
        currency: 'PHP',
        refundAmount: 1600,
        refundStatus: 'succeeded',
        refundType: 'full',
      ),
      cancellationRequest: const BookingCancellationRequest(
        status: 'Approved',
        requestedByRole: 'renter',
        reason: 'Schedule changed',
        refundStatus: 'succeeded',
        renterPenalty: {'refundAmount': 1600, 'retainedOwnerAmount': 0},
      ),
      payoutFlow: const BookingPayoutFlow(
        ownerPayoutStatus: 'cancelled',
        ownerPayoutAmount: 0,
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Cancellation summary'), findsOneWidget);
    expect(find.text('Cancellation status'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Requested by'), findsOneWidget);
    expect(find.text('Renter'), findsOneWidget);
    expect(find.text('Renter refund'), findsOneWidget);
    expect(find.text('PHP 1,600.00'), findsOneWidget);
    expect(find.text('Final payout'), findsOneWidget);
    expect(find.text('PHP 0.00'), findsOneWidget);
  });

  testWidgets('owner sees retained amount, payout fee, and final payout', (
    tester,
  ) async {
    final booking = _booking(
      paymentFlow: const BookingPaymentFlow(
        amount: 1600,
        currency: 'PHP',
        refundAmount: 600,
        refundStatus: 'succeeded',
        refundType: 'partial',
      ),
      cancellationRequest: const BookingCancellationRequest(
        status: 'Approved',
        requestedByRole: 'renter',
        refundStatus: 'succeeded',
        renterPenalty: {'refundAmount': 600, 'retainedOwnerAmount': 1000},
      ),
      payoutFlow: const BookingPayoutFlow(
        ownerPayoutGrossAmount: 1000,
        ownerPayoutTransferFee: 10,
        ownerPayoutAmount: 990,
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Cancellation summary'), findsOneWidget);
    expect(find.text('Owner retained amount'), findsOneWidget);
    expect(find.text('PHP 1,000.00'), findsOneWidget);
    expect(find.text('Payout fee'), findsOneWidget);
    expect(find.text('-PHP 10.00'), findsOneWidget);
    expect(find.text('Final payout'), findsOneWidget);
    expect(find.text('PHP 990.00'), findsOneWidget);
  });

  testWidgets('renter sees cancellation summary with refund details', (
    tester,
  ) async {
    final booking = _booking(
      paymentFlow: const BookingPaymentFlow(
        amount: 1600,
        currency: 'PHP',
        refundAmount: 1600,
        refundStatus: 'succeeded',
        refundType: 'full',
      ),
      cancellationRequest: const BookingCancellationRequest(
        status: 'Approved',
        requestedByRole: 'renter',
        refundStatus: 'succeeded',
        renterPenalty: {'refundAmount': 1600, 'retainedOwnerAmount': 0},
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: false);

    expect(find.text('Cancellation summary'), findsOneWidget);
    expect(find.text('Requested by'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Your refund'), findsOneWidget);
    expect(find.text('Final refund'), findsOneWidget);
    expect(find.text('PHP 1,600.00'), findsNWidgets(2));
    expect(find.text('Final payout'), findsNothing);
    expect(find.text('Owner retained amount'), findsNothing);
    expect(find.text('Owner cancellation penalty'), findsNothing);
    expect(find.text('Payout fee'), findsNothing);
  });

  testWidgets('renter sees non-refundable and manual refund details', (
    tester,
  ) async {
    final booking = _booking(
      paymentFlow: const BookingPaymentFlow(
        amount: 1250,
        currency: 'PHP',
        refundAmount: 250,
        refundStatus: 'not_refundable',
        refundType: 'none',
      ),
      cancellationRequest: const BookingCancellationRequest(
        status: 'Approved',
        requestedByRole: 'owner',
        refundStatus: 'not_refundable',
        renterPenalty: {
          'refundAmount': 250,
          'retainedOwnerAmount': 1000,
          'securityDepositRefundAmount': 500,
          'manualSecurityDepositRefundAmount': 500,
        },
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: false);

    expect(find.text('Cancellation summary'), findsOneWidget);
    expect(find.text('Requested by'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Your refund'), findsOneWidget);
    expect(find.text('Security deposit refund'), findsOneWidget);
    expect(find.text('Manual security deposit refund'), findsOneWidget);
    expect(find.text('Non-refundable amount'), findsOneWidget);
    expect(find.text('Final refund'), findsOneWidget);
    expect(find.text('PHP 750.00'), findsOneWidget);
    expect(find.text('Final payout'), findsNothing);
    expect(find.text('Owner retained amount'), findsNothing);
    expect(find.text('Payout fee'), findsNothing);
  });
}

Future<void> _pumpSummary(
  WidgetTester tester, {
  required Booking booking,
  required bool isOwner,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: LNDAppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: BookingDetailsCancellationSummaryCard(
            booking: booking,
            isOwner: isOwner,
          ),
        ),
      ),
    ),
  );
}

Booking _booking({
  BookingPaymentFlow? paymentFlow,
  BookingPayoutFlow? payoutFlow,
  BookingCancellationRequest? cancellationRequest,
}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: null,
    startDate: null,
    endDate: null,
    numDays: null,
    payment: null,
    paymentFlow: paymentFlow,
    priceBreakdown: const BookingPriceBreakdown(currency: 'PHP'),
    payoutFlow: payoutFlow,
    renter: null,
    status: BookingStatus.cancelled,
    totalPrice: 1500,
    cancellationRequest: cancellationRequest,
  );
}

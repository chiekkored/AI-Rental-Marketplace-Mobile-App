import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_payment_summary_section.component.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  testWidgets('owner summary shows base payout without dispute amount', (
    tester,
  ) async {
    final booking = _booking(
      payment: Payment(
        amount: 1600,
        currency: 'php',
        rentalSubtotal: 1500,
        ownerPayoutAmount: 1400,
        pricingBreakdown: {'ownerPayoutAmount': 1400},
      ),
      priceBreakdown: const BookingPriceBreakdown(
        rentalSubtotal: 1500,
        ownerProcessingFee: 100,
        ownerPayoutAmount: 1400,
        currency: 'PHP',
      ),
      payoutFlow: const BookingPayoutFlow(ownerPayoutAmount: 1900),
      settlement: Settlement(
        finalOwnerPayoutAmount: 1900,
        finalOwnerPayoutReleasedComponents: {
          'baseOwnerGrossAmount': 1400,
          'depositCoveredDamageAmount': 500,
        },
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Payment summary'), findsOneWidget);
    expect(find.text('Rental subtotal'), findsOneWidget);
    expect(find.text('PHP 1,500.00'), findsOneWidget);
    expect(find.text('Processing fee'), findsOneWidget);
    expect(find.text('-PHP 100.00'), findsOneWidget);
    expect(find.text('Your payout'), findsOneWidget);
    expect(find.text('PHP 1,400.00'), findsOneWidget);
    expect(find.text('PHP 1,900.00'), findsNothing);
    expect(find.text('Dispute amount'), findsNothing);
  });

  testWidgets('owner summary falls back to legacy payment payout amount', (
    tester,
  ) async {
    final booking = _booking(
      payment: Payment(
        amount: 1600,
        currency: 'php',
        rentalSubtotal: 1500,
        ownerPayoutAmount: 1400,
        pricingBreakdown: {'ownerPayoutAmount': 1400},
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Payment summary'), findsOneWidget);
    expect(find.text('Rental subtotal'), findsOneWidget);
    expect(find.text('PHP 1,500.00'), findsOneWidget);
    expect(find.text('Your payout'), findsOneWidget);
    expect(find.text('PHP 1,400.00'), findsOneWidget);
  });

  testWidgets('owner summary shows previous cancellation deduction', (
    tester,
  ) async {
    final booking = _booking(
      payment: Payment(amount: 1600, currency: 'php', rentalSubtotal: 1500),
      priceBreakdown: const BookingPriceBreakdown(
        rentalSubtotal: 1500,
        ownerProcessingFee: 100,
        ownerPayoutAmount: 1400,
        currency: 'PHP',
      ),
      payoutFlow: const BookingPayoutFlow(
        ownerPayoutAmountBeforePenalty: 1400,
        ownerPenaltyDeductionAmount: 500,
        ownerPayoutAmount: 900,
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Payment summary'), findsOneWidget);
    expect(find.text('Previous cancellation deduction'), findsOneWidget);
    expect(find.text('-PHP 500.00'), findsOneWidget);
    expect(find.text('Your payout'), findsOneWidget);
    expect(find.text('PHP 900.00'), findsOneWidget);
    expect(find.text('PHP 1,400.00'), findsNothing);
  });

  testWidgets('owner summary hides zero previous cancellation deduction', (
    tester,
  ) async {
    final booking = _booking(
      payment: Payment(amount: 1600, currency: 'php', rentalSubtotal: 1500),
      priceBreakdown: const BookingPriceBreakdown(
        rentalSubtotal: 1500,
        ownerProcessingFee: 100,
        ownerPayoutAmount: 1400,
        currency: 'PHP',
      ),
      payoutFlow: const BookingPayoutFlow(
        ownerPayoutAmountBeforePenalty: 1400,
        ownerPenaltyDeductionAmount: 0,
        ownerPayoutAmount: 1400,
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Previous cancellation deduction'), findsNothing);
    expect(find.text('-PHP 0.00'), findsNothing);
    expect(find.text('Your payout'), findsOneWidget);
    expect(find.text('PHP 1,400.00'), findsOneWidget);
  });

  testWidgets('renter summary does not show owner deductions', (tester) async {
    final booking = _booking(
      payment: Payment(amount: 1600, currency: 'php', rentalSubtotal: 1500),
      priceBreakdown: const BookingPriceBreakdown(
        rentalSubtotal: 1500,
        paymentAmount: 1600,
        currency: 'PHP',
      ),
      payoutFlow: const BookingPayoutFlow(
        ownerPayoutAmountBeforePenalty: 1400,
        ownerPenaltyDeductionAmount: 500,
        ownerPayoutAmount: 900,
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: false);

    expect(find.text('Previous cancellation deduction'), findsNothing);
    expect(find.text('-PHP 500.00'), findsNothing);
    expect(find.text('Your payout'), findsNothing);
    expect(find.text('Total paid'), findsOneWidget);
    expect(find.text('PHP 1,600.00'), findsOneWidget);
  });

  testWidgets('owner cancelled full refund summary keeps original payout', (
    tester,
  ) async {
    final booking = _booking(
      status: BookingStatus.cancelled,
      payment: Payment(amount: 1600, currency: 'php', rentalSubtotal: 1500),
      paymentFlow: const BookingPaymentFlow(
        amount: 1600,
        currency: 'PHP',
        refundAmount: 1600,
        refundStatus: 'succeeded',
        refundType: 'full',
      ),
      priceBreakdown: const BookingPriceBreakdown(
        rentalSubtotal: 1500,
        ownerProcessingFee: 100,
        ownerPayoutAmount: 1400,
        currency: 'PHP',
      ),
      cancellationRequest: const BookingCancellationRequest(
        status: 'Approved',
        requestedByRole: 'renter',
        refundStatus: 'succeeded',
        renterPenalty: {'refundAmount': 1600, 'retainedOwnerAmount': 0},
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Payout status'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Your payout'), findsOneWidget);
    expect(find.text('PHP 1,400.00'), findsOneWidget);
    expect(find.text('PHP 0.00'), findsNothing);
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
          child: BookingDetailsPaymentSummaryCard(
            booking: booking,
            isOwner: isOwner,
          ),
        ),
      ),
    ),
  );
}

Booking _booking({
  BookingStatus status = BookingStatus.completed,
  Payment? payment,
  BookingPaymentFlow? paymentFlow,
  BookingPriceBreakdown priceBreakdown = const BookingPriceBreakdown(),
  BookingPayoutFlow? payoutFlow,
  BookingCancellationRequest? cancellationRequest,
  Settlement? settlement,
}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: null,
    startDate: null,
    endDate: null,
    numDays: null,
    payment: payment,
    paymentFlow: paymentFlow,
    priceBreakdown: priceBreakdown,
    payoutFlow: payoutFlow,
    renter: null,
    status: status,
    totalPrice: 1500,
    cancellationRequest: cancellationRequest,
    settlement: settlement,
  );
}

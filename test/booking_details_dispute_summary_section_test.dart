import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_dispute_summary_section.component.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  test('shows only completed bookings with dispute data', () {
    expect(
      BookingDetailsDisputeSummaryCard.shouldShow(
        _booking(status: BookingStatus.completed),
      ),
      false,
    );
    expect(
      BookingDetailsDisputeSummaryCard.shouldShow(
        _booking(
          status: BookingStatus.returned,
          damageDeductionRequest: DamageDeductionRequest(
            status: 'resolved',
            requestedAmount: 800,
          ),
        ),
      ),
      false,
    );
    expect(
      BookingDetailsDisputeSummaryCard.shouldShow(
        _booking(
          status: BookingStatus.completed,
          settlement: Settlement(
            depositReturnAmount: 500,
            ownerPayoutAmount: 90,
            status: 'completed',
            supportStatus: 'resolved',
          ),
        ),
      ),
      false,
    );
    expect(
      BookingDetailsDisputeSummaryCard.shouldShow(
        _booking(
          status: BookingStatus.completed,
          settlement: Settlement(approvedDamageDeductionAmount: 0),
        ),
      ),
      false,
    );
    expect(
      BookingDetailsDisputeSummaryCard.shouldShow(
        _booking(
          status: BookingStatus.completed,
          damageDeductionRequest: DamageDeductionRequest(
            status: 'resolved',
            requestedAmount: 300,
            approvedAmount: 0,
          ),
        ),
      ),
      true,
    );
    expect(
      BookingDetailsDisputeSummaryCard.shouldShow(
        _booking(
          status: BookingStatus.completed,
          settlement: Settlement(
            renterResponse: 'disputed',
            approvedDamageDeductionAmount: 700,
          ),
        ),
      ),
      true,
    );
  });

  testWidgets('renders renter-facing dispute details', (tester) async {
    final booking = _disputeBooking(ownerPayoutAmount: 1700);

    await _pumpSummary(tester, booking: booking, isOwner: false);

    expect(find.text('Dispute summary'), findsOneWidget);
    expect(find.text('Dispute status'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
    expect(find.text('Your response'), findsNothing);
    expect(find.text('Renter response'), findsNothing);
    expect(find.text('Disputed'), findsNothing);
    expect(find.text('Damage reason'), findsOneWidget);
    expect(find.text('Lens scratch'), findsOneWidget);
    expect(find.text('Requested deduction'), findsOneWidget);
    expect(find.text('PHP 900.00'), findsOneWidget);
    expect(find.text('Your outstanding balance'), findsOneWidget);
    expect(find.text('PHP 200.00'), findsOneWidget);
    expect(find.text('Dispute processing fee'), findsOneWidget);
    expect(find.text('PHP 12.00'), findsOneWidget);
    expect(find.text('Your outstanding balance paid'), findsOneWidget);
    expect(find.text('PHP 212.00'), findsOneWidget);
    expect(find.text('Your security deposit used'), findsOneWidget);
    expect(find.text('PHP 500.00'), findsOneWidget);
    expect(find.text('Your security deposit returned'), findsOneWidget);
    expect(find.text('PHP 300.00'), findsOneWidget);
    expect(find.text('Owner payout'), findsNothing);
    expect(find.text('Your payout'), findsNothing);
    expect(find.text('PHP 1,700.00'), findsNothing);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Admin notes'), findsOneWidget);
    expect(find.text('Approved partial deduction.'), findsOneWidget);

    expect(find.text('Owner notes'), findsNothing);
    expect(find.text('Owner-only note'), findsNothing);
    expect(find.text('Evidence photos'), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('renders owner-facing payout with retained deposit deduction', (
    tester,
  ) async {
    final booking = _ownerDepositOnlyDisputeBooking(
      payment: Payment(
        currency: 'php',
        ownerPayoutAmount: 147.50,
        pricingBreakdown: {
          'rentalSubtotal': 100,
          'ownerSecurityDepositPaymentFee': 52.50,
        },
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Renter response'), findsNothing);
    expect(find.text('Your response'), findsNothing);
    expect(find.text("Renter's outstanding balance paid"), findsNothing);
    expect(find.text('Dispute processing fee'), findsNothing);
    expect(find.text('Security deposit deducted'), findsOneWidget);
    expect(find.text('Dispute amount'), findsOneWidget);
    expect(find.text('PHP 100.00'), findsNWidgets(3));
    expect(find.text('Your final payout'), findsOneWidget);
    expect(find.text('PHP 252.50'), findsOneWidget);
    expect(find.text('Your payout'), findsNothing);
    expect(find.text('PHP 147.50'), findsNothing);
    expect(find.text('Owner payout'), findsNothing);
  });

  testWidgets('shows owner payout fallback calculation sheet', (tester) async {
    final booking = _ownerDepositOnlyDisputeBooking(
      payment: Payment(
        currency: 'php',
        ownerPayoutAmount: 147.50,
        pricingBreakdown: {
          'rentalSubtotal': 100,
          'ownerSecurityDepositPaymentFee': 52.50,
        },
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Your payout calculation'), findsOneWidget);
    expect(find.text('Rental subtotal'), findsOneWidget);
    expect(find.text('Processing fee'), findsOneWidget);
    expect(find.text('Base payout subtotal'), findsOneWidget);
    expect(find.text('Security deposit deducted'), findsNWidgets(2));
    expect(find.text('Your final payout'), findsNWidgets(2));
    expect(find.text('PHP 252.50'), findsNWidgets(2));
  });

  testWidgets(
    'includes approved deposit deduction when covered field is absent',
    (tester) async {
      final booking = _ownerApprovedDepositFallbackDisputeBooking(
        payment: Payment(
          currency: 'php',
          ownerPayoutAmount: 147.50,
          pricingBreakdown: {
            'rentalSubtotal': 100,
            'ownerSecurityDepositPaymentFee': 52.50,
          },
        ),
      );

      await _pumpSummary(tester, booking: booking, isOwner: true);

      expect(find.text('Security deposit deducted'), findsOneWidget);
      expect(find.text('Dispute amount'), findsOneWidget);
      expect(find.text('PHP 100.00'), findsNWidgets(3));
      expect(find.text('Your final payout'), findsOneWidget);
      expect(find.text('PHP 252.50'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Your payout calculation'), findsOneWidget);
      expect(find.text('Security deposit deducted'), findsNWidgets(2));
      expect(find.text('Your final payout'), findsNWidgets(2));
      expect(find.text('PHP 252.50'), findsNWidgets(2));
    },
  );

  testWidgets('uses stored final owner payout when available', (tester) async {
    final booking = _disputeBooking(
      ownerPayoutAmount: 1700,
      finalOwnerPayoutAmount: 1720,
      finalOwnerPayoutGrossAmount: 1730,
      finalOwnerPayoutWalletTransferFee: 10,
      finalOwnerPayoutReleasedComponents: {
        'baseOwnerGrossAmount': 980,
        'depositCoveredDamageAmount': 500,
        'paidOutstandingDamageAmount': 250,
      },
    );

    await _pumpSummary(tester, booking: booking, isOwner: true);

    expect(find.text('Dispute amount'), findsOneWidget);
    expect(find.text('PHP 750.00'), findsOneWidget);
    expect(find.text('Your final payout'), findsOneWidget);
    expect(find.text('PHP 1,720.00'), findsOneWidget);
    expect(find.text('PHP 1,700.00'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Dispute amount')).dy,
      lessThan(tester.getTopLeft(find.text('Your final payout')).dy),
    );

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Your payout calculation'), findsOneWidget);
    expect(find.text('Base owner payout'), findsOneWidget);
    expect(find.text('Gross payout'), findsOneWidget);
    expect(find.text('Wallet transfer fee'), findsOneWidget);
    expect(find.text('-PHP 10.00'), findsOneWidget);
    expect(find.text('PHP 1,730.00'), findsOneWidget);
    expect(find.text('Your final payout'), findsNWidgets(2));
  });

  testWidgets(
    'payment flow owner summary shows dispute amount before final payout',
    (tester) async {
      final booking = _booking(
        status: BookingStatus.completed,
        payment: Payment(currency: 'php'),
        priceBreakdown: const BookingPriceBreakdown(
          ownerPayoutAmount: 900,
          currency: 'PHP',
        ),
        payoutFlow: const BookingPayoutFlow(ownerPayoutAmount: 1400),
        disputeFlow: const BookingDisputeFlow(
          status: 'resolved',
          requestedAmount: 500,
          approvedAmount: 500,
          renterResponse: 'accepted',
          depositCoveredAmount: 300,
          paidOutstandingAmount: 200,
        ),
      );

      await _pumpSummary(tester, booking: booking, isOwner: true);

      expect(find.text('Payout before dispute'), findsOneWidget);
      expect(find.text('PHP 900.00'), findsOneWidget);
      expect(find.text('Dispute amount'), findsOneWidget);
      expect(find.text('PHP 500.00'), findsNWidgets(2));
      expect(find.text('Your final payout'), findsOneWidget);
      expect(find.text('PHP 1,400.00'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Dispute amount')).dy,
        lessThan(tester.getTopLeft(find.text('Your final payout')).dy),
      );
    },
  );

  testWidgets(
    'payment flow owner summary shows removed deposit return fee for full deposit deduction',
    (tester) async {
      final booking = _booking(
        status: BookingStatus.completed,
        payment: Payment(currency: 'php'),
        securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
        priceBreakdown: const BookingPriceBreakdown(
          ownerPayoutAmount: 47.50,
          renterDepositReturnTransferFee: 10,
          currency: 'PHP',
        ),
        payoutFlow: const BookingPayoutFlow(ownerPayoutAmount: 757.50),
        disputeFlow: const BookingDisputeFlow(
          status: 'resolved',
          requestedAmount: 700,
          approvedAmount: 700,
          renterResponse: 'accepted',
          depositCoveredAmount: 500,
          paidOutstandingAmount: 200,
          remainingSecurityDeposit: 0,
        ),
      );

      await _pumpSummary(tester, booking: booking, isOwner: true);

      expect(find.text('Payout before dispute'), findsOneWidget);
      expect(find.text('PHP 47.50'), findsOneWidget);
      expect(find.text('Dispute amount'), findsOneWidget);
      expect(find.text('PHP 700.00'), findsNWidgets(2));
      expect(find.text('Deposit return fee removed'), findsOneWidget);
      expect(find.text('PHP 10.00'), findsOneWidget);
      expect(find.text('Your final payout'), findsOneWidget);
      expect(find.text('PHP 757.50'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Deposit return fee removed')).dy,
        lessThan(tester.getTopLeft(find.text('Your final payout')).dy),
      );
    },
  );

  testWidgets(
    'does not show removed deposit return fee for renter or positive deposit return',
    (tester) async {
      final booking = _booking(
        status: BookingStatus.completed,
        payment: Payment(currency: 'php'),
        securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
        priceBreakdown: const BookingPriceBreakdown(
          ownerPayoutAmount: 47.50,
          renterDepositReturnTransferFee: 10,
          currency: 'PHP',
        ),
        payoutFlow: const BookingPayoutFlow(ownerPayoutAmount: 557.50),
        disputeFlow: const BookingDisputeFlow(
          status: 'resolved',
          requestedAmount: 500,
          approvedAmount: 500,
          renterResponse: 'accepted',
          depositCoveredAmount: 300,
          paidOutstandingAmount: 200,
          remainingSecurityDeposit: 200,
        ),
      );

      await _pumpSummary(tester, booking: booking, isOwner: true);
      expect(find.text('Deposit return fee removed'), findsNothing);

      await _pumpSummary(tester, booking: booking, isOwner: false);
      expect(find.text('Deposit return fee removed'), findsNothing);
    },
  );

  testWidgets('does not show owner payout calculation on renter view', (
    tester,
  ) async {
    final booking = _disputeBooking(ownerPayoutAmount: 1700);

    await _pumpSummary(tester, booking: booking, isOwner: false);

    expect(find.text('Your payout'), findsNothing);
    expect(find.text('Your final payout'), findsNothing);
    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
  });
}

Future<void> _pumpSummary(
  WidgetTester tester, {
  required Booking booking,
  required bool isOwner,
}) {
  return tester.pumpWidget(
    GetMaterialApp(
      theme: LNDAppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: BookingDetailsDisputeSummaryCard(
            booking: booking,
            isOwner: isOwner,
          ),
        ),
      ),
    ),
  );
}

Booking _disputeBooking({
  num? ownerPayoutAmount,
  num? finalOwnerPayoutAmount,
  num? finalOwnerPayoutGrossAmount,
  num? finalOwnerPayoutWalletTransferFee,
  Map<String, dynamic>? finalOwnerPayoutReleasedComponents,
  Payment? payment,
}) {
  return _booking(
    status: BookingStatus.completed,
    payment: payment ?? Payment(currency: 'php', ownerPayoutAmount: 1400),
    securityDeposit: const SecurityDeposit(enabled: true, amount: 1000),
    settlement: Settlement(
      renterResponse: 'disputed',
      approvedDamageDeductionAmount: 700,
      depositCoveredDamageAmount: 500,
      outstandingDamageAmount: 200,
      depositReturnAmount: 300,
      ownerPayoutAmount: ownerPayoutAmount,
      finalOwnerPayoutAmount: finalOwnerPayoutAmount,
      finalOwnerPayoutGrossAmount: finalOwnerPayoutGrossAmount,
      finalOwnerPayoutWalletTransferFee: finalOwnerPayoutWalletTransferFee,
      finalOwnerPayoutReleasedComponents: finalOwnerPayoutReleasedComponents,
      damageBalancePaymentStatus: 'paid',
      damageBalancePayment: {'amount': 200, 'renterProcessingFee': 12},
    ),
    damageDeductionRequest: DamageDeductionRequest(
      status: 'resolved',
      requestedAmount: 900,
      reason: 'Lens scratch',
      notes: 'Owner-only note',
      evidenceUrls: const ['https://example.test/photo.jpg'],
      adminNotes: 'Approved partial deduction.',
    ),
  );
}

Booking _ownerDepositOnlyDisputeBooking({required Payment payment}) {
  return _booking(
    status: BookingStatus.completed,
    payment: payment,
    securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
    settlement: Settlement(
      renterResponse: 'accepted',
      approvedDamageDeductionAmount: 100,
      depositCoveredDamageAmount: 100,
      depositReturnAmount: 400,
      ownerPayoutAmount: 147.50,
      damageBalancePaymentStatus: 'not_required',
    ),
    damageDeductionRequest: DamageDeductionRequest(
      status: 'resolved',
      requestedAmount: 100,
      reason: 'Lens scratch',
      adminNotes: 'Approved deposit deduction.',
    ),
  );
}

Booking _ownerApprovedDepositFallbackDisputeBooking({
  required Payment payment,
}) {
  return _booking(
    status: BookingStatus.completed,
    payment: payment,
    securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
    settlement: Settlement(
      renterResponse: 'accepted',
      approvedDamageDeductionAmount: 100,
      depositReturnAmount: 400,
      ownerPayoutAmount: 147.50,
      damageBalancePaymentStatus: 'not_required',
    ),
    damageDeductionRequest: DamageDeductionRequest(
      status: 'resolved',
      requestedAmount: 100,
      approvedAmount: 100,
      reason: 'Lens scratch',
      adminNotes: 'Approved deposit deduction.',
    ),
  );
}

Booking _booking({
  required BookingStatus status,
  Payment? payment,
  BookingPriceBreakdown priceBreakdown = const BookingPriceBreakdown(),
  BookingPayoutFlow? payoutFlow,
  BookingDisputeFlow? disputeFlow,
  SecurityDeposit securityDeposit = const SecurityDeposit.disabled(),
  Settlement? settlement,
  DamageDeductionRequest? damageDeductionRequest,
}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: null,
    payment: payment,
    priceBreakdown: priceBreakdown,
    payoutFlow: payoutFlow,
    disputeFlow: disputeFlow,
    renter: null,
    status: status,
    totalPrice: 1500,
    securityDeposit: securityDeposit,
    settlement: settlement,
    damageDeductionRequest: damageDeductionRequest,
  );
}

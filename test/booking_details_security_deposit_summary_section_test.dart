import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_security_deposit_summary_section.component.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  testWidgets('renter sees completed security deposit return summary', (
    tester,
  ) async {
    final sentAt = Timestamp.fromDate(DateTime(2026, 4, 15, 10, 30));
    final booking = _booking(
      status: BookingStatus.completed,
      depositFlow: const BookingDepositFlow(
        required: true,
        amount: 500,
        depositCoveredAmount: 100,
        depositReturnAmount: 400,
      ),
      payoutFlow: BookingPayoutFlow(
        depositReturnStatus: 'processing',
        depositReturnAmount: 400,
        movements: {
          'deposit_return': {'amount': 400, 'createdAt': sentAt},
        },
      ),
    );

    await _pumpSummary(tester, booking: booking, isOwner: false);

    expect(find.text('Security deposit summary'), findsOneWidget);
    expect(find.text('Security deposit'), findsOneWidget);
    expect(find.text('PHP 500.00'), findsOneWidget);
    expect(find.text('Used for damage'), findsOneWidget);
    expect(find.text('PHP 100.00'), findsOneWidget);
    expect(find.text('Returned amount'), findsOneWidget);
    expect(find.text('PHP 400.00'), findsOneWidget);
    expect(find.text('Return status'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Sent on'), findsOneWidget);
    expect(find.text('April 15, 2026 10:30 AM'), findsOneWidget);
  });

  testWidgets('owner does not see renter security deposit summary', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      booking: _booking(status: BookingStatus.completed),
      isOwner: true,
    );

    expect(find.text('Security deposit summary'), findsNothing);
  });

  testWidgets('non-completed booking hides renter security deposit summary', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      booking: _booking(status: BookingStatus.returned),
      isOwner: false,
    );

    expect(find.text('Security deposit summary'), findsNothing);
  });

  testWidgets('fully deducted deposit shows zero return without sent date', (
    tester,
  ) async {
    final booking = _booking(
      status: BookingStatus.completed,
      depositFlow: const BookingDepositFlow(
        required: true,
        amount: 500,
        depositCoveredAmount: 500,
      ),
      payoutFlow: const BookingPayoutFlow(depositReturnStatus: 'skipped'),
    );

    await _pumpSummary(tester, booking: booking, isOwner: false);

    expect(find.text('Security deposit summary'), findsOneWidget);
    expect(find.text('Used for damage'), findsOneWidget);
    expect(find.text('Returned amount'), findsOneWidget);
    expect(find.text('PHP 0.00'), findsOneWidget);
    expect(find.text('Return status'), findsOneWidget);
    expect(find.text('Skipped'), findsOneWidget);
    expect(find.text('Sent on'), findsNothing);
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
          child: BookingDetailsSecurityDepositSummaryCard(
            booking: booking,
            isOwner: isOwner,
          ),
        ),
      ),
    ),
  );
}

Booking _booking({
  required BookingStatus status,
  BookingDepositFlow? depositFlow,
  BookingPayoutFlow? payoutFlow,
}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: null,
    payment: Payment(currency: 'php'),
    renter: null,
    status: status,
    totalPrice: 1500,
    securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
    depositFlow:
        depositFlow ?? const BookingDepositFlow(required: true, amount: 500),
    payoutFlow: payoutFlow,
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/presentation/common/cancel_booking_sheet.common.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  testWidgets('renter sees current refund tier and processing fee note', (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      booking: _booking(
        createdAt: DateTime.utc(2026, 4, 1),
        startDate: DateTime.utc(2026, 4, 10),
      ),
      isOwner: false,
      now: DateTime.utc(2026, 4, 5),
    );

    expect(find.text('Request cancellation'), findsOneWidget);
    expect(find.textContaining('Partial rental refund'), findsOneWidget);
    expect(
      find.textContaining('Processing fees are not included'),
      findsOneWidget,
    );
    expect(find.textContaining('Full refund within'), findsNothing);
    expect(find.textContaining('No rental refund during'), findsNothing);
  });

  testWidgets('owner sees penalty warning without refund tier', (tester) async {
    await _pumpSheet(
      tester,
      booking: _booking(
        createdAt: DateTime.utc(2026, 4, 1),
        startDate: DateTime.utc(2026, 4, 10),
      ),
      isOwner: true,
      now: DateTime.utc(2026, 4, 9),
    );

    expect(find.textContaining('Potential penalty'), findsOneWidget);
    expect(find.textContaining('No rental refund'), findsNothing);
    expect(
      find.textContaining('Processing fees are not included'),
      findsNothing,
    );
  });

  testWidgets('missing policy dates hide current refund tier', (tester) async {
    await _pumpSheet(
      tester,
      booking: _booking(createdAt: null, startDate: null),
      isOwner: false,
      now: DateTime.utc(2026, 4, 5),
    );

    expect(find.text('Request cancellation'), findsOneWidget);
    expect(find.textContaining('Current refund policy'), findsNothing);
    expect(
      find.textContaining('Processing fees are not included'),
      findsNothing,
    );
  });
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required Booking booking,
  required bool isOwner,
  required DateTime now,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: LNDAppTheme.light,
      home: Scaffold(
        body: LNDCancelBookingSheet(
          booking: booking,
          isOwner: isOwner,
          renterCancellationPolicy: _policy(),
          now: now,
        ),
      ),
    ),
  );
}

Booking _booking({required DateTime? createdAt, required DateTime? startDate}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: createdAt == null ? null : Timestamp.fromDate(createdAt),
    startDate: startDate == null ? null : Timestamp.fromDate(startDate),
    payment: null,
    renter: null,
    status: null,
    totalPrice: 1000,
    priceBreakdown: const BookingPriceBreakdown(ownerPayoutAmount: 900),
  );
}

LNDRenterCancellationPolicy _policy() {
  return LNDRenterCancellationPolicy.fromMap({
    'full_refund_window': {'lead_time_rate_bps': 2500, 'max_hours': 168},
    'middle_retention': {
      'type': 'percentage',
      'rate_bps': 5000,
      'fixed_amount': 0,
    },
    'no_refund_window': {'lead_time_rate_bps': 1000, 'max_hours': 48},
    'no_refund_retention': {
      'type': 'percentage',
      'rate_bps': 10000,
      'fixed_amount': 0,
    },
  });
}

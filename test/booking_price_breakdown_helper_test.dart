import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';

void main() {
  group('BookingPriceBreakdown', () {
    test('uses daily-only rate for all selected days', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 500),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      );

      expect(lines, hasLength(1));
      expect(lines.first.count, 3);
      expect(lines.first.unit, 'day');
      expect(lines.first.rate, 500);
      expect(lines.first.amount, 1500);
    });

    test('uses weekly chunks before daily remainder', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 500, weekly: 3000),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 11),
      );

      expect(lines, hasLength(2));
      expect(lines[0].count, 1);
      expect(lines[0].unit, 'week');
      expect(lines[0].amount, 3000);
      expect(lines[1].count, 3);
      expect(lines[1].unit, 'day');
      expect(lines[1].amount, 1500);
    });

    test('uses monthly, weekly, and daily chunks in order', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 500, weekly: 3000, monthly: 10000),
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 7, 11),
      );

      expect(lines, hasLength(3));
      expect(lines[0].unit, 'month');
      expect(lines[0].count, 1);
      expect(lines[0].amount, 10000);
      expect(lines[1].unit, 'week');
      expect(lines[1].count, 1);
      expect(lines[1].amount, 3000);
      expect(lines[2].unit, 'day');
      expect(lines[2].count, 3);
      expect(lines[2].amount, 1500);
    });

    test('uses annual calendar-year chunks before smaller rates', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(
          daily: 500,
          weekly: 3000,
          monthly: 10000,
          annually: 100000,
        ),
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2027, 6, 1),
      );

      expect(lines, hasLength(1));
      expect(lines.first.count, 1);
      expect(lines.first.unit, 'year');
      expect(lines.first.amount, 100000);
    });

    test('returns no rows for missing rates', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
      );

      expect(lines, isEmpty);
    });

    test(
      'splits 5 months 2 weeks 1 day into upfront remainders and monthly subscription',
      () {
        final lines = BookingPriceBreakdown.calculate(
          rates: Rates(daily: 100, weekly: 700, monthly: 3000),
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 6, 16),
        );
        final split = BookingPriceBreakdown.subscriptionSplit(lines);

        expect(split.hasRecurringBilling, true);
        expect(split.dueTodayRentalSubtotal, 4500);
        expect(split.scheduledRentalSubtotal, 12000);
        expect(split.subscriptionUnit, 'month');
        expect(split.nextBillingAmount, 3000);
        expect(split.nextBillingDate, DateTime(2026, 2, 1));
        expect(split.upfrontLines.map((line) => line.amount).toList(), [
          3000,
          1400,
          100,
        ]);
      },
    );

    test(
      'splits 5 months 3 weeks 1 day into one monthly subscription only',
      () {
        final lines = BookingPriceBreakdown.calculate(
          rates: Rates(daily: 100, weekly: 700, monthly: 3000),
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 6, 23),
        );
        final split = BookingPriceBreakdown.subscriptionSplit(lines);

        expect(split.hasRecurringBilling, true);
        expect(split.dueTodayRentalSubtotal, 5200);
        expect(split.scheduledRentalSubtotal, 12000);
        expect(split.subscriptionUnit, 'month');
        expect(split.nextBillingAmount, 3000);
        expect(split.nextBillingDate, DateTime(2026, 2, 1));
        expect(split.upfrontLines.map((line) => line.amount).toList(), [
          3000,
          2100,
          100,
        ]);
      },
    );

    test('uses weekly subscription when weekly is the largest cadence', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 100, weekly: 700),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 23),
      );
      final split = BookingPriceBreakdown.subscriptionSplit(lines);

      expect(split.dueTodayRentalSubtotal, 800);
      expect(split.scheduledRentalSubtotal, 1400);
      expect(split.subscriptionUnit, 'week');
      expect(split.nextBillingAmount, 700);
      expect(split.nextBillingDate, DateTime(2026, 1, 8));
      expect(split.upfrontLines.map((line) => line.amount).toList(), [
        700,
        100,
      ]);
    });

    test(
      'collects weekly rentals upfront when remaining cycles are too short',
      () {
        final lines = BookingPriceBreakdown.calculate(
          rates: Rates(daily: 100, weekly: 700),
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 16),
        );
        final split = BookingPriceBreakdown.subscriptionSplit(lines);

        expect(split.dueTodayRentalSubtotal, 1500);
        expect(split.scheduledRentalSubtotal, 0);
        expect(split.subscriptionUnit, null);
        expect(split.nextBillingAmount, null);
        expect(split.nextBillingDate, null);
        expect(split.upfrontLines.map((line) => line.amount).toList(), [
          1400,
          100,
        ]);
      },
    );

    test('returns enabled rate lines in display order', () {
      final rates = Rates(
        daily: 100,
        weekly: 700,
        monthly: 3000,
        annually: 30000,
      );

      final allRates = BookingPriceBreakdown.enabledRates(rates);
      final otherRates = BookingPriceBreakdown.enabledRates(
        rates,
        includeDaily: false,
      );

      expect(allRates.map((line) => line.label).toList(), [
        'Daily',
        'Weekly',
        'Monthly',
        'Yearly',
      ]);
      expect(otherRates.map((line) => line.label).toList(), [
        'Weekly',
        'Monthly',
        'Yearly',
      ]);
    });

    test('formats display breakdown rows and normalized duration', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 100, weekly: 700, monthly: 3000),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 6, 16),
      );

      final displayLines = BookingPriceBreakdown.displayLines(lines);

      expect(displayLines.map((line) => line.label).toList(), [
        '5 months x',
        '2 weeks x',
        '1 day x',
      ]);
      expect(displayLines.map((line) => line.rate).toList(), [3000, 700, 100]);
      expect(displayLines.map((line) => line.amount).toList(), [
        15000,
        1400,
        100,
      ]);
      expect(
        BookingPriceBreakdown.normalizedDurationLabel(lines),
        '5 months, 2 weeks and 1 day',
      );
    });

    test('falls back to day duration when breakdown is empty', () {
      expect(
        BookingPriceBreakdown.normalizedDurationLabel(
          const [],
          fallbackDays: 1,
        ),
        '1 day',
      );
      expect(
        BookingPriceBreakdown.normalizedDurationLabel(
          const [],
          fallbackDays: 3,
        ),
        '3 days',
      );
    });
  });
}

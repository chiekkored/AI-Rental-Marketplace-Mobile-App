import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_payment_due_today.helper.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';

void main() {
  group('BookingPaymentDueTodayHelper', () {
    test('calculates non-recurring final due today with deposit and fees', () {
      final dueToday = BookingPaymentDueTodayHelper.calculate(
        asset: _asset(
          rates: Rates(daily: 100, currency: 'PHP'),
          securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
        ),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
        totalPrice: 300,
        policy: _policy(),
        selectedPaymentMethod: _cardPaymentMethod(),
        payerCountryShortName: 'PH',
      );

      expect(dueToday.hasRecurringBilling, false);
      expect(dueToday.dueNowRentalSubtotal, 300);
      expect(dueToday.securityDeposit, 500);
      expect(dueToday.platformFee, 10);
      expect(dueToday.paymentMethodProcessingFee, 31);
      expect(dueToday.processingFee, 41);
      expect(dueToday.totalDue, 841);
      expect(dueToday.totalDueLabel, 'PHP 841.00');
    });

    test('calculates recurring final due today from upfront split', () {
      final dueToday = BookingPaymentDueTodayHelper.calculate(
        asset: _asset(
          rates: Rates(daily: 100, weekly: 700, monthly: 3000, currency: 'PHP'),
          securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
        ),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 6, 23),
        totalPrice: 17200,
        policy: _policy(),
        selectedPaymentMethod: _cardPaymentMethod(),
        payerCountryShortName: 'PH',
      );

      expect(dueToday.hasRecurringBilling, true);
      expect(dueToday.dueNowRentalSubtotal, 5200);
      expect(dueToday.subscriptionSplit.scheduledRentalSubtotal, 12000);
      expect(dueToday.securityDeposit, 500);
      expect(dueToday.platformFee, 10);
      expect(dueToday.paymentMethodProcessingFee, 521);
      expect(dueToday.processingFee, 531);
      expect(dueToday.totalDue, 6231);
      expect(dueToday.totalDueLabel, 'PHP 6,231.00');
    });

    test('excludes method-specific fees before payment method selection', () {
      final dueToday = BookingPaymentDueTodayHelper.calculate(
        asset: _asset(
          rates: Rates(daily: 100, currency: 'PHP'),
          securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
        ),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
        totalPrice: 300,
        policy: _policy(),
        selectedPaymentMethod: null,
        payerCountryShortName: 'PH',
      );

      expect(dueToday.resolvedFee, null);
      expect(dueToday.paymentMethodProcessingFee, 0);
      expect(dueToday.processingFee, 10);
      expect(dueToday.totalDue, 810);
      expect(dueToday.totalDueLabel, 'PHP 810.00');
    });

    test('keeps non-PHP listing fees as external fees label', () {
      final dueToday = BookingPaymentDueTodayHelper.calculate(
        asset: _asset(
          rates: Rates(daily: 100, currency: 'USD'),
          securityDeposit: const SecurityDeposit(enabled: true, amount: 500),
        ),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
        totalPrice: 300,
        policy: _policy(),
        selectedPaymentMethod: _cardPaymentMethod(),
        payerCountryShortName: 'PH',
      );

      expect(dueToday.amountBeforeFees, 800);
      expect(dueToday.totalDue, 800);
      expect(dueToday.totalDueLabel, 'USD 800.00 + fees');
    });

    test('two monthly cycles are fully upfront', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 100, monthly: 3000, currency: 'PHP'),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 1),
      );
      final split = BookingPriceBreakdown.subscriptionSplit(lines);

      expect(split.hasRecurringBilling, false);
      expect(split.dueTodayRentalSubtotal, 6000);
      expect(split.scheduledRentalSubtotal, 0);
    });

    test('three monthly cycles schedule future recurring billing', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 100, monthly: 3000, currency: 'PHP'),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
      );
      final split = BookingPriceBreakdown.subscriptionSplit(lines);

      expect(split.hasRecurringBilling, true);
      expect(split.dueTodayRentalSubtotal, 3000);
      expect(split.scheduledRentalSubtotal, 6000);
    });

    test('monthly cycle clamps to shorter end month', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 100, monthly: 3000, currency: 'PHP'),
        startDate: DateTime(2026, 1, 31),
        endDate: DateTime(2026, 2, 28),
      );

      expect(lines, hasLength(1));
      expect(lines.first.unit, 'month');
      expect(lines.first.count, 1);
      expect(lines.first.amount, 3000);
    });

    test('yearly cycle clamps leap day to shorter end year', () {
      final lines = BookingPriceBreakdown.calculate(
        rates: Rates(daily: 100, annually: 30000, currency: 'PHP'),
        startDate: DateTime(2028, 2, 29),
        endDate: DateTime(2029, 2, 28),
      );

      expect(lines, hasLength(1));
      expect(lines.first.unit, 'year');
      expect(lines.first.count, 1);
      expect(lines.first.amount, 30000);
    });
  });
}

Asset _asset({required Rates rates, required SecurityDeposit securityDeposit}) {
  return Asset(id: 'asset-1', rates: rates, securityDeposit: securityDeposit);
}

LNDSelectedPaymentMethod _cardPaymentMethod() {
  return LNDSelectedPaymentMethod.channel(methodType: 'card', label: 'Card');
}

LNDPricingPolicy _policy() {
  return LNDPricingPolicy.fromMap({
    'payment_method_fee_vat_rate_bps': 0,
    'payment_method_fees': {
      'card': {
        'label': 'Cards',
        'domestic': {
          'rate_bps': 1000,
          'fixed_amount': 0,
          'calculation': 'rate_only',
        },
      },
    },
    'platform_fee': {
      'rate_bps': 0,
      'fixed_amount': 10,
      'calculation': 'fixed_only',
    },
    'wallet_transfer_fee': {
      'rate_bps': 0,
      'fixed_amount': 10,
      'calculation': 'fixed_only',
    },
    'renter_cancellation_policy': {
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
    },
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/presentation/pages/booking_payment/components/booking_summary_section.component.dart';

void main() {
  const renterCancellationPolicy = {
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
  };

  group('LNDPricingPolicy', () {
    test('parses split wallet transfer provider fee and Lend markup', () {
      final policy = LNDPricingPolicy.fromMap({
        'payment_method_fees': const <String, dynamic>{},
        'platform_fee': {
          'rate_bps': 0,
          'fixed_amount': 0,
          'calculation': 'rate_plus_fixed',
        },
        'wallet_transfer_fee': {
          'provider_fee': {
            'rate_bps': 0,
            'fixed_amount': 10,
            'calculation': 'fixed_only',
          },
          'lend_markup': {
            'rate_bps': 0,
            'fixed_amount': 5,
            'calculation': 'fixed_only',
          },
        },
        'renter_cancellation_policy': renterCancellationPolicy,
      });

      expect(policy.walletTransferFee.providerFee.calculate(100), 10);
      expect(policy.walletTransferFee.lendMarkup.calculate(100), 5);
      expect(policy.walletTransferFee.calculate(100), 15);
    });

    test('keeps legacy flat wallet transfer fee compatible', () {
      final policy = LNDPricingPolicy.fromMap({
        'payment_method_fees': const <String, dynamic>{},
        'platform_fee': {
          'rate_bps': 0,
          'fixed_amount': 0,
          'calculation': 'rate_plus_fixed',
        },
        'wallet_transfer_fee': {
          'rate_bps': 0,
          'fixed_amount': 15,
          'calculation': 'fixed_only',
        },
        'renter_cancellation_policy': renterCancellationPolicy,
      });

      expect(policy.walletTransferFee.providerFee.calculate(100), 15);
      expect(policy.walletTransferFee.lendMarkup.calculate(100), 0);
      expect(policy.walletTransferFee.calculate(100), 15);
    });

    test('parses payment method VAT and calculates VAT-inclusive fee', () {
      final policy = LNDPricingPolicy.fromMap({
        'payment_method_fee_vat_rate_bps': 1200,
        'payment_method_fees': {
          'card': {
            'label': 'Cards',
            'domestic': {
              'rate_bps': 312.5,
              'fixed_amount': 13.39,
              'calculation': 'rate_plus_fixed',
            },
          },
        },
        'platform_fee': {
          'rate_bps': 0,
          'fixed_amount': 0,
          'calculation': 'rate_plus_fixed',
        },
        'wallet_transfer_fee': {
          'rate_bps': 0,
          'fixed_amount': 10,
          'calculation': 'fixed_only',
        },
        'renter_cancellation_policy': renterCancellationPolicy,
      });
      final resolved = policy.resolvePaymentMethodFee(method: 'card');

      expect(policy.paymentMethodFeeVatRateBps, 1200);
      expect(policy.calculatePaymentMethodFee(200, resolved.rule), 22);
    });

    test('resolves international card fee for non-PH payer country', () {
      final policy = LNDPricingPolicy.fromMap({
        'payment_method_fees': {
          'card': {
            'label': 'Cards',
            'domestic': {
              'rate_bps': 312.5,
              'fixed_amount': 13.39,
              'calculation': 'rate_plus_fixed',
            },
            'international': {
              'rate_bps': 402,
              'fixed_amount': 13.39,
              'calculation': 'rate_plus_fixed',
            },
          },
          'gcash': {
            'label': 'GCash',
            'rate_bps': 223,
            'fixed_amount': 0,
            'calculation': 'rate_only',
          },
        },
        'platform_fee': {
          'rate_bps': 0,
          'fixed_amount': 0,
          'calculation': 'rate_plus_fixed',
        },
        'wallet_transfer_fee': {
          'rate_bps': 0,
          'fixed_amount': 10,
          'calculation': 'fixed_only',
        },
        'renter_cancellation_policy': renterCancellationPolicy,
      });

      final domestic = policy.resolvePaymentMethodFee(
        method: 'card',
        payerCountryShortName: 'PH',
      );
      final missingCountry = policy.resolvePaymentMethodFee(method: 'card');
      final international = policy.resolvePaymentMethodFee(
        method: 'card',
        payerCountryShortName: 'sg',
      );
      final gcash = policy.resolvePaymentMethodFee(
        method: 'gcash',
        payerCountryShortName: 'SG',
      );

      expect(domestic.rule.rateBps, 312.5);
      expect(missingCountry.rule.rateBps, 312.5);
      expect(international.rule.rateBps, 402);
      expect(gcash.rule.rateBps, 223);
    });

    test(
      'matches booking payment debug calculation for card processing fee',
      () {
        final policy = LNDPricingPolicy.fromMap({
          'payment_method_fee_vat_rate_bps': 1200,
          'payment_method_fees': {
            'card': {
              'label': 'Cards',
              'domestic': {
                'rate_bps': 312.5,
                'fixed_amount': 13.39,
                'calculation': 'rate_plus_fixed',
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
          'renter_cancellation_policy': renterCancellationPolicy,
        });
        final resolved = policy.resolvePaymentMethodFee(method: 'card');

        const rentalSubtotal = 200;
        final platformFee = policy.platformFee.calculate(rentalSubtotal);
        final processingBase = rentalSubtotal + platformFee;
        final cardBaseFee = resolved.rule.calculate(processingBase);
        final processingFee = policy.calculatePaymentMethodFee(
          processingBase,
          resolved.rule,
        );
        final totalDue = rentalSubtotal + platformFee + processingFee;

        expect(platformFee, 10);
        expect(processingBase, 210);
        expect(cardBaseFee, 19.9525);
        expect(processingFee, 22.35);
        expect(totalDue, 232.35);
        expect(
          debugFeeFormula(processingBase, resolved.rule),
          '(210 * 3.125%) + 13.39',
        );
        expect(debugPercentFromBps(policy.paymentMethodFeeVatRateBps), '12%');
        expect(debugFormulaAmount(cardBaseFee), '19.9525');
        expect(debugCurrencyAmount(totalDue), '232.35');
      },
    );

    test('parses renter cancellation policy', () {
      final policy = LNDPricingPolicy.fromMap({
        'payment_method_fees': const <String, dynamic>{},
        'platform_fee': {
          'rate_bps': 0,
          'fixed_amount': 0,
          'calculation': 'rate_plus_fixed',
        },
        'wallet_transfer_fee': {
          'rate_bps': 0,
          'fixed_amount': 10,
          'calculation': 'fixed_only',
        },
        'renter_cancellation_policy': renterCancellationPolicy,
      });

      expect(policy.renterCancellationPolicy.fullRefundWindow.maxHours, 168);
      expect(policy.renterCancellationPolicy.middleRetention.rateBps, 5000);
      expect(policy.renterCancellationPolicy.noRefundWindow.maxHours, 48);
    });

    test('formats cancellation windows below 24 hours as hours', () {
      expect(formatPolicyDuration(const Duration(hours: 23)), '23 hours');
      expect(formatPolicyDuration(const Duration(minutes: 30)), '1 hour');
    });

    test('formats cancellation windows from 24 hours as rounded days', () {
      expect(formatPolicyDuration(const Duration(hours: 24)), '1 day');
      expect(formatPolicyDuration(const Duration(hours: 48)), '2 days');
    });

    test('describes short-lead bookings as non-refundable', () {
      final policy =
          LNDPricingPolicy.fromMap({
            'payment_method_fees': const <String, dynamic>{},
            'platform_fee': {
              'rate_bps': 0,
              'fixed_amount': 0,
              'calculation': 'rate_plus_fixed',
            },
            'wallet_transfer_fee': {
              'rate_bps': 0,
              'fixed_amount': 10,
              'calculation': 'fixed_only',
            },
            'renter_cancellation_policy': renterCancellationPolicy,
          }).renterCancellationPolicy;

      final text = cancellationPolicyText(
        policy: policy,
        startDate: DateTime(2026, 5, 1, 23),
        isNonRefundableMethod: false,
        now: DateTime(2026, 5, 1),
      );

      expect(text, contains('less than 24 hours'));
      expect(text, contains('rental payment is non-refundable'));
      expect(text, contains('Security deposit is fully refundable'));
    });

    test('calculates current full refund tier', () {
      final policy =
          LNDPricingPolicy.fromMap({
            'payment_method_fees': const <String, dynamic>{},
            'platform_fee': {
              'rate_bps': 0,
              'fixed_amount': 0,
              'calculation': 'rate_plus_fixed',
            },
            'wallet_transfer_fee': {
              'rate_bps': 0,
              'fixed_amount': 10,
              'calculation': 'fixed_only',
            },
            'renter_cancellation_policy': renterCancellationPolicy,
          }).renterCancellationPolicy;

      final tier = currentRenterCancellationRefundTier(
        policy: policy,
        createdAt: DateTime.utc(2026, 4, 1),
        startDate: DateTime.utc(2026, 4, 10),
        now: DateTime.utc(2026, 4, 1, 12),
      );

      expect(tier, LNDRenterCancellationRefundTier.full);
      expect(
        currentRenterCancellationRefundPolicyText(tier),
        contains('Full rental refund'),
      );
    });

    test('calculates current partial refund tier', () {
      final policy =
          LNDPricingPolicy.fromMap({
            'payment_method_fees': const <String, dynamic>{},
            'platform_fee': {
              'rate_bps': 0,
              'fixed_amount': 0,
              'calculation': 'rate_plus_fixed',
            },
            'wallet_transfer_fee': {
              'rate_bps': 0,
              'fixed_amount': 10,
              'calculation': 'fixed_only',
            },
            'renter_cancellation_policy': renterCancellationPolicy,
          }).renterCancellationPolicy;

      final tier = currentRenterCancellationRefundTier(
        policy: policy,
        createdAt: DateTime.utc(2026, 4, 1),
        startDate: DateTime.utc(2026, 4, 10),
        now: DateTime.utc(2026, 4, 5),
      );

      expect(tier, LNDRenterCancellationRefundTier.partial);
      expect(
        currentRenterCancellationRefundPolicyText(tier),
        contains('Partial rental refund'),
      );
    });

    test('calculates current no refund tier', () {
      final policy =
          LNDPricingPolicy.fromMap({
            'payment_method_fees': const <String, dynamic>{},
            'platform_fee': {
              'rate_bps': 0,
              'fixed_amount': 0,
              'calculation': 'rate_plus_fixed',
            },
            'wallet_transfer_fee': {
              'rate_bps': 0,
              'fixed_amount': 10,
              'calculation': 'fixed_only',
            },
            'renter_cancellation_policy': renterCancellationPolicy,
          }).renterCancellationPolicy;

      final tier = currentRenterCancellationRefundTier(
        policy: policy,
        createdAt: DateTime.utc(2026, 4, 1),
        startDate: DateTime.utc(2026, 4, 10),
        now: DateTime.utc(2026, 4, 9),
      );

      expect(tier, LNDRenterCancellationRefundTier.none);
      expect(
        currentRenterCancellationRefundPolicyText(tier),
        contains('No rental refund'),
      );
    });

    test('calculates short-lead booking as no refund tier', () {
      final policy =
          LNDPricingPolicy.fromMap({
            'payment_method_fees': const <String, dynamic>{},
            'platform_fee': {
              'rate_bps': 0,
              'fixed_amount': 0,
              'calculation': 'rate_plus_fixed',
            },
            'wallet_transfer_fee': {
              'rate_bps': 0,
              'fixed_amount': 10,
              'calculation': 'fixed_only',
            },
            'renter_cancellation_policy': renterCancellationPolicy,
          }).renterCancellationPolicy;

      final tier = currentRenterCancellationRefundTier(
        policy: policy,
        createdAt: DateTime.utc(2026, 4, 9, 18),
        startDate: DateTime.utc(2026, 4, 10),
        now: DateTime.utc(2026, 4, 9, 18),
      );

      expect(tier, LNDRenterCancellationRefundTier.none);
    });
  });
}

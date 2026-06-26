import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_fee_calculator_sheet.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  setUp(() {
    LNDRemoteConfigService.setPricingPolicyForTesting(_testPricingPolicy());
  });

  tearDown(LNDRemoteConfigService.resetForTesting);

  testWidgets('defaults to daily rate and days quantity', (tester) async {
    await _pumpCalculator(tester);

    expect(find.text('Owner fee calculator'), findsOneWidget);
    expect(find.text('Daily rate'), findsOneWidget);
    expect(find.text('Days'), findsOneWidget);
    expect(find.text('PHP 100.00'), findsNWidgets(2));
  });

  testWidgets('selected rate mode controls quantity label and calculation', (
    tester,
  ) async {
    await _pumpCalculator(tester);

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    expect(find.text('Weekly rate'), findsOneWidget);
    expect(find.text('Weeks'), findsOneWidget);
    expect(_firstRateField(tester).controller?.text, '1000');
    expect(find.text('PHP 1,000.00'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('PHP 2,000.00'), findsNWidgets(2));
  });

  testWidgets('switching modes preserves edited calculator values', (
    tester,
  ) async {
    await _pumpCalculator(tester);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '3500');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(find.text('Yearly rate'), findsOneWidget);
    expect(find.text('Years'), findsOneWidget);
    expect(_firstRateField(tester).controller?.text, '12000');

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(_firstRateField(tester).controller?.text, '3500');
    expect(find.text('PHP 3,500.00'), findsNWidgets(2));
  });

  testWidgets('security deposit stays independent of selected rate mode', (
    tester,
  ) async {
    await _pumpCalculator(tester, initialDeposit: '500');

    expect(find.text('Security deposit'), findsOneWidget);
    expect(find.text('PHP 500.00'), findsOneWidget);

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    expect(find.text('Security deposit'), findsOneWidget);
    expect(find.text('PHP 500.00'), findsOneWidget);
    expect(find.text('PHP 1,500.00'), findsOneWidget);
  });
}

Future<void> _pumpCalculator(
  WidgetTester tester, {
  String initialDeposit = '',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: LNDAppTheme.light,
      home: Scaffold(
        body: PricingFeeCalculatorSheet(
          initialDailyRate: '100',
          initialWeeklyRate: '1000',
          initialMonthlyRate: '3000',
          initialYearlyRate: '12000',
          initialDeposit: initialDeposit,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextFormField _firstRateField(WidgetTester tester) {
  return tester.widget<TextFormField>(find.byType(TextFormField).first);
}

LNDPricingPolicy _testPricingPolicy() {
  return LNDPricingPolicy.fromMap({
    'payment_method_fees': {
      'card': {
        'label': 'Card',
        'rate_bps': 0,
        'fixed_amount': 0,
        'calculation': 'rate_plus_fixed',
      },
      'gcash': {
        'label': 'E-wallet',
        'rate_bps': 0,
        'fixed_amount': 0,
        'calculation': 'rate_plus_fixed',
      },
      'dob': {
        'label': 'Bank transfer',
        'rate_bps': 0,
        'fixed_amount': 0,
        'calculation': 'rate_plus_fixed',
      },
    },
    'platform_fee': {
      'rate_bps': 0,
      'fixed_amount': 0,
      'calculation': 'rate_plus_fixed',
    },
    'wallet_transfer_fee': {
      'rate_bps': 0,
      'fixed_amount': 0,
      'calculation': 'rate_plus_fixed',
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

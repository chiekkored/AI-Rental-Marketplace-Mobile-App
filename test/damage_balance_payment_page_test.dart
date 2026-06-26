import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/presentation/controllers/damage_balance_payment/damage_balance_payment.controller.dart';
import 'package:lend/presentation/pages/damage_balance_payment/damage_balance_payment.page.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.testMode = false;
  });

  testWidgets(
    'does not show remaining deposit return for over-deposit damage',
    (tester) async {
      await _pumpPage(
        tester,
        booking: _booking(
          settlement: Settlement(
            approvedDamageDeductionAmount: 2500,
            depositReturnAmount: 0,
          ),
        ),
      );

      expect(find.text('Outstanding balance'), findsOneWidget);
      expect(find.text('Total due'), findsOneWidget);
      expect(find.text('Approved damage'), findsOneWidget);
      expect(find.text('Security deposit'), findsOneWidget);
      expect(find.text('Remaining deposit return'), findsNothing);
      expect(find.text('Deposit return'), findsNothing);
    },
  );

  testWidgets('shows backend deposit return amount when settlement has one', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      booking: _booking(
        settlement: Settlement(
          approvedDamageDeductionAmount: 700,
          depositReturnAmount: 300,
        ),
      ),
    );

    expect(find.text('Deposit return'), findsOneWidget);
    expect(find.text('PHP 300.00'), findsOneWidget);
    expect(find.text('Remaining deposit return'), findsNothing);
  });
}

Future<void> _pumpPage(WidgetTester tester, {required Booking booking}) async {
  await tester.pumpWidget(
    GetMaterialApp(theme: LNDAppTheme.light, home: const SizedBox.shrink()),
  );

  Get.to<void>(
    () => const DamageBalancePaymentPage(),
    arguments: DamageBalancePaymentPageArgs(
      chat: Chat(),
      bookingId: 'booking-1',
      chatId: 'chat-1',
      damagePaymentRequestId: 'request-1',
      amount: 1500,
      currency: 'PHP',
    ),
    binding: BindingsBuilder(() {
      final controller = Get.put<DamageBalancePaymentController>(
        _TestDamageBalancePaymentController(),
      );
      controller.booking.value = booking;
      controller.selectedPaymentMethod.value = LNDSelectedPaymentMethod.channel(
        methodType: 'gcash',
        label: 'GCash',
      );
      controller.checkoutPreview.value = const LNDPaymentCheckout(
        checkoutId: 'checkout-1',
        paymentIntentId: 'pi-1',
        clientKey: 'client-key',
        publicKey: 'public-key',
        returnUrl: 'lend://payment-return',
        amount: 1500,
        paymentAmount: 1560,
        renterProcessingFee: 60,
      );
    }),
  );

  await tester.pumpAndSettle();
}

class _TestDamageBalancePaymentController
    extends DamageBalancePaymentController {
  // Avoid the production Firestore load; each test seeds the booking directly.
  @override
  // ignore: must_call_super
  void onInit() {}
}

Booking _booking({required Settlement settlement}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: null,
    payment: Payment(currency: 'PHP'),
    renter: null,
    status: BookingStatus.returned,
    totalPrice: 1500,
    securityDeposit: const SecurityDeposit(enabled: true, amount: 1000),
    settlement: settlement,
  );
}

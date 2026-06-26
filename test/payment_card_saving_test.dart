import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/payment_method_config.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';

void main() {
  setUp(() {
    LNDPaymentService.resetSavedPaymentMethodCacheForTesting();
  });

  test('new card selections do not request card saving while disabled', () {
    final method = LNDSelectedPaymentMethod.newCard(
      cardNumber: '4242424242424242',
      expMonth: 12,
      expYear: 2030,
      cvc: '123',
      shouldSaveCard: LNDPaymentService.isCardSavingEnabled,
    );

    expect(LNDPaymentService.isCardSavingEnabled, isFalse);
    expect(method.shouldSaveCard, isFalse);
  });

  test('new card selections preserve explicit save card opt in', () {
    final method = LNDSelectedPaymentMethod.newCard(
      cardNumber: '4242424242424242',
      expMonth: 12,
      expYear: 2030,
      cvc: '123',
      shouldSaveCard: true,
    );

    expect(method.shouldSaveCard, isTrue);
  });

  test(
    'recurring new card form does not require saved card while disabled',
    () {
      final controller = PaymentMethodsController(
        args: const PaymentMethodsPageArgs(recurringBillingOnly: true),
      );
      addTearDown(controller.onClose);

      controller.prepareNewCardForm();

      expect(controller.isSaveCardRequiredForRecurring, isFalse);
      expect(controller.canToggleSaveCard, isTrue);
      expect(controller.shouldSaveCard.value, isFalse);
    },
  );

  test('upfront new card form can leave save card off', () {
    final controller = PaymentMethodsController(
      args: const PaymentMethodsPageArgs(recurringBillingOnly: false),
    );
    addTearDown(controller.onClose);

    controller.prepareNewCardForm();

    expect(controller.isSaveCardRequiredForRecurring, isFalse);
    expect(controller.canToggleSaveCard, isTrue);
    expect(controller.shouldSaveCard.value, isFalse);
  });

  test('recurring checkout does not track saved card cache while disabled', () {
    final method = LNDSelectedPaymentMethod.newCard(
      cardNumber: '4242424242424242',
      expMonth: 12,
      expYear: 2030,
      cvc: '123',
      shouldSaveCard: false,
    );

    expect(
      LNDPaymentService.shouldTrackSavedPaymentMethodCacheForTesting(
        paymentMethod: method,
        checkout: _checkout(isRecurringBilling: true),
      ),
      isFalse,
    );
    expect(
      LNDPaymentService.shouldTrackSavedPaymentMethodCacheForTesting(
        paymentMethod: method,
        checkout: _checkout(isRecurringBilling: false),
      ),
      isFalse,
    );
  });

  test('successful tracked checkout dirties saved method cache', () {
    LNDPaymentService.resetSavedPaymentMethodCacheForTesting(dirty: false);
    LNDPaymentService.trackSavedPaymentMethodCacheForTesting('checkout_123');

    LNDPaymentService.syncSavedPaymentMethodCacheStateForTesting(
      'checkout_123',
      const LNDPaymentSyncResult(status: 'booked', bookingId: 'booking_123'),
    );

    expect(LNDPaymentService.isSavedPaymentMethodsCacheDirty, isTrue);
  });

  test('failed tracked checkout clears tracking without dirtying cache', () {
    LNDPaymentService.resetSavedPaymentMethodCacheForTesting(dirty: false);
    LNDPaymentService.trackSavedPaymentMethodCacheForTesting('checkout_123');

    LNDPaymentService.syncSavedPaymentMethodCacheStateForTesting(
      'checkout_123',
      const LNDPaymentSyncResult(status: 'failed'),
    );
    LNDPaymentService.syncSavedPaymentMethodCacheStateForTesting(
      'checkout_123',
      const LNDPaymentSyncResult(status: 'booked', bookingId: 'booking_123'),
    );

    expect(LNDPaymentService.isSavedPaymentMethodsCacheDirty, isFalse);
  });

  test('debug saved methods include PayMongo test cards as local cards', () {
    final methods =
        LNDPaymentService.cachedSavedPaymentMethods
            .where((method) => method.id.startsWith('debug_paymongo_'))
            .toList();

    expect(methods, hasLength(9));
    expect(
      methods.map((method) => method.cardNumber),
      containsAll([
        '4343434343434345',
        '4571736000000075',
        '5123000000000002',
        '4120000000000007',
        '5123000000000001',
        '4200000000000018',
        '4300000000000017',
        '5100000000000198',
        '4111111111111111',
      ]),
    );
    expect(methods.every((method) => method.isLocal), isTrue);
    expect(methods.every((method) => method.paymentMethodId == null), isTrue);
    expect(methods.every((method) => method.shouldSaveCard == false), isTrue);
    expect(
      methods.every((method) => method.subtitle?.isNotEmpty == true),
      isTrue,
    );
  });

  test('debug PayMongo test cards are identifiable after selection', () {
    final savedMethod = LNDPaymentService.cachedSavedPaymentMethods.firstWhere(
      (method) => method.isDebugPayMongoTestCard,
    );

    final selected = LNDSelectedPaymentMethod.newCard(
      cardNumber: savedMethod.cardNumber!,
      expMonth: savedMethod.expMonth!,
      expYear: savedMethod.expYear!,
      cvc: '123',
      shouldSaveCard: false,
      localCardId: savedMethod.id,
    );

    expect(selected.isDebugPayMongoTestCard, isTrue);
  });

  test(
    'recurring billing supports only visa mastercard and maya selections',
    () {
      final visa = LNDSelectedPaymentMethod.newCard(
        cardNumber: '4242424242424242',
        expMonth: 12,
        expYear: 2030,
        cvc: '123',
        shouldSaveCard: false,
      );
      final mastercard = LNDSelectedPaymentMethod.newCard(
        cardNumber: '5123000000000002',
        expMonth: 12,
        expYear: 2030,
        cvc: '123',
        shouldSaveCard: false,
      );
      final amex = LNDSelectedPaymentMethod.newCard(
        cardNumber: '378282246310005',
        expMonth: 12,
        expYear: 2030,
        cvc: '1234',
        shouldSaveCard: false,
      );
      final maya = LNDSelectedPaymentMethod.channel(
        methodType: 'paymaya',
        label: 'Maya',
      );
      final gcash = LNDSelectedPaymentMethod.channel(
        methodType: 'gcash',
        label: 'GCash',
      );

      expect(visa.isRecurringBillingSupported, isTrue);
      expect(mastercard.isRecurringBillingSupported, isTrue);
      expect(maya.isRecurringBillingSupported, isTrue);
      expect(amex.isRecurringBillingSupported, isFalse);
      expect(gcash.isRecurringBillingSupported, isFalse);
    },
  );

  test('payment method groups report no visible wallet methods', () {
    final controller = PaymentMethodsController();
    addTearDown(controller.onClose);

    controller.paymentMethodConfig.value = const LNDPaymentMethodConfig(
      upfrontMethods: {
        'card': LNDPaymentMethodState.visibleEnabled,
        'gcash': LNDPaymentMethodState.hiddenDisabled,
        'paymaya': LNDPaymentMethodState.hiddenDisabled,
        'grab_pay': LNDPaymentMethodState.hiddenDisabled,
        'shopeepay': LNDPaymentMethodState.hiddenDisabled,
        'qrph': LNDPaymentMethodState.hiddenDisabled,
      },
      subscriptionMethods: {},
    );

    expect(controller.visibleWalletPaymentMethodIds, isEmpty);
    expect(controller.hasVisibleWalletPaymentMethods, isFalse);
  });

  test('payment method groups report no visible bank methods', () {
    final controller = PaymentMethodsController();
    addTearDown(controller.onClose);

    controller.paymentMethodConfig.value = const LNDPaymentMethodConfig(
      upfrontMethods: {
        'card': LNDPaymentMethodState.visibleEnabled,
        'bpi': LNDPaymentMethodState.hiddenDisabled,
        'ubp': LNDPaymentMethodState.hiddenDisabled,
        'bdo': LNDPaymentMethodState.hiddenDisabled,
        'landbank': LNDPaymentMethodState.hiddenDisabled,
        'metrobank': LNDPaymentMethodState.hiddenDisabled,
      },
      subscriptionMethods: {},
    );

    expect(controller.visibleBankPaymentMethodIds, isEmpty);
    expect(controller.hasVisibleBankPaymentMethods, isFalse);
  });

  test('selected card server details include brand and last4', () {
    final selected = LNDSelectedPaymentMethod.newCard(
      cardNumber: '4242424242424242',
      expMonth: 12,
      expYear: 2030,
      cvc: '123',
      shouldSaveCard: false,
    );

    expect(selected.serverDetails['card_brand'], 'Visa');
    expect(selected.serverDetails['last4'], '4242');
  });

  test('debug PayMongo test cards are blocked with live public keys', () async {
    final savedMethod = LNDPaymentService.cachedSavedPaymentMethods.firstWhere(
      (method) => method.isDebugPayMongoTestCard,
    );
    final selected = LNDSelectedPaymentMethod.newCard(
      cardNumber: savedMethod.cardNumber!,
      expMonth: savedMethod.expMonth!,
      expYear: savedMethod.expYear!,
      cvc: '123',
      shouldSaveCard: false,
      localCardId: savedMethod.id,
    );

    await expectLater(
      LNDPaymentService.createPaymentMethod(
        publicKey: 'pk_live_example',
        selected: selected,
      ),
      throwsA(
        isA<LNDPaymentServiceException>().having(
          (error) => error.message,
          'message',
          'PayMongo test cards require test API keys.',
        ),
      ),
    );
  });

  test('PayMongo 400 responses are normalized to API error detail', () {
    final requestOptions = RequestOptions(path: '/v1/payment_methods');
    final error = DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 400,
        data: {
          'errors': [
            {'detail': 'card number is invalid'},
          ],
        },
      ),
    );

    expect(
      LNDPaymentService.paymentMethodErrorMessage(error),
      'card number is invalid',
    );
  });

  test('live card authentication statuses are recoverable', () {
    expect(
      LNDPaymentService.isRecoverablePaymentStatus('awaiting_next_action'),
      isTrue,
    );
    expect(
      LNDPaymentService.isRecoverablePaymentStatus('requires_action'),
      isTrue,
    );
    expect(LNDPaymentService.isRecoverablePaymentStatus('processing'), isTrue);
    expect(
      LNDPaymentService.isRecoverablePaymentStatus('awaiting_payment_method'),
      isFalse,
    );
    expect(LNDPaymentService.isRecoverablePaymentStatus('failed'), isFalse);
  });

  test('PayMongo next action URLs are parsed from alternate shapes', () {
    final nextAction = {
      'type': 'redirect',
      'authentication': {'redirect_url': 'https://issuer.example/3ds'},
    };

    expect(
      LNDPaymentService.nextActionRedirectUrl(nextAction),
      'https://issuer.example/3ds',
    );
  });

  test('PayMongo QR and test URLs are parsed from nested action data', () {
    final nextAction = {
      'code': {
        'image_url': 'data:image/png;base64,abc',
        'test_url': 'https://paymongo.example/test',
      },
    };

    expect(
      LNDPaymentService.nextActionQrImageUrl(nextAction),
      'data:image/png;base64,abc',
    );
    expect(
      LNDPaymentService.nextActionTestUrl(nextAction),
      'https://paymongo.example/test',
    );
  });

  test('awaiting next action without redirect URL is detected', () {
    const result = LNDPaymentSyncResult(
      status: 'awaiting_next_action',
      paymentStatus: 'awaiting_next_action',
      nextAction: {
        'type': 'redirect',
        'redirect': {'url': null, 'return_url': 'https://example.com/return'},
      },
    );

    expect(
      LNDPaymentService.isMissingRequiredNextActionUrl(result, null),
      isTrue,
    );
  });

  test('payment method attributes include cleaned billing details', () {
    final selected = LNDSelectedPaymentMethod.newCard(
      cardNumber: '4242424242424242',
      expMonth: 12,
      expYear: 2030,
      cvc: '123',
      shouldSaveCard: false,
    );

    final attributes = LNDPaymentService.buildPaymentMethodAttributes(
      selected,
      billingDetails: LNDPaymentService.buildBillingDetails(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        phone: '+639171234567',
        line1: '123 Main St',
        city: 'Manila',
        state: 'Metro Manila',
        postalCode: '1000',
        country: 'PH',
      ),
    );

    expect(attributes['billing'], {
      'name': 'Ada Lovelace',
      'email': 'ada@example.com',
      'phone': '+639171234567',
      'address': {
        'line1': '123 Main St',
        'city': 'Manila',
        'state': 'Metro Manila',
        'postal_code': '1000',
        'country': 'PH',
      },
    });
  });
}

LNDPaymentCheckout _checkout({required bool isRecurringBilling}) {
  return LNDPaymentCheckout(
    checkoutId: 'checkout_123',
    paymentIntentId: 'pi_123',
    clientKey: 'pi_123_client_secret',
    publicKey: 'pk_test_123',
    returnUrl: 'https://example.com/return',
    isRecurringBilling: isRecurringBilling,
  );
}

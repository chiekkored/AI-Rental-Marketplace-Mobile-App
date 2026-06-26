import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/payment_holding/payment_holding.controller.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class DamageBalancePaymentPageArgs {
  final Chat chat;
  final String bookingId;
  final String chatId;
  final String damagePaymentRequestId;
  final int amount;
  final String currency;

  const DamageBalancePaymentPageArgs({
    required this.chat,
    required this.bookingId,
    required this.chatId,
    required this.damagePaymentRequestId,
    required this.amount,
    required this.currency,
  });
}

class DamageBalancePaymentController extends GetxController
    with WidgetsBindingObserver {
  final DamageBalancePaymentPageArgs args =
      Get.arguments as DamageBalancePaymentPageArgs;

  final Rxn<Booking> booking = Rxn<Booking>();
  final Rxn<LNDSelectedPaymentMethod> selectedPaymentMethod =
      Rxn<LNDSelectedPaymentMethod>();
  final Rxn<LNDPaymentCheckout> checkoutPreview = Rxn<LNDPaymentCheckout>();
  final RxBool isLoading = false.obs;
  final RxnString qrImageUrl = RxnString();
  StreamSubscription<LNDPaymentCheckoutStatus>? _checkoutSubscription;
  String? _activeCheckoutId;
  bool _terminalPaymentHandled = false;
  bool _isSyncingOnResume = false;
  bool _isControllerClosed = false;
  bool _waitingForExternalPayment = false;

  bool get canPay => !isLoading.value && selectedPaymentMethod.value != null;
  num? get renterProcessingFee => checkoutPreview.value?.renterProcessingFee;
  num? get totalToPay => checkoutPreview.value?.paymentAmount;
  num? get estimatedProcessingFee {
    final paymentMethod = selectedPaymentMethod.value;
    if (paymentMethod == null) return null;

    final policy = LNDRemoteConfigService.pricingPolicy;
    final resolvedFee = policy.resolvePaymentMethodFee(
      method: paymentMethod.methodType,
      details: paymentMethod.details,
      payerCountryShortName:
          ProfileController.instance.user?.location?.countryShortName,
    );
    return policy.calculatePaymentMethodFee(args.amount, resolvedFee.rule);
  }

  num? get displayProcessingFee =>
      checkoutPreview.value?.renterProcessingFee ?? estimatedProcessingFee;

  num get displayTotalToPay {
    final checkoutTotal = checkoutPreview.value?.paymentAmount;
    if (checkoutTotal != null) return checkoutTotal;
    return args.amount + (estimatedProcessingFee ?? 0);
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadBooking());
  }

  @override
  void onClose() {
    _isControllerClosed = true;
    WidgetsBinding.instance.removeObserver(this);
    _checkoutSubscription?.cancel();
    if (isLoading.value) {
      LNDLoading.hide();
    }
    booking.close();
    selectedPaymentMethod.close();
    checkoutPreview.close();
    isLoading.close();
    qrImageUrl.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncActiveCheckoutOnResume());
    }
  }

  Future<void> selectPaymentMethod() async {
    final result = await LNDNavigate.toPaymentMethodsPage(
      args: PaymentMethodsPageArgs(current: selectedPaymentMethod.value),
    );
    if (result is LNDSelectedPaymentMethod) {
      selectedPaymentMethod.value = result;
      checkoutPreview.value = null;
      qrImageUrl.value = null;
    }
  }

  Future<void> pay() async {
    final paymentMethod = selectedPaymentMethod.value;
    if (paymentMethod == null || isLoading.value) return;

    String? checkoutId;
    _activeCheckoutId = null;
    _terminalPaymentHandled = false;
    _waitingForExternalPayment = false;

    try {
      isLoading.value = true;
      LNDLoading.show(text: 'Preparing payment');
      final checkout =
          await LNDPaymentService.createDamageBalancePaymentCheckout(
            bookingId: args.bookingId,
            chatId: args.chatId,
            damagePaymentRequestId: args.damagePaymentRequestId,
            paymentMethod: paymentMethod,
          );
      checkoutPreview.value = checkout;
      checkoutId = checkout.checkoutId;

      late LNDPaymentSyncResult syncResult;
      if (paymentMethod.kind == LNDPaymongoPaymentKind.savedCard) {
        LNDLoading.show(text: 'Processing payment');
        syncResult = await LNDPaymentService.attachSavedCardPaymentMethod(
          checkoutId: checkout.checkoutId,
          customerPaymentMethodId: paymentMethod.customerPaymentMethodId!,
          cvc: paymentMethod.cvc!,
        );
      } else {
        LNDLoading.show(text: 'Creating payment method');
        final paymongoMethod = await LNDPaymentService.createPaymentMethod(
          publicKey: checkout.publicKey,
          selected: paymentMethod,
          billingDetails: _paymentBillingDetails(),
        );
        final paymentMethodId =
            (paymongoMethod['data'] as Map?)?['id'] as String?;
        if (paymentMethodId == null) {
          throw 'Unable to create payment method';
        }

        LNDLoading.show(text: 'Processing payment');
        syncResult = await LNDPaymentService.attachPaymentMethod(
          checkout: checkout,
          paymentMethodId: paymentMethodId,
        );
      }

      await _handleSyncResult(checkout.checkoutId, syncResult);
    } catch (e, st) {
      if (checkoutId != null && !_waitingForExternalPayment) {
        await _cancelFailedCheckout(checkoutId, e);
        await _stopCheckoutWatch();
        _activeCheckoutId = null;
      }
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDLoading.hide();
      LNDSnackbar.showError(_paymentErrorText(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBooking() async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection(LNDCollections.bookings.name)
              .doc(args.bookingId)
              .get();
      if (snap.exists) {
        booking.value = Booking.fromMap(snap.data() ?? const {});
      }
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to load damage payment details.');
    }
  }

  Future<void> _handleSyncResult(
    String checkoutId,
    LNDPaymentSyncResult result, {
    bool fromResume = false,
  }) async {
    if (_isControllerClosed || _terminalPaymentHandled) return;
    _activeCheckoutId = checkoutId;

    if (result.isPaid) {
      if (!_beginTerminalPaymentHandling()) return;
      await _stopCheckoutWatch();
      LNDLoading.hide();
      _finishPaidPayment();
      return;
    }

    if (result.status == 'failed' ||
        result.status == 'expired' ||
        result.status == 'cancelled') {
      if (!_beginTerminalPaymentHandling()) return;
      await _stopCheckoutWatch();
      LNDLoading.hide();
      LNDSnackbar.showError(_syncFailureText(result));
      return;
    }

    final nextAction = result.nextAction;
    _debugLogPaymentSyncResult(result);
    final redirectUrl = LNDPaymentService.nextActionRedirectUrl(nextAction);
    final testUrl = LNDPaymentService.nextActionTestUrl(nextAction);
    final qrUrl = LNDPaymentService.nextActionQrImageUrl(nextAction);
    if (LNDPaymentService.isMissingRequiredNextActionUrl(result, redirectUrl)) {
      _debugLogMissingNextActionUrl(result);
      throw LNDPaymentService.missingNextActionUrlMessage();
    }

    if ((fromResume &&
            ((redirectUrl != null && redirectUrl.isNotEmpty) ||
                (testUrl != null && testUrl.isNotEmpty))) ||
        (kDebugMode && testUrl != null && testUrl.isNotEmpty) ||
        (qrUrl != null && qrUrl.isNotEmpty) ||
        (redirectUrl != null && redirectUrl.isNotEmpty) ||
        LNDPaymentService.isRecoverablePaymentStatus(result.paymentStatus) ||
        LNDPaymentService.isRecoverablePaymentStatus(result.status) ||
        nextAction != null) {
      _waitingForExternalPayment = false;
      LNDLoading.hide();
      await _openPaymentHoldingPage(checkoutId, result);
      return;
    }

    throw result.lastPaymentError?['failed_message'] ??
        result.lastPaymentError?['message'] ??
        'Payment was not completed';
  }

  Future<void> _openPaymentHoldingPage(
    String checkoutId,
    LNDPaymentSyncResult result,
  ) async {
    final paymentMethod = selectedPaymentMethod.value;
    final holdingResult =
        await LNDNavigate.toPaymentHoldingPage(
              args: PaymentHoldingPageArgs(
                checkoutId: checkoutId,
                methodType: _holdingMethodType(
                  paymentMethod,
                  result.nextAction,
                ),
                methodLabel: paymentMethod?.displayLabel ?? 'Payment',
                methodDetails: paymentMethod?.details ?? const {},
                nextAction: result.nextAction,
                successMode: PaymentHoldingSuccessMode.damageBalance,
                cancelReason: 'User cancelled pending damage balance payment',
              ),
            )
            as PaymentHoldingResult?;

    if (_isControllerClosed || holdingResult == null) return;

    switch (holdingResult.status) {
      case PaymentHoldingResultStatus.success:
        if (!_beginTerminalPaymentHandling()) return;
        await _stopCheckoutWatch();
        _finishPaidPayment();
      case PaymentHoldingResultStatus.failed:
        if (!_beginTerminalPaymentHandling()) return;
        await _stopCheckoutWatch();
        LNDSnackbar.showError(
          holdingResult.message ?? 'Payment failed. Please try another method.',
        );
      case PaymentHoldingResultStatus.cancelled:
        _terminalPaymentHandled = true;
        _waitingForExternalPayment = false;
        _activeCheckoutId = null;
    }
  }

  String _holdingMethodType(
    LNDSelectedPaymentMethod? paymentMethod,
    Map<String, dynamic>? nextAction,
  ) {
    final methodType = paymentMethod?.methodType;
    if (methodType != null && methodType.isNotEmpty) return methodType;

    final qrUrl = LNDPaymentService.nextActionQrImageUrl(nextAction);
    if (qrUrl != null && qrUrl.isNotEmpty) return 'qrph';

    return 'card';
  }

  Future<void> _syncActiveCheckoutOnResume() async {
    final checkoutId = _activeCheckoutId;
    if (_isControllerClosed ||
        checkoutId == null ||
        _terminalPaymentHandled ||
        _isSyncingOnResume) {
      return;
    }

    _isSyncingOnResume = true;
    try {
      final result = await LNDPaymentService.syncPaymentCheckout(checkoutId);
      await _handleSyncResult(checkoutId, result, fromResume: true);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      _isSyncingOnResume = false;
    }
  }

  bool _beginTerminalPaymentHandling() {
    if (_isControllerClosed || _terminalPaymentHandled) return false;
    _terminalPaymentHandled = true;
    _waitingForExternalPayment = false;
    return true;
  }

  Future<void> _stopCheckoutWatch() async {
    await _checkoutSubscription?.cancel();
    _checkoutSubscription = null;
  }

  Future<void> _cancelFailedCheckout(String checkoutId, Object error) async {
    try {
      await LNDPaymentService.cancelPaymentCheckout(
        checkoutId: checkoutId,
        reason: _paymentErrorText(error),
      );
    } catch (cancelError, st) {
      LNDLogger.e(cancelError.toString(), error: cancelError, stackTrace: st);
    }
  }

  void _finishPaidPayment() {
    LNDSnackbar.showSuccess('Damage balance paid.');
    Get.back();
  }

  String _syncFailureText(LNDPaymentSyncResult result) {
    if (result.status == 'expired') {
      return 'Payment expired. Please try again.';
    }
    return result.lastPaymentError?['failed_message'] as String? ??
        result.lastPaymentError?['message'] as String? ??
        'Payment failed. Please try another method.';
  }

  void _debugLogPaymentSyncResult(LNDPaymentSyncResult result) {
    if (!kDebugMode) return;
    debugPrint(
      'PayMongo damage balance sync result: '
      'status=${result.status}, '
      'paymentStatus=${result.paymentStatus ?? 'none'}, '
      'nextActionKeys=${result.nextAction?.keys.toList() ?? 'none'}, '
      'lastPaymentError=${result.lastPaymentError ?? 'none'}',
    );
  }

  void _debugLogMissingNextActionUrl(LNDPaymentSyncResult result) {
    if (!kDebugMode) return;
    final redirect = result.nextAction?['redirect'];
    debugPrint(
      'PayMongo damage balance missing 3DS URL: '
      'status=${result.status}, '
      'paymentStatus=${result.paymentStatus ?? 'none'}, '
      'nextActionType=${result.nextAction?['type'] ?? 'none'}, '
      'redirectKeys=${redirect is Map ? redirect.keys.toList() : 'none'}, '
      'paymentMethod=${selectedPaymentMethod.value?.methodType ?? 'unknown'}',
    );
  }

  String _paymentErrorText(Object error) {
    final rawText = error.toString();
    final text = rawText.toLowerCase();
    if (text.contains('expired')) {
      return 'Payment expired. Please try again.';
    }
    if (text.contains('card details are incomplete')) {
      return 'Card details are incomplete.';
    }
    return rawText
        .replaceFirst('Exception: ', '')
        .replaceFirst('LNDPaymentServiceException: ', '');
  }

  Map<String, dynamic> _paymentBillingDetails() {
    if (!Get.isRegistered<ProfileController>()) return const {};
    final user = ProfileController.instance.user;
    final location = user?.location;
    return LNDPaymentService.buildBillingDetails(
      firstName: user?.firstName,
      lastName: user?.lastName,
      email: user?.email,
      phone: user?.phone,
      line1: location?.formattedAddress,
      city: location?.locality,
      state: location?.administrativeAreaLevel1,
      postalCode: location?.postalCode,
      country: location?.countryShortName,
    );
  }
}

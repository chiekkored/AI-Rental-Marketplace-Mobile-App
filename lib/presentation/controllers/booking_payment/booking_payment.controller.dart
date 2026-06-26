import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_instructions/booking_instructions.controller.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/controllers/navigation/navigation.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/controllers/payment_holding/payment_holding.controller.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';
import 'package:lend/utilities/enums/bottom_nav_page.enum.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class BookingPaymentPageArgs {
  final Asset asset;
  final String? assetControllerTag;
  final List<DateTime> selectedDates;
  final int totalPrice;
  final bool isRecoveredCheckout;
  final String? checkoutId;
  final String? paymentStatus;
  final Map<String, dynamic>? nextAction;
  final int? checkoutLockExpiresAtMs;

  const BookingPaymentPageArgs({
    required this.asset,
    this.assetControllerTag,
    required this.selectedDates,
    required this.totalPrice,
    this.isRecoveredCheckout = false,
    this.checkoutId,
    this.paymentStatus,
    this.nextAction,
    this.checkoutLockExpiresAtMs,
  });
}

class BookingPaymentController extends GetxController
    with WidgetsBindingObserver {
  final BookingPaymentPageArgs args = Get.arguments as BookingPaymentPageArgs;

  final Rxn<LNDSelectedPaymentMethod> selectedPaymentMethod =
      Rxn<LNDSelectedPaymentMethod>();
  final RxBool isLoading = false.obs;
  final RxnString qrImageUrl = RxnString();
  StreamSubscription<LNDPaymentCheckoutStatus>? _checkoutSubscription;
  Timer? _checkoutPendingTimer;
  String? _activeCheckoutId;
  bool _terminalPaymentHandled = false;
  bool _isSyncingOnResume = false;
  bool _isControllerClosed = false;
  bool _waitingForExternalPayment = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  Map<String, dynamic>? _latestNextAction;

  Asset get asset => args.asset;
  AssetController? get assetController {
    final tag = args.assetControllerTag;
    if (tag == null || !Get.isRegistered<AssetController>(tag: tag)) {
      return null;
    }
    return Get.find<AssetController>(tag: tag);
  }

  DateTime get startDate => args.selectedDates.first;
  DateTime get endDate => args.selectedDates.last;
  int get totalPrice => args.totalPrice;
  bool get isRecoveredCheckout => args.isRecoveredCheckout;
  bool get isRecoveredPendingCheckout =>
      isRecoveredCheckout &&
      !_terminalPaymentHandled &&
      args.checkoutId != null;
  bool get canBook =>
      !isLoading.value &&
      (qrImageUrl.value == null || qrImageUrl.value!.isEmpty) &&
      (isRecoveredCheckout || selectedPaymentMethod.value != null);
  bool get canUsePrimaryAction =>
      !isLoading.value &&
      (isRecoveredCheckout || selectedPaymentMethod.value != null);
  String get primaryActionText =>
      isRecoveredCheckout ? 'Continue payment' : 'Book and pay';
  bool get isRecurringBillingBooking =>
      _usesRecurringRateChunk(startDate, endDate);
  bool get hasRecurringAutoDeductPayment {
    final lines = BookingPriceBreakdown.calculate(
      rates: asset.rates,
      startDate: startDate,
      endDate: endDate,
    );
    return BookingPriceBreakdown.subscriptionSplit(lines).hasRecurringBilling;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _latestNextAction = args.nextAction;
    if (isRecoveredCheckout && args.checkoutId != null) {
      unawaited(_startRecoveredCheckout());
    }
  }

  @override
  void onClose() {
    _isControllerClosed = true;
    WidgetsBinding.instance.removeObserver(this);
    _checkoutSubscription?.cancel();
    _checkoutPendingTimer?.cancel();
    if (isLoading.value) {
      LNDLoading.hide();
    }
    selectedPaymentMethod.close();
    isLoading.close();
    qrImageUrl.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncActiveCheckoutOnResume());
    }
  }

  Future<void> selectPaymentMethod() async {
    if (isRecoveredCheckout) return;
    final result = await LNDNavigate.toPaymentMethodsPage(
      args: PaymentMethodsPageArgs(
        current: selectedPaymentMethod.value,
        recurringBillingOnly: isRecurringBillingBooking,
      ),
    );
    if (result is LNDSelectedPaymentMethod) {
      selectedPaymentMethod.value = result;
      qrImageUrl.value = null;
    }
  }

  void openRecurringPaymentInfo() {
    LNDShow.bottomSheetInfo([
      LNDText.regular(
        text:
            'Some weekly, monthly, or yearly bookings are paid fully upfront.\n\n'
            'Example:\n'
            '2 months × PHP 3,000/month\n'
            '= PHP 6,000 due today\n\n'
            'Future auto-deduction: PHP 0',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'Longer bookings can use recurring auto-deduct.\n\n'
            'Example:\n'
            '3 months × PHP 3,000/month\n\n'
            'Due today: PHP 3,000\n'
            'Remaining balance: PHP 6,000\n'
            'Auto-deduct: PHP 3,000/month\n'
            'Billing dates left: 2',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'Yearly bookings follow the same rule: shorter selections can be fully upfront, while recurring selections charge the first annual cycle today and future annual cycles on their billing dates.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'Due today can also include security deposit, fees, and smaller rental remainders. Your payment provider may ask you to authorize recurring billing after the upfront payment.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'The booking is confirmed only after the required upfront payment and authorization are completed.',
        overflow: TextOverflow.visible,
      ),
    ], title: 'Recurring payments');
  }

  Future<void> book() async {
    if (isRecoveredCheckout) {
      await continueRecoveredPayment();
      return;
    }

    final paymentMethod = selectedPaymentMethod.value;
    if (paymentMethod == null || isLoading.value) return;
    String? checkoutId;

    try {
      isLoading.value = true;
      if (asset.securityDeposit.enabled) {
        if (ProfileController.instance.verified != VerificationLevel.full) {
          isLoading.value = false;
          LNDSnackbar.showError(
            'Full verification is required to book listings with security deposits.',
          );
          LNDNavigate.toFullVerificationPage();
          return;
        }

        final depositDestination =
            await LNDPaymentService.getDepositReturnDestination();
        if (depositDestination == null) {
          isLoading.value = false;
          LNDSnackbar.showError(
            'Add a security deposit return destination before booking.',
          );
          await LNDNavigate.toDepositReturnDestinationPage();
          return;
        }
      }

      _activeCheckoutId = null;
      _terminalPaymentHandled = false;
      _waitingForExternalPayment = false;
      LNDLoading.show(text: 'Preparing payment');

      final checkout = await LNDPaymentService.createPaymentCheckout(
        assetId: asset.id,
        startDate: startDate,
        endDate: endDate,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
      );
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
      final errorText = _paymentErrorText(e);
      LNDLoading.hide();
      LNDSnackbar.showError(errorText);
      if (_isTemporaryReservationError(e)) {
        await _returnToCalendarAndRefreshAvailability();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> simulatePendingPayment() async {
    if (!kDebugMode) return;
    final paymentMethod = selectedPaymentMethod.value;
    if (paymentMethod == null || isLoading.value || isRecoveredCheckout) {
      return;
    }

    try {
      isLoading.value = true;
      _activeCheckoutId = null;
      _terminalPaymentHandled = false;
      _waitingForExternalPayment = false;
      LNDLoading.show(text: 'Creating pending payment');

      final checkout = await LNDPaymentService.createPaymentCheckout(
        assetId: asset.id,
        startDate: startDate,
        endDate: endDate,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
      );

      _activeCheckoutId = checkout.checkoutId;
      LNDLoading.show(text: 'Pending payment simulated');
      _watchCheckout(checkout.checkoutId);
      LNDSnackbar.showInfo(
        'Pending payment created. Close and reopen the app to test recovery.',
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDLoading.hide();
      LNDSnackbar.showError(_paymentErrorText(e));
      if (_isTemporaryReservationError(e)) {
        await _returnToCalendarAndRefreshAvailability();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continueRecoveredPayment() async {
    final checkoutId = args.checkoutId;
    if (checkoutId == null || isLoading.value || _terminalPaymentHandled) {
      return;
    }

    try {
      isLoading.value = true;
      final syncResult = LNDPaymentSyncResult(
        status: args.paymentStatus ?? 'processing',
        paymentStatus: args.paymentStatus,
        nextAction: _latestNextAction,
      );
      await _handleSyncResult(checkoutId, syncResult);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDLoading.hide();
      LNDSnackbar.showError(_paymentErrorText(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> onWillPop() async {
    if (!isRecoveredPendingCheckout) return true;
    await requestClosePaymentPage();
    return false;
  }

  Future<void> requestClosePaymentPage() async {
    if (!isRecoveredPendingCheckout) {
      Get.back();
      return;
    }

    final confirmed = await LNDShow.alertDialog<bool?>(
      title: 'Cancel pending booking?',
      content:
          'Leaving this payment will cancel the pending booking and release the selected dates.',
      cancelText: 'Stay',
      confirmText: 'Cancel booking',
      confirmColor: Get.theme.colorScheme.error,
    );
    if (confirmed != true) return;

    final checkoutId = args.checkoutId;
    if (checkoutId == null) return;

    try {
      isLoading.value = true;
      LNDLoading.show(text: 'Cancelling pending booking');
      await LNDPaymentService.cancelPaymentCheckout(
        checkoutId: checkoutId,
        reason: 'User cancelled recovered pending payment',
      );
      await _stopCheckoutWatch();
      await LNDPaymentService.clearPendingPaymentMarker(checkoutId: checkoutId);
      _terminalPaymentHandled = true;
      LNDLoading.hide();
      Get.back();
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDLoading.hide();
      LNDSnackbar.showError('Unable to cancel pending booking.');
    } finally {
      isLoading.value = false;
    }
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

  Future<void> _handleSyncResult(
    String checkoutId,
    LNDPaymentSyncResult result, {
    bool fromResume = false,
  }) async {
    if (_isControllerClosed || _terminalPaymentHandled) return;
    _activeCheckoutId = checkoutId;

    if (result.isBooked) {
      if (!_beginTerminalPaymentHandling()) return;
      await _stopCheckoutWatch();
      LNDLoading.hide();
      await _finishBookedPayment();
      return;
    }

    if (_isTerminalSyncFailure(result)) {
      if (!_beginTerminalPaymentHandling()) return;
      await _stopCheckoutWatch();
      LNDLoading.hide();
      LNDSnackbar.showError(_syncFailureText(result));
      return;
    }

    final nextAction = result.nextAction;
    if (nextAction != null) {
      _latestNextAction = nextAction;
    }
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

  Future<void> checkPaymentStatus() async {
    LNDSnackbar.showError('Start a payment first.');
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
                successMode: PaymentHoldingSuccessMode.booking,
                clearPendingMarkerOnTerminal: true,
                cancelReason: 'User cancelled pending booking payment',
                onSuccess: (_) async {
                  if (_isControllerClosed) return;
                  if (!_beginTerminalPaymentHandling()) return;
                  await _stopCheckoutWatch();
                  await _finishBookedPayment();
                },
              ),
            )
            as PaymentHoldingResult?;

    if (_isControllerClosed || holdingResult == null) return;

    switch (holdingResult.status) {
      case PaymentHoldingResultStatus.success:
        if (!_beginTerminalPaymentHandling()) return;
        await _stopCheckoutWatch();
        await _finishBookedPayment();
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

  void _watchCheckout(String checkoutId) {
    if (_isControllerClosed) return;
    if (_activeCheckoutId != checkoutId) {
      _terminalPaymentHandled = false;
    }
    _activeCheckoutId = checkoutId;
    _checkoutSubscription?.cancel();
    _checkoutPendingTimer?.cancel();

    _checkoutPendingTimer = Timer(const Duration(seconds: 90), () {
      if (_isControllerClosed || _terminalPaymentHandled) return;
      if (_lifecycleState != AppLifecycleState.resumed) return;
      if (qrImageUrl.value == null) {
        LNDLoading.show(
          text:
              'Payment is still pending. You can return to Messages after confirmation.',
        );
      }
      LNDSnackbar.showError(
        'Payment is still pending. We will confirm the booking after PayMongo confirms payment.',
      );
    });

    _checkoutSubscription = LNDPaymentService.watchPaymentCheckout(
      checkoutId,
    ).listen(
      (checkout) {
        unawaited(_handleCheckoutUpdate(checkout));
      },
      onError: (Object error, StackTrace st) {
        LNDLogger.e(error.toString(), error: error, stackTrace: st);
        if (_isControllerClosed ||
            _lifecycleState != AppLifecycleState.resumed ||
            isTransientCheckoutWatchError(error)) {
          return;
        }
        LNDSnackbar.showError('Unable to watch payment confirmation.');
      },
    );
  }

  Future<void> _startRecoveredCheckout() async {
    final checkoutId = args.checkoutId;
    if (checkoutId == null || _isControllerClosed) return;
    _activeCheckoutId = checkoutId;
    _watchCheckout(checkoutId);
    await _syncActiveCheckoutOnResume();
  }

  Future<void> _handleCheckoutUpdate(LNDPaymentCheckoutStatus checkout) async {
    if (_isControllerClosed || _terminalPaymentHandled) return;

    if (checkout.isBooked) {
      if (_lifecycleState != AppLifecycleState.resumed) return;
      if (!_beginTerminalPaymentHandling()) return;
      await _stopCheckoutWatch();
      LNDLoading.hide();
      await _finishBookedPayment();
      return;
    }

    if (checkout.isTerminalFailure) {
      if (_lifecycleState != AppLifecycleState.resumed) return;
      if (!_beginTerminalPaymentHandling()) return;
      await _stopCheckoutWatch();
      LNDLoading.hide();
      LNDSnackbar.showError(_checkoutFailureText(checkout));
      return;
    }

    if (checkout.status == 'processing' && qrImageUrl.value == null) {
      if (_lifecycleState != AppLifecycleState.resumed) return;
      LNDLoading.show(text: 'Waiting for PayMongo confirmation');
    }
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
    final checkoutId = _activeCheckoutId ?? args.checkoutId;
    if (checkoutId != null) {
      unawaited(
        LNDPaymentService.clearPendingPaymentMarker(checkoutId: checkoutId),
      );
    }
    return true;
  }

  Future<void> _stopCheckoutWatch() async {
    _checkoutPendingTimer?.cancel();
    _checkoutPendingTimer = null;
    await _checkoutSubscription?.cancel();
    _checkoutSubscription = null;
  }

  @visibleForTesting
  static bool isTransientCheckoutWatchError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('unavailable') ||
        text.contains('unknownhostexception') ||
        text.contains('unable to resolve host') ||
        text.contains('broken pipe') ||
        text.contains('software caused connection abort') ||
        text.contains('end of stream') ||
        text.contains('failed to resolve name');
  }

  String _checkoutFailureText(LNDPaymentCheckoutStatus checkout) {
    if (checkout.status == 'expired') {
      return 'Payment expired. Please try again.';
    }
    return checkout.lastPaymentError?['failed_message'] as String? ??
        checkout.lastPaymentError?['message'] as String? ??
        'Payment failed. Please try another method.';
  }

  bool _isTerminalSyncFailure(LNDPaymentSyncResult result) {
    return result.status == 'failed' ||
        result.status == 'expired' ||
        result.status == 'cancelled';
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
      'PayMongo booking sync result: '
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
      'PayMongo missing 3DS URL: '
      'status=${result.status}, '
      'paymentStatus=${result.paymentStatus ?? 'none'}, '
      'nextActionType=${result.nextAction?['type'] ?? 'none'}, '
      'redirectKeys=${redirect is Map ? redirect.keys.toList() : 'none'}, '
      'paymentMethod=${selectedPaymentMethod.value?.methodType ?? 'unknown'}',
    );
  }

  Future<void> _finishBookedPayment() async {
    await assetController?.refreshAsset();
    if (Get.isRegistered<NowController>()) {
      await NowController.instance.getNowBookings();
    }

    final instructions = asset.ownerInstructions?.trim();
    if (instructions?.isNotEmpty == true) {
      await LNDNavigate.offBookingInstructionsPage(
        args: BookingInstructionsPageArgs(
          instructions: instructions!,
          ownerPhotoUrl: asset.owner?.photoUrl,
        ),
      );
      return;
    }

    if (Get.isRegistered<NavigationController>()) {
      NavigationController.instance.changeTab(LNDBottomNavPage.messages.indexx);
    }
    Get.until((page) => page.isFirst);
  }

  Map<String, dynamic> _paymentBillingDetails() {
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

  String _paymentErrorText(Object error) {
    final rawText = error.toString();
    final text = rawText.toLowerCase();
    if (text.contains('owner has not set a payout destination')) {
      return 'The owner needs to add a payout destination before this item can be booked.';
    }
    if (_isTemporaryReservationError(error)) {
      return 'Those dates are temporarily reserved. Please choose dates again.';
    }
    if (text.contains('paymongo test cards require test api keys')) {
      return 'PayMongo test cards require test API keys.';
    }
    if (text.contains('paymongo did not return a 3ds authentication url')) {
      return LNDPaymentService.missingNextActionUrlMessage();
    }
    if (text.contains('unable to create paymongo payment method:')) {
      return rawText
          .replaceFirst('Exception: ', '')
          .replaceFirst('LNDPaymentServiceException: ', '');
    }
    if (text.contains('card details are incomplete')) {
      return 'Card details are incomplete.';
    }
    if (text.contains('expired')) {
      return 'Card is expired. Please use another card.';
    }
    if (text.contains('unavailable')) {
      return 'Those dates are no longer available.';
    }
    if (text.contains('cvc')) {
      return 'Invalid CVC number.';
    }
    if (text.contains('insufficient')) {
      return 'Card has insufficient funds.';
    }
    if (text.contains('selected payment method')) {
      return 'Payment method unavailable.';
    }
    return 'Payment failed. Please try again.';
  }

  bool _isTemporaryReservationError(Object error) {
    return error.toString().toLowerCase().contains('temporarily reserved');
  }

  bool _usesRecurringRateChunk(DateTime start, DateTime end) {
    final rates = asset.rates;
    if (rates == null) return false;
    var cursor = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    while (cursor.isBefore(endDay)) {
      final nextYear = DateTime(cursor.year + 1, cursor.month, cursor.day);
      if (rates.annually != null && !nextYear.isAfter(endDay)) {
        return true;
      }

      final nextMonth = DateTime(cursor.year, cursor.month + 1, cursor.day);
      if (rates.monthly != null && !nextMonth.isAfter(endDay)) {
        return true;
      }

      final nextWeek = DateTime(cursor.year, cursor.month, cursor.day + 7);
      if (rates.weekly != null && !nextWeek.isAfter(endDay)) {
        return true;
      }

      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    return false;
  }

  Future<void> _returnToCalendarAndRefreshAvailability() async {
    final assetController = this.assetController;
    await assetController?.getBookings();

    if (Get.isRegistered<CalendarPickerController>() &&
        assetController != null) {
      final blockedDates = <DateTime>{};
      for (final booking in assetController.confirmedBookingDates) {
        final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
        final endDate = LNDUtils.bookingDateFromTimestamp(booking.endDate);
        if (startDate != null && endDate != null) {
          blockedDates.addAll(
            LNDUtils.daysInExclusiveEndRange(startDate, endDate),
          );
          if (assetController.asset?.blocksEndDate == true) {
            blockedDates.add(LNDUtils.normalizeToDay(endDate));
          }
        }
      }
      CalendarPickerController.instance.setBlockedDates(blockedDates.toList());
    }

    if (Get.isOverlaysOpen) {
      Get.back(closeOverlays: true);
    }
    if (Get.currentRoute == '/booking-payment') {
      Get.back();
    }
  }
}

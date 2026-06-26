import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/pages/payment_holding/widgets/payment_holding_cancel_sheet.widget.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentHoldingSuccessMode { booking, damageBalance }

enum PaymentHoldingResultStatus { success, failed, cancelled }

class PaymentHoldingPageArgs {
  final String checkoutId;
  final String methodType;
  final String methodLabel;
  final Map<String, dynamic> methodDetails;
  final Map<String, dynamic>? nextAction;
  final PaymentHoldingSuccessMode successMode;
  final bool clearPendingMarkerOnTerminal;
  final String cancelReason;
  final Future<void> Function(PaymentHoldingResult result)? onSuccess;

  const PaymentHoldingPageArgs({
    required this.checkoutId,
    required this.methodType,
    required this.methodLabel,
    this.methodDetails = const {},
    this.nextAction,
    required this.successMode,
    this.clearPendingMarkerOnTerminal = false,
    required this.cancelReason,
    this.onSuccess,
  });
}

class PaymentHoldingResult {
  final PaymentHoldingResultStatus status;
  final String? message;
  final LNDPaymentSyncResult? syncResult;
  final LNDPaymentCheckoutStatus? checkoutStatus;

  const PaymentHoldingResult._({
    required this.status,
    this.message,
    this.syncResult,
    this.checkoutStatus,
  });

  factory PaymentHoldingResult.success({
    LNDPaymentSyncResult? syncResult,
    LNDPaymentCheckoutStatus? checkoutStatus,
  }) {
    return PaymentHoldingResult._(
      status: PaymentHoldingResultStatus.success,
      syncResult: syncResult,
      checkoutStatus: checkoutStatus,
    );
  }

  factory PaymentHoldingResult.failed(String message) {
    return PaymentHoldingResult._(
      status: PaymentHoldingResultStatus.failed,
      message: message,
    );
  }

  factory PaymentHoldingResult.cancelled() {
    return const PaymentHoldingResult._(
      status: PaymentHoldingResultStatus.cancelled,
    );
  }
}

class PaymentHoldingController extends GetxController
    with WidgetsBindingObserver {
  final PaymentHoldingPageArgs args = Get.arguments as PaymentHoldingPageArgs;

  final RxBool isSuccess = false.obs;
  final RxBool isCancelling = false.obs;
  final RxBool isLaunchingExternalPayment = false.obs;

  StreamSubscription<LNDPaymentCheckoutStatus>? _checkoutSubscription;
  bool _isControllerClosed = false;
  bool _terminalPaymentHandled = false;
  bool _isSyncingOnResume = false;
  bool _hasOpenedExternalPayment = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  String? get qrImageUrl =>
      LNDPaymentService.nextActionQrImageUrl(args.nextAction);

  String? get externalPaymentUrl {
    final testUrl = LNDPaymentService.nextActionTestUrl(args.nextAction);
    if (testUrl != null && testUrl.isNotEmpty) return testUrl;
    return LNDPaymentService.nextActionRedirectUrl(args.nextAction);
  }

  bool get isQrPayment => qrImageUrl?.isNotEmpty == true;
  bool get hasExternalPayment {
    final url = externalPaymentUrl;
    if (url == null || url.isEmpty) return false;
    if (!isQrPayment) return true;

    final testUrl = LNDPaymentService.nextActionTestUrl(args.nextAction);
    return kDebugMode && testUrl != null && testUrl.isNotEmpty;
  }

  bool get shouldAutoOpenExternalPayment => hasExternalPayment && !isQrPayment;

  String get title {
    if (isQrPayment) return 'Scan to complete payment';
    if (_isCardMethod) return 'Complete bank verification';
    if (_isBankMethod) return 'Complete bank payment';
    if (_isWalletMethod) return 'Complete wallet payment';
    return 'Waiting for payment';
  }

  String get subtitle {
    if (isQrPayment) {
      return "Scan or save the QR code using your banking or wallet app. We'll update this screen once payment is confirmed.";
    }
    if (_isCardMethod) {
      return 'We opened a secure bank verification page. Complete the OTP or approval step, then return to Lend.';
    }
    if (_isWalletMethod || _isBankMethod) {
      return 'Complete the payment in your wallet or banking app. Keep this screen open while we verify your payment.';
    }
    return 'Keep this screen open while we verify your payment with PayMongo.';
  }

  bool get _isCardMethod => args.methodType == 'card';
  bool get _isWalletMethod =>
      args.methodType == 'gcash' ||
      args.methodType == 'paymaya' ||
      args.methodType == 'grab_pay' ||
      args.methodType == 'shopeepay';
  bool get _isBankMethod =>
      args.methodType == 'dob' || args.methodType == 'brankas';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _watchCheckout();
    unawaited(_syncCheckout());
    if (shouldAutoOpenExternalPayment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(openExternalPayment());
      });
    }
  }

  @override
  void onClose() {
    _isControllerClosed = true;
    WidgetsBinding.instance.removeObserver(this);
    _checkoutSubscription?.cancel();
    isSuccess.close();
    isCancelling.close();
    isLaunchingExternalPayment.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncCheckout());
    }
  }

  Future<void> openExternalPayment() async {
    final url = externalPaymentUrl;
    if (url == null || url.isEmpty || isLaunchingExternalPayment.value) return;

    try {
      isLaunchingExternalPayment.value = true;
      _hasOpenedExternalPayment = true;
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        LNDSnackbar.showError('Unable to open payment page.');
      }
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to open payment page.');
    } finally {
      isLaunchingExternalPayment.value = false;
    }
  }

  Future<void> requestClose() async {
    if (_terminalPaymentHandled || isCancelling.value) return;

    final sheetConfirmed = await LNDShow.bottomSheet<bool>(
      const PaymentHoldingCancelSheet(),
      enableDrag: false,
      isDismissible: false,
    );
    if (sheetConfirmed != true) return;

    final confirmed = await LNDShow.alertDialog<bool?>(
      title: 'Cancel pending payment?',
      content:
          'This will cancel your pending checkout. If you’ve already completed the payment, please wait for confirmation instead.',
      cancelText: 'Keep waiting',
      confirmText: 'Cancel payment',
      confirmColor: Get.theme.colorScheme.error,
    );
    if (confirmed != true) return;

    await _cancelCheckout();
  }

  Future<void> _cancelCheckout() async {
    try {
      isCancelling.value = true;
      await LNDPaymentService.cancelPaymentCheckout(
        checkoutId: args.checkoutId,
        reason: args.cancelReason,
      );
      await _clearPendingMarkerIfNeeded();
      _terminalPaymentHandled = true;
      await _checkoutSubscription?.cancel();
      if (!_isControllerClosed) {
        Get.back(result: PaymentHoldingResult.cancelled());
      }
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to cancel pending payment.');
    } finally {
      isCancelling.value = false;
    }
  }

  void _watchCheckout() {
    _checkoutSubscription?.cancel();
    _checkoutSubscription = LNDPaymentService.watchPaymentCheckout(
      args.checkoutId,
    ).listen(
      (checkout) {
        unawaited(_handleCheckoutUpdate(checkout));
      },
      onError: (Object error, StackTrace st) {
        LNDLogger.e(error.toString(), error: error, stackTrace: st);
      },
    );
  }

  Future<void> _syncCheckout() async {
    if (_isControllerClosed ||
        _terminalPaymentHandled ||
        _isSyncingOnResume ||
        (_lifecycleState != AppLifecycleState.resumed &&
            _hasOpenedExternalPayment)) {
      return;
    }

    _isSyncingOnResume = true;
    try {
      final result = await LNDPaymentService.syncPaymentCheckout(
        args.checkoutId,
      );
      await _handleSyncResult(result);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      _isSyncingOnResume = false;
    }
  }

  Future<void> _handleSyncResult(LNDPaymentSyncResult result) async {
    if (_terminalPaymentHandled || _isControllerClosed) return;

    if (_isSuccessfulSync(result)) {
      await _completeSuccessfully(syncResult: result);
      return;
    }

    if (_isTerminalFailure(result.status)) {
      await _completeWithFailure(_syncFailureText(result));
    }
  }

  Future<void> _handleCheckoutUpdate(LNDPaymentCheckoutStatus checkout) async {
    if (_terminalPaymentHandled || _isControllerClosed) return;
    if (_lifecycleState != AppLifecycleState.resumed) return;

    if (_isSuccessfulCheckout(checkout)) {
      await _completeSuccessfully(checkoutStatus: checkout);
      return;
    }

    if (checkout.isTerminalFailure) {
      await _completeWithFailure(_checkoutFailureText(checkout));
    }
  }

  Future<void> _completeSuccessfully({
    LNDPaymentSyncResult? syncResult,
    LNDPaymentCheckoutStatus? checkoutStatus,
  }) async {
    if (_terminalPaymentHandled || _isControllerClosed) return;
    _terminalPaymentHandled = true;
    isSuccess.value = true;
    await _clearPendingMarkerIfNeeded();
    await _checkoutSubscription?.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!_isControllerClosed) {
      final result = PaymentHoldingResult.success(
        syncResult: syncResult,
        checkoutStatus: checkoutStatus,
      );
      final onSuccess = args.onSuccess;
      if (onSuccess != null) {
        await onSuccess(result);
        return;
      }

      Get.back(result: result);
    }
  }

  Future<void> _completeWithFailure(String message) async {
    if (_terminalPaymentHandled || _isControllerClosed) return;
    _terminalPaymentHandled = true;
    await _clearPendingMarkerIfNeeded();
    await _checkoutSubscription?.cancel();
    if (!_isControllerClosed) {
      Get.back(result: PaymentHoldingResult.failed(message));
    }
  }

  bool _isSuccessfulSync(LNDPaymentSyncResult result) {
    return switch (args.successMode) {
      PaymentHoldingSuccessMode.booking => result.isBooked,
      PaymentHoldingSuccessMode.damageBalance => result.isPaid,
    };
  }

  bool _isSuccessfulCheckout(LNDPaymentCheckoutStatus checkout) {
    return switch (args.successMode) {
      PaymentHoldingSuccessMode.booking => checkout.isBooked,
      PaymentHoldingSuccessMode.damageBalance => checkout.isPaid,
    };
  }

  bool _isTerminalFailure(String status) {
    return status == 'failed' || status == 'expired' || status == 'cancelled';
  }

  Future<void> _clearPendingMarkerIfNeeded() async {
    if (!args.clearPendingMarkerOnTerminal) return;
    await LNDPaymentService.clearPendingPaymentMarker(
      checkoutId: args.checkoutId,
    );
  }

  String _checkoutFailureText(LNDPaymentCheckoutStatus checkout) {
    if (checkout.status == 'expired') {
      return 'Payment expired. Please try again.';
    }
    return checkout.lastPaymentError?['failed_message'] as String? ??
        checkout.lastPaymentError?['message'] as String? ??
        'Payment failed. Please try another method.';
  }

  String _syncFailureText(LNDPaymentSyncResult result) {
    if (result.status == 'expired') {
      return 'Payment expired. Please try again.';
    }
    return result.lastPaymentError?['failed_message'] as String? ??
        result.lastPaymentError?['message'] as String? ??
        'Payment failed. Please try another method.';
  }
}

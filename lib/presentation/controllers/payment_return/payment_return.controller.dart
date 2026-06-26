import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/core/services/booking_deep_link.service.dart';
import 'package:lend/core/services/listing_share.service.dart';
import 'package:lend/core/services/owner_invite.service.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/booking_instructions/booking_instructions.controller.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/controllers/navigation/navigation.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/controllers/booking_payment/booking_payment.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/verification_rejection/verification_rejection.controller.dart';
import 'package:lend/presentation/pages/eligibility/eligibility.page.dart';
import 'package:lend/presentation/pages/splash/splash.page.dart';
import 'package:lend/utilities/enums/bottom_nav_page.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class PaymentReturnController extends GetxController
    with WidgetsBindingObserver {
  static PaymentReturnController get instance =>
      Get.find<PaymentReturnController>();

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  final Map<String, StreamSubscription<LNDPaymentCheckoutStatus>>
  _checkoutSubscriptions =
      <String, StreamSubscription<LNDPaymentCheckoutStatus>>{};
  Worker? _authWorker;
  String? _pendingCheckoutId;
  String? _pendingBookingId;
  String? _pendingListingShareCode;
  Uri? _pendingVerificationUri;
  final Set<String> _processingCheckoutIds = <String>{};
  final Set<String> _processingBookingIds = <String>{};
  final Set<String> _processingListingShareCodes = <String>{};
  bool _canRunStartupRecovery = false;
  bool _isRecoveringPendingPayment = false;
  bool _isSilentlyRecoveringPendingPayment = false;
  bool _hasOpenedRecoveredPayment = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _listenForAuth();
    unawaited(_listenForLinks());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    for (final subscription in _checkoutSubscriptions.values) {
      subscription.cancel();
    }
    _checkoutSubscriptions.clear();
    _authWorker?.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(startSilentPendingPaymentRecovery());
    }
  }

  Future<void> _listenForLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleLink,
      onError: (Object error, StackTrace st) {
        LNDLogger.e(error.toString(), error: error, stackTrace: st);
      },
    );
  }

  void _listenForAuth() {
    _authWorker = ever<User?>(AuthController.instance.firebaseUser, (_) {
      if (!AuthController.instance.isAuthenticated) return;

      final bookingId = _pendingBookingId;
      if (bookingId != null) {
        _pendingBookingId = null;
        unawaited(_openBookingLink(bookingId));
      }

      final verificationUri = _pendingVerificationUri;
      if (verificationUri != null) {
        _pendingVerificationUri = null;
        unawaited(_openVerificationLink(verificationUri));
      }

      final listingShareCode = _pendingListingShareCode;
      if (listingShareCode != null) {
        _pendingListingShareCode = null;
        unawaited(_openListingShareLink(listingShareCode));
      }

      unawaited(_claimPendingOwnerInviteCode());

      final checkoutId = _pendingCheckoutId;
      if (checkoutId != null) {
        _pendingCheckoutId = null;
        unawaited(syncCheckout(checkoutId));
      }
    });
  }

  Future<void> startPendingPaymentRecovery() async {
    _canRunStartupRecovery = true;
    await _recoverPendingPaymentIfNeeded();
  }

  Future<void> startSilentPendingPaymentRecovery() async {
    if (_isSilentlyRecoveringPendingPayment ||
        !AuthController.instance.isAuthenticated) {
      return;
    }

    final marker = LNDPaymentService.readPendingPaymentMarker();
    final recoveryUid = AuthController.instance.uid;
    if (marker == null || recoveryUid == null) return;

    _isSilentlyRecoveringPendingPayment = true;
    try {
      final recovery = await LNDPaymentService.recoverPendingPaymentCheckout(
        checkoutId: marker.checkoutId,
        assetId: marker.assetId,
      );

      if (!AuthController.instance.isAuthenticated ||
          AuthController.instance.uid != recoveryUid) {
        return;
      }

      if (recovery.isBooked ||
          !recovery.hasPendingCheckout ||
          recovery.isTerminal) {
        await LNDPaymentService.clearPendingPaymentMarker(
          checkoutId: marker.checkoutId,
        );
      }
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      _isSilentlyRecoveringPendingPayment = false;
    }
  }

  void _handleLink(Uri uri) {
    if (_isEmailVerificationReturnUri(uri)) {
      unawaited(_handleEmailVerificationReturn(uri));
      return;
    }

    if (_isVerificationUri(uri)) {
      if (!AuthController.instance.isAuthenticated) {
        _pendingVerificationUri = uri;
        return;
      }
      unawaited(_openVerificationLink(uri));
      return;
    }

    final bookingId = _bookingIdFromUri(uri);
    if (bookingId != null) {
      if (!AuthController.instance.isAuthenticated) {
        _pendingBookingId = bookingId;
        return;
      }
      unawaited(_openBookingLink(bookingId));
      return;
    }

    final listingShareCode = _listingShareCodeFromUri(uri);
    if (listingShareCode != null) {
      unawaited(_openListingShareLink(listingShareCode));
      return;
    }

    if (!_isPaymentReturnUri(uri)) return;

    final checkoutId = uri.queryParameters['checkoutId'];
    if (checkoutId == null || checkoutId.isEmpty) {
      return;
    }

    if (!AuthController.instance.isAuthenticated) {
      _pendingCheckoutId = checkoutId;
      return;
    }

    unawaited(syncCheckout(checkoutId));
  }

  bool _isPaymentReturnUri(Uri uri) {
    if (uri.scheme == 'https' &&
        uri.host == 'getlend.dev' &&
        uri.path == '/payment/return') {
      return true;
    }

    return uri.scheme == 'lend' &&
        uri.host == 'payment' &&
        uri.path == '/return';
  }

  bool _isEmailVerificationReturnUri(Uri uri) {
    return uri.scheme == 'lend' &&
        uri.host == 'email' &&
        uri.path == '/verified';
  }

  bool _isVerificationUri(Uri uri) {
    return uri.scheme == 'lend' && uri.host == 'verification';
  }

  Future<void> _openVerificationLink(Uri uri) async {
    if (!AuthController.instance.isAuthenticated) return;
    final isRejection =
        uri.pathSegments.length == 1 && uri.pathSegments.first == 'rejection';
    final submissionId = uri.queryParameters['submissionId'];
    if (isRejection && submissionId != null && submissionId.isNotEmpty) {
      await LNDNavigate.toVerificationRejectionPage(
        args: VerificationRejectionPageArgs(submissionId: submissionId),
      );
      return;
    }
    Get.toNamed(EligibilityPage.routeName);
  }

  String? _bookingIdFromUri(Uri uri) {
    return bookingIdFromDeepLink(uri);
  }

  Future<void> _openBookingLink(String bookingId) async {
    if (_processingBookingIds.contains(bookingId)) return;
    final userId = AuthController.instance.uid;
    if (userId == null || userId.isEmpty) {
      _pendingBookingId = bookingId;
      return;
    }

    _processingBookingIds.add(bookingId);
    try {
      await _waitForSplashToFinish();
      final booking = await LNDBookingDeepLinkService.loadParticipantBooking(
        bookingId: bookingId,
        userId: userId,
      );
      await LNDNavigate.toBookingDetailsPage(
        args: BookingDetailsPageArgs(booking: booking),
      );
    } on BookingDeepLinkException catch (e) {
      LNDSnackbar.showWarning(e.message);
    } catch (e, st) {
      LNDLogger.e('Error opening booking link', error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to open this booking.');
    } finally {
      _processingBookingIds.remove(bookingId);
    }
  }

  Future<void> _handleEmailVerificationReturn(Uri uri) async {
    if (uri.queryParameters['status'] != 'success') return;

    try {
      await AuthController.instance.firebaseAuth.currentUser?.reload();
      if (Get.isRegistered<ProfileController>()) {
        await ProfileController.instance.syncEmailVerification();
      }
      LNDSnackbar.showSuccess('Email verified.');
    } catch (e, st) {
      LNDLogger.e(
        'Error handling email verification return',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showInfo('Please refresh Lend to update your verification.');
    }
  }

  String? _listingShareCodeFromUri(Uri uri) {
    final segments = uri.pathSegments;

    if ((uri.scheme == 'https') &&
        uri.host == 'getlend.dev' &&
        segments.length == 2 &&
        segments.first == 'l') {
      final code = segments.last.trim();
      return code.isEmpty ? null : code;
    }

    if (uri.scheme == 'lend' && uri.host == 'listing' && segments.length == 1) {
      final code = segments.first.trim();
      return code.isEmpty ? null : code;
    }

    return null;
  }

  Future<void> _claimPendingOwnerInviteCode() async {
    try {
      final result = await LNDOwnerInviteService.claimPendingInviteCode();
      if (result?.claimed == true && result?.alreadyClaimed != true) {
        LNDSnackbar.showSuccess('Founding Owner invite applied.');
      }
    } catch (_) {
      LNDSnackbar.showWarning('Unable to apply your Founding Owner invite.');
    }
  }

  Future<void> _openListingShareLink(String code) async {
    if (_processingListingShareCodes.contains(code)) return;

    _processingListingShareCodes.add(code);
    try {
      await _waitForSplashToFinish();
      final result = await LNDListingShareService.resolveListingShareLink(
        code: code,
        context: ListingShareResolveContext.appOpen,
      );

      if (result.assetId.isEmpty) {
        LNDSnackbar.showError('Listing unavailable.');
        return;
      }

      await LNDNavigate.toAssetPage(args: Asset(id: result.assetId));
    } catch (e, st) {
      LNDLogger.e('Error opening listing share link', error: e, stackTrace: st);
      if (!AuthController.instance.isAuthenticated) {
        _pendingListingShareCode = code;
        return;
      }
      final message =
          LNDListingShareService.isUnavailableError(e)
              ? 'Listing unavailable.'
              : 'Unable to open this listing.';
      LNDSnackbar.showError(message);
    } finally {
      _processingListingShareCodes.remove(code);
    }
  }

  Future<void> _waitForSplashToFinish() async {
    for (var i = 0; i < 20; i += 1) {
      if (Get.currentRoute != SplashPage.routeName) return;
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> syncCheckout(String checkoutId) async {
    if (_processingCheckoutIds.contains(checkoutId)) return;

    _processingCheckoutIds.add(checkoutId);
    final marker = LNDPaymentService.readPendingPaymentMarker();
    try {
      final result = await LNDPaymentService.syncPaymentCheckout(checkoutId);
      await _handleResult(checkoutId, result, assetId: marker?.assetId);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to confirm payment yet.');
    } finally {
      _processingCheckoutIds.remove(checkoutId);
    }
  }

  Future<void> _recoverPendingPaymentIfNeeded() async {
    if (!_canRunStartupRecovery ||
        _isRecoveringPendingPayment ||
        _hasOpenedRecoveredPayment ||
        !AuthController.instance.isAuthenticated) {
      return;
    }

    final marker = LNDPaymentService.readPendingPaymentMarker();
    if (marker == null) return;

    _isRecoveringPendingPayment = true;
    try {
      final recovery = await LNDPaymentService.recoverPendingPaymentCheckout(
        checkoutId: marker.checkoutId,
        assetId: marker.assetId,
      );

      if (recovery.isBooked) {
        final ownerInstructionDetails =
            _ownerInstructionDetailsFromAssetMap(recovery.asset) ??
            await _loadOwnerInstructionDetails(marker.assetId);
        await LNDPaymentService.clearPendingPaymentMarker(
          checkoutId: marker.checkoutId,
        );
        await _finishBookedPayment(
          marker.checkoutId,
          ownerInstructions: ownerInstructionDetails?.instructions,
          ownerPhotoUrl: ownerInstructionDetails?.ownerPhotoUrl,
        );
        return;
      }

      if (!recovery.hasPendingCheckout ||
          recovery.checkout == null ||
          recovery.asset == null ||
          recovery.isTerminal) {
        await LNDPaymentService.clearPendingPaymentMarker(
          checkoutId: marker.checkoutId,
        );
        return;
      }

      _hasOpenedRecoveredPayment = true;
      final checkout = recovery.checkout!;
      await LNDNavigate.toBookingPaymentPage(
        args: BookingPaymentPageArgs(
          asset: Asset.fromMap(recovery.asset!),
          selectedDates: [
            LNDUtils.bookingDateFromMillisecondsSinceEpoch(
              (checkout['startDateMs'] as num).toInt(),
            ),
            LNDUtils.bookingDateFromMillisecondsSinceEpoch(
              (checkout['endDateMs'] as num).toInt(),
            ),
          ],
          totalPrice: (checkout['totalPrice'] as num).toInt(),
          isRecoveredCheckout: true,
          checkoutId: checkout['checkoutId'] as String?,
          paymentStatus: checkout['paymentStatus'] as String?,
          nextAction: recovery.nextAction,
          checkoutLockExpiresAtMs:
              (checkout['checkoutLockExpiresAtMs'] as num?)?.toInt(),
        ),
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      _isRecoveringPendingPayment = false;
    }
  }

  Future<void> _handleResult(
    String checkoutId,
    LNDPaymentSyncResult result, {
    String? assetId,
  }) async {
    if (result.isBooked) {
      final ownerInstructionDetails = await _loadOwnerInstructionDetails(
        assetId,
      );
      await _finishBookedPayment(
        checkoutId,
        ownerInstructions: ownerInstructionDetails?.instructions,
        ownerPhotoUrl: ownerInstructionDetails?.ownerPhotoUrl,
      );
      return;
    }

    if (result.paymentStatus == 'processing') {
      LNDSnackbar.showInfo('Payment is still being confirmed.');
      _watchCheckout(checkoutId);
      return;
    }

    LNDSnackbar.showError('Payment was not completed.');
  }

  void _watchCheckout(String checkoutId) {
    if (_checkoutSubscriptions.containsKey(checkoutId)) return;

    _checkoutSubscriptions[checkoutId] = LNDPaymentService.watchPaymentCheckout(
      checkoutId,
    ).listen(
      (checkout) {
        unawaited(_handleCheckoutUpdate(checkout));
      },
      onError: (Object error, StackTrace st) {
        LNDLogger.e(error.toString(), error: error, stackTrace: st);
        _cancelCheckoutWatch(checkoutId);
      },
    );
  }

  Future<void> _handleCheckoutUpdate(LNDPaymentCheckoutStatus checkout) async {
    if (checkout.isBooked) {
      final marker = LNDPaymentService.readPendingPaymentMarker();
      final ownerInstructionDetails = await _loadOwnerInstructionDetails(
        marker?.assetId,
      );
      await _finishBookedPayment(
        checkout.id,
        ownerInstructions: ownerInstructionDetails?.instructions,
        ownerPhotoUrl: ownerInstructionDetails?.ownerPhotoUrl,
      );
      return;
    }

    if (checkout.isTerminalFailure ||
        checkout.paymentStatus == 'awaiting_payment_method') {
      await _cancelCheckoutWatch(checkout.id);
      LNDSnackbar.showError('Payment was not completed.');
    }
  }

  Future<void> _finishBookedPayment(
    String checkoutId, {
    String? ownerInstructions,
    String? ownerPhotoUrl,
  }) async {
    await _cancelCheckoutWatch(checkoutId);
    await LNDPaymentService.clearPendingPaymentMarker(checkoutId: checkoutId);
    if (Get.isRegistered<NowController>()) {
      await NowController.instance.getNowBookings();
    }

    final instructions = ownerInstructions?.trim();
    if (instructions?.isNotEmpty == true) {
      await LNDNavigate.toBookingInstructionsPage(
        args: BookingInstructionsPageArgs(
          instructions: instructions!,
          ownerPhotoUrl: ownerPhotoUrl,
        ),
      );
      return;
    }

    if (Get.isRegistered<NavigationController>()) {
      NavigationController.instance.changeTab(LNDBottomNavPage.messages.indexx);
    }
    Get.until((page) => page.isFirst);
  }

  _OwnerInstructionDetails? _ownerInstructionDetailsFromAssetMap(
    Map<String, dynamic>? asset,
  ) {
    final instructions = asset?['ownerInstructions'] as String?;
    final trimmed = instructions?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final owner = asset?['owner'];
    final ownerPhotoUrl = owner is Map ? owner['photoUrl'] as String? : null;
    return _OwnerInstructionDetails(
      instructions: trimmed,
      ownerPhotoUrl: ownerPhotoUrl,
    );
  }

  Future<_OwnerInstructionDetails?> _loadOwnerInstructionDetails(
    String? assetId,
  ) async {
    if (assetId == null || assetId.isEmpty) return null;
    final asset = await LNDAssetService.getAssetById(assetId);
    final instructions = asset?.ownerInstructions?.trim();
    if (instructions == null || instructions.isEmpty) return null;
    return _OwnerInstructionDetails(
      instructions: instructions,
      ownerPhotoUrl: asset?.owner?.photoUrl,
    );
  }

  Future<void> _cancelCheckoutWatch(String checkoutId) async {
    final subscription = _checkoutSubscriptions.remove(checkoutId);
    await subscription?.cancel();
  }
}

class _OwnerInstructionDetails {
  final String instructions;
  final String? ownerPhotoUrl;

  const _OwnerInstructionDetails({
    required this.instructions,
    this.ownerPhotoUrl,
  });
}

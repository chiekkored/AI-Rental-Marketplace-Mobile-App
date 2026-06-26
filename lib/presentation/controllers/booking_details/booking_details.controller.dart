import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/presentation/common/cancel_booking_sheet.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/controllers/booking_document_pdf/booking_document_pdf.controller.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class BookingDetailsPageArgs {
  const BookingDetailsPageArgs({required this.booking, this.role});

  final Booking booking;
  final NowBookingRole? role;
}

class BookingDetailsController extends GetxController {
  final BookingDetailsPageArgs args = Get.arguments as BookingDetailsPageArgs;
  late final LatLng? _mapCenter = _buildMapCenter();

  Booking get booking => args.booking;
  NowBookingRole? get role => args.role;

  bool get isOwner => booking.asset?.owner?.uid == AuthController.instance.uid;

  String? get roleLabel {
    final role = this.role;
    if (role == null) return null;
    return role == NowBookingRole.owner ? 'Your Unit' : 'To Rent';
  }

  SimpleUserModel? get counterparty {
    if (isOwner) return booking.renter;
    return booking.asset?.owner;
  }

  String get counterpartyName => LNDUtils.formatSimpleUserName(counterparty);

  bool get shouldObscureCounterpartyName => LNDUtils.canShowName(
    counterparty?.uid,
    booking.asset?.owner?.uid,
    booking,
  );

  String get displayCounterpartyName =>
      shouldObscureCounterpartyName
          ? counterpartyName.toObscure()
          : counterpartyName;

  String get locationText => LNDUtils.getLocationText(
    location: booking.asset?.location,
    showFullAddress: canViewActiveOwnerInfo,
  );

  LatLng? get assetLatLng {
    final lat = booking.asset?.location?.lat;
    final lng = booking.asset?.location?.lng;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  LatLng? get mapCenter => _mapCenter;

  CameraPosition get cameraPosition =>
      CameraPosition(target: mapCenter ?? const LatLng(0.0, 0.0), zoom: 13);

  bool get shouldShowExactMapLocation => booking.isCompleted;

  bool get canShowListing => booking.asset?.id.isNotEmpty == true;

  bool get canOpenChat => booking.chatId?.isNotEmpty == true;

  bool get canStartHandover => booking.canStartHandover;

  bool get canStartReturn => booking.canStartReturn;

  bool get canRequestBookingCancellation =>
      booking.canRequestCancellationBy(AuthController.instance.uid);

  bool get canViewReceipt =>
      !isOwner &&
      booking.paymentFlow?.status == 'paid' &&
      (booking.paymentFlow?.amount ?? 0) > 0;

  bool get canViewEarnings =>
      isOwner &&
      booking.status == BookingStatus.completed &&
      (booking.payoutFlow != null || booking.settlement != null);

  bool get canViewConfirmedOwnerInfo => booking.canViewConfirmedOwnerInfo;

  bool get canViewActiveOwnerInfo => booking.canViewActiveOwnerInfo;

  void showListing() {
    final asset = booking.asset;
    if (asset == null || asset.id.isEmpty) {
      LNDSnackbar.showError('Unable to open this listing.');
      return;
    }

    LNDNavigate.toAssetPage(args: asset, source: AssetPageSource.booking);
  }

  void viewReceipt() {
    final bookingId = booking.id;
    if (bookingId == null || bookingId.isEmpty || !canViewReceipt) return;

    LNDNavigate.toBookingDocumentPdfPage(
      args: BookingDocumentPdfPageArgs(
        bookingId: bookingId,
        documentType: LNDBookingDocumentType.receipt,
        title: 'Receipt',
      ),
    );
  }

  void viewEarnings() {
    final bookingId = booking.id;
    if (bookingId == null || bookingId.isEmpty || !canViewEarnings) return;

    LNDNavigate.toBookingDocumentPdfPage(
      args: BookingDocumentPdfPageArgs(
        bookingId: bookingId,
        documentType: LNDBookingDocumentType.earnings,
        title: 'Earnings',
      ),
    );
  }

  Future<void> openChat() async {
    if (!canOpenChat) {
      LNDSnackbar.showError('Unable to open this booking chat.');
      return;
    }

    try {
      final chat = await MessagesController.instance.findFreshChatForBooking(
        booking,
      );
      if (chat == null) throw 'Cannot find chat for this booking';

      await LNDNavigate.toChatPage(chat: chat);
    } catch (e, st) {
      LNDLogger.e(
        'Unable to open booking details chat',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to open this booking chat.');
    }
  }

  void onTapHandedOver() {
    if (!canStartHandover) return;

    if (isOwner) {
      LNDNavigate.toQRViewPage(qrToken: booking.tokens?.handoverToken ?? '');
    } else {
      LNDNavigate.toScanQRPage();
    }
  }

  void onTapReturned() {
    if (!canStartReturn) return;

    if (isOwner) {
      LNDNavigate.toScanQRPage();
    } else {
      LNDNavigate.toQRViewPage(qrToken: booking.tokens?.returnToken ?? '');
    }
  }

  void requestBookingCancellation() async {
    if (!canRequestBookingCancellation) return;

    final selectedReason = await LNDShow.bottomSheet<String>(
      LNDCancelBookingSheet(booking: booking, isOwner: isOwner),
    );
    if (selectedReason == null || selectedReason.isEmpty) return;

    final assetId = booking.asset?.id;
    final bookingId = booking.id;
    if (assetId == null ||
        assetId.isEmpty ||
        bookingId == null ||
        bookingId.isEmpty) {
      LNDSnackbar.showError('Unable to request cancellation for this booking.');
      return;
    }

    try {
      LNDLoading.show();
      final result = await LNDBookingService.requestBookingCancellation(
        assetId: assetId,
        bookingId: bookingId,
        reason: selectedReason,
      );

      result.fold(ifLeft: (_) {}, ifRight: (error) => throw error);

      LNDLoading.hide();
      Get.back(result: true);
      LNDSnackbar.showSuccess(
        'Cancellation request submitted for admin review.',
      );
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(
        'Error requesting booking cancellation',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Failed to request cancellation.');
    }
  }

  LatLng? _buildMapCenter() {
    final latLng = assetLatLng;
    if (latLng == null) return null;
    if (shouldShowExactMapLocation) return latLng;
    return LNDUtils.getRandomLocationWithinRadius(latLng, 500.0);
  }
}

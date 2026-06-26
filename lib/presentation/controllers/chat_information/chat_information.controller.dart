import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/core/services/messaging.service.dart';
import 'package:lend/presentation/common/cancel_booking_sheet.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/report_sheet.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/chat/chat.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/presentation/pages/chat_information/widgets/block_user_sheet.widget.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class ChatInformationArgs {
  const ChatInformationArgs({required this.chat});

  final Chat chat;
}

class ChatInformationController extends GetxController with AuthMixin {
  final ChatInformationArgs args = Get.arguments as ChatInformationArgs;

  Chat get chat => args.chat;

  Booking? get booking => ChatController.instance.booking;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  SimpleUserModel? get participant => chat.participants?.firstWhereOrNull(
    (user) => user.uid != AuthController.instance.uid,
  );

  bool get isOwner => chat.asset?.owner?.uid == AuthController.instance.uid;

  bool get canViewConfirmedOwnerInfo =>
      booking?.canViewConfirmedOwnerInfo == true;

  bool get canViewActiveOwnerInfo => booking?.canViewActiveOwnerInfo == true;

  bool get bookingIsCompelete => booking?.isCompleted == true;

  bool get canStartHandover => booking?.canStartHandover == true;

  bool get canStartReturn => booking?.canStartReturn == true;

  bool get canRequestBookingCancellation =>
      booking?.canRequestCancellationBy(currentUid) == true;

  bool get hasBlockedParticipant =>
      Get.isRegistered<UserBlockController>() &&
      UserBlockController.instance.hasBlocked(participant?.uid);

  bool get canBlockParticipant =>
      participant?.uid != null &&
      participant?.uid != Chat.lendSupportUid &&
      !hasBlockedParticipant;

  bool get bookingRequiresCoordination {
    final booking = this.booking;
    if (booking == null) {
      return chat.bookingId?.isNotEmpty == true;
    }

    return booking.requiresBlockedPairCoordination;
  }

  final _mapController = Rxn<GoogleMapController>();
  GoogleMapController? get mapController => _mapController.value;

  final circles = <Circle>{}.obs;
  final markers = <Marker>{}.obs;

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 13,
  );

  @override
  void onClose() {
    _isLoading.close();
    super.onClose();
  }

  void onTapHandedOver() async {
    if (!canStartHandover) return;

    if (isOwner) {
      LNDNavigate.toQRViewPage(qrToken: booking?.tokens?.handoverToken ?? '');
    } else {
      await LNDNavigate.toScanQRPage();
    }
  }

  void onTapReturned() {
    if (!canStartReturn) return;

    if (isOwner) {
      LNDNavigate.toScanQRPage();
    } else {
      LNDNavigate.toQRViewPage(qrToken: booking?.tokens?.returnToken ?? '');
    }
  }

  void viewLiveListing() {
    final asset = chat.asset;
    if (asset == null || asset.id.isEmpty) {
      LNDSnackbar.showError('Unable to open this listing.');
      return;
    }

    LNDNavigate.toAssetPage(
      args: Asset.fromMap(asset.toMap()),
      source: AssetPageSource.booking,
    );
  }

  void viewBooking() {
    final booking = this.booking;
    if (booking == null) {
      LNDSnackbar.showError('Booking is still loading.');
      return;
    }

    LNDNavigate.toBookingDetailsPage(
      args: BookingDetailsPageArgs(booking: booking),
    );
  }

  Future<void> report() async {
    final reportedUserId = participant?.uid;
    if (reportedUserId == null ||
        reportedUserId.isEmpty ||
        currentUid == null) {
      LNDSnackbar.showError('Unable to report this user.');
      return;
    }

    final submission = await LNDShow.bottomSheet<LNDReportSubmission>(
      const LNDReportSheet(
        types: [
          LNDReportType.user,
          LNDReportType.listing,
          LNDReportType.message,
          LNDReportType.other,
        ],
        showArchiveAction: true,
        description:
            'Reports help Lend review safety and conduct concerns. Reporting does not block this user.',
      ),
    );
    if (submission == null) return;

    try {
      LNDLoading.show();
      final chatId = chat.chatId ?? chat.id;
      final shouldCancelBooking =
          submission.archiveRequested &&
          booking?.canRequestCancellationBy(currentUid) == true &&
          booking?.id != null &&
          booking?.asset?.id != null;

      await LNDMessagingService.reportContent(
        reporterId: currentUid!,
        reportedUserId: reportedUserId,
        reportType: submission.type.label,
        reason: submission.reason,
        details: submission.details,
        chatId: chatId,
        bookingId: booking?.id ?? chat.bookingId,
        assetId: booking?.asset?.id ?? chat.asset?.id,
        archiveRequested: submission.archiveRequested,
        bookingCancelRequested: shouldCancelBooking,
      );

      if (submission.archiveRequested) {
        if (shouldCancelBooking) {
          final result = await LNDBookingService.requestBookingCancellation(
            assetId: booking!.asset!.id,
            bookingId: booking!.id!,
            reason: submission.reason,
          );
          result.fold(ifLeft: (_) {}, ifRight: (error) => throw error);
        } else if (chatId != null && chatId.isNotEmpty) {
          await LNDMessagingService.archiveChatForUser(
            userId: currentUid!,
            chatId: chatId,
          );
        }
      }

      LNDLoading.hide();
      if (submission.archiveRequested) {
        Get.back(result: true);
      }
      LNDSnackbar.showSuccess('Report submitted.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error reporting', error: e, stackTrace: st);
      LNDSnackbar.showError('Failed to submit report.');
    }
  }

  Future<void> blockUser() async {
    final targetUserId = participant?.uid;
    if (targetUserId == null || targetUserId.isEmpty || !canBlockParticipant) {
      LNDSnackbar.showError('Unable to block this user.');
      return;
    }

    final action = await LNDShow.bottomSheet<BlockUserSheetAction>(
      BlockUserSheet(
        displayName: participant?.getName ?? '',
        bookingRequiresCoordination: () => bookingRequiresCoordination,
      ),
    );
    if (action == BlockUserSheetAction.report) {
      await report();
      return;
    }
    if (action != BlockUserSheetAction.block) return;

    final name = participant?.getName.trim();
    final confirmed = await LNDShow.alertDialog<bool>(
      title: 'Confirm block',
      content:
          bookingRequiresCoordination
              ? 'Block ${name?.isNotEmpty == true ? name : 'this user'}? Your current booking and chat will remain available until the booking is resolved.'
              : 'Block ${name?.isNotEmpty == true ? name : 'this user'}? This chat will be archived and you will not be able to contact each other.',
      confirmText: 'Block',
      confirmColor: Get.context?.lndTheme.danger,
    );
    if (confirmed != true) return;

    try {
      LNDLoading.show();
      await UserBlockController.instance.blockUser(targetUserId);
      LNDLoading.hide();
      Get.back(result: true);
      LNDSnackbar.showSuccess('User blocked.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error blocking user', error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to block this user.');
    }
  }

  void onMapCreated(GoogleMapController mapCtrl) {
    _mapController.value = mapCtrl;
    cameraPosition = CameraPosition(
      target: LatLng(
        chat.asset?.location?.latLng?.latitude ?? 0.0,
        chat.asset?.location?.latLng?.longitude ?? 0.0,
      ),
      zoom: 13,
    );
    if (booking?.canViewConfirmedOwnerInfo ?? false) {
      mapCtrl.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: cameraPosition.target,
        ),
      );
    } else {
      const radius = 500.0;
      final randomLocation = LNDUtils.getRandomLocationWithinRadius(
        cameraPosition.target,
        radius,
      );
      mapCtrl.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: randomLocation, zoom: 13),
        ),
      );
      final color =
          Get.context?.lndTheme.info ??
          Theme.of(Get.context!).colorScheme.secondary;
      circles.add(
        Circle(
          circleId: const CircleId('selected-location'),
          center: randomLocation,
          radius: radius,
          fillColor: color.withValues(alpha: 0.5),
          strokeColor: color,
          strokeWidth: 1,
        ),
      );
    }

    // _getAddressFromLatLng(cameraPosition.target);
  }

  void requestBookingCancellation() async {
    if (!canRequestBookingCancellation) return;

    final selectedReason = await LNDShow.bottomSheet<String>(
      LNDCancelBookingSheet(booking: booking, isOwner: isOwner),
    );
    if (selectedReason == null || selectedReason.isEmpty) return;

    final assetId = booking?.asset?.id;
    final bookingId = booking?.id;
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

  void deleteChat() async {
    final chatId = chat.chatId ?? chat.id;
    if (chatId == null || chatId.isEmpty || currentUid == null) {
      LNDSnackbar.showError('Unable to delete this chat.');
      return;
    }

    final confirmed = await LNDShow.alertDialog<bool?>(
      title: 'Delete chat?',
      content:
          'Are you sure you want to delete this chat? This only removes it from your inbox.',
      confirmText: 'Delete',
      confirmColor: Get.context?.theme.colorScheme.error,
    );
    if (confirmed != true) return;

    try {
      LNDLoading.show();
      await LNDMessagingService.deleteChatForUser(
        userId: currentUid!,
        chatId: chatId,
      );
      LNDLoading.hide();
      Get.back(result: true);
      LNDSnackbar.showSuccess('Chat deleted.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error deleting chat', error: e, stackTrace: st);
      LNDSnackbar.showError('Failed to delete chat.');
    }
  }
}

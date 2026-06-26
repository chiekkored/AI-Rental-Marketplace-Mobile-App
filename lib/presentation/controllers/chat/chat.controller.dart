import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/messaging.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/controllers/chat/chat_list.controller.dart';
import 'package:lend/presentation/controllers/chat_information/chat_information.controller.dart';
import 'package:lend/presentation/controllers/damage_fee_request/damage_fee_request.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/controllers/rental_history/rental_history.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/enums/chat_status.enum.dart';
import 'package:lend/utilities/enums/message_type.enum.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/firebase_storage.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class ChatController extends GetxController with AuthMixin {
  static ChatController get instance => Get.find<ChatController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<Chat> _chat = Rx<Chat>(Get.arguments as Chat);
  Chat get chat => _chat.value;

  final TextEditingController textController = TextEditingController();

  final Rx<Booking?> _booking = Rx<Booking?>(null);
  Booking? get booking => _booking.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  SimpleUserModel? get recepientUser => chat.participants?.firstWhereOrNull(
    (user) => user.uid != AuthController.instance.uid,
  );

  bool get isLendSupportChat => chat.isLendSupportChatFor(currentUid);

  bool get isOwner => booking?.asset?.owner?.uid == AuthController.instance.uid;

  bool get isCancellationUnderReview =>
      booking?.status == BookingStatus.cancellationRequested;

  bool get isChatReadOnly {
    if (chat.status == ChatStatus.deleted) return true;
    if (isLendSupportChat) {
      return chat.status == ChatStatus.archived;
    }

    final bookingStatus = booking?.status;
    if (bookingStatus == BookingStatus.cancellationRequested ||
        bookingStatus == BookingStatus.cancelled ||
        bookingStatus == BookingStatus.completed ||
        bookingStatus == BookingStatus.declined) {
      return true;
    }

    if (bookingStatus != null) return false;

    return chat.isReadOnly;
  }

  StreamSubscription? _bookingSubscription;
  StreamSubscription? _chatSubscription;
  bool _hasShownQrTransactionReminder = false;

  @override
  void onClose() {
    cancelSubscriptions();
    _chat.close();
    _booking.close();
    textController.dispose();
    _isLoading.close();

    super.onClose();
  }

  @override
  void onReady() {
    _subscribeChatMirror();
    _subscribeBooking();

    super.onReady();
  }

  void cancelSubscriptions() {
    LNDLogger.dNoStack('🔴 Booking Subscription Cancelled for ${booking?.id}');
    _bookingSubscription?.cancel();
    _chatSubscription?.cancel();
  }

  Future<void> _subscribeChatMirror() async {
    if (!isLendSupportChat) {
      return;
    }

    final userId = currentUid;
    final chatId = chat.chatId ?? chat.id;

    if (userId == null || userId.isEmpty || chatId == null || chatId.isEmpty) {
      return;
    }

    try {
      _chatSubscription?.cancel();

      LNDLogger.dNoStack('🟢 Chat Mirror Subscription Started');
      _chatSubscription = _firestore
          .collection(LNDCollections.userChats.name)
          .doc(userId)
          .collection(LNDCollections.chats.name)
          .doc(chatId)
          .snapshots()
          .listen(
            (snapshot) {
              final data = snapshot.data();
              if (data == null) return;

              _chat.value = Chat.fromMap(data);
            },
            onError: (e, st) {
              _chatSubscription?.cancel();
              LNDLogger.e(
                'Error listening to chat mirror',
                error: e,
                stackTrace: st,
              );
            },
          );
    } catch (e, st) {
      _chatSubscription?.cancel();
      LNDLogger.e('Error listening to chat mirror', error: e, stackTrace: st);
    }
  }

  Future<void> _subscribeBooking() async {
    final bookingId = chat.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;
      _bookingSubscription?.cancel();

      LNDLogger.dNoStack('🟢 Booking Subscription Started');
      _bookingSubscription = _firestore
          .collection(LNDCollections.bookings.name)
          .doc(bookingId)
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.exists) {
                final bookingData = snapshot.data();

                if (bookingData != null) {
                  final booking = Booking.fromMap(bookingData);
                  _booking.value = booking;
                  _maybeShowQrTransactionReminder(booking);
                }
              }
            },
            onError: (e, st) {
              cancelSubscriptions();
              LNDLogger.e(
                'Error listening to booking',
                error: e,
                stackTrace: st,
              );
              _isLoading.value = false;
            },
          );
    } catch (e, st) {
      cancelSubscriptions();
      LNDLogger.e('Error listening to booking', error: e, stackTrace: st);
    }
  }

  void _maybeShowQrTransactionReminder(Booking booking) {
    if (isLendSupportChat) return;
    if (_hasShownQrTransactionReminder) return;

    final isHidden =
        LNDStorageService.read<bool>(
          LNDStorageConstants.hideQrTransactionReminder,
        ) ??
        false;
    if (isHidden) return;

    final shouldShow =
        booking.lifecyclePhase == BookingLifecyclePhase.confirmed ||
        booking.lifecyclePhase == BookingLifecyclePhase.handedOver;
    if (!shouldShow) return;

    _hasShownQrTransactionReminder = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;
      LNDShow.bottomSheet(const _QrTransactionReminderSheet());
    });
  }

  void sendMessage() async {
    try {
      if (isChatReadOnly) {
        LNDSnackbar.showWarning('This chat is closed.');
        return;
      }

      if (textController.text.isNotEmpty) {
        final textMessage = textController.text.trim();
        textController.clear();

        if ((chat.chatId?.isEmpty ?? true) ||
            (currentUid?.isEmpty ?? true) ||
            (recepientUser?.uid?.isEmpty ?? true)) {
          throw 'Something went wrong';
        }

        if (isLendSupportChat) {
          await LNDMessagingService.sendSupportMessage(
            message: textMessage,
            type: MessageType.text,
            chatId: chat.chatId!,
            fromUid: currentUid!,
          );
        } else {
          await LNDMessagingService.sendMessage(
            message: textMessage,
            type: MessageType.text,
            chatId: chat.chatId!,
            toUid: recepientUser!.uid!,
            fromUid: currentUid!,
          );
        }
      }
    } catch (e, st) {
      LNDLogger.e(
        'Something wrong while sending a message',
        error: e,
        stackTrace: st,
      );
    }
  }

  void regenerateQr() async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.regenerateToken,
    );
    await callable.call({
      'userId': booking?.renter?.uid,
      'assetId': booking?.asset?.id,
      'bookingId': booking?.id,
    });
  }

  void onTapAccept() async {
    if (booking == null) return;

    final result = await LNDShow.alertDialog<bool?>(
      title: 'Accept this booking?',
      content:
          'Are you sure you want to accept this booking request? '
          'All other pending bookings for the same day will be declined.',
    );

    if (result == null || !result) return;

    try {
      LNDLoading.show();
      final isAvailable = await _isBookingStillAvailable(booking!);
      if (!isAvailable) {
        LNDLoading.hide();
        LNDSnackbar.showError(
          'This booking overlaps an active booking and can no longer be accepted.',
        );
        return;
      }

      final result = await LNDBookingService.confirmBookingViaFunction(
        bookingId: booking!.id!,
        assetId: booking!.asset?.id ?? '',
        renterId: booking!.renter?.uid ?? '',
      );

      result.fold(
        ifLeft: (response) async {
          await NowController.instance.refreshNow();
          LNDLoading.hide();
          await MessagesController.instance.openAcceptedBookingChat(booking!);
        },
        ifRight: (error) {
          throw error;
        },
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDLoading.hide();
      LNDSnackbar.showError('Something went wrong');
    }
  }

  Future<bool> _isBookingStillAvailable(Booking booking) async {
    final assetId = booking.asset?.id;
    final startDate = booking.startDate;
    final endDate = booking.endDate;

    if (assetId == null ||
        assetId.isEmpty ||
        startDate == null ||
        endDate == null) {
      throw 'Unable to validate booking dates.';
    }

    final result = await LNDBookingService.isAssetAvailable(
      assetId: assetId,
      startDate: Timestamp(startDate.seconds, startDate.nanoseconds),
      endDate: Timestamp(endDate.seconds, endDate.nanoseconds),
      blocksEndDate: booking.asset?.blocksEndDate ?? false,
    );

    return result.fold(
      ifLeft: (isAvailable) => isAvailable,
      ifRight: (error) => throw error,
    );
  }

  void onTapHandedOver() async {
    if (booking == null) return;

    if (isOwner) {
      LNDNavigate.toQRViewPage(qrToken: booking?.tokens?.handoverToken ?? '');
    } else {
      await LNDNavigate.toScanQRPage();
    }
  }

  void onTapReturned() {
    if (booking == null) return;

    if (isOwner) {
      LNDNavigate.toScanQRPage();
    } else {
      LNDNavigate.toQRViewPage(qrToken: booking?.tokens?.returnToken ?? '');
    }
  }

  Future<void> onTapCompleteRental() async {
    final booking = this.booking;
    if (booking == null) return;

    final result = await LNDShow.alertDialog<bool?>(
      title: 'Complete rental?',
      content:
          'This will finalize the rental and start owner payout and deposit return processing.',
    );
    if (result != true) return;

    await _submitSettlementAction(LNDFunctions.completeReturnedBooking);
  }

  Future<void> onTapRequestDamageDeduction() async {
    final booking = this.booking;
    if (booking == null) return;

    await LNDNavigate.toDamageFeeRequestPage(
      args: DamageFeeRequestPageArgs(booking: booking),
    );
  }

  Future<void> onTapAcceptDamageDeduction() async {
    final result = await LNDShow.alertDialog<bool?>(
      title: 'Accept deduction?',
      content: 'Are you sure you want to accept this damage deduction?',
    );
    if (result == true) {
      await _submitSettlementAction(LNDFunctions.acceptDepositDeduction);
    }
  }

  Future<void> onTapDisputeDamageDeduction() async {
    final result = await LNDShow.alertDialog<bool?>(
      title: 'Dispute deduction?',
      content: 'Lend Support will review the damage deduction request.',
    );
    if (result == true) {
      await _submitSettlementAction(LNDFunctions.disputeDepositDeduction);
    }
  }

  Future<void> _submitSettlementAction(
    String functionName, {
    Map<String, dynamic> extra = const {},
  }) async {
    final booking = this.booking;
    if (booking?.id == null) return;

    try {
      LNDLoading.show();
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        functionName,
      );
      await callable.call({'bookingId': booking!.id, ...extra});
      await NowController.instance.refreshNow();
      if (functionName == LNDFunctions.completeReturnedBooking &&
          Get.isRegistered<RentalHistoryController>()) {
        await Get.find<RentalHistoryController>()
            .refreshAfterBookingCompleted();
      }
      LNDLoading.hide();
      LNDSnackbar.showSuccess('Booking updated.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to update booking.');
    }
  }

  void onTapMenu(String menu) async {
    XFile? file;
    switch (menu) {
      case 'camera':
        final status = await LNDCamerAlbumHelper.checkCameraPermission();
        if (status) {
          file = await ImagePicker().pickImage(source: ImageSource.camera);
        }
        break;
      case 'gallery':
        final status = await LNDCamerAlbumHelper.checkGalleryPermission();
        if (status) {
          file = await ImagePicker().pickImage(source: ImageSource.gallery);
        }

        break;
      default:
      // Open saved bank qrs
    }

    if (file != null) await _sendImageMessage(File(file.path));
  }

  Future<void> _sendImageMessage(File file) async {
    if (isChatReadOnly) {
      LNDSnackbar.showWarning('This chat is closed.');
      return;
    }

    if ((chat.chatId?.isEmpty ?? true) || (currentUid?.isEmpty ?? true)) {
      LNDSnackbar.showError('Unable to send image.');
      return;
    }

    if (!isLendSupportChat && (recepientUser?.uid?.isEmpty ?? true)) {
      LNDSnackbar.showError('Unable to send image.');
      return;
    }

    final chatListController =
        Get.isRegistered<ChatListController>()
            ? ChatListController.instance
            : null;
    final pendingId = chatListController?.addPendingImageMessage(
      localFilePath: file.path,
      senderId: currentUid!,
    );

    try {
      final url = await LNDFirebaseStorageHelper.uploadFile(
        file: file,
        folder: '$currentUid/chats/${chat.id}',
        onProgress: (_, progress) {
          if (pendingId == null) return;
          chatListController?.updatePendingImageProgress(pendingId, progress);
        },
      );

      final success =
          isLendSupportChat
              ? await LNDMessagingService.sendSupportMessage(
                message: url,
                type: MessageType.image,
                chatId: chat.chatId!,
                fromUid: currentUid!,
              )
              : await LNDMessagingService.sendMessage(
                message: url,
                type: MessageType.image,
                chatId: chat.chatId!,
                toUid: recepientUser!.uid!,
                fromUid: currentUid!,
              );

      if (!success) throw 'Unable to send image message';
      if (pendingId != null) {
        chatListController?.removePendingMessage(pendingId);
      }
    } catch (e, st) {
      if (pendingId != null) {
        chatListController?.markPendingMessageFailed(pendingId);
      }
      LNDLogger.e('Error sending image message', error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to send image.');
    }
  }

  void goToBookingDetails() {
    final booking = this.booking;
    if (booking == null) return;

    LNDNavigate.toBookingDetailsPage(
      args: BookingDetailsPageArgs(booking: booking),
    );
  }

  void viewBookingInfo() async {
    if (booking == null) return;

    final deleted = await LNDNavigate.toChatInformationPage(
      args: ChatInformationArgs(chat: chat),
    );

    if (deleted == true) Get.back();
  }
}

class _QrTransactionReminderSheet extends StatelessWidget {
  const _QrTransactionReminderSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                color: colors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            LNDText.semibold(
              text: 'Use QR scans for handover and return',
              fontSize: 18,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 8),
            const Column(
              spacing: 10,
              children: [
                _QrReminderBullet(text: 'Records when the item changes hands.'),
                _QrReminderBullet(
                  text: 'Confirms both handover and return activity.',
                ),
                _QrReminderBullet(
                  text: 'Helps support dispute evidence if needed.',
                ),
                _QrReminderBullet(
                  text:
                      'Receive/send ratings and reviews after booking is completed.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            LNDButton.primary(text: 'Done', enabled: true, onPressed: Get.back),
            const SizedBox(height: 24),
            LNDButton.text(
              text: 'Don\'t show again',
              enabled: true,
              color: colors.textSecondary,
              onPressed: () async {
                await LNDStorageService.write(
                  LNDStorageConstants.hideQrTransactionReminder,
                  true,
                );
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QrReminderBullet extends StatelessWidget {
  const _QrReminderBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: LNDText.regular(text: text, overflow: TextOverflow.visible),
        ),
      ],
    );
  }
}

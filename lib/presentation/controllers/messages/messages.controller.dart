import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/mixins/scroll.mixin.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/message.model.dart';
import 'package:lend/core/services/messaging.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/navigation/navigation.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/bottom_nav_page.enum.dart';
import 'package:lend/utilities/enums/chat_status.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class MessagesController extends GetxController with AuthMixin, LNDScrollMixin {
  static MessagesController get instance => Get.find<MessagesController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Chat> _chats = <Chat>[].obs;
  List<Chat> get allChats => _chats;
  List<Chat> get activeChats =>
      _chats.where((chat) => chat.status == ChatStatus.active).toList();
  List<Chat> get archivedChats =>
      _chats.where((chat) => chat.status == ChatStatus.archived).toList();
  List<Chat> get deletedChats =>
      _chats.where((chat) => chat.status == ChatStatus.deleted).toList();
  bool get unreadCount =>
      activeChats.where((chat) => chat.hasRead == false).toList().isNotEmpty;

  final RxList<Message> _messages = <Message>[].obs;
  List<Message> get messages => _messages;

  final RxBool _isChatsLoading = false.obs;
  bool get isChatsLoading => _isChatsLoading.value;

  final RxBool _isMessagesLoading = false.obs;
  bool get isMessagesLoading => _isMessagesLoading.value;

  StreamSubscription? _chatsSubscription;

  @override
  void onClose() {
    _chatsSubscription?.cancel();
    _chats.close();
    _messages.close();
    _isChatsLoading.close();
    _isMessagesLoading.close();
    super.onClose();
  }

  void cancelSubscriptions() {
    if (_chatsSubscription != null) {
      _chatsSubscription?.cancel();
      LNDLogger.dNoStack('🔴 Chat Subscription Cancelled');
    }
  }

  // Listen to user's chats
  void listenToChats() {
    _isChatsLoading.value = true;
    final userId = AuthController.instance.uid;

    try {
      cancelSubscriptions();

      LNDLogger.dNoStack('🟢 Chat Subscription Started');
      _chatsSubscription = _firestore
          .collection(LNDCollections.userChats.name)
          .doc(userId)
          .collection(LNDCollections.chats.name)
          .orderBy('lastMessageDate', descending: true)
          .limit(20)
          .snapshots()
          .listen(
            (snapshot) {
              final List<Chat> chatsList = [];

              for (var doc in snapshot.docs) {
                final chat = Chat.fromMap(doc.data());
                chatsList.add(chat);
              }

              _chats.value = chatsList;
              _isChatsLoading.value = false;
            },
            onError: (e, st) {
              LNDLogger.e('Error listening to chats', error: e, stackTrace: st);
              _isChatsLoading.value = false;
            },
          );
    } catch (e, st) {
      LNDLogger.e('Error setting up chat listener', error: e, stackTrace: st);
      _isChatsLoading.value = false;
    }
  }

  void clearChats() {
    _chats.clear();
    _messages.clear();
  }

  Chat? findChatByBookingId(String bookingId) {
    return allChats.firstWhereOrNull((chat) => chat.bookingId == bookingId);
  }

  Future<Chat?> findFreshChatForBooking(Booking booking) async {
    final uid = currentUid;
    final chatId = booking.chatId;

    if (uid != null && uid.isNotEmpty && chatId != null && chatId.isNotEmpty) {
      final snapshot =
          await _firestore
              .collection(LNDCollections.userChats.name)
              .doc(uid)
              .collection(LNDCollections.chats.name)
              .doc(chatId)
              .get();
      final data = snapshot.data();
      if (data != null) return Chat.fromMap(data);
    }

    final bookingId = booking.id;
    if (bookingId == null || bookingId.isEmpty) return null;
    return findChatByBookingId(bookingId);
  }

  Future<void> openAcceptedBookingChat(Booking booking) async {
    try {
      final chat = await findFreshChatForBooking(booking);
      if (chat == null) throw 'Cannot find chat for this booking';

      NavigationController.instance.changeTab(LNDBottomNavPage.messages.indexx);
      Get.until((page) => page.isFirst);
      await LNDNavigate.toChatPage(chat: chat);
    } catch (e, st) {
      LNDLogger.e(
        'Unable to open accepted booking chat',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to open this booking chat.');
    }
  }

  void goToChatPage(Chat chat) {
    if (chat.status == ChatStatus.deleted) {
      LNDSnackbar.showWarning('This chat has been deleted.');
      return;
    }

    LNDNavigate.toChatPage(chat: chat);
  }

  void goToArchivedMessagesPage() {
    LNDNavigate.toArchivedMessagesPage();
  }

  void deleteChat(Chat chat) async {
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
      LNDSnackbar.showSuccess('Chat deleted.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error deleting chat', error: e, stackTrace: st);
      LNDSnackbar.showError('Failed to delete chat.');
    }
  }
}

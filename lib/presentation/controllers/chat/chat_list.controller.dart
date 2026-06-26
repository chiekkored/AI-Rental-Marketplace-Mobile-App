import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/message.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/services/messaging.service.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/message_type.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class ChatListController extends GetxController {
  final Chat chat;
  ChatListController({required this.chat})
    : _isUserChatRead = chat.hasRead == true;

  static ChatListController get instance => Get.find<ChatListController>();
  static const int messagePageSize = 50;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController textController = TextEditingController();
  late final PagingController<int, Message> pagingController =
      PagingController<int, Message>(
        getNextPageKey: _getNextPageKey,
        fetchPage: _fetchMessagesPage,
      );

  final Map<String, Message> _liveMessageById = <String, Message>{};
  final Map<String, Message> _pendingMessageById = <String, Message>{};
  final Map<String, int> _localSortOrderById = <String, int>{};

  SimpleUserModel? get recepientUser => chat.participants?.firstWhereOrNull(
    (user) => user.uid != AuthController.instance.uid,
  );

  final List<StreamSubscription> _messageSubscriptions = [];
  QueryDocumentSnapshot<Map<String, dynamic>>? _oldestLoadedDocument;
  bool _hasMoreOlderMessages = true;
  bool _deferredFirstPageReplacement = false;
  bool _hasAppliedInitialSnapshot = false;
  bool _isMarkingChatAsRead = false;
  bool _shouldMarkChatAsReadAgain = false;
  bool _isUserChatRead;

  @override
  void onClose() {
    textController.dispose();
    cancelSubscriptions();
    pagingController.removeListener(_applyDeferredFirstPageReplacement);
    pagingController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    pagingController.addListener(_applyDeferredFirstPageReplacement);
    listenToChats();
    super.onInit();
  }

  @override
  void onReady() {
    updateHasRead();
    super.onReady();
  }

  void cancelSubscriptions() {
    LNDLogger.dNoStack('🔴 Chat Subscription Cancelled for ${chat.id}');
    for (final subscription in _messageSubscriptions) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
  }

  // Listen to user's latest messages only. Older pages are fetched by the
  // PagingController as the reversed list scrolls upward.
  void listenToChats() {
    final userId = AuthController.instance.uid;
    if (userId == null || userId.isEmpty) {
      _hasMoreOlderMessages = false;
      pagingController.value = pagingController.value.copyWith(
        pages: <List<Message>>[<Message>[]],
        keys: <int>[1],
        hasNextPage: false,
        isLoading: false,
      );
      return;
    }

    try {
      cancelSubscriptions();

      LNDLogger.dNoStack(
        '🟢 Chat Messages Subscription Started for ${chat.id}',
      );
      final messagesRef = _firestore
          .collection(LNDCollections.chats.name)
          .doc(chat.chatId)
          .collection(LNDCollections.messages.name);

      _liveMessageById.clear();
      _oldestLoadedDocument = null;
      _hasMoreOlderMessages = true;
      _deferredFirstPageReplacement = false;
      _hasAppliedInitialSnapshot = false;
      pagingController.refresh();

      void applySnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty && !_hasOlderPagesLoaded) {
          _oldestLoadedDocument = snapshot.docs.last;
        }
        if (snapshot.docs.length < messagePageSize && !_hasOlderPagesLoaded) {
          _hasMoreOlderMessages = false;
        }

        var hasNewIncomingMessage = false;
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.removed) {
            _liveMessageById.remove(change.doc.id);
            continue;
          }

          var message = Message.fromMap(change.doc.data()!);
          final isIncomingMessage =
              message.senderId != null &&
              message.senderId != userId &&
              !change.doc.metadata.hasPendingWrites;
          if (_hasAppliedInitialSnapshot && isIncomingMessage) {
            hasNewIncomingMessage = true;
          }
          if (message.createdAt == null &&
              change.doc.metadata.hasPendingWrites) {
            message = message.copyWith(
              isSending: true,
              localSortOrder: _localSortOrderFor(change.doc.id),
            );
          }
          _liveMessageById[change.doc.id] = message;
        }

        if (pagingController.value.pages == null ||
            pagingController.value.isLoading) {
          _deferredFirstPageReplacement = true;
        } else {
          _replaceFirstPage();
        }
        if (!_hasAppliedInitialSnapshot) {
          _hasAppliedInitialSnapshot = true;
          updateHasRead();
          return;
        }
        if (hasNewIncomingMessage) {
          _isUserChatRead = false;
          updateHasRead();
        }
      }

      void handleError(Object e, StackTrace st) {
        cancelSubscriptions();
        LNDLogger.e('Error listening to chats', error: e, stackTrace: st);
        pagingController.value = pagingController.value.copyWith(error: e);
      }

      _messageSubscriptions.add(
        messagesRef
            .where('visibleTo', arrayContains: userId)
            .orderBy('createdAt', descending: true)
            .limit(messagePageSize)
            .snapshots()
            .listen(applySnapshot, onError: handleError),
      );
    } catch (e, st) {
      cancelSubscriptions();
      LNDLogger.e('Error setting up chat listener', error: e, stackTrace: st);
      pagingController.value = pagingController.value.copyWith(error: e);
    }
  }

  int? _getNextPageKey(PagingState<int, Message> state) {
    final keys = state.keys;
    if (keys == null || keys.isEmpty) return 1;
    if (!_hasMoreOlderMessages) return null;
    return keys.last + 1;
  }

  Future<List<Message>> _fetchMessagesPage(int pageKey) async {
    final userId = AuthController.instance.uid;
    if (userId == null || userId.isEmpty) {
      _hasMoreOlderMessages = false;
      return <Message>[];
    }

    try {
      if (pageKey > 1 && _oldestLoadedDocument == null) {
        _hasMoreOlderMessages = false;
        return <Message>[];
      }

      final snapshot = await _messageQuery(userId, pageKey).get();

      if (snapshot.docs.isNotEmpty) {
        _oldestLoadedDocument = snapshot.docs.last;
      }
      _hasMoreOlderMessages = snapshot.docs.length >= messagePageSize;

      final liveMessageIds = _liveMessageById.keys.toSet();
      return snapshot.docs
          .where((doc) => pageKey == 1 || !liveMessageIds.contains(doc.id))
          .map((doc) => Message.fromMap(doc.data()))
          .toList();
    } catch (e, st) {
      LNDLogger.e('Error loading chat messages page', error: e, stackTrace: st);
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  Query<Map<String, dynamic>> _messageQuery(String userId, int pageKey) {
    var query = _firestore
        .collection(LNDCollections.chats.name)
        .doc(chat.chatId)
        .collection(LNDCollections.messages.name)
        .where('visibleTo', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(messagePageSize);

    if (pageKey > 1) {
      query = query.startAfterDocument(_oldestLoadedDocument!);
    }

    return query;
  }

  bool get _hasOlderPagesLoaded {
    final keys = pagingController.value.keys;
    return keys != null && keys.length > 1;
  }

  void _applyDeferredFirstPageReplacement() {
    if (!_deferredFirstPageReplacement) return;
    final state = pagingController.value;
    if (state.pages == null || state.isLoading) return;

    _replaceFirstPage();
  }

  void _replaceFirstPage() {
    _deferredFirstPageReplacement = false;
    final current = pagingController.value;
    final currentPages = current.pages ?? const <List<Message>>[];
    final currentKeys = current.keys ?? const <int>[];
    final firstPage = _sortedMessages([
      ..._liveMessageById.values,
      ..._pendingMessageById.values,
    ]);
    final firstPageIds = firstPage.map((message) => message.id).toSet();
    final olderPages =
        currentPages
            .skip(1)
            .map(
              (page) =>
                  page
                      .where((message) => !firstPageIds.contains(message.id))
                      .toList(),
            )
            .where((page) => page.isNotEmpty)
            .toList();
    final olderKeys = currentKeys.skip(1).take(olderPages.length).toList();

    pagingController.value = current.copyWith(
      pages: <List<Message>>[firstPage, ...olderPages],
      keys: <int>[1, ...olderKeys],
      hasNextPage: _hasMoreOlderMessages,
      isLoading: false,
    );
    update();
  }

  List<Message> _sortedMessages(List<Message> messages) {
    return messages..sort((a, b) {
      final aLocalOrder = a.localSortOrder;
      final bLocalOrder = b.localSortOrder;
      if (aLocalOrder != null && bLocalOrder != null) {
        return bLocalOrder.compareTo(aLocalOrder);
      }
      if (aLocalOrder != null) return -1;
      if (bLocalOrder != null) return 1;

      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
  }

  List<Message> messagesFromState(PagingState<int, Message> state) {
    return state.items ?? const <Message>[];
  }

  String addPendingImageMessage({
    required String localFilePath,
    required String senderId,
  }) {
    final pendingId = 'local-image-${DateTime.now().microsecondsSinceEpoch}';
    _pendingMessageById[pendingId] = Message(
      id: pendingId,
      text: localFilePath,
      senderId: senderId,
      type: MessageType.image,
      localFilePath: localFilePath,
      isLocalOnly: true,
      isSending: true,
      uploadProgress: 0,
      localSortOrder: _localSortOrderFor(pendingId),
    );
    _replaceFirstPage();
    return pendingId;
  }

  void updatePendingImageProgress(String pendingId, double progress) {
    final pending = _pendingMessageById[pendingId];
    if (pending == null) return;

    _pendingMessageById[pendingId] = pending.copyWith(
      uploadProgress: progress.clamp(0, 1).toDouble(),
    );
    _replaceFirstPage();
  }

  void removePendingMessage(String pendingId) {
    if (_pendingMessageById.remove(pendingId) == null) return;
    _replaceFirstPage();
  }

  void markPendingMessageFailed(String pendingId) {
    final pending = _pendingMessageById[pendingId];
    if (pending == null) return;

    _pendingMessageById[pendingId] = pending.copyWith(
      isSending: false,
      hasSendError: true,
      uploadProgress: 0,
    );
    _replaceFirstPage();
  }

  int _localSortOrderFor(String id) {
    return _localSortOrderById.putIfAbsent(
      id,
      () => DateTime.now().microsecondsSinceEpoch,
    );
  }

  Future<void> updateHasRead() async {
    final userId = AuthController.instance.uid;
    final chatDocId = chat.id;
    if (userId == null || chatDocId == null) return;
    if (_isUserChatRead) return;
    if (_isMarkingChatAsRead) {
      _shouldMarkChatAsReadAgain = true;
      return;
    }

    _isMarkingChatAsRead = true;
    try {
      await LNDMessagingService.markChatAsRead(
        userId: userId,
        chatId: chatDocId,
      );
      _isUserChatRead = true;
    } finally {
      _isMarkingChatAsRead = false;
      if (_shouldMarkChatAsReadAgain) {
        _shouldMarkChatAsReadAgain = false;
        _isUserChatRead = false;
        updateHasRead();
      }
    }
  }
}

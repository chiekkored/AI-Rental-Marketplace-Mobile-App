import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/message.model.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/chat_status.enum.dart';
import 'package:lend/utilities/enums/message_type.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class LNDMessagingService {
  LNDMessagingService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @visibleForTesting
  static ({Map<String, dynamic> sender, Map<String, dynamic> recipient})
  buildUserMessageChatUpdateMaps({
    required String message,
    required MessageType type,
    required String fromUid,
  }) {
    final isMedia = type == MessageType.image || type == MessageType.video;
    final lastMessage = isMedia ? 'Sent a media' : message;

    return (
      sender:
          Chat(
            lastMessage: lastMessage,
            lastMessageSenderId: fromUid,
            hasRead: true,
          ).toMap(),
      recipient:
          Chat(
            lastMessage: lastMessage,
            lastMessageSenderId: fromUid,
            hasRead: false,
          ).toMap(),
    );
  }

  static Future<bool> sendMessage({
    required String message,
    required MessageType type,
    required String chatId,
    required String toUid,
    required String fromUid,
  }) async {
    try {
      final batch = _firestore.batch();
      final serverTimestamp = FieldValue.serverTimestamp();

      final messageCollection = _firestore
          .collection(LNDCollections.chats.name)
          .doc(chatId)
          .collection(LNDCollections.messages.name);

      // Update the sender's chat root
      final userChatsCollection = _firestore
          .collection(LNDCollections.userChats.name)
          .doc(fromUid)
          .collection(LNDCollections.chats.name)
          .doc(chatId);
      // Update the recepient's chat root
      final recepientChatsCollection = _firestore
          .collection(LNDCollections.userChats.name)
          .doc(toUid)
          .collection(LNDCollections.chats.name)
          .doc(chatId);

      final messageData = Message(
        id: messageCollection.doc().id,
        text: message,
        senderId: fromUid,
        type: type,
        visibleTo: [fromUid, toUid],
      );

      final chatUpdates = buildUserMessageChatUpdateMaps(
        message: message,
        type: type,
        fromUid: fromUid,
      );

      batch.set(messageCollection.doc(messageData.id), {
        ...messageData.toMap(),
        'createdAt': serverTimestamp,
      });
      batch.update(userChatsCollection, {
        ...chatUpdates.sender,
        'lastMessageDate': serverTimestamp,
      });
      batch.update(recepientChatsCollection, {
        ...chatUpdates.recipient,
        'lastMessageDate': serverTimestamp,
      });

      await batch.commit().catchError((e) => throw e);

      return true;
    } catch (e, st) {
      LNDLogger.e('Error sending message', error: e, stackTrace: st);
      return false;
    }
  }

  static Future<bool> sendSupportMessage({
    required String message,
    required MessageType type,
    required String chatId,
    required String fromUid,
  }) async {
    try {
      final batch = _firestore.batch();
      final serverTimestamp = FieldValue.serverTimestamp();

      final messageCollection = _firestore
          .collection(LNDCollections.chats.name)
          .doc(chatId)
          .collection(LNDCollections.messages.name);
      final userChatsCollection = _firestore
          .collection(LNDCollections.userChats.name)
          .doc(fromUid)
          .collection(LNDCollections.chats.name)
          .doc(chatId);

      final messageData = Message(
        id: messageCollection.doc().id,
        text: message,
        senderId: fromUid,
        type: type,
        visibleTo: [fromUid, 'lend_support'],
      );
      final isMedia = type == MessageType.image || type == MessageType.video;
      final chatDoc = Chat(
        lastMessage: isMedia ? 'Sent a media' : message,
        lastMessageSenderId: fromUid,
        hasRead: true,
      );

      batch.set(messageCollection.doc(messageData.id), {
        ...messageData.toMap(),
        'createdAt': serverTimestamp,
      });
      batch.update(userChatsCollection, {
        ...chatDoc.toMap(),
        'lastMessageDate': serverTimestamp,
      });

      await batch.commit().catchError((e) => throw e);

      return true;
    } catch (e, st) {
      LNDLogger.e('Error sending support message', error: e, stackTrace: st);
      return false;
    }
  }

  static Future<bool> markChatAsRead({
    required String userId,
    required String chatId,
  }) async {
    try {
      final userChatRef = _firestore
          .collection(LNDCollections.userChats.name)
          .doc(userId)
          .collection(LNDCollections.chats.name)
          .doc(chatId);

      return await _firestore.runTransaction((transaction) async {
        final userChatSnapshot = await transaction.get(userChatRef);
        if (!userChatSnapshot.exists) return false;
        if (userChatSnapshot.data()?['hasRead'] == true) return false;

        transaction.update(userChatRef, Chat(hasRead: true).toMap());
        return true;
      });
    } catch (e, st) {
      LNDLogger.e('Error updating hasRead', error: e, stackTrace: st);
      return false;
    }
  }

  static Future<void> reportContent({
    required String reporterId,
    String? reportedUserId,
    required String reportType,
    required String reason,
    String? details,
    String? chatId,
    String? bookingId,
    String? assetId,
    bool archiveRequested = false,
    bool bookingCancelRequested = false,
  }) async {
    final reportRef = _firestore.collection(LNDCollections.reports.name).doc();

    await reportRef.set({
      'id': reportRef.id,
      'reporterId': reporterId,
      if (reportedUserId != null) 'reportedUserId': reportedUserId,
      'reportType': reportType,
      'reason': reason,
      if (details != null && details.isNotEmpty) 'details': details,
      if (chatId != null) 'chatId': chatId,
      if (bookingId != null) 'bookingId': bookingId,
      if (assetId != null) 'assetId': assetId,
      'archiveRequested': archiveRequested,
      'bookingCancelRequested': bookingCancelRequested,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Open',
    });
  }

  static Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required Chat chat,
  }) async {
    await reportContent(
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      reportType: 'User',
      reason: 'Other',
      chatId: chat.chatId ?? chat.id,
      bookingId: chat.bookingId,
      assetId: chat.asset?.id,
    );
  }

  static Future<void> deleteChatForUser({
    required String userId,
    required String chatId,
  }) async {
    final userChatRef = _firestore
        .collection(LNDCollections.userChats.name)
        .doc(userId)
        .collection(LNDCollections.chats.name)
        .doc(chatId);

    await userChatRef.update(Chat(status: ChatStatus.deleted).toMap());
  }

  static Future<void> archiveChatForUser({
    required String userId,
    required String chatId,
  }) async {
    final userChatRef = _firestore
        .collection(LNDCollections.userChats.name)
        .doc(userId)
        .collection(LNDCollections.chats.name)
        .doc(chatId);

    await userChatRef.update(Chat(status: ChatStatus.archived).toMap());
  }
}

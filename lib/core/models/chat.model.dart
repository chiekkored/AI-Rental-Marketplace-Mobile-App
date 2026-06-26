// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lend/core/models/availability.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';

import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/enums/chat_status.enum.dart';

class Chat {
  static const String lendSupportChatType = 'lend_support';
  static const String legacySupportChatType = 'Support';
  static const String lendSupportUid = 'lend_support';

  String? id;
  String? chatId;
  String? chatType;
  String? bookingId;
  String? renterId;
  SimpleAsset? asset;
  List<SimpleUserModel>? participants;
  String? lastMessage;
  Timestamp? lastMessageDate;
  String? lastMessageSenderId;
  Timestamp? bookingStartDate;
  Timestamp? bookingEndDate;
  BookingStatus? bookingStatus;
  Timestamp? createdAt;
  bool? hasRead;
  ChatStatus? status;
  Chat({
    this.id,
    this.chatId,
    this.chatType,
    this.bookingId,
    this.renterId,
    this.asset,
    this.participants,
    this.lastMessage,
    this.lastMessageDate,
    this.lastMessageSenderId,
    this.bookingStartDate,
    this.bookingEndDate,
    this.bookingStatus,
    this.createdAt,
    this.hasRead,
    this.status,
  });

  bool get isReadOnly =>
      status == ChatStatus.archived ||
      status == ChatStatus.deleted ||
      bookingStatus == BookingStatus.completed;

  bool get hasLendSupportType =>
      chatType == lendSupportChatType || chatType == legacySupportChatType;

  bool get hasLendSupportParticipant =>
      participants?.any((user) => user.uid == lendSupportUid) ?? false;

  bool isLendSupportChatFor(String? currentUid) {
    if (hasLendSupportType || hasLendSupportParticipant) return true;
    if (currentUid == null || currentUid.isEmpty) return false;
    return participants?.any(
          (user) => user.uid != currentUid && user.uid == lendSupportUid,
        ) ??
        false;
  }

  Chat copyWith({
    String? id,
    String? chatId,
    String? chatType,
    String? bookingId,
    String? renterId,
    SimpleAsset? asset,
    List<SimpleUserModel>? participants,
    List<Availability>? availabilities,
    String? lastMessage,
    Timestamp? lastMessageDate,
    String? lastMessageSenderId,
    Timestamp? bookingStartDate,
    Timestamp? bookingEndDate,
    BookingStatus? bookingStatus,
    Timestamp? createdAt,
    bool? hasRead,
    ChatStatus? status,
  }) {
    return Chat(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      chatType: chatType ?? this.chatType,
      bookingId: bookingId ?? this.bookingId,
      renterId: renterId ?? this.renterId,
      asset: asset ?? this.asset,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      bookingStartDate: bookingStartDate ?? this.bookingStartDate,
      bookingEndDate: bookingEndDate ?? this.bookingEndDate,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      createdAt: createdAt ?? this.createdAt,
      hasRead: hasRead ?? this.hasRead,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chatId': chatId,
      'chatType': chatType,
      'bookingId': bookingId,
      'renterId': renterId,
      'asset': asset?.toMap(),
      'participants': participants?.map((x) => x.toMap()).toList(),
      'lastMessage': lastMessage,
      'lastMessageDate':
          lastMessageDate != null
              ? Timestamp(
                lastMessageDate!.seconds,
                lastMessageDate!.nanoseconds,
              )
              : null,
      'lastMessageSenderId': lastMessageSenderId,
      'bookingStartDate':
          bookingStartDate != null
              ? Timestamp(
                bookingStartDate!.seconds,
                bookingStartDate!.nanoseconds,
              )
              : null,
      'bookingEndDate':
          bookingEndDate != null
              ? Timestamp(bookingEndDate!.seconds, bookingEndDate!.nanoseconds)
              : null,
      'bookingStatus': bookingStatus?.label,
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds)
              : null,
      'hasRead': hasRead,
      'status': status?.label,
    }..removeWhere((key, value) => value == null);
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] != null ? map['id'] as String : null,
      chatId: map['chatId'] != null ? map['chatId'] as String : null,
      chatType: map['chatType'] != null ? map['chatType'] as String : null,
      bookingId: map['bookingId'] != null ? map['bookingId'] as String : null,
      renterId: map['renterId'] != null ? map['renterId'] as String : null,
      asset:
          map['asset'] != null
              ? SimpleAsset.fromMap(map['asset'] as Map<String, dynamic>)
              : null,
      participants:
          map['participants'] != null
              ? List<SimpleUserModel>.from(
                (map['participants']).map<SimpleUserModel?>(
                  (x) => SimpleUserModel.fromMap(x as Map<String, dynamic>),
                ),
              )
              : null,
      lastMessage:
          map['lastMessage'] != null ? map['lastMessage'] as String : null,
      lastMessageDate: _timestampFromMap(map['lastMessageDate']),
      lastMessageSenderId:
          map['lastMessageSenderId'] != null
              ? map['lastMessageSenderId'] as String
              : null,
      bookingStartDate: _timestampFromMap(map['bookingStartDate']),
      bookingEndDate: _timestampFromMap(map['bookingEndDate']),
      bookingStatus:
          map['bookingStatus'] != null
              ? BookingStatus.fromString(map['bookingStatus'])
              : null,
      createdAt: _timestampFromMap(map['createdAt']),
      hasRead: map['hasRead'] != null ? map['hasRead'] as bool : null,
      status:
          map['status'] != null ? ChatStatus.fromString(map['status']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chat(id: $id, chatId: $chatId, chatType: $chatType, bookingId: $bookingId, renterId: $renterId, asset: $asset, participants: $participants, lastMessage: $lastMessage, lastMessageDate: $lastMessageDate, lastMessageSenderId: $lastMessageSenderId, bookingStartDate: $bookingStartDate, bookingEndDate: $bookingEndDate, bookingStatus: $bookingStatus, createdAt: $createdAt, hasRead: $hasRead, status: $status)';
  }

  @override
  bool operator ==(covariant Chat other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.chatId == chatId &&
        other.chatType == chatType &&
        other.bookingId == bookingId &&
        other.renterId == renterId &&
        other.asset == asset &&
        listEquals(other.participants, participants) &&
        other.lastMessage == lastMessage &&
        other.lastMessageDate == lastMessageDate &&
        other.lastMessageSenderId == lastMessageSenderId &&
        other.bookingStartDate == bookingStartDate &&
        other.bookingEndDate == bookingEndDate &&
        other.bookingStatus == bookingStatus &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.hasRead == hasRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatId.hashCode ^
        chatType.hashCode ^
        bookingId.hashCode ^
        renterId.hashCode ^
        asset.hashCode ^
        participants.hashCode ^
        lastMessage.hashCode ^
        lastMessageDate.hashCode ^
        lastMessageSenderId.hashCode ^
        bookingStartDate.hashCode ^
        bookingEndDate.hashCode ^
        bookingStatus.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        hasRead.hashCode;
  }

  static Timestamp? _timestampFromMap(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value;
    return Timestamp(value['_seconds'], value['_nanoseconds']);
  }
}

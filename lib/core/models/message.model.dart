// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lend/utilities/enums/message_type.enum.dart';

class Message {
  String? id;
  String? text;
  String? senderId;
  Timestamp? createdAt;
  MessageType? type;
  String? mediaUrl;
  String? systemAction;
  String? damagePaymentRequestId;
  String? bookingId;
  String? chatId;
  int? amount;
  String? currency;
  String? paymentStatus;
  List<String>? visibleTo;
  String? localFilePath;
  bool isLocalOnly;
  bool isSending;
  bool hasSendError;
  double? uploadProgress;
  int? localSortOrder;
  Message({
    this.id,
    this.text,
    this.senderId,
    this.createdAt,
    this.type,
    this.mediaUrl,
    this.systemAction,
    this.damagePaymentRequestId,
    this.bookingId,
    this.chatId,
    this.amount,
    this.currency,
    this.paymentStatus,
    this.visibleTo,
    this.localFilePath,
    this.isLocalOnly = false,
    this.isSending = false,
    this.hasSendError = false,
    this.uploadProgress,
    this.localSortOrder,
  });

  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    Timestamp? createdAt,
    MessageType? type,
    String? mediaUrl,
    String? systemAction,
    String? damagePaymentRequestId,
    String? bookingId,
    String? chatId,
    int? amount,
    String? currency,
    String? paymentStatus,
    List<String>? visibleTo,
    String? localFilePath,
    bool? isLocalOnly,
    bool? isSending,
    bool? hasSendError,
    double? uploadProgress,
    int? localSortOrder,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      systemAction: systemAction ?? this.systemAction,
      damagePaymentRequestId:
          damagePaymentRequestId ?? this.damagePaymentRequestId,
      bookingId: bookingId ?? this.bookingId,
      chatId: chatId ?? this.chatId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      visibleTo: visibleTo ?? this.visibleTo,
      localFilePath: localFilePath ?? this.localFilePath,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      isSending: isSending ?? this.isSending,
      hasSendError: hasSendError ?? this.hasSendError,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      localSortOrder: localSortOrder ?? this.localSortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'senderId': senderId,
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds)
              : null,
      'type': type?.label,
      'mediaUrl': mediaUrl,
      'systemAction': systemAction,
      'damagePaymentRequestId': damagePaymentRequestId,
      'bookingId': bookingId,
      'chatId': chatId,
      'amount': amount,
      'currency': currency,
      'paymentStatus': paymentStatus,
      'visibleTo': visibleTo,
    }..removeWhere((key, value) => value == null);
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] != null ? map['id'] as String : null,
      text: map['text'] != null ? map['text'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      createdAt:
          map['createdAt'] != null
              ? map['createdAt'] is Timestamp
                  ? map['createdAt'] as Timestamp
                  : Timestamp(
                    map['createdAt']['_seconds'],
                    map['createdAt']['_nanoseconds'],
                  )
              : null,
      type: map['type'] != null ? MessageType.fromString(map['type']) : null,
      mediaUrl: map['mediaUrl'] != null ? map['mediaUrl'] as String : null,
      systemAction:
          map['systemAction'] != null ? map['systemAction'] as String : null,
      damagePaymentRequestId:
          map['damagePaymentRequestId'] != null
              ? map['damagePaymentRequestId'] as String
              : map['paymentRequestId'] != null
              ? map['paymentRequestId'] as String
              : null,
      bookingId: map['bookingId'] != null ? map['bookingId'] as String : null,
      chatId: map['chatId'] != null ? map['chatId'] as String : null,
      amount: map['amount'] != null ? (map['amount'] as num).round() : null,
      currency: map['currency'] != null ? map['currency'] as String : null,
      paymentStatus:
          map['paymentStatus'] != null ? map['paymentStatus'] as String : null,
      visibleTo:
          map['visibleTo'] != null
              ? List<String>.from(map['visibleTo'] as List)
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, text: $text, senderId: $senderId, createdAt: $createdAt, type: $type, mediaUrl: $mediaUrl, systemAction: $systemAction, damagePaymentRequestId: $damagePaymentRequestId, bookingId: $bookingId, chatId: $chatId, amount: $amount, currency: $currency, paymentStatus: $paymentStatus, visibleTo: $visibleTo, localFilePath: $localFilePath, isLocalOnly: $isLocalOnly, isSending: $isSending, hasSendError: $hasSendError, uploadProgress: $uploadProgress, localSortOrder: $localSortOrder)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.senderId == senderId &&
        other.createdAt == createdAt &&
        other.type == type &&
        other.mediaUrl == mediaUrl &&
        other.systemAction == systemAction &&
        other.damagePaymentRequestId == damagePaymentRequestId &&
        other.bookingId == bookingId &&
        other.chatId == chatId &&
        other.amount == amount &&
        other.currency == currency &&
        other.paymentStatus == paymentStatus &&
        listEquals(other.visibleTo, visibleTo) &&
        other.localFilePath == localFilePath &&
        other.isLocalOnly == isLocalOnly &&
        other.isSending == isSending &&
        other.hasSendError == hasSendError &&
        other.uploadProgress == uploadProgress &&
        other.localSortOrder == localSortOrder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        senderId.hashCode ^
        createdAt.hashCode ^
        type.hashCode ^
        mediaUrl.hashCode ^
        systemAction.hashCode ^
        damagePaymentRequestId.hashCode ^
        bookingId.hashCode ^
        chatId.hashCode ^
        amount.hashCode ^
        currency.hashCode ^
        paymentStatus.hashCode ^
        visibleTo.hashCode ^
        localFilePath.hashCode ^
        isLocalOnly.hashCode ^
        isSending.hashCode ^
        hasSendError.hashCode ^
        uploadProgress.hashCode ^
        localSortOrder.hashCode;
  }
}

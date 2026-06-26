import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/enums/chat_status.enum.dart';

void main() {
  group('Chat.fromMap', () {
    test('parses booking dates from Firestore timestamps', () {
      final chat = Chat.fromMap({
        'id': 'chat-1',
        'chatId': 'chat-1',
        'bookingStartDate': Timestamp.fromDate(DateTime(2026, 4, 10)),
        'bookingEndDate': Timestamp.fromDate(DateTime(2026, 4, 12)),
      });

      expect(chat.bookingStartDate?.toDate(), DateTime(2026, 4, 10));
      expect(chat.bookingEndDate?.toDate(), DateTime(2026, 4, 12));
    });

    test('parses booking dates from JSON timestamp maps', () {
      final chat = Chat.fromMap({
        'id': 'chat-1',
        'chatId': 'chat-1',
        'bookingStartDate': {'_seconds': 1775779200, '_nanoseconds': 0},
        'bookingEndDate': {'_seconds': 1775952000, '_nanoseconds': 0},
      });

      expect(
        chat.bookingStartDate?.toDate().toUtc(),
        DateTime.utc(2026, 4, 10),
      );
      expect(chat.bookingEndDate?.toDate().toUtc(), DateTime.utc(2026, 4, 12));
    });

    test('parses and serializes booking status', () {
      final chat = Chat.fromMap({
        'id': 'chat-1',
        'chatId': 'chat-1',
        'bookingStatus': BookingStatus.handedOver.label,
      });

      expect(chat.bookingStatus, BookingStatus.handedOver);
      expect(chat.toMap()['bookingStatus'], BookingStatus.handedOver.label);
    });

    test('marks archived and completed chats as read-only', () {
      final archivedChat = Chat.fromMap({
        'id': 'chat-1',
        'chatId': 'chat-1',
        'status': ChatStatus.archived.label,
      });
      final completedChat = Chat.fromMap({
        'id': 'chat-2',
        'chatId': 'chat-2',
        'bookingStatus': BookingStatus.completed.label,
        'status': ChatStatus.active.label,
      });
      final activeChat = Chat.fromMap({
        'id': 'chat-3',
        'chatId': 'chat-3',
        'bookingStatus': BookingStatus.confirmed.label,
        'status': ChatStatus.active.label,
      });

      expect(archivedChat.isReadOnly, isTrue);
      expect(completedChat.isReadOnly, isTrue);
      expect(activeChat.isReadOnly, isFalse);
    });
  });
}

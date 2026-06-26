import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/services/messaging.service.dart';
import 'package:lend/utilities/enums/message_type.enum.dart';

void main() {
  group('LNDMessagingService.buildUserMessageChatUpdateMaps', () {
    test('marks sender mirror read and recipient mirror unread', () {
      final updates = LNDMessagingService.buildUserMessageChatUpdateMaps(
        message: 'Hello',
        type: MessageType.text,
        fromUid: 'sender-1',
      );

      expect(updates.sender['lastMessage'], 'Hello');
      expect(updates.sender['lastMessageSenderId'], 'sender-1');
      expect(updates.sender['hasRead'], isTrue);
      expect(updates.recipient['lastMessage'], 'Hello');
      expect(updates.recipient['lastMessageSenderId'], 'sender-1');
      expect(updates.recipient['hasRead'], isFalse);
    });

    test('uses media placeholder for image and video messages', () {
      final imageUpdates = LNDMessagingService.buildUserMessageChatUpdateMaps(
        message: 'https://example.com/image.jpg',
        type: MessageType.image,
        fromUid: 'sender-1',
      );
      final videoUpdates = LNDMessagingService.buildUserMessageChatUpdateMaps(
        message: 'https://example.com/video.mp4',
        type: MessageType.video,
        fromUid: 'sender-1',
      );

      expect(imageUpdates.sender['lastMessage'], 'Sent a media');
      expect(imageUpdates.recipient['lastMessage'], 'Sent a media');
      expect(videoUpdates.sender['lastMessage'], 'Sent a media');
      expect(videoUpdates.recipient['lastMessage'], 'Sent a media');
    });
  });
}

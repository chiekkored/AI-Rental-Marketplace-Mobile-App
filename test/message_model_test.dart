import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/message.model.dart';
import 'package:lend/utilities/enums/message_type.enum.dart';

void main() {
  group('Message', () {
    test('parses and serializes visibleTo recipients', () {
      final message = Message.fromMap({
        'id': 'message-1',
        'text': 'Rate this booking',
        'senderId': '',
        'type': MessageType.rating.label,
        'visibleTo': ['renter-1'],
      });

      expect(message.visibleTo, ['renter-1']);
      expect(message.toMap()['visibleTo'], ['renter-1']);
    });
  });
}

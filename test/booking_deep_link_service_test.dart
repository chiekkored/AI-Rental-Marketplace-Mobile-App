import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/services/booking_deep_link.service.dart';

void main() {
  group('bookingIdFromDeepLink', () {
    test('reads a valid Lend booking link', () {
      expect(
        bookingIdFromDeepLink(Uri.parse('lend://booking/booking-123')),
        'booking-123',
      );
    });

    test('rejects malformed and unrelated links', () {
      expect(bookingIdFromDeepLink(Uri.parse('lend://booking')), isNull);
      expect(
        bookingIdFromDeepLink(Uri.parse('lend://booking/one/two')),
        isNull,
      );
      expect(
        bookingIdFromDeepLink(
          Uri.parse('https://getlend.dev/booking/booking-123'),
        ),
        isNull,
      );
      expect(
        bookingIdFromDeepLink(Uri.parse('lend://listing/booking-123')),
        isNull,
      );
    });
  });

  group('isBookingParticipant', () {
    test('allows the owner or renter only', () {
      expect(
        isBookingParticipant(
          ownerId: 'owner',
          renterId: 'renter',
          userId: 'owner',
        ),
        isTrue,
      );
      expect(
        isBookingParticipant(
          ownerId: 'owner',
          renterId: 'renter',
          userId: 'renter',
        ),
        isTrue,
      );
      expect(
        isBookingParticipant(
          ownerId: 'owner',
          renterId: 'renter',
          userId: 'other',
        ),
        isFalse,
      );
      expect(
        isBookingParticipant(ownerId: 'owner', renterId: 'renter', userId: ''),
        isFalse,
      );
    });
  });
}

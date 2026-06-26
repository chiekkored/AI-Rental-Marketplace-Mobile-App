import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/utilities/constants/collections.constant.dart';

class BookingDeepLinkException implements Exception {
  const BookingDeepLinkException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LNDBookingDeepLinkService {
  const LNDBookingDeepLinkService._();

  static Future<Booking> loadParticipantBooking({
    required String bookingId,
    required String userId,
  }) async {
    final normalizedBookingId = bookingId.trim();
    if (normalizedBookingId.isEmpty || userId.isEmpty) {
      throw const BookingDeepLinkException('Invalid booking link.');
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection(LNDCollections.bookings.name)
            .doc(normalizedBookingId)
            .get();
    final data = snapshot.data();
    if (data == null) {
      throw const BookingDeepLinkException(
        'This booking is no longer available.',
      );
    }

    final booking = Booking.fromMap(data);
    final isParticipant = isBookingParticipant(
      ownerId: booking.asset?.owner?.uid,
      renterId: booking.renter?.uid,
      userId: userId,
    );
    if (!isParticipant) {
      throw const BookingDeepLinkException(
        'You do not have access to this booking.',
      );
    }
    return booking;
  }
}

String? bookingIdFromDeepLink(Uri uri) {
  if (uri.scheme != 'lend' || uri.host != 'booking') return null;
  if (uri.pathSegments.length != 1) return null;
  final bookingId = uri.pathSegments.first.trim();
  return bookingId.isEmpty ? null : bookingId;
}

bool isBookingParticipant({
  required String? ownerId,
  required String? renterId,
  required String userId,
}) {
  if (userId.isEmpty) return false;
  return ownerId == userId || renterId == userId;
}

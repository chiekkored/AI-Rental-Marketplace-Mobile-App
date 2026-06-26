import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_either/dart_either.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class LNDBookingService {
  static final _db = FirebaseFirestore.instance;

  static Future<Either<bool, String>> createBookingRequest({
    required String assetId,
    required DateTime startDate,
    required DateTime endDate,
    required int totalPrice,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.createBookingRequest,
      );

      final result = await callable.call({
        'assetId': assetId,
        'startDateMs': LNDUtils.bookingDateMillisecondsSinceEpoch(startDate),
        'endDateMs': LNDUtils.bookingDateMillisecondsSinceEpoch(endDate),
        'totalPrice': totalPrice,
      });

      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true) {
        return const Left(true);
      }

      return Right(data['message'] ?? 'Booking request failed');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  static Future<Either<bool, String>> rateAndReviewBooking({
    required String chatId,
    required String assetId,
    required String bookingId,
    required int rating,
    required String review,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.submitBookingReview,
      );

      final result = await callable.call({
        'chatId': chatId,
        'assetId': assetId,
        'bookingId': bookingId,
        'rating': rating,
        'review': review,
      });

      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true) {
        return const Left(true);
      }

      return Right(data['message'] ?? 'Failed to submit review');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      LNDLogger.e(e.toString(), error: e, stackTrace: StackTrace.current);
      return Right('Error: $e');
    }
  }

  static Future<Either<Booking, String>> getUserBooking({
    required String userId,
    required String bookingId,
  }) async {
    final bookingDoc =
        await _db
            .collection(LNDCollections.users.name)
            .doc(userId)
            .collection(LNDCollections.bookings.name)
            .doc(bookingId)
            .get();

    if (bookingDoc.exists) {
      final bookingData = bookingDoc.data();

      if (bookingData != null) {
        return Left(Booking.fromMap(bookingData));
      } else {
        return const Right('Booking data is empty');
      }
    } else {
      return const Right('Booking does not exist');
    }
  }

  static Future<Either<Booking, String>> getAssetBooking({
    required String assetId,
    required String bookingId,
  }) async {
    final bookingDoc =
        await _db
            .collection(LNDCollections.assets.name)
            .doc(assetId)
            .collection(LNDCollections.bookings.name)
            .doc(bookingId)
            .get();

    if (bookingDoc.exists) {
      final bookingData = bookingDoc.data();

      if (bookingData != null) {
        return Left(Booking.fromMap(bookingData));
      } else {
        return const Right('Booking data is empty');
      }
    } else {
      return const Right('Booking does not exist');
    }
  }

  static Future<Either<bool, String>> confirmBookingViaFunction({
    required String bookingId,
    required String assetId,
    required String renterId,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        'confirmBooking',
      );

      final result = await callable.call({
        'bookingId': bookingId,
        'assetId': assetId,
        'renterId': renterId,
      });

      final data = Map<String, dynamic>.from(result.data);

      if (data['success'] == true) {
        if (data['phase2'] == 'enqueue_failed') {
          LNDLogger.e(
            data['warning']?.toString() ??
                'Booking confirmed but overlapping decline task was not queued',
            error: data,
            stackTrace: StackTrace.current,
          );
        }
        return const Left(true);
      }

      return Right(data['message'] ?? 'Confirmation failed');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  static Future<Either<Map<String, dynamic>?, String>> markBooking({
    required String token,
    bool debugBypass = false,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.verifyAndMark,
      );

      final result = await callable.call({
        'token': token,
        if (debugBypass) 'debugBypass': true,
      });

      return Left(Map<String, dynamic>.from(result.data));
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return const Right('Something went wrong');
    }
  }

  static Future<Either<Map<String, dynamic>, String>> verifyToken({
    required String token,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.verifyToken,
      );

      final result = await callable.call({'token': token});

      return Left(Map<String, dynamic>.from(result.data));
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return const Right('Something went wrong');
    }
  }

  static Future<Either<bool, String>> cancelBooking({
    required String assetId,
    required String bookingId,
    required String reason,
  }) async {
    return requestBookingCancellation(
      assetId: assetId,
      bookingId: bookingId,
      reason: reason,
    );
  }

  static Future<Either<bool, String>> requestBookingCancellation({
    required String assetId,
    required String bookingId,
    required String reason,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.requestBookingCancellation,
      );

      final result = await callable.call({
        'assetId': assetId,
        'bookingId': bookingId,
        'reason': reason,
      });

      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true) return const Left(true);

      return Right(data['message'] ?? 'Cancellation request failed');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  static Future<Either<LNDBookingDocumentLink, String>> getBookingDocument({
    required String bookingId,
    required LNDBookingDocumentType bookingDocumentType,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.getBookingDocument,
      );

      final result = await callable.call({
        'bookingId': bookingId,
        'documentType': bookingDocumentType.value,
      });

      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true) {
        return Left(LNDBookingDocumentLink.fromMap(data));
      }

      return Right(data['message'] ?? 'Unable to open booking document.');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  /// Check if asset is available for the requested date range
  /// Returns true if no overlapping active bookings exist
  static Future<Either<bool, String>> isAssetAvailable({
    required String assetId,
    required Timestamp startDate,
    required Timestamp endDate,
    bool blocksEndDate = false,
  }) async {
    try {
      final bookings = _db
          .collection(LNDCollections.assets.name)
          .doc(assetId)
          .collection(LNDCollections.bookings.name);
      final query =
          await (blocksEndDate
                  ? bookings
                      .where('startDate', isLessThanOrEqualTo: endDate)
                      .where('endDate', isGreaterThanOrEqualTo: startDate)
                  : bookings
                      .where('startDate', isLessThan: endDate)
                      .where('endDate', isGreaterThan: startDate))
              .where('status', whereIn: BookingStatus.dateBlockingLabels)
              .get();

      // Asset is available if no active bookings overlap
      return Left(query.docs.isEmpty);
    } catch (e) {
      return Right('Error checking availability: $e');
    }
  }
}

enum LNDBookingDocumentType {
  receipt('receipt'),
  earnings('earnings');

  const LNDBookingDocumentType(this.value);

  final String value;
}

class LNDBookingDocumentLink {
  const LNDBookingDocumentLink({
    required this.documentType,
    required this.documentNumber,
    required this.storagePath,
    required this.fileName,
    required this.contentType,
    required this.contentBase64,
  });

  final String documentType;
  final String documentNumber;
  final String storagePath;
  final String fileName;
  final String contentType;
  final String contentBase64;

  factory LNDBookingDocumentLink.fromMap(Map<String, dynamic> map) {
    return LNDBookingDocumentLink(
      documentType: map['documentType']?.toString() ?? '',
      documentNumber: map['documentNumber']?.toString() ?? '',
      storagePath: map['storagePath']?.toString() ?? '',
      fileName: map['fileName']?.toString() ?? '',
      contentType: map['contentType']?.toString() ?? '',
      contentBase64: map['contentBase64']?.toString() ?? '',
    );
  }
}

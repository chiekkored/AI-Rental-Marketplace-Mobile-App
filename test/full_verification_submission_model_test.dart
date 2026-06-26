import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/full_verification_submission.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/user.model.dart';

void main() {
  group('FullVerificationSubmission', () {
    test('serializes pending submission and user summary', () {
      final submission = FullVerificationSubmission.pending(
        id: 'submission-1',
        userId: 'user-1',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        dateOfBirth: DateTime(1995, 1, 1),
        email: 'juan@example.com',
        phone: '09171234567',
        location: Location(
          formattedAddress: 'Makati City',
          country: 'Philippines',
          countryShortName: 'PH',
          locality: 'Makati',
          administrativeAreaLevel1: 'Metro Manila',
          lat: 14.5547,
          lng: 121.0244,
          useSpecificLocation: true,
        ),
        diditSessionId: 'didit-session-1',
        diditWorkflowId: 'didit-workflow-1',
        diditStatus: 'Approved',
        diditDecision: {'document': 'approved'},
        diditStartedAt: DateTime(2026, 1, 1),
        diditCompletedAt: DateTime(2026, 1, 2),
      );

      expect(submission.toMap(), {
        'id': 'submission-1',
        'userId': 'user-1',
        'firstName': 'Juan',
        'lastName': 'Dela Cruz',
        'dateOfBirth': DateTime(1995, 1, 1),
        'email': 'juan@example.com',
        'phone': '09171234567',
        'address': 'Makati City',
        'location': {
          'country': 'Philippines',
          'countryShortName': 'PH',
          'locality': 'Makati',
          'administrativeAreaLevel1': 'Metro Manila',
          'formattedAddress': 'Makati City',
          'lat': 14.5547,
          'lng': 121.0244,
          'geohash': isA<String>(),
        },
        'photoUrl': null,
        'faceKycStatus': 'Approved',
        'verificationProvider': 'didit',
        'diditSessionId': 'didit-session-1',
        'diditWorkflowId': 'didit-workflow-1',
        'diditStatus': 'Approved',
        'diditDecision': {'document': 'approved'},
        'diditStartedAt': DateTime(2026, 1, 1),
        'diditCompletedAt': DateTime(2026, 1, 2),
        'status': 'Pending',
        'submittedAt': isA<FieldValue>(),
        'reviewedAt': null,
        'isRentalBusinessOwner': false,
      });
      expect(submission.toUserSummary().toMap(), {
        'status': 'Pending',
        'activeSubmissionId': 'submission-1',
        'submittedAt': isA<FieldValue>(),
        'reviewedAt': null,
      });
    });

    test('UserModel handles missing and present full verification summary', () {
      final userWithoutSummary = UserModel.fromMap({
        'uid': 'user-1',
        'verified': 'None',
      });

      expect(userWithoutSummary.fullVerification, isNull);

      final userWithSummary = UserModel.fromMap({
        'uid': 'user-1',
        'verified': 'None',
        'fullVerification': {
          'status': 'Pending',
          'activeSubmissionId': 'submission-1',
        },
      });

      expect(userWithSummary.fullVerification?.status, 'Pending');
      expect(
        userWithSummary.fullVerification?.activeSubmissionId,
        'submission-1',
      );
    });

    test('UserModel derives pending full verification status', () {
      final pendingUser = UserModel.fromMap({
        'uid': 'user-1',
        'verified': 'Basic',
        'fullVerification': {'status': 'Pending'},
      });
      final approvedUser = UserModel.fromMap({
        'uid': 'user-2',
        'verified': 'Full',
        'fullVerification': {'status': 'Approved'},
      });
      final userWithoutSummary = UserModel.fromMap({
        'uid': 'user-3',
        'verified': 'Basic',
      });

      expect(pendingUser.hasPendingFullVerification, isTrue);
      expect(approvedUser.hasPendingFullVerification, isFalse);
      expect(userWithoutSummary.hasPendingFullVerification, isFalse);
    });

    test('serializes account information update metadata when provided', () {
      final submission = FullVerificationSubmission.pending(
        id: 'submission-1',
        userId: 'user-1',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        dateOfBirth: DateTime(1995, 1, 1),
        email: 'juan@example.com',
        phone: '09171234567',
        location: Location(formattedAddress: 'Makati City'),
        requestType: 'account_information_update',
        updatedFields: const ['email'],
      );

      expect(submission.toMap()['requestType'], 'account_information_update');
      expect(submission.toMap()['updatedFields'], ['email']);
    });

    test('serializes upgrade verification request type when provided', () {
      final submission = FullVerificationSubmission.pending(
        id: 'submission-1',
        userId: 'user-1',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        dateOfBirth: DateTime(1995, 1, 1),
        email: 'juan@example.com',
        phone: '09171234567',
        location: Location(formattedAddress: 'Makati City'),
        requestType: 'upgrade_verification',
      );

      expect(submission.toMap()['requestType'], 'upgrade_verification');
      expect(submission.toMap().containsKey('updatedFields'), isFalse);
    });

    test('serializes rental business owner declaration', () {
      final submission = FullVerificationSubmission.pending(
        id: 'submission-1',
        userId: 'user-1',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        dateOfBirth: DateTime(1995, 1, 1),
        email: 'juan@example.com',
        phone: '09171234567',
        location: Location(formattedAddress: 'Makati City'),
        requestType: 'upgrade_verification',
        isRentalBusinessOwner: true,
      );

      expect(submission.toMap()['isRentalBusinessOwner'], isTrue);
      expect(
        FullVerificationSubmission.fromMap(
          submission.toMap(),
        ).isRentalBusinessOwner,
        isTrue,
      );
    });

    test('parses rejection reason fields', () {
      final submission = FullVerificationSubmission.fromMap({
        'id': 'submission-1',
        'userId': 'user-1',
        'firstName': 'Juan',
        'lastName': 'Dela Cruz',
        'dateOfBirth': Timestamp.fromDate(DateTime(1995, 1, 1)),
        'email': 'juan@example.com',
        'phone': '09171234567',
        'location': Location(formattedAddress: 'Makati City').toMap(),
        'status': 'Rejected',
        'submittedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'reviewedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
        'rejectionReasonCode': 'document_issue',
        'rejectionReason': 'The submitted document could not be verified.',
      });

      expect(submission.status, 'Rejected');
      expect(submission.rejectionReasonCode, 'document_issue');
      expect(
        submission.rejectionReason,
        'The submitted document could not be verified.',
      );
      expect(submission.toMap()['rejectionReasonCode'], 'document_issue');
      expect(
        submission.toMap()['rejectionReason'],
        'The submitted document could not be verified.',
      );
    });
  });
}

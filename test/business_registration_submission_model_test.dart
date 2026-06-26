import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/business_registration_submission.model.dart';

void main() {
  test('BusinessRegistrationSubmission parses rejection fields', () {
    final submission = BusinessRegistrationSubmission.fromMap({
      'ownerId': 'owner-1',
      'status': 'Rejected',
      'documents': {
        'dti': 'users/owner-1/businessRegistration/dti.jpg',
        'bir': 'users/owner-1/businessRegistration/bir.jpg',
      },
      'taxInvoiceAcknowledged': true,
      'rejectionReason': 'One or more documents are unclear or unreadable.',
      'rejectionReasonCode': 'document_unreadable',
      'verificationSubmissionId': 'verification-1',
    });

    expect(submission.status, 'Rejected');
    expect(
      submission.rejectionReason,
      'One or more documents are unclear or unreadable.',
    );
    expect(submission.rejectionReasonCode, 'document_unreadable');
    expect(submission.verificationSubmissionId, 'verification-1');
    expect(
      submission.toMap()['rejectionReason'],
      'One or more documents are unclear or unreadable.',
    );
    expect(submission.toMap()['rejectionReasonCode'], 'document_unreadable');
    expect(submission.toMap()['verificationSubmissionId'], 'verification-1');
  });
}

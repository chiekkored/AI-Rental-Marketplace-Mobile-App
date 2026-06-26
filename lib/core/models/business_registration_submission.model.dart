import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessRegistrationDocuments {
  final String dti;
  final String bir;
  final String? mayorBusinessPermit;

  const BusinessRegistrationDocuments({
    required this.dti,
    required this.bir,
    this.mayorBusinessPermit,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dti': dti,
      'bir': bir,
      if (mayorBusinessPermit != null && mayorBusinessPermit!.trim().isNotEmpty)
        'mayorBusinessPermit': mayorBusinessPermit,
    };
  }

  factory BusinessRegistrationDocuments.fromMap(Map<String, dynamic> map) {
    return BusinessRegistrationDocuments(
      dti: map['dti'] as String? ?? '',
      bir: map['bir'] as String? ?? '',
      mayorBusinessPermit: map['mayorBusinessPermit'] as String?,
    );
  }
}

class BusinessRegistrationSubmission {
  final String ownerId;
  final String status;
  final BusinessRegistrationDocuments documents;
  final bool taxInvoiceAcknowledged;
  final String? businessName;
  final String? businessType;
  final String? businessAddress;
  final String? rejectionReason;
  final String? rejectionReasonCode;
  final String? requestedListingReviewSubmissionId;
  final String? verificationSubmissionId;
  final dynamic submittedAt;
  final dynamic reviewedAt;
  final dynamic updatedAt;

  const BusinessRegistrationSubmission({
    required this.ownerId,
    this.status = 'Pending',
    required this.documents,
    required this.taxInvoiceAcknowledged,
    this.businessName,
    this.businessType,
    this.businessAddress,
    this.rejectionReason,
    this.rejectionReasonCode,
    this.requestedListingReviewSubmissionId,
    this.verificationSubmissionId,
    this.submittedAt,
    this.reviewedAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ownerId': ownerId,
      'status': status,
      'documents': documents.toMap(),
      'taxInvoiceAcknowledged': taxInvoiceAcknowledged,
      if (businessName != null && businessName!.trim().isNotEmpty)
        'businessName': businessName,
      if (businessType != null && businessType!.trim().isNotEmpty)
        'businessType': businessType,
      if (businessAddress != null && businessAddress!.trim().isNotEmpty)
        'businessAddress': businessAddress,
      if (rejectionReason != null && rejectionReason!.trim().isNotEmpty)
        'rejectionReason': rejectionReason,
      if (rejectionReasonCode != null && rejectionReasonCode!.trim().isNotEmpty)
        'rejectionReasonCode': rejectionReasonCode,
      'requestedListingReviewSubmissionId': requestedListingReviewSubmissionId,
      if (verificationSubmissionId != null &&
          verificationSubmissionId!.trim().isNotEmpty)
        'verificationSubmissionId': verificationSubmissionId,
      'submittedAt': submittedAt ?? FieldValue.serverTimestamp(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory BusinessRegistrationSubmission.fromMap(Map<String, dynamic> map) {
    return BusinessRegistrationSubmission(
      ownerId: map['ownerId'] as String? ?? '',
      status: map['status'] as String? ?? 'Pending',
      documents:
          map['documents'] != null
              ? BusinessRegistrationDocuments.fromMap(
                Map<String, dynamic>.from(map['documents'] as Map),
              )
              : const BusinessRegistrationDocuments(dti: '', bir: ''),
      taxInvoiceAcknowledged: map['taxInvoiceAcknowledged'] == true,
      businessName: map['businessName'] as String?,
      businessType: map['businessType'] as String?,
      businessAddress: map['businessAddress'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      rejectionReasonCode: map['rejectionReasonCode'] as String?,
      requestedListingReviewSubmissionId:
          map['requestedListingReviewSubmissionId'] as String?,
      verificationSubmissionId: map['verificationSubmissionId'] as String?,
      submittedAt: map['submittedAt'],
      reviewedAt: map['reviewedAt'],
      updatedAt: map['updatedAt'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/location.model.dart';

class UserFullVerificationSummary {
  final String? status;
  final String? activeSubmissionId;
  final dynamic submittedAt;
  final dynamic reviewedAt;

  const UserFullVerificationSummary({
    this.status,
    this.activeSubmissionId,
    this.submittedAt,
    this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'activeSubmissionId': activeSubmissionId,
      'submittedAt': submittedAt,
      'reviewedAt': reviewedAt,
    };
  }

  factory UserFullVerificationSummary.fromMap(Map<String, dynamic> map) {
    return UserFullVerificationSummary(
      status: map['status'] as String?,
      activeSubmissionId: map['activeSubmissionId'] as String?,
      submittedAt: map['submittedAt'],
      reviewedAt: map['reviewedAt'],
    );
  }

  @override
  String toString() {
    return 'UserFullVerificationSummary(status: $status, activeSubmissionId: $activeSubmissionId, submittedAt: $submittedAt, reviewedAt: $reviewedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserFullVerificationSummary) return false;

    return other.status == status &&
        other.activeSubmissionId == activeSubmissionId &&
        other.submittedAt == submittedAt &&
        other.reviewedAt == reviewedAt;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        activeSubmissionId.hashCode ^
        submittedAt.hashCode ^
        reviewedAt.hashCode;
  }
}

class UserBusinessRegistrationSummary {
  final bool visible;
  final bool required;
  final String status;
  final List<String> visibilityReasons;
  final String? businessName;
  final String? businessType;
  final String? businessAddress;
  final String? requestedListingReviewSubmissionId;
  final dynamic requestedAt;
  final dynamic reviewedAt;
  final Map<String, dynamic>? reviewedBy;
  final dynamic submittedAt;
  final dynamic updatedAt;

  const UserBusinessRegistrationSummary({
    this.visible = false,
    this.required = false,
    this.status = 'Not Submitted',
    this.visibilityReasons = const <String>[],
    this.businessName,
    this.businessType,
    this.businessAddress,
    this.requestedListingReviewSubmissionId,
    this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.submittedAt,
    this.updatedAt,
  });

  bool get isVisible => visible;
  bool get isRequired => required;
  bool get isSubmitted => status == 'Submitted';
  bool get isApproved => status == 'Approved';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'visible': visible,
      'required': required,
      'status': status,
      'visibilityReasons': visibilityReasons,
      'businessName': businessName,
      'businessType': businessType,
      'businessAddress': businessAddress,
      'requestedListingReviewSubmissionId': requestedListingReviewSubmissionId,
      'requestedAt': requestedAt,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
      'submittedAt': submittedAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserBusinessRegistrationSummary.fromMap(Map<String, dynamic> map) {
    return UserBusinessRegistrationSummary(
      visible: map['visible'] == true,
      required: map['required'] == true,
      status: map['status'] as String? ?? 'Not Submitted',
      visibilityReasons:
          map['visibilityReasons'] is List
              ? List<String>.from(map['visibilityReasons'] as List)
              : const <String>[],
      businessName: map['businessName'] as String?,
      businessType: map['businessType'] as String?,
      businessAddress: map['businessAddress'] as String?,
      requestedListingReviewSubmissionId:
          map['requestedListingReviewSubmissionId'] as String?,
      requestedAt: map['requestedAt'],
      reviewedAt: map['reviewedAt'],
      reviewedBy:
          map['reviewedBy'] is Map
              ? Map<String, dynamic>.from(map['reviewedBy'] as Map)
              : null,
      submittedAt: map['submittedAt'],
      updatedAt: map['updatedAt'],
    );
  }

  @override
  String toString() {
    return 'UserBusinessRegistrationSummary(visible: $visible, required: $required, status: $status, visibilityReasons: $visibilityReasons, businessName: $businessName, businessType: $businessType, businessAddress: $businessAddress, requestedListingReviewSubmissionId: $requestedListingReviewSubmissionId, requestedAt: $requestedAt, reviewedAt: $reviewedAt, submittedAt: $submittedAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserBusinessRegistrationSummary) return false;

    return other.visible == visible &&
        other.required == required &&
        other.status == status &&
        other.visibilityReasons.toString() == visibilityReasons.toString() &&
        other.businessName == businessName &&
        other.businessType == businessType &&
        other.businessAddress == businessAddress &&
        other.requestedListingReviewSubmissionId ==
            requestedListingReviewSubmissionId &&
        other.requestedAt == requestedAt &&
        other.reviewedAt == reviewedAt &&
        other.reviewedBy.toString() == reviewedBy.toString() &&
        other.submittedAt == submittedAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return visible.hashCode ^
        required.hashCode ^
        status.hashCode ^
        visibilityReasons.hashCode ^
        businessName.hashCode ^
        businessType.hashCode ^
        businessAddress.hashCode ^
        requestedListingReviewSubmissionId.hashCode ^
        requestedAt.hashCode ^
        reviewedAt.hashCode ^
        reviewedBy.hashCode ^
        submittedAt.hashCode ^
        updatedAt.hashCode;
  }
}

class FullVerificationSubmission {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String email;
  final String phone;
  final Location location;
  final String? photoUrl;
  final String faceKycStatus;
  final String verificationProvider;
  final String? diditSessionId;
  final String? diditWorkflowId;
  final String? diditStatus;
  final Map<String, dynamic>? diditDecision;
  final dynamic diditStartedAt;
  final dynamic diditCompletedAt;
  final String status;
  final dynamic submittedAt;
  final dynamic reviewedAt;
  final String? rejectionReasonCode;
  final String? rejectionReason;
  final String? requestType;
  final List<String> updatedFields;
  final bool isRentalBusinessOwner;

  const FullVerificationSubmission({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    required this.location,
    this.photoUrl,
    required this.faceKycStatus,
    this.verificationProvider = 'didit',
    this.diditSessionId,
    this.diditWorkflowId,
    this.diditStatus,
    this.diditDecision,
    this.diditStartedAt,
    this.diditCompletedAt,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReasonCode,
    this.rejectionReason,
    this.requestType,
    this.updatedFields = const <String>[],
    this.isRentalBusinessOwner = false,
  });

  factory FullVerificationSubmission.pending({
    required String id,
    required String userId,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String email,
    required String phone,
    required Location location,
    String? photoUrl,
    String? diditSessionId,
    String? diditWorkflowId,
    String? diditStatus,
    Map<String, dynamic>? diditDecision,
    dynamic diditStartedAt,
    dynamic diditCompletedAt,
    String? requestType,
    List<String> updatedFields = const <String>[],
    bool isRentalBusinessOwner = false,
  }) {
    return FullVerificationSubmission(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      email: email,
      phone: phone,
      location: location,
      photoUrl: photoUrl,
      faceKycStatus: diditStatus ?? 'Submitted',
      diditSessionId: diditSessionId,
      diditWorkflowId: diditWorkflowId,
      diditStatus: diditStatus,
      diditDecision: diditDecision,
      diditStartedAt: diditStartedAt,
      diditCompletedAt: diditCompletedAt,
      status: 'Pending',
      submittedAt: FieldValue.serverTimestamp(),
      requestType: requestType,
      updatedFields: updatedFields,
      isRentalBusinessOwner: isRentalBusinessOwner,
    );
  }

  UserFullVerificationSummary toUserSummary() {
    return UserFullVerificationSummary(
      status: status,
      activeSubmissionId: id,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt,
    );
  }

  Map<String, dynamic> toUserUpdateMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'phone': phone,
      'location': location.toMap(),
      if (photoUrl != null && photoUrl!.trim().isNotEmpty) 'photoUrl': photoUrl,
      'fullVerification': toUserSummary().toMap(),
      'userMetadataVersion': FieldValue.increment(1),
    };
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'phone': phone,
      'address': location.description,
      'location': location.toMap(),
      'photoUrl': photoUrl,
      'faceKycStatus': faceKycStatus,
      'verificationProvider': verificationProvider,
      'diditSessionId': diditSessionId,
      'diditWorkflowId': diditWorkflowId,
      'diditStatus': diditStatus,
      'diditDecision': diditDecision,
      'diditStartedAt': diditStartedAt,
      'diditCompletedAt': diditCompletedAt,
      'status': status,
      'submittedAt': submittedAt,
      'reviewedAt': reviewedAt,
      if (rejectionReasonCode != null)
        'rejectionReasonCode': rejectionReasonCode,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (requestType != null) 'requestType': requestType,
      if (updatedFields.isNotEmpty) 'updatedFields': updatedFields,
      'isRentalBusinessOwner': isRentalBusinessOwner,
    };
  }

  factory FullVerificationSubmission.fromMap(Map<String, dynamic> map) {
    return FullVerificationSubmission(
      id: map['id'] as String,
      userId: map['userId'] as String,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      dateOfBirth:
          map['dateOfBirth'] is Timestamp
              ? (map['dateOfBirth'] as Timestamp).toDate()
              : DateTime.tryParse(map['dateOfBirth']?.toString() ?? '') ??
                  DateTime(1900),
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String,
      location:
          map['location'] != null
              ? Location.fromMap(map['location'] as Map<String, dynamic>)
              : Location(description: map['address'] as String? ?? ''),
      photoUrl: map['photoUrl'] as String?,
      faceKycStatus: map['faceKycStatus'] as String? ?? 'Submitted',
      verificationProvider: map['verificationProvider'] as String? ?? 'didit',
      diditSessionId: map['diditSessionId'] as String?,
      diditWorkflowId: map['diditWorkflowId'] as String?,
      diditStatus: map['diditStatus'] as String?,
      diditDecision:
          map['diditDecision'] == null
              ? null
              : Map<String, dynamic>.from(
                map['diditDecision'] as Map<dynamic, dynamic>,
              ),
      diditStartedAt: map['diditStartedAt'],
      diditCompletedAt: map['diditCompletedAt'],
      status: map['status'] as String? ?? 'Pending',
      submittedAt: map['submittedAt'],
      reviewedAt: map['reviewedAt'],
      rejectionReasonCode: map['rejectionReasonCode'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      requestType: map['requestType'] as String?,
      updatedFields:
          map['updatedFields'] is List
              ? List<String>.from(map['updatedFields'] as List)
              : const <String>[],
      isRentalBusinessOwner: map['isRentalBusinessOwner'] == true,
    );
  }
}

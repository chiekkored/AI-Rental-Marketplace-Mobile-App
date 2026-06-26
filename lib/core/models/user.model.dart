// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/full_verification_submission.model.dart';
import 'package:lend/core/models/location.model.dart';

import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/enums/user_status.enum.dart';

class UserModel {
  String? uid;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  Location? location;
  String? photoUrl;
  Timestamp? createdAt;
  String? email;
  String? phone;
  String? type;
  VerificationLevel? verified;
  UserFullVerificationSummary? fullVerification;
  UserBusinessRegistrationSummary? businessRegistration;
  UserFoundingOwnerSummary? foundingOwner;
  UserStatus? status;
  bool? isFoundingOwner;
  bool? useBusinessNameForListingOwnerName;
  int? userMetadataVersion;
  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.location,
    required this.photoUrl,
    required this.createdAt,
    required this.email,
    required this.phone,
    required this.type,
    required this.verified,
    required this.status,
    this.fullVerification,
    this.businessRegistration,
    this.foundingOwner,
    this.isFoundingOwner = false,
    this.useBusinessNameForListingOwnerName = false,
    this.userMetadataVersion = 1,
  });

  bool get hasPendingFullVerification => fullVerification?.status == 'Pending';
  bool get isBusinessRegistrationVisible =>
      businessRegistration?.visible == true;
  bool get isBusinessRegistrationRequired =>
      businessRegistration?.required == true;
  bool get hasApprovedBusinessName =>
      businessRegistration?.isApproved == true &&
      (businessRegistration?.businessName?.trim().isNotEmpty ?? false);
  bool get isFoundingOwnerAccount =>
      isFoundingOwner == true || foundingOwner != null;
  String? get approvedBusinessName {
    final businessName = businessRegistration?.businessName?.trim();
    if (businessRegistration?.isApproved != true ||
        businessName == null ||
        businessName.isEmpty) {
      return null;
    }
    return businessName;
  }

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    Location? location,
    String? photoUrl,
    Timestamp? createdAt,
    String? email,
    String? phone,
    String? type,
    VerificationLevel? verified,
    UserFullVerificationSummary? fullVerification,
    UserBusinessRegistrationSummary? businessRegistration,
    UserFoundingOwnerSummary? foundingOwner,
    UserStatus? status,
    bool? isFoundingOwner,
    bool? useBusinessNameForListingOwnerName,
    int? userMetadataVersion,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      verified: verified ?? this.verified,
      fullVerification: fullVerification ?? this.fullVerification,
      businessRegistration: businessRegistration ?? this.businessRegistration,
      foundingOwner: foundingOwner ?? this.foundingOwner,
      status: status ?? this.status,
      isFoundingOwner: isFoundingOwner ?? this.isFoundingOwner,
      useBusinessNameForListingOwnerName:
          useBusinessNameForListingOwnerName ??
          this.useBusinessNameForListingOwnerName,
      userMetadataVersion: userMetadataVersion ?? this.userMetadataVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'location': location,
      'photoUrl': photoUrl,
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds)
              : null,
      'email': email,
      'phone': phone,
      'type': type,
      'verified': verified?.label ?? VerificationLevel.none.label,
      'status': status?.label ?? UserStatus.active.label,
      'fullVerification': fullVerification?.toMap(),
      'businessRegistration': businessRegistration?.toMap(),
      'foundingOwner': foundingOwner?.toMap(),
      'isFoundingOwner': isFoundingOwner ?? false,
      'useBusinessNameForListingOwnerName':
          useBusinessNameForListingOwnerName ?? false,
      'userMetadataVersion': userMetadataVersion,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] != null ? map['uid'] as String : null,
      firstName: map['firstName'] != null ? map['firstName'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      dateOfBirth:
          map['dateOfBirth'] != null
              ? (map['dateOfBirth'] as Timestamp).toDate()
              : null,
      location:
          map['location'] != null
              ? Location.fromMap(map['location'] as Map<String, dynamic>)
              : null,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      createdAt:
          map['createdAt'] != null
              ? map['createdAt'] is Timestamp
                  ? map['createdAt'] as Timestamp
                  : Timestamp(
                    map['createdAt']['_seconds'],
                    map['createdAt']['_nanoseconds'],
                  )
              : null,
      email: map['email'] != null ? map['email'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      verified: VerificationLevel.fromLabel(map['verified'] as String?),
      status: UserStatus.fromLabel(map['status'] as String?),
      fullVerification:
          map['fullVerification'] != null
              ? UserFullVerificationSummary.fromMap(
                map['fullVerification'] as Map<String, dynamic>,
              )
              : null,
      businessRegistration:
          map['businessRegistration'] != null
              ? UserBusinessRegistrationSummary.fromMap(
                map['businessRegistration'] as Map<String, dynamic>,
              )
              : null,
      foundingOwner:
          map['foundingOwner'] != null
              ? UserFoundingOwnerSummary.fromMap(
                Map<String, dynamic>.from(map['foundingOwner'] as Map),
              )
              : map['foundingOwnerInvite'] != null
              ? UserFoundingOwnerSummary.fromMap(
                Map<String, dynamic>.from(map['foundingOwnerInvite'] as Map),
              )
              : null,
      isFoundingOwner: map['isFoundingOwner'] == true,
      useBusinessNameForListingOwnerName:
          map['useBusinessNameForListingOwnerName'] == true,
      userMetadataVersion: map['userMetadataVersion'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, location: $location, photoUrl: $photoUrl, createdAt: $createdAt, email: $email, phone: $phone, type: $type, verified: $verified, status: $status, fullVerification: $fullVerification, businessRegistration: $businessRegistration, foundingOwner: $foundingOwner, isFoundingOwner: $isFoundingOwner, useBusinessNameForListingOwnerName: $useBusinessNameForListingOwnerName, userMetadataVersion: $userMetadataVersion)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.dateOfBirth == dateOfBirth &&
        other.location == location &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.email == email &&
        other.phone == phone &&
        other.type == type &&
        other.verified == verified &&
        other.status == status &&
        other.fullVerification == fullVerification &&
        other.businessRegistration == businessRegistration &&
        other.foundingOwner == foundingOwner &&
        other.isFoundingOwner == isFoundingOwner &&
        other.useBusinessNameForListingOwnerName ==
            useBusinessNameForListingOwnerName &&
        other.userMetadataVersion == userMetadataVersion;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        dateOfBirth.hashCode ^
        location.hashCode ^
        photoUrl.hashCode ^
        createdAt.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        type.hashCode ^
        verified.hashCode ^
        status.hashCode ^
        fullVerification.hashCode ^
        businessRegistration.hashCode ^
        foundingOwner.hashCode ^
        isFoundingOwner.hashCode ^
        useBusinessNameForListingOwnerName.hashCode ^
        userMetadataVersion.hashCode;
  }
}

class UserFoundingOwnerSummary {
  final String? inviteId;
  final String? inviteSlug;
  final String? inviteCode;
  final String? displayName;
  final Timestamp? claimedAt;
  final String? targetCategory;
  final String? targetLocation;
  final List<String> perks;

  const UserFoundingOwnerSummary({
    this.inviteId,
    this.inviteSlug,
    this.inviteCode,
    this.displayName,
    this.claimedAt,
    this.targetCategory,
    this.targetLocation,
    this.perks = const [],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'inviteId': inviteId,
      'inviteSlug': inviteSlug,
      'inviteCode': inviteCode,
      'displayName': displayName,
      'claimedAt': claimedAt,
      'targetCategory': targetCategory,
      'targetLocation': targetLocation,
      'perks': perks,
    };
  }

  factory UserFoundingOwnerSummary.fromMap(Map<String, dynamic> map) {
    return UserFoundingOwnerSummary(
      inviteId: map['inviteId'] as String?,
      inviteSlug: (map['inviteSlug'] ?? map['slug']) as String?,
      inviteCode: (map['inviteCode'] ?? map['code']) as String?,
      displayName: map['displayName'] as String?,
      claimedAt: _timestampFromValue(map['claimedAt']),
      targetCategory: map['targetCategory'] as String?,
      targetLocation: map['targetLocation'] as String?,
      perks:
          map['perks'] is List
              ? List<String>.from((map['perks'] as List).whereType<String>())
              : const [],
    );
  }

  @override
  String toString() {
    return 'UserFoundingOwnerSummary(inviteId: $inviteId, inviteSlug: $inviteSlug, inviteCode: $inviteCode, displayName: $displayName, claimedAt: $claimedAt, targetCategory: $targetCategory, targetLocation: $targetLocation, perks: $perks)';
  }

  @override
  bool operator ==(covariant UserFoundingOwnerSummary other) {
    if (identical(this, other)) return true;

    return other.inviteId == inviteId &&
        other.inviteSlug == inviteSlug &&
        other.inviteCode == inviteCode &&
        other.displayName == displayName &&
        other.claimedAt == claimedAt &&
        other.targetCategory == targetCategory &&
        other.targetLocation == targetLocation &&
        other.perks.toString() == perks.toString();
  }

  @override
  int get hashCode {
    return inviteId.hashCode ^
        inviteSlug.hashCode ^
        inviteCode.hashCode ^
        displayName.hashCode ^
        claimedAt.hashCode ^
        targetCategory.hashCode ^
        targetLocation.hashCode ^
        perks.hashCode;
  }
}

Timestamp? _timestampFromValue(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value;
  if (value is Map &&
      value['_seconds'] is int &&
      value['_nanoseconds'] is int) {
    return Timestamp(value['_seconds'] as int, value['_nanoseconds'] as int);
  }
  return null;
}

import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/enums/user_status.enum.dart';

class SimpleUserModel {
  String? uid;
  String? firstName;
  String? lastName;
  String? displayName;
  String? photoUrl;
  VerificationLevel? verified;
  UserStatus? status;
  bool? isFoundingOwner;
  int? userMetadataVersion;
  SimpleUserModel({
    this.uid,
    this.firstName,
    this.lastName,
    this.displayName,
    this.photoUrl,
    this.verified = VerificationLevel.none,
    this.status = UserStatus.active,
    this.isFoundingOwner = false,
    this.userMetadataVersion = 1,
  });
  SimpleUserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    firstName = map['firstName'];
    lastName = map['lastName'];
    displayName = map['displayName'];
    photoUrl = map['photoUrl'];
    verified = VerificationLevel.fromLabel(map['verified']);
    status = UserStatus.fromLabel(map['status'] as String?);
    isFoundingOwner =
        map['isFoundingOwner'] == true ||
        map['foundingOwner'] != null ||
        map['foundingOwnerInvite'] != null;
    userMetadataVersion = map['userMetadataVersion'] ?? 1;
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'verified': verified?.label ?? VerificationLevel.none.label,
      'status': status?.label ?? UserStatus.active.label,
      'isFoundingOwner': isFoundingOwner ?? false,
      'userMetadataVersion': userMetadataVersion,
    };
  }

  SimpleUserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? displayName,
    String? photoUrl,
    VerificationLevel? verified,
    UserStatus? status,
    bool? isFoundingOwner,
    int? userMetadataVersion,
  }) {
    return SimpleUserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      verified: verified ?? this.verified,
      status: status ?? this.status,
      isFoundingOwner: isFoundingOwner ?? this.isFoundingOwner,
      userMetadataVersion: userMetadataVersion ?? this.userMetadataVersion,
    );
  }

  String get getName {
    if (status == UserStatus.deactivated) return 'Deactivated User';
    if (status == UserStatus.deleted) return 'Deleted User';
    final preferredName = (displayName ?? '').trim();
    if (preferredName.isNotEmpty) return preferredName;
    return (firstName ?? '').trim();
  }

  bool get hasDisplayName => (displayName ?? '').trim().isNotEmpty;

  bool get isFoundingOwnerAccount => isFoundingOwner == true;

  @override
  String toString() {
    return 'SimpleUserModel(uid: $uid, firstName: $firstName, lastName: $lastName, displayName: $displayName, photoUrl: $photoUrl, verified: $verified, status: $status, isFoundingOwner: $isFoundingOwner, userMetadataVersion: $userMetadataVersion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SimpleUserModel) return false;

    return other.uid == uid &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.verified == verified &&
        other.status == status &&
        other.isFoundingOwner == isFoundingOwner &&
        other.userMetadataVersion == userMetadataVersion;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode ^
        verified.hashCode ^
        status.hashCode ^
        isFoundingOwner.hashCode ^
        userMetadataVersion.hashCode;
  }
}

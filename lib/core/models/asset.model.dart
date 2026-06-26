// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:lend/core/models/availability.model.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/utilities/extensions/timestamp.extension.dart';

class Asset {
  String id;
  String? ownerId;
  SimpleUserModel? owner;
  String? title;
  String? description;
  String? categoryId;
  String? categoryName;
  String? subcategoryId;
  String? subcategoryName;
  ListingDetailsModel listingDetails;
  Rates? rates;
  Location? location;
  List<String>? images;
  List<String>? showcase;
  List<String>? inclusions;
  String? ownerInstructions;
  bool blocksEndDate;
  Timestamp? createdAt;
  String? status;
  bool isDeleted;
  double? averageRating;
  int? reviewCount;
  SecurityDeposit securityDeposit;
  Asset({
    required this.id,
    this.ownerId,
    this.owner,
    this.title,
    this.description,
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.listingDetails = const ListingDetailsModel.empty(),
    this.rates,
    this.location,
    this.images,
    this.showcase,
    this.inclusions,
    this.ownerInstructions,
    this.blocksEndDate = false,
    this.createdAt,
    this.status,
    this.isDeleted = false,
    this.averageRating,
    this.reviewCount,
    this.securityDeposit = const SecurityDeposit.disabled(),
  });

  Asset copyWith({
    String? id,
    String? ownerId,
    SimpleUserModel? owner,
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    String? subcategoryId,
    String? subcategoryName,
    ListingDetailsModel? listingDetails,
    Rates? rates,
    List<Availability>? availability,
    Location? location,
    List<String>? images,
    List<String>? showcase,
    List<String>? inclusions,
    String? ownerInstructions,
    bool? blocksEndDate,
    Timestamp? createdAt,
    String? status,
    bool? isDeleted,
    double? averageRating,
    int? reviewCount,
    SecurityDeposit? securityDeposit,
  }) {
    return Asset(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      owner: owner ?? this.owner,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      listingDetails: listingDetails ?? this.listingDetails,
      rates: rates ?? this.rates,
      location: location ?? this.location,
      images: images ?? this.images,
      showcase: showcase ?? this.showcase,
      inclusions: inclusions ?? this.inclusions,
      ownerInstructions: ownerInstructions ?? this.ownerInstructions,
      blocksEndDate: blocksEndDate ?? this.blocksEndDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      securityDeposit: securityDeposit ?? this.securityDeposit,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'owner': owner?.toMap(),
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      ...listingDetails.toMap(),
      'rates': rates?.toMap(),
      'location': location?.toMap(),
      'images': images,
      'showcase': showcase,
      'inclusions': inclusions,
      'ownerInstructions': ownerInstructions,
      'blocksEndDate': blocksEndDate,
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds).toMap()
              : null,
      'status': status,
      'isDeleted': isDeleted,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'securityDeposit': securityDeposit.toMap(),
    }..removeWhere((key, value) => value == null);
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'],
      ownerId: map['ownerId'] != null ? map['ownerId'] as String : null,
      owner:
          map['owner'] != null
              ? SimpleUserModel.fromMap(map['owner'] as Map<String, dynamic>)
              : null,
      title: map['title'] != null ? map['title'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      categoryId:
          map['categoryId'] != null ? map['categoryId'] as String : null,
      categoryName:
          map['categoryName'] != null ? map['categoryName'] as String : null,
      subcategoryId:
          map['subcategoryId'] != null ? map['subcategoryId'] as String : null,
      subcategoryName:
          map['subcategoryName'] != null
              ? map['subcategoryName'] as String
              : null,
      listingDetails: ListingDetailsModel.fromMap(map),
      rates:
          map['rates'] != null
              ? Rates.fromMap(map['rates'] as Map<String, dynamic>)
              : null,
      location:
          map['location'] != null
              ? Location.fromMap(map['location'] as Map<String, dynamic>)
              : null,
      images: map['images'] != null ? List<String>.from((map['images'])) : null,
      showcase:
          map['showcase'] != null ? List<String>.from((map['showcase'])) : null,
      inclusions:
          map['inclusions'] != null
              ? List<String>.from((map['inclusions']))
              : null,
      ownerInstructions:
          map['ownerInstructions'] != null
              ? map['ownerInstructions'] as String
              : null,
      blocksEndDate:
          map['blocksEndDate'] != null ? map['blocksEndDate'] as bool : false,
      createdAt:
          map['createdAt'] != null
              ? map['createdAt'] is Timestamp
                  ? map['createdAt'] as Timestamp
                  : Timestamp(
                    map['createdAt']['_seconds'],
                    map['createdAt']['_nanoseconds'],
                  )
              : null,
      status: map['status'] != null ? map['status'] as String : null,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : false,
      averageRating:
          map['averageRating'] != null
              ? (map['averageRating'] as num).toDouble()
              : null,
      reviewCount:
          map['reviewCount'] != null ? map['reviewCount'] as int : null,
      securityDeposit:
          map['securityDeposit'] != null
              ? SecurityDeposit.fromMap(
                Map<String, dynamic>.from(map['securityDeposit'] as Map),
              )
              : const SecurityDeposit.disabled(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Asset.fromJson(String source) =>
      Asset.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Asset(id: $id, ownerId: $ownerId, owner: $owner, title: $title, description: $description, categoryId: $categoryId, categoryName: $categoryName, subcategoryId: $subcategoryId, subcategoryName: $subcategoryName, listingDetails: $listingDetails, rates: $rates, location: $location, images: $images, showcase: $showcase, inclusions: $inclusions, ownerInstructions: $ownerInstructions, blocksEndDate: $blocksEndDate, createdAt: $createdAt, status: $status, isDeleted: $isDeleted, averageRating: $averageRating, reviewCount: $reviewCount, securityDeposit: $securityDeposit)';
  }

  @override
  bool operator ==(covariant Asset other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.ownerId == ownerId &&
        other.owner == owner &&
        other.title == title &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.subcategoryId == subcategoryId &&
        other.subcategoryName == subcategoryName &&
        other.listingDetails == listingDetails &&
        other.rates == rates &&
        other.location == location &&
        listEquals(other.images, images) &&
        listEquals(other.showcase, showcase) &&
        listEquals(other.inclusions, inclusions) &&
        other.ownerInstructions == ownerInstructions &&
        other.blocksEndDate == blocksEndDate &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.isDeleted == isDeleted &&
        other.averageRating == averageRating &&
        other.reviewCount == reviewCount &&
        other.securityDeposit == securityDeposit;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ownerId.hashCode ^
        owner.hashCode ^
        title.hashCode ^
        description.hashCode ^
        categoryId.hashCode ^
        categoryName.hashCode ^
        subcategoryId.hashCode ^
        subcategoryName.hashCode ^
        listingDetails.hashCode ^
        rates.hashCode ^
        location.hashCode ^
        images.hashCode ^
        showcase.hashCode ^
        inclusions.hashCode ^
        ownerInstructions.hashCode ^
        blocksEndDate.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        isDeleted.hashCode ^
        averageRating.hashCode ^
        reviewCount.hashCode ^
        securityDeposit.hashCode;
  }
}

class SecurityDeposit {
  final bool enabled;
  final int amount;

  const SecurityDeposit({required this.enabled, required this.amount});
  const SecurityDeposit.disabled() : enabled = false, amount = 0;

  Map<String, dynamic> toMap() {
    return {'enabled': enabled, 'amount': enabled ? amount : 0};
  }

  factory SecurityDeposit.fromMap(Map<String, dynamic> map) {
    final enabled = map['enabled'] == true;
    final amount = (map['amount'] as num?)?.toInt() ?? 0;
    return SecurityDeposit(enabled: enabled, amount: enabled ? amount : 0);
  }

  @override
  String toString() => 'SecurityDeposit(enabled: $enabled, amount: $amount)';

  @override
  bool operator ==(Object other) {
    return other is SecurityDeposit &&
        other.enabled == enabled &&
        other.amount == amount;
  }

  @override
  int get hashCode => enabled.hashCode ^ amount.hashCode;
}

class AddAsset {
  String id;
  String ownerId;
  SimpleUserModel? owner;
  String title;
  String description;
  String categoryId;
  String categoryName;
  String? subcategoryId;
  String? subcategoryName;
  ListingDetailsModel listingDetails;
  Rates rates;
  Location? location;
  List<String> images;
  List<String> showcase;
  List<String> inclusions;
  String? ownerInstructions;
  bool blocksEndDate;
  Timestamp createdAt;
  String status;
  bool isDeleted;
  SecurityDeposit securityDeposit;
  AddAsset({
    required this.id,
    required this.ownerId,
    required this.owner,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.listingDetails = const ListingDetailsModel.empty(),
    required this.rates,
    required this.location,
    required this.images,
    required this.showcase,
    required this.inclusions,
    this.ownerInstructions,
    this.blocksEndDate = false,
    required this.createdAt,
    required this.status,
    this.isDeleted = false,
    this.securityDeposit = const SecurityDeposit.disabled(),
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'owner': owner?.toMap(),
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      ...listingDetails.toMap(),
      'rates': rates.toMap(),
      'location': location?.toMap(),
      'images': images,
      'showcase': showcase,
      'inclusions': inclusions,
      'ownerInstructions': ownerInstructions,
      'blocksEndDate': blocksEndDate,
      'createdAt': createdAt,
      'status': status,
      'isDeleted': isDeleted,
      'securityDeposit': securityDeposit.toMap(),
    };
  }

  factory AddAsset.fromMap(Map<String, dynamic> map) {
    return AddAsset(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      owner: map['owner'] as SimpleUserModel,
      title: map['title'] as String,
      description: map['description'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      subcategoryId: map['subcategoryId'] as String?,
      subcategoryName: map['subcategoryName'] as String?,
      listingDetails: ListingDetailsModel.fromMap(map),
      rates: Rates.fromMap(map['rates'] as Map<String, dynamic>),
      location: Location.fromMap(map['location'] as Map<String, dynamic>),
      images: List<String>.from((map['images'] as List<String>)),
      showcase: List<String>.from((map['showcase'] as List<String>)),
      inclusions: List<String>.from((map['inclusions'] as List<String>)),
      ownerInstructions:
          map['ownerInstructions'] != null
              ? map['ownerInstructions'] as String
              : null,
      blocksEndDate:
          map['blocksEndDate'] != null ? map['blocksEndDate'] as bool : false,
      createdAt: map['createdAt'] as Timestamp,
      status: map['status'] as String,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : false,
      securityDeposit:
          map['securityDeposit'] != null
              ? SecurityDeposit.fromMap(
                Map<String, dynamic>.from(map['securityDeposit'] as Map),
              )
              : const SecurityDeposit.disabled(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AddAsset.fromJson(String source) =>
      AddAsset.fromMap(json.decode(source) as Map<String, dynamic>);
}

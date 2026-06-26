// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/models/simple_user.model.dart';

dynamic _toJsonEncodable(dynamic value) {
  if (value is Timestamp) {
    return {'_seconds': value.seconds, '_nanoseconds': value.nanoseconds};
  }

  if (value is Map) {
    return value.map(
      (key, value) => MapEntry(key.toString(), _toJsonEncodable(value)),
    );
  }

  if (value is Iterable) {
    return value.map(_toJsonEncodable).toList();
  }

  return value;
}

class SimpleAsset {
  final String id;
  final SimpleUserModel? owner;
  final String? title;
  final List<String>? images;
  final List<Booking>? bookings;
  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final Rates? rates;
  final Timestamp? createdAt;
  final String? status;
  final Location? location;
  final bool isDeleted;
  final int pendingBookingCount;
  final SecurityDeposit securityDeposit;
  final String? ownerInstructions;
  final bool blocksEndDate;
  SimpleAsset({
    required this.id,
    required this.owner,
    required this.title,
    required this.images,
    this.bookings,
    required this.categoryId,
    required this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.rates,
    required this.createdAt,
    required this.status,
    required this.location,
    this.isDeleted = false,
    this.pendingBookingCount = 0,
    this.securityDeposit = const SecurityDeposit.disabled(),
    this.ownerInstructions,
    this.blocksEndDate = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'owner': owner?.toMap(),
      'title': title,
      'images': images,
      'bookings': bookings?.map((x) => x.toMap()).toList(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'rates': rates?.toMap(),
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds)
              : null,
      'status': status,
      'location': location?.toMap(),
      'isDeleted': isDeleted,
      'pendingBookingCount': pendingBookingCount,
      'securityDeposit': securityDeposit.toMap(),
      'ownerInstructions': ownerInstructions,
      'blocksEndDate': blocksEndDate,
    };
  }

  factory SimpleAsset.fromMap(Map<String, dynamic> map) {
    return SimpleAsset(
      id: map['id'] as String,
      owner:
          map['owner'] != null
              ? SimpleUserModel.fromMap(map['owner'] as Map<String, dynamic>)
              : null,
      title: map['title'] != null ? map['title'] as String : null,
      images: map['images'] != null ? List<String>.from((map['images'])) : null,
      bookings:
          map['bookings'] != null
              ? (map['bookings'] as List)
                  .map(
                    (booking) =>
                        Booking.fromMap(booking as Map<String, dynamic>),
                  )
                  .toList()
              : null,
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
      rates:
          map['rates'] != null
              ? Rates.fromMap(Map<String, dynamic>.from(map['rates'] as Map))
              : null,
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
      location:
          map['location'] != null
              ? Location.fromMap(map['location'] as Map<String, dynamic>)
              : null,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : false,
      pendingBookingCount:
          map['pendingBookingCount'] != null
              ? map['pendingBookingCount'] as int
              : 0,
      securityDeposit:
          map['securityDeposit'] != null
              ? SecurityDeposit.fromMap(
                Map<String, dynamic>.from(map['securityDeposit'] as Map),
              )
              : const SecurityDeposit.disabled(),
      ownerInstructions:
          map['ownerInstructions'] != null
              ? map['ownerInstructions'] as String
              : null,
      blocksEndDate:
          map['blocksEndDate'] != null ? map['blocksEndDate'] as bool : false,
    );
  }

  String toJson() => json.encode(_toJsonEncodable(toMap()));

  factory SimpleAsset.fromJson(String source) =>
      SimpleAsset.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SimpleAsset(id: $id, owner: $owner, title: $title, images: $images, bookings: $bookings, categoryId: $categoryId, categoryName: $categoryName, subcategoryId: $subcategoryId, subcategoryName: $subcategoryName, rates: $rates, createdAt: $createdAt, status: $status, location: $location, isDeleted: $isDeleted, pendingBookingCount: $pendingBookingCount, securityDeposit: $securityDeposit, ownerInstructions: $ownerInstructions, blocksEndDate: $blocksEndDate)';
  }

  @override
  bool operator ==(covariant SimpleAsset other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.owner == owner &&
        other.title == title &&
        listEquals(other.images, images) &&
        listEquals(other.bookings, bookings) &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.subcategoryId == subcategoryId &&
        other.subcategoryName == subcategoryName &&
        other.rates == rates &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.location == location &&
        other.isDeleted == isDeleted &&
        other.pendingBookingCount == pendingBookingCount &&
        other.securityDeposit == securityDeposit &&
        other.ownerInstructions == ownerInstructions &&
        other.blocksEndDate == blocksEndDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        owner.hashCode ^
        title.hashCode ^
        images.hashCode ^
        bookings.hashCode ^
        categoryId.hashCode ^
        categoryName.hashCode ^
        subcategoryId.hashCode ^
        subcategoryName.hashCode ^
        rates.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        location.hashCode ^
        isDeleted.hashCode ^
        pendingBookingCount.hashCode ^
        securityDeposit.hashCode ^
        ownerInstructions.hashCode ^
        blocksEndDate.hashCode;
  }
}

class AddSimpleAsset {
  final String id;
  final SimpleUserModel? owner;
  final String? title;
  final List<String>? images;
  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final Rates? rates;
  final Timestamp? createdAt;
  final String? status;
  final Location? location;
  final bool isDeleted;
  final int pendingBookingCount;
  final SecurityDeposit securityDeposit;
  final String? ownerInstructions;
  final bool blocksEndDate;
  AddSimpleAsset({
    required this.id,
    required this.owner,
    required this.title,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.rates,
    required this.createdAt,
    required this.status,
    required this.location,
    this.isDeleted = false,
    this.pendingBookingCount = 0,
    this.securityDeposit = const SecurityDeposit.disabled(),
    this.ownerInstructions,
    this.blocksEndDate = false,
  });

  AddSimpleAsset copyWith({
    String? id,
    SimpleUserModel? owner,
    String? title,
    List<String>? images,
    String? categoryId,
    String? categoryName,
    String? subcategoryId,
    String? subcategoryName,
    Rates? rates,
    Timestamp? createdAt,
    String? status,
    Location? location,
    bool? isDeleted,
    int? pendingBookingCount,
    SecurityDeposit? securityDeposit,
    String? ownerInstructions,
    bool? blocksEndDate,
  }) {
    return AddSimpleAsset(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      title: title ?? this.title,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      rates: rates ?? this.rates,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      location: location ?? this.location,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingBookingCount: pendingBookingCount ?? this.pendingBookingCount,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      ownerInstructions: ownerInstructions ?? this.ownerInstructions,
      blocksEndDate: blocksEndDate ?? this.blocksEndDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'owner': owner?.toMap(),
      'title': title,
      'images': images,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'rates': rates?.toMap(),
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds)
              : null,
      'status': status,
      'location': location?.toMap(),
      'isDeleted': isDeleted,
      'pendingBookingCount': pendingBookingCount,
      'securityDeposit': securityDeposit.toMap(),
      'ownerInstructions': ownerInstructions,
      'blocksEndDate': blocksEndDate,
    };
  }

  factory AddSimpleAsset.fromMap(Map<String, dynamic> map) {
    return AddSimpleAsset(
      id: map['id'] as String,
      owner:
          map['owner'] != null
              ? SimpleUserModel.fromMap(map['owner'] as Map<String, dynamic>)
              : null,
      title: map['title'] != null ? map['title'] as String : null,
      images: map['images'] != null ? List<String>.from((map['images'])) : null,
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
      rates:
          map['rates'] != null
              ? Rates.fromMap(Map<String, dynamic>.from(map['rates'] as Map))
              : null,
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
      location:
          map['location'] != null
              ? Location.fromMap(map['location'] as Map<String, dynamic>)
              : null,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : false,
      pendingBookingCount:
          map['pendingBookingCount'] != null
              ? map['pendingBookingCount'] as int
              : 0,
      securityDeposit:
          map['securityDeposit'] != null
              ? SecurityDeposit.fromMap(
                Map<String, dynamic>.from(map['securityDeposit'] as Map),
              )
              : const SecurityDeposit.disabled(),
      ownerInstructions:
          map['ownerInstructions'] != null
              ? map['ownerInstructions'] as String
              : null,
      blocksEndDate:
          map['blocksEndDate'] != null ? map['blocksEndDate'] as bool : false,
    );
  }

  String toJson() => json.encode(_toJsonEncodable(toMap()));

  factory AddSimpleAsset.fromJson(String source) =>
      AddSimpleAsset.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AddSimpleAsset(id: $id, owner: $owner, title: $title, images: $images, categoryId: $categoryId, categoryName: $categoryName, subcategoryId: $subcategoryId, subcategoryName: $subcategoryName, rates: $rates, createdAt: $createdAt, status: $status, location: $location, isDeleted: $isDeleted, pendingBookingCount: $pendingBookingCount, securityDeposit: $securityDeposit, ownerInstructions: $ownerInstructions, blocksEndDate: $blocksEndDate)';
  }

  @override
  bool operator ==(covariant AddSimpleAsset other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.owner == owner &&
        other.title == title &&
        listEquals(other.images, images) &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.subcategoryId == subcategoryId &&
        other.subcategoryName == subcategoryName &&
        other.rates == rates &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.location == location &&
        other.isDeleted == isDeleted &&
        other.pendingBookingCount == pendingBookingCount &&
        other.securityDeposit == securityDeposit &&
        other.ownerInstructions == ownerInstructions &&
        other.blocksEndDate == blocksEndDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        owner.hashCode ^
        title.hashCode ^
        images.hashCode ^
        categoryId.hashCode ^
        categoryName.hashCode ^
        subcategoryId.hashCode ^
        subcategoryName.hashCode ^
        rates.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        location.hashCode ^
        isDeleted.hashCode ^
        pendingBookingCount.hashCode ^
        securityDeposit.hashCode ^
        ownerInstructions.hashCode ^
        blocksEndDate.hashCode;
  }
}

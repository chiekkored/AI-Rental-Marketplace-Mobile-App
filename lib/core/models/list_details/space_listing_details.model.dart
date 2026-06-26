import 'package:flutter/foundation.dart';
import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';
import 'package:lend/core/models/list_details/listing_time_range.model.dart';

class SpaceListingDetails extends ListingDetailsData {
  final int? capacity;
  final List<String> allowedUses;
  final List<String> amenities;
  final bool hasParking;
  final int? setupTimeMinutes;
  final int? cleanupTimeMinutes;
  final ListingTimeRange? operatingHours;
  final ListingTimeRange? noiseRestrictions;

  const SpaceListingDetails({
    this.capacity,
    this.allowedUses = const [],
    this.amenities = const [],
    this.hasParking = false,
    this.setupTimeMinutes,
    this.cleanupTimeMinutes,
    this.operatingHours,
    this.noiseRestrictions,
  });

  @override
  String get detailSchemaKey => 'space';

  factory SpaceListingDetails.fromMap(Map<String, dynamic> map) {
    return SpaceListingDetails(
      capacity: listingDetailInt(map['capacity']),
      allowedUses: listingDetailStringList(map['allowedUses']),
      amenities: listingDetailStringList(map['amenities']),
      hasParking: map['hasParking'] == true,
      setupTimeMinutes: listingDetailInt(map['setupTimeMinutes']),
      cleanupTimeMinutes: listingDetailInt(map['cleanupTimeMinutes']),
      operatingHours: ListingTimeRange.fromMapOrNull(map['operatingHours']),
      noiseRestrictions: ListingTimeRange.fromMapOrNull(
        map['noiseRestrictions'],
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'capacity': capacity,
      'allowedUses': allowedUses,
      'amenities': amenities,
      'hasParking': hasParking,
      'setupTimeMinutes': setupTimeMinutes,
      'cleanupTimeMinutes': cleanupTimeMinutes,
      if (operatingHours != null) 'operatingHours': operatingHours!.toMap(),
      if (noiseRestrictions != null)
        'noiseRestrictions': noiseRestrictions!.toMap(),
    }..removeWhere((key, value) => value == null);
  }

  @override
  bool operator ==(Object other) {
    return other is SpaceListingDetails &&
        other.capacity == capacity &&
        listEquals(other.allowedUses, allowedUses) &&
        listEquals(other.amenities, amenities) &&
        other.hasParking == hasParking &&
        other.setupTimeMinutes == setupTimeMinutes &&
        other.cleanupTimeMinutes == cleanupTimeMinutes &&
        other.operatingHours == operatingHours &&
        other.noiseRestrictions == noiseRestrictions;
  }

  @override
  int get hashCode => Object.hash(
    capacity,
    Object.hashAll(allowedUses),
    Object.hashAll(amenities),
    hasParking,
    setupTimeMinutes,
    cleanupTimeMinutes,
    operatingHours,
    noiseRestrictions,
  );
}

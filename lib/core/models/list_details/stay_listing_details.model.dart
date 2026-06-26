import 'package:flutter/foundation.dart';
import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';

class StayListingDetails extends ListingDetailsData {
  final String stayType;
  final int? maxGuests;
  final int? bedrooms;
  final int? beds;
  final int? bathrooms;
  final List<String> amenities;
  final String checkInTime;
  final String checkOutTime;
  final int? minimumNights;
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool partiesAllowed;

  const StayListingDetails({
    this.stayType = 'entire_place',
    this.maxGuests,
    this.bedrooms,
    this.beds,
    this.bathrooms,
    this.amenities = const [],
    this.checkInTime = '14:00',
    this.checkOutTime = '11:00',
    this.minimumNights,
    this.petsAllowed = false,
    this.smokingAllowed = false,
    this.partiesAllowed = false,
  });

  @override
  String get detailSchemaKey => 'stay';

  factory StayListingDetails.fromMap(Map<String, dynamic> map) {
    return StayListingDetails(
      stayType: listingDetailString(map['stayType'], fallback: 'entire_place'),
      maxGuests: listingDetailInt(map['maxGuests']),
      bedrooms: listingDetailInt(map['bedrooms']),
      beds: listingDetailInt(map['beds']),
      bathrooms: listingDetailInt(map['bathrooms']),
      amenities: listingDetailStringList(map['amenities']),
      checkInTime: listingDetailString(map['checkInTime'], fallback: '14:00'),
      checkOutTime: listingDetailString(map['checkOutTime'], fallback: '11:00'),
      minimumNights: listingDetailInt(map['minimumNights']),
      petsAllowed: map['petsAllowed'] == true,
      smokingAllowed: map['smokingAllowed'] == true,
      partiesAllowed: map['partiesAllowed'] == true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'stayType': stayType,
      'maxGuests': maxGuests,
      'bedrooms': bedrooms,
      'beds': beds,
      'bathrooms': bathrooms,
      'amenities': amenities,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'minimumNights': minimumNights,
      'petsAllowed': petsAllowed,
      'smokingAllowed': smokingAllowed,
      'partiesAllowed': partiesAllowed,
    }..removeWhere((key, value) => value == null);
  }

  @override
  bool operator ==(Object other) {
    return other is StayListingDetails &&
        other.stayType == stayType &&
        other.maxGuests == maxGuests &&
        other.bedrooms == bedrooms &&
        other.beds == beds &&
        other.bathrooms == bathrooms &&
        listEquals(other.amenities, amenities) &&
        other.checkInTime == checkInTime &&
        other.checkOutTime == checkOutTime &&
        other.minimumNights == minimumNights &&
        other.petsAllowed == petsAllowed &&
        other.smokingAllowed == smokingAllowed &&
        other.partiesAllowed == partiesAllowed;
  }

  @override
  int get hashCode => Object.hash(
    stayType,
    maxGuests,
    bedrooms,
    beds,
    bathrooms,
    Object.hashAll(amenities),
    checkInTime,
    checkOutTime,
    minimumNights,
    petsAllowed,
    smokingAllowed,
    partiesAllowed,
  );
}

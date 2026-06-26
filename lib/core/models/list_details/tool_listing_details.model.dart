import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';

class ToolListingDetails extends ListingDetailsData {
  final String brand;
  final String model;
  final String powerSource;
  final String skillLevel;
  final bool safetyGearRequired;
  final bool consumablesIncluded;

  const ToolListingDetails({
    this.brand = '',
    this.model = '',
    this.powerSource = 'battery',
    this.skillLevel = 'beginner',
    this.safetyGearRequired = false,
    this.consumablesIncluded = false,
  });

  @override
  String get detailSchemaKey => 'tool';

  factory ToolListingDetails.fromMap(Map<String, dynamic> map) {
    return ToolListingDetails(
      brand: listingDetailString(map['brand']),
      model: listingDetailString(map['model']),
      powerSource: listingDetailString(map['powerSource'], fallback: 'battery'),
      skillLevel: listingDetailString(map['skillLevel'], fallback: 'beginner'),
      safetyGearRequired: map['safetyGearRequired'] == true,
      consumablesIncluded: map['consumablesIncluded'] == true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'powerSource': powerSource,
      'safetyGearRequired': safetyGearRequired,
      'consumablesIncluded': consumablesIncluded,
      'skillLevel': skillLevel,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ToolListingDetails &&
        other.brand == brand &&
        other.model == model &&
        other.powerSource == powerSource &&
        other.skillLevel == skillLevel &&
        other.safetyGearRequired == safetyGearRequired &&
        other.consumablesIncluded == consumablesIncluded;
  }

  @override
  int get hashCode => Object.hash(
    brand,
    model,
    powerSource,
    skillLevel,
    safetyGearRequired,
    consumablesIncluded,
  );
}

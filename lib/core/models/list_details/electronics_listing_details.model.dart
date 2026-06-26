import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';

class ElectronicsListingDetails extends ListingDetailsData {
  final String brand;
  final String model;
  final bool batteryIncluded;
  final bool chargerIncluded;
  final String compatibilityNote;
  final String specsNote;

  const ElectronicsListingDetails({
    this.brand = '',
    this.model = '',
    this.batteryIncluded = false,
    this.chargerIncluded = false,
    this.compatibilityNote = '',
    this.specsNote = '',
  });

  @override
  String get detailSchemaKey => 'electronics';

  factory ElectronicsListingDetails.fromMap(Map<String, dynamic> map) {
    return ElectronicsListingDetails(
      brand: listingDetailString(map['brand']),
      model: listingDetailString(map['model']),
      batteryIncluded: map['batteryIncluded'] == true,
      chargerIncluded: map['chargerIncluded'] == true,
      compatibilityNote: listingDetailString(map['compatibilityNote']),
      specsNote: listingDetailString(map['specsNote']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'batteryIncluded': batteryIncluded,
      'chargerIncluded': chargerIncluded,
      'compatibilityNote': compatibilityNote,
      'specsNote': specsNote,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ElectronicsListingDetails &&
        other.brand == brand &&
        other.model == model &&
        other.batteryIncluded == batteryIncluded &&
        other.chargerIncluded == chargerIncluded &&
        other.compatibilityNote == compatibilityNote &&
        other.specsNote == specsNote;
  }

  @override
  int get hashCode => Object.hash(
    brand,
    model,
    batteryIncluded,
    chargerIncluded,
    compatibilityNote,
    specsNote,
  );
}

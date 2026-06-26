import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';

class GenericAssetListingDetails extends ListingDetailsData {
  final String brand;
  final String model;
  final String notes;

  const GenericAssetListingDetails({
    this.brand = '',
    this.model = '',
    this.notes = '',
  });

  @override
  String get detailSchemaKey => 'generic_asset';

  factory GenericAssetListingDetails.fromMap(Map<String, dynamic> map) {
    return GenericAssetListingDetails(
      brand: listingDetailString(map['brand']),
      model: listingDetailString(map['model']),
      notes: listingDetailString(map['notes']),
    );
  }

  @override
  bool get isEmpty =>
      brand.trim().isEmpty && model.trim().isEmpty && notes.trim().isEmpty;

  @override
  Map<String, dynamic> toMap() {
    return {'brand': brand, 'model': model, 'notes': notes}
      ..removeWhere((key, value) {
        return value is String && value.trim().isEmpty;
      });
  }

  @override
  bool operator ==(Object other) {
    return other is GenericAssetListingDetails &&
        other.brand == brand &&
        other.model == model &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(brand, model, notes);
}

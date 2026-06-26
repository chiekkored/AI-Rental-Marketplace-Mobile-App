import 'package:lend/core/models/list_details/generic_asset_listing_details.model.dart';
import 'package:lend/core/models/list_details/listing_details_data.model.dart';

class ListingDetailsModel {
  final String listingKind;
  final String detailSchemaKey;
  final ListingDetailsData details;

  const ListingDetailsModel({
    required this.listingKind,
    required this.detailSchemaKey,
    required this.details,
  });

  const ListingDetailsModel.empty()
    : listingKind = '',
      detailSchemaKey = '',
      details = const GenericAssetListingDetails();

  bool get isEmpty =>
      listingKind.trim().isEmpty &&
      detailSchemaKey.trim().isEmpty &&
      details.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'listingKind': listingKind,
      'detailSchemaKey': detailSchemaKey,
      'details': details.toMap(),
    }..removeWhere((key, value) {
      if (value == null) return true;
      if (value is String) return value.trim().isEmpty;
      if (value is Map) return value.isEmpty;
      return false;
    });
  }

  factory ListingDetailsModel.fromMap(Map<String, dynamic> map) {
    final rawDetails = map['details'];
    final detailSchemaKey = map['detailSchemaKey']?.toString() ?? '';
    return ListingDetailsModel(
      listingKind: map['listingKind']?.toString() ?? '',
      detailSchemaKey: detailSchemaKey,
      details: ListingDetailsData.fromMap(
        detailSchemaKey,
        rawDetails is Map
            ? Map<String, dynamic>.from(rawDetails)
            : <String, dynamic>{},
      ),
    );
  }

  @override
  String toString() {
    return 'ListingDetailsModel(listingKind: $listingKind, detailSchemaKey: $detailSchemaKey, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return other is ListingDetailsModel &&
        other.listingKind == listingKind &&
        other.detailSchemaKey == detailSchemaKey &&
        other.details == details;
  }

  @override
  int get hashCode =>
      listingKind.hashCode ^ detailSchemaKey.hashCode ^ details.hashCode;
}

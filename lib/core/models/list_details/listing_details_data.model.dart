import 'package:lend/core/models/list_details/clothing_listing_details.model.dart';
import 'package:lend/core/models/list_details/electronics_listing_details.model.dart';
import 'package:lend/core/models/list_details/generic_asset_listing_details.model.dart';
import 'package:lend/core/models/list_details/party_event_listing_details.model.dart';
import 'package:lend/core/models/list_details/space_listing_details.model.dart';
import 'package:lend/core/models/list_details/stay_listing_details.model.dart';
import 'package:lend/core/models/list_details/tool_listing_details.model.dart';
import 'package:lend/core/models/list_details/vehicle_listing_details.model.dart';

abstract class ListingDetailsData {
  const ListingDetailsData();

  String get detailSchemaKey;

  bool get isEmpty => toMap().isEmpty;

  Map<String, dynamic> toMap();

  static ListingDetailsData fromMap(
    String? detailSchemaKey,
    Map<String, dynamic> map,
  ) {
    switch (detailSchemaKey) {
      case 'stay':
        return StayListingDetails.fromMap(map);
      case 'space':
        return SpaceListingDetails.fromMap(map);
      case 'vehicle':
        return VehicleListingDetails.fromMap(map);
      case 'tool':
        return ToolListingDetails.fromMap(map);
      case 'electronics':
        return ElectronicsListingDetails.fromMap(map);
      case 'party_event':
        return PartyEventListingDetails.fromMap(map);
      case 'clothing':
        return ClothingListingDetails.fromMap(map);
      default:
        return GenericAssetListingDetails.fromMap(map);
    }
  }
}

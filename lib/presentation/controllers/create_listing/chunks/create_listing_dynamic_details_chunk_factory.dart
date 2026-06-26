import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_clothing_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_electronics_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_generic_asset_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_party_event_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_space_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_stay_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_tool_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_vehicle_details.chunk.dart';

CreateListingDynamicDetailsChunk createDynamicDetailsChunk(
  String? detailSchemaKey,
) {
  switch (detailSchemaKey) {
    case 'stay':
      return CreateListingStayDetailsChunk();
    case 'space':
      return CreateListingSpaceDetailsChunk();
    case 'vehicle':
      return CreateListingVehicleDetailsChunk();
    case 'tool':
      return CreateListingToolDetailsChunk();
    case 'electronics':
      return CreateListingElectronicsDetailsChunk();
    case 'party_event':
      return CreateListingPartyEventDetailsChunk();
    case 'clothing':
      return CreateListingClothingDetailsChunk();
    default:
      return CreateListingGenericAssetDetailsChunk();
  }
}

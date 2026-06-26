import 'package:flutter/widgets.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_clothing_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_electronics_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_generic_asset_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_party_event_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_space_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_stay_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_tool_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_vehicle_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/clothing_details_form.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/electronics_details_form.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/generic_asset_details_form.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/party_event_details_form.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/space_details_form.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/stay_details_form.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/tool_details_form.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/vehicle_details_form.dart';

CreateListingDynamicDetailsStepContent
buildCreateListingDynamicDetailsStepContent({
  required BuildContext context,
  required CreateListingDynamicDetailsChunk? chunk,
  required int stepIndex,
}) {
  if (chunk is CreateListingStayDetailsChunk) {
    return buildStayDetailsStepContent(context, chunk, stepIndex);
  }
  if (chunk is CreateListingSpaceDetailsChunk) {
    return buildSpaceDetailsStepContent(context, chunk, stepIndex);
  }
  if (chunk is CreateListingVehicleDetailsChunk) {
    return buildVehicleDetailsStepContent(context, chunk, stepIndex);
  }
  if (chunk is CreateListingToolDetailsChunk) {
    return buildToolDetailsStepContent(context, chunk, stepIndex);
  }
  if (chunk is CreateListingElectronicsDetailsChunk) {
    return buildElectronicsDetailsStepContent(context, chunk, stepIndex);
  }
  if (chunk is CreateListingPartyEventDetailsChunk) {
    return buildPartyEventDetailsStepContent(context, chunk, stepIndex);
  }
  if (chunk is CreateListingClothingDetailsChunk) {
    return buildClothingDetailsStepContent(context, chunk, stepIndex);
  }
  if (chunk is CreateListingGenericAssetDetailsChunk) {
    return buildGenericAssetDetailsStepContent(context, chunk, stepIndex);
  }
  return const CreateListingDynamicDetailsStepContent(
    title: 'Listing details',
    description: 'Add category-specific details for this listing.',
    sectionTitle: 'Details',
    sectionDescription: 'Choose a category first.',
    child: SizedBox.shrink(),
  );
}

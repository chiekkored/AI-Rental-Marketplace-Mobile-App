import 'package:flutter/material.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_generic_asset_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';

CreateListingDynamicDetailsStepContent buildGenericAssetDetailsStepContent(
  BuildContext context,
  CreateListingGenericAssetDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      return buildBrandModelStep(
        title: 'Property basics',
        description: 'Add brand and model.',
        brandController: chunk.brandController,
        modelController: chunk.modelController,
      );
    default:
      return CreateListingDynamicDetailsStepContent(
        title: 'Notes',
        description: 'Add optional notes about this property.',
        sectionTitle: 'Notes',
        sectionDescription: 'Use notes for details that do not fit elsewhere.',
        child: formTextBox(
          controller: chunk.notesController,
          hintText: 'Add any additional details renters should know.',
          maxLength: 300,
        ),
      );
  }
}

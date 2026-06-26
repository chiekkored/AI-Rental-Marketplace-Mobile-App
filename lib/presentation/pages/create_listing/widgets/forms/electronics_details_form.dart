import 'package:flutter/material.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_electronics_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';

CreateListingDynamicDetailsStepContent buildElectronicsDetailsStepContent(
  BuildContext context,
  CreateListingElectronicsDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      return buildBrandModelStep(
        title: 'Electronics basics',
        description: 'Add the brand and model.',
        brandController: chunk.brandController,
        modelController: chunk.modelController,
      );
    case 1:
      return CreateListingDynamicDetailsStepContent(
        title: 'Power accessories',
        description: 'Choose whether battery and charger are included.',
        sectionTitle: 'Included power items',
        sectionDescription:
            'These details help renters know what they need to bring or prepare.',
        child: Column(
          children: spaced([
            buildCreateListingSwitchTile(
              'Battery included',
              chunk.batteryIncluded.value,
              (value) => chunk.batteryIncluded.value = value,
              subtitle:
                  'Turn this on if at least one usable battery is included.',
            ),
            buildCreateListingSwitchTile(
              'Charger included',
              chunk.chargerIncluded.value,
              (value) => chunk.chargerIncluded.value = value,
              subtitle:
                  'Turn this on if the matching charger or power adapter is included.',
            ),
          ]),
        ),
      );
    default:
      return CreateListingDynamicDetailsStepContent(
        title: 'Compatibility and specs',
        description:
            'Add helpful notes about compatibility and specifications.',
        sectionTitle: 'Notes',
        sectionDescription: 'Keep these notes short and useful for renters.',
        child: Column(
          children: spaced([
            CreateListingSection(
              title: 'Compatibility Note',
              description: 'Please enter compatibility details.',
              child: formTextBox(
                controller: chunk.compatibilityNoteController,
                hintText:
                    'Mention supported devices, mounts, ports, apps, or accessories.',
                maxLength: 200,
              ),
            ),
            CreateListingSection(
              title: 'Specs Note',
              description: 'Please enter key specifications.',
              child: formTextBox(
                controller: chunk.specsNoteController,
                hintText: 'Add key specs renters may care about.',
                maxLength: 200,
                maxLines: 4,
              ),
            ),
          ]),
        ),
      );
  }
}

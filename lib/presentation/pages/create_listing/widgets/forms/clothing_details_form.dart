import 'package:flutter/material.dart';
import 'package:lend/presentation/common/textfield_suggestions.common.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_clothing_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';
import 'package:lend/utilities/enums/listing_details.enum.dart';

const _clothingColorSuggestions = [
  'Black',
  'White',
  'Gray',
  'Navy',
  'Blue',
  'Red',
  'Pink',
  'Purple',
  'Green',
  'Yellow',
  'Orange',
  'Brown',
  'Beige',
  'Cream',
  'Tan',
  'Gold',
  'Silver',
  'Multi-color',
];

CreateListingDynamicDetailsStepContent buildClothingDetailsStepContent(
  BuildContext context,
  CreateListingClothingDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      final requiredControllers = [
        chunk.brandController,
        chunk.colorController,
        chunk.sizeController,
      ];
      return CreateListingDynamicDetailsStepContent(
        title: 'Clothing basics',
        description: 'Add the brand, color, and size.',
        sectionTitle: 'Item details',
        sectionDescription: 'These basics help renters check fit and style.',
        required: true,
        canContinue: areControllersFilled(requiredControllers),
        listenables: requiredControllers,
        child: Column(
          children: spaced([
            CreateListingSection(
              title: 'Brand',
              required: true,
              description: 'Please enter the brand.',
              child: formTextField(
                controller: chunk.brandController,
                hintText: 'e.g.,Nike',
                required: true,
              ),
            ),
            CreateListingSection(
              title: 'Color',
              required: true,
              description: 'Please enter the color.',
              child: LNDTextFieldWithSuggestions(
                required: true,
                controller: chunk.colorController,
                hintText: 'e.g.,Black',
                suggestions: _clothingColorSuggestions,
              ),
            ),
            CreateListingSection(
              title: 'Size',
              required: true,
              description: 'Please enter the size.',
              child: buildCreateListingRadioField(
                label: 'Size',
                value: chunk.sizeController.text,
                icon: Icons.straighten_outlined,
                options:
                    ClothingSize.values
                        .map((item) => FormOption(item.value, item.label))
                        .toList(),
                onChanged: (value) => chunk.sizeController.text = value,
              ),
            ),
          ]),
        ),
      );
    case 1:
      return CreateListingDynamicDetailsStepContent(
        title: 'Fit and policy',
        description: 'Choose fit, cleaning policy, and occasion.',
        sectionTitle: 'Attributes',
        sectionDescription:
            'These details help renters evaluate fit and care requirements.',
        child: Column(
          children: spaced([
            buildCreateListingRadioField(
              label: 'Fit',
              value: chunk.fit.value,
              icon: Icons.checkroom_outlined,
              options:
                  ClothingFit.values
                      .map((item) => FormOption(item.value, item.label))
                      .toList(),
              onChanged: (value) => chunk.fit.value = value,
            ),
            buildCreateListingRadioField(
              label: 'Cleaning policy',
              value: chunk.cleaningPolicy.value,
              icon: Icons.local_laundry_service_outlined,
              options:
                  CleaningPolicy.values
                      .map((item) => FormOption(item.value, item.label))
                      .toList(),
              onChanged: (value) => chunk.cleaningPolicy.value = value,
            ),
            buildCreateListingRadioField(
              label: 'Occasion',
              value: chunk.occasion.value,
              icon: Icons.event_outlined,
              options:
                  ClothingOccasion.values
                      .map((item) => FormOption(item.value, item.label))
                      .toList(),
              onChanged: (value) => chunk.occasion.value = value,
            ),
          ]),
        ),
      );
    default:
      return CreateListingDynamicDetailsStepContent(
        title: 'Measurements',
        description: 'Add optional measurement details.',
        sectionTitle: 'Measurements note',
        sectionDescription:
            'Include measurements that make fit easier to evaluate.',
        child: formTextBox(
          controller: chunk.measurementsNoteController,
          hintText: 'e.g.,Bust 36", Waist 28", Hips 38"',
          maxLength: 200,
        ),
      );
  }
}

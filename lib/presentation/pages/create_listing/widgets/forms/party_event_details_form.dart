import 'package:flutter/material.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_party_event_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';
import 'package:lend/utilities/enums/listing_details.enum.dart';

CreateListingDynamicDetailsStepContent buildPartyEventDetailsStepContent(
  BuildContext context,
  CreateListingPartyEventDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      final requiredControllers = [chunk.quantityController];
      return CreateListingDynamicDetailsStepContent(
        title: 'Quantity and set size',
        description: 'Set how many items are included and describe the set.',
        sectionTitle: 'Set details',
        sectionDescription: 'Use a stepper for quantity.',
        required: true,
        canContinue: areControllersFilled(requiredControllers),
        listenables: requiredControllers,
        child: Column(
          children: spaced([
            buildControllerStepper(
              'Quantity',
              chunk.quantityController,
              minimum: 1,
            ),
            formTextField(
              controller: chunk.setSizeController,
              label: 'Set size',
              maxLength: 120,
            ),
          ]),
        ),
      );
    case 1:
      return CreateListingDynamicDetailsStepContent(
        title: 'Use setting',
        description: 'Choose where the item can be used.',
        sectionTitle: 'Indoor or outdoor',
        sectionDescription:
            'Use the bottom sheet to select the allowed setting.',
        child: buildCreateListingRadioField(
          label: 'Indoor or outdoor',
          value: chunk.indoorOutdoor.value,
          icon: Icons.wb_sunny_outlined,
          options:
              IndoorOutdoor.values
                  .map((item) => FormOption(item.value, item.label))
                  .toList(),
          onChanged: (value) => chunk.indoorOutdoor.value = value,
        ),
      );
    default:
      return CreateListingDynamicDetailsStepContent(
        title: 'Setup requirements',
        description: 'Set setup, delivery, power, and instruction details.',
        sectionTitle: 'Requirements',
        sectionDescription:
            'Use toggles for requirements and a note for setup instructions.',
        child: Column(
          children: spaced([
            buildCreateListingSwitchTile(
              'Setup required',
              chunk.setupRequired.value,
              (value) => chunk.setupRequired.value = value,
            ),
            buildCreateListingSwitchTile(
              'Delivery required',
              chunk.deliveryRequired.value,
              (value) => chunk.deliveryRequired.value = value,
            ),
            buildCreateListingSwitchTile(
              'Power required',
              chunk.powerRequired.value,
              (value) => chunk.powerRequired.value = value,
            ),
            formTextField(
              controller: chunk.setupInstructionsController,
              label: 'Setup instructions',
              maxLength: 300,
              maxLines: 3,
            ),
          ]),
        ),
      );
  }
}

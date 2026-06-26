import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_stay_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/dynamic_details_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/amenity_selector.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';
import 'package:lend/utilities/enums/listing_details.enum.dart';

CreateListingDynamicDetailsStepContent buildStayDetailsStepContent(
  BuildContext context,
  CreateListingStayDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      return CreateListingDynamicDetailsStepContent(
        title: 'What type of stay is this?',
        description: 'Choose how renters will use the property.',
        sectionTitle: 'Stay type',
        sectionDescription:
            'This helps renters understand whether they’ll have the whole place or share part of it.',
        required: true,
        canContinue: chunk.stayType.value.trim().isNotEmpty,
        child: Column(
          children: spaced([
            _stayTypeCard(
              chunk,
              StayType.entirePlace,
              'A whole house, condo, apartment, or unit.',
            ),
            _stayTypeCard(
              chunk,
              StayType.privateRoom,
              'A private room inside a shared property.',
            ),
            _stayTypeCard(
              chunk,
              StayType.sharedRoom,
              'A shared room or shared sleeping space.',
            ),
          ]),
        ),
      );
    case 1:
      final capacityControllers = [
        chunk.maxGuestsController,
        chunk.bedroomsController,
        chunk.bedsController,
        chunk.bathroomsController,
      ];
      return CreateListingDynamicDetailsStepContent(
        title: 'Guest capacity',
        description:
            'Set how many guests your place can comfortably accommodate.',
        sectionTitle: 'Capacity',
        sectionDescription:
            'Use accurate numbers so renters know what to expect before booking.',
        required: true,
        canContinue: havePositiveControllerInts(capacityControllers),
        listenables: capacityControllers,
        child: Column(
          children: spaced([
            buildControllerStepper(
              'Max guests',
              chunk.maxGuestsController,
              minimum: 1,
              subtitle: 'Total number of guests allowed.',
            ),
            buildControllerStepper(
              'Bedrooms',
              chunk.bedroomsController,
              minimum: 1,
              subtitle: 'Number of bedrooms available to renters.',
            ),
            buildControllerStepper(
              'Beds',
              chunk.bedsController,
              minimum: 1,
              subtitle: 'Total beds available for sleeping.',
            ),
            buildControllerStepper(
              'Bathrooms',
              chunk.bathroomsController,
              minimum: 1,
              subtitle: 'Bathrooms renters can use.',
            ),
          ]),
        ),
      );
    case 2:
      final scheduleControllers = [chunk.minimumNightsController];
      return CreateListingDynamicDetailsStepContent(
        title: 'Stay schedule',
        description: 'Set booking rules and daily arrival windows.',
        sectionTitle: 'Nights and times',
        sectionDescription:
            'Minimum nights require renters to book for at least this many nights.',
        required: true,
        canContinue:
            areControllersFilled(scheduleControllers) &&
            chunk.checkInTime.value.trim().isNotEmpty &&
            chunk.checkOutTime.value.trim().isNotEmpty,
        listenables: scheduleControllers,
        child: Column(
          children: spaced([
            buildControllerStepper(
              'Minimum nights',
              chunk.minimumNightsController,
              minimum: 1,
              subtitle: 'The shortest stay renters can book.',
            ),
            CreateListingTimeField(
              label: 'Check-in time',
              value: chunk.checkInTime.value,
              icon: Icons.login_rounded,
              onChanged: (value) => chunk.checkInTime.value = value,
            ),
            CreateListingTimeField(
              label: 'Check-out time',
              value: chunk.checkOutTime.value,
              icon: Icons.logout_rounded,
              onChanged: (value) => chunk.checkOutTime.value = value,
            ),
          ]),
        ),
      );
    case 3:
      return CreateListingDynamicDetailsStepContent(
        title: 'Amenities',
        description: 'Choose the amenities renters can expect.',
        sectionTitle: '',
        sectionDescription: '',
        child: CreateListingAmenitySelector(
          detailSchemaKey: chunk.detailSchemaKey,
          selectedValues: chunk.amenities.toList(),
          onChanged: chunk.amenities.assignAll,
        ),
      );
    default:
      return CreateListingDynamicDetailsStepContent(
        title: 'Stay rules',
        description: 'Choose rules renters should know before booking.',
        sectionTitle: 'House rules',
        sectionDescription:
            'These rules help set clear expectations and reduce misunderstandings.',
        child: Column(
          children: spaced([
            buildCreateListingSwitchTile(
              'Pets allowed',
              chunk.petsAllowed.value,
              (value) => chunk.petsAllowed.value = value,
              subtitle: 'Allow renters to bring pets during their stay.',
            ),
            buildCreateListingSwitchTile(
              'Smoking allowed',
              chunk.smokingAllowed.value,
              (value) => chunk.smokingAllowed.value = value,
              subtitle: 'Allow smoking in approved areas of the property.',
            ),
            buildCreateListingSwitchTile(
              'Parties allowed',
              chunk.partiesAllowed.value,
              (value) => chunk.partiesAllowed.value = value,
              subtitle: 'Allow gatherings, parties, or events during the stay.',
            ),
          ]),
        ),
      );
  }
}

Widget _stayTypeCard(
  CreateListingStayDetailsChunk chunk,
  StayType stayType,
  String description,
) {
  return CreateListingOptionCard(
    title: stayType.label,
    description: description,
    icon: stayType.icon,
    selected: chunk.stayType.value == stayType.value,
    onTap: () => chunk.stayType.value = stayType.value,
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_space_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/dynamic_details_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/amenity_selector.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';

CreateListingDynamicDetailsStepContent buildSpaceDetailsStepContent(
  BuildContext context,
  CreateListingSpaceDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      final requiredControllers = [chunk.capacityController];
      return CreateListingDynamicDetailsStepContent(
        title: 'Capacity',
        description: 'Tell renters how many people this space can accommodate.',
        sectionTitle: 'Guest capacity',
        sectionDescription:
            'Set a realistic maximum number of people allowed in the space.',
        required: true,
        canContinue: havePositiveControllerInts(requiredControllers),
        listenables: requiredControllers,
        child: Column(
          children: spaced([
            buildControllerStepper(
              'Capacity',
              chunk.capacityController,
              minimum: 1,
              subtitle: 'Maximum number of people allowed in the space.',
            ),
          ]),
        ),
      );
    case 1:
      return buildListStep(
        context: context,
        title: 'Allowed uses',
        description:
            'List the activities renters are allowed to book this space for.',
        sectionTitle: 'Allowed use',
        sectionDescription:
            'Examples: photo shoot, meeting, workshop, birthday, storage.',
        label: '',
        hintText: 'Add allowed use',
        controller: chunk.allowedUseController,
        values: chunk.allowedUses.toList(),
        onChanged: chunk.allowedUses.assignAll,
      );
    case 2:
      return CreateListingDynamicDetailsStepContent(
        title: 'Amenities',
        description: 'Choose the amenities included with the space.',
        sectionTitle: '',
        sectionDescription: '',
        child: CreateListingAmenitySelector(
          detailSchemaKey: chunk.detailSchemaKey,
          selectedValues: chunk.amenities.toList(),
          onChanged: chunk.amenities.assignAll,
        ),
      );
    case 3:
      return CreateListingDynamicDetailsStepContent(
        title: 'Setup and parking',
        description: 'Set setup, cleanup, and parking details for renters.',
        sectionTitle: 'Operations',
        sectionDescription:
            'Use these details to help renters plan their booking properly.',
        child: Column(
          children: spaced([
            CreateListingDurationField(
              label: 'Setup time',
              controller: chunk.setupTimeMinutesController,
              icon: Icons.timer_outlined,
              placeholder: 'Choose setup duration',
            ),
            CreateListingDurationField(
              label: 'Cleanup time',
              controller: chunk.cleanupTimeMinutesController,
              icon: Icons.cleaning_services_outlined,
              placeholder: 'Choose cleanup duration',
            ),
            buildCreateListingSwitchTile(
              'Parking available',
              chunk.hasParking.value,
              (value) => chunk.hasParking.value = value,
              subtitle:
                  'Turn this on if renters or guests can park at or near the space.',
            ),
          ]),
        ),
      );
    default:
      final timeWindowListenable = [
        chunk.operatingHoursEnabled,
        chunk.operatingHoursStartTimeController,
        chunk.operatingHoursEndTimeController,
        chunk.noiseRestrictionsEnabled,
        chunk.noiseRestrictionsStartTimeController,
        chunk.noiseRestrictionsEndTimeController,
      ];
      return CreateListingDynamicDetailsStepContent(
        title: 'Operating hours and noise restrictions',
        description:
            'Set the time windows renters should follow while using the space.',
        sectionTitle: 'Time windows',
        sectionDescription:
            'Use start and end times so renters know when each rule applies.',
        canContinue:
            _isTimeWindowComplete(
              chunk.operatingHoursEnabled.value,
              chunk.operatingHoursStartTimeController,
              chunk.operatingHoursEndTimeController,
            ) &&
            _isTimeWindowComplete(
              chunk.noiseRestrictionsEnabled.value,
              chunk.noiseRestrictionsStartTimeController,
              chunk.noiseRestrictionsEndTimeController,
            ),
        listenables: timeWindowListenable,
        child: Column(
          children: spaced([
            CreateListingTimeRangeField(
              title: 'Operating hours',
              description:
                  'Set the time window when the space should be used or booked.',
              enabledListenable: chunk.operatingHoursEnabled,
              onEnabledChanged:
                  (value) => chunk.operatingHoursEnabled.value = value,
              startController: chunk.operatingHoursStartTimeController,
              endController: chunk.operatingHoursEndTimeController,
              startIcon: Icons.wb_sunny_outlined,
              endIcon: Icons.nightlight_round,
            ),
            CreateListingTimeRangeField(
              title: 'Noise restrictions',
              description:
                  'Set when quiet hours or sound limits should be followed.',
              enabledListenable: chunk.noiseRestrictionsEnabled,
              onEnabledChanged:
                  (value) => chunk.noiseRestrictionsEnabled.value = value,
              startController: chunk.noiseRestrictionsStartTimeController,
              endController: chunk.noiseRestrictionsEndTimeController,
              startIcon: Icons.volume_up_outlined,
              endIcon: Icons.volume_off_outlined,
            ),
          ]),
        ),
      );
  }
}

bool _isTimeWindowComplete(
  bool enabled,
  TextEditingController startController,
  TextEditingController endController,
) {
  if (!enabled) return true;
  return startController.text.trim().isNotEmpty &&
      endController.text.trim().isNotEmpty;
}

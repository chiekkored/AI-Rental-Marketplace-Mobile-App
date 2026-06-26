import 'package:flutter/material.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_vehicle_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';
import 'package:lend/utilities/enums/listing_details.enum.dart';

CreateListingDynamicDetailsStepContent buildVehicleDetailsStepContent(
  BuildContext context,
  CreateListingVehicleDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      final requiredControllers = [
        chunk.makeController,
        chunk.modelController,
        chunk.yearController,
      ];
      return CreateListingDynamicDetailsStepContent(
        title: 'Vehicle basics',
        description: 'Add the make, model, and year.',
        sectionTitle: 'Vehicle',
        sectionDescription: 'These fields identify the vehicle.',
        canContinue: areControllersFilled(requiredControllers),
        listenables: requiredControllers,
        child: Column(
          children: spaced([
            CreateListingSection(
              title: 'Make',
              required: true,
              description:
                  'The manufacturer of the vehicle, such as Toyota, Ford, or Honda.',
              child: formTextField(
                controller: chunk.makeController,
                required: true,
                hintText: 'e.g.,Toyota',
              ),
            ),
            CreateListingSection(
              title: 'Model',
              required: true,
              description:
                  'The specific model of the vehicle, such as Camry, F-150, or Civic.',
              child: formTextField(
                controller: chunk.modelController,
                hintText: 'e.g.,Camry',
                required: true,
              ),
            ),
            CreateListingSection(
              title: 'Year',
              required: true,
              description: 'The year the vehicle was manufactured.',
              child: formTextField(
                controller: chunk.yearController,
                hintText: 'e.g.,2020',
                required: true,
                number: true,
                maxLength: 4,
              ),
            ),
          ]),
        ),
      );
    case 1:
      return CreateListingDynamicDetailsStepContent(
        title: 'Vehicle specs',
        description: 'Choose transmission and fuel type.',
        sectionTitle: 'Specs',
        sectionDescription:
            'These help renters check if the vehicle fits their driving needs.',
        child: Column(
          children: spaced([
            buildCreateListingRadioField(
              label: 'Transmission',
              value: chunk.transmission.value,
              icon: Icons.settings_input_component_outlined,
              options:
                  VehicleTransmission.values
                      .map((item) => FormOption(item.value, item.label))
                      .toList(),
              onChanged: (value) => chunk.transmission.value = value,
            ),
            buildCreateListingRadioField(
              label: 'Fuel type',
              value: chunk.fuelType.value,
              icon: Icons.local_gas_station_outlined,
              options:
                  VehicleFuelType.values
                      .map((item) => FormOption(item.value, item.label))
                      .toList(),
              onChanged: (value) => chunk.fuelType.value = value,
            ),
          ]),
        ),
      );
    case 2:
      final capacityControllers = [
        chunk.seatsController,
        chunk.mileageLimitKmPerDayController,
      ];
      return CreateListingDynamicDetailsStepContent(
        title: 'Seats and mileage',
        description: 'Set seat count and mileage limits.',
        sectionTitle: 'Capacity and limits',
        sectionDescription:
            'Use accurate limits to avoid disputes after the rental.',
        listenables: capacityControllers,
        child: Column(
          children: spaced([
            buildControllerStepper(
              'Seats',
              chunk.seatsController,
              minimum: 1,
              subtitle: 'Number of passenger seats available.',
            ),
            CreateListingSection(
              title: 'Mileage limit km/day',
              description:
                  'The maximum mileage allowed per day. Leave blank for unlimited.',
              child: formTextField(
                controller: chunk.mileageLimitKmPerDayController,
                hintText: 'e.g.,100',
                number: true,
                maxLength: 4,
                validator: _validateOptionalPositiveInt,
              ),
            ),
          ]),
        ),
      );
    default:
      return CreateListingDynamicDetailsStepContent(
        title: 'Vehicle requirements',
        description:
            'Choose requirements and included services for this vehicle.',
        sectionTitle: 'Requirements',
        sectionDescription: 'These helps renters prepare before booking.',
        child: Column(
          children: spaced([
            buildCreateListingSwitchTile(
              'License required',
              chunk.licenseRequired.value,
              (value) => chunk.licenseRequired.value = value,
              subtitle:
                  'Renters must present a valid license before receiving the vehicle.',
            ),
            buildCreateListingSwitchTile(
              'Helmet included',
              chunk.helmetIncluded.value,
              (value) => chunk.helmetIncluded.value = value,
              subtitle:
                  'Turn this on if a helmet is included, such as for motorcycles or e-scooters.',
            ),
            buildCreateListingSwitchTile(
              'Delivery available',
              chunk.deliveryAvailable.value,
              (value) => chunk.deliveryAvailable.value = value,
              subtitle:
                  'Turn this on if you can deliver the vehicle to the renter.',
            ),
          ]),
        ),
      );
  }
}

String? _validateOptionalPositiveInt(String? value) {
  final trimmed = value?.replaceAll(',', '').trim() ?? '';
  if (trimmed.isEmpty) return null;

  final parsed = int.tryParse(trimmed);
  if (parsed == null || parsed < 1) {
    return 'Enter a value of at least 1';
  }

  return null;
}

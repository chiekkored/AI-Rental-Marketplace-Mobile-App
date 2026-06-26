import 'package:flutter/material.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_tool_details.chunk.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/dynamic_details_form_content.dart';
import 'package:lend/utilities/enums/listing_details.enum.dart';

CreateListingDynamicDetailsStepContent buildToolDetailsStepContent(
  BuildContext context,
  CreateListingToolDetailsChunk chunk,
  int index,
) {
  switch (index) {
    case 0:
      return buildBrandModelStep(
        title: 'Tool details',
        description: 'Choose important tool values renters should know.',
        brandController: chunk.brandController,
        modelController: chunk.modelController,
      );
    case 1:
      return CreateListingDynamicDetailsStepContent(
        title: 'Tool details',
        description: 'Add the tool’s power source and skill level.',
        sectionTitle: 'Tool options',
        sectionDescription:
            'These details help renters choose the right tool for the job.',
        child: Column(
          children: spaced([
            buildCreateListingRadioField(
              label: 'Power source',
              value: chunk.powerSource.value,
              icon: Icons.bolt_outlined,
              options:
                  ToolPowerSource.values
                      .map((item) => FormOption(item.value, item.label))
                      .toList(),
              onChanged: (value) => chunk.powerSource.value = value,
            ),
            buildCreateListingRadioField(
              label: 'Skill level',
              value: chunk.skillLevel.value,
              icon: Icons.school_outlined,
              options:
                  SkillLevel.values
                      .map((item) => FormOption(item.value, item.label))
                      .toList(),
              onChanged: (value) => chunk.skillLevel.value = value,
            ),
          ]),
        ),
      );
    default:
      return CreateListingDynamicDetailsStepContent(
        title: 'Tool requirements',
        description: 'Set safety and consumable details.',
        sectionTitle: 'Requirements',
        sectionDescription:
            'These toggles let renters know what they may need before pickup.',
        child: Column(
          children: spaced([
            buildCreateListingSwitchTile(
              'Safety gear required',
              chunk.safetyGearRequired.value,
              (value) => chunk.safetyGearRequired.value = value,
              subtitle:
                  'Turn this on if renters should wear safety gear such as gloves, goggles, or a mask.',
            ),
            buildCreateListingSwitchTile(
              'Consumables included',
              chunk.consumablesIncluded.value,
              (value) => chunk.consumablesIncluded.value = value,
              subtitle:
                  'Turn this on if consumables like blades, bits, sandpaper, fuel, or cleaning solution are included.',
            ),
          ]),
        ),
      );
  }
}

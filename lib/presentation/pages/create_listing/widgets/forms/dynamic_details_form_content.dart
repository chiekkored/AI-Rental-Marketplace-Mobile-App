import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/dynamic_details_fields.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingDynamicDetailsStepContent {
  const CreateListingDynamicDetailsStepContent({
    required this.title,
    required this.description,
    required this.sectionTitle,
    required this.sectionDescription,
    required this.child,
    this.required = false,
    this.canContinue = true,
    this.listenables = const [],
  });

  final String title;
  final String description;
  final String sectionTitle;
  final String sectionDescription;
  final Widget child;
  final bool required;
  final bool canContinue;
  final List<Listenable> listenables;
}

CreateListingDynamicDetailsStepContent buildBrandModelStep({
  required String title,
  required String description,
  required TextEditingController brandController,
  required TextEditingController modelController,
}) {
  final listenables = [brandController, modelController];
  return CreateListingDynamicDetailsStepContent(
    title: title,
    description: description,
    sectionTitle: 'Brand and model',
    sectionDescription: 'These details identify the item.',
    canContinue: areControllersFilled(listenables),
    listenables: listenables,
    child: Column(
      children: spaced([
        CreateListingSection(
          title: 'Brand',
          required: true,
          description: 'Please enter the brand.',
          child: formTextField(
            controller: brandController,
            required: true,
            hintText: 'e.g.,Sony',
          ),
        ),
        CreateListingSection(
          title: 'Model',
          required: true,
          description: 'Please enter the model. Write "N/A" if not applicable.',
          child: formTextField(
            controller: modelController,
            hintText: 'e.g.,A6400',
            required: true,
          ),
        ),
      ]),
    ),
  );
}

CreateListingDynamicDetailsStepContent buildListStep({
  required BuildContext context,
  required String title,
  required String description,
  required String sectionTitle,
  required String sectionDescription,
  required String label,
  required TextEditingController controller,
  required List<String> values,
  required ValueChanged<List<String>> onChanged,
  String? hintText,
}) {
  return CreateListingDynamicDetailsStepContent(
    title: title,
    description: description,
    sectionTitle: sectionTitle,
    sectionDescription: sectionDescription,
    child: createListingListEditor(
      context: context,
      label: label,
      controller: controller,
      values: values,
      onChanged: onChanged,
      hintText: hintText,
    ),
  );
}

Widget buildCreateListingRadioField({
  required String label,
  required String value,
  required IconData icon,
  required List<FormOption> options,
  required ValueChanged<String> onChanged,
}) {
  return CreateListingRadioField(
    label: label,
    value: value,
    icon: icon,
    placeholder: 'Choose $label',
    items:
        options
            .map(
              (option) =>
                  LNDRadioItem<String>(text: option.label, value: option.value),
            )
            .toList(),
    onChanged: onChanged,
  );
}

Widget buildCreateListingSwitchTile(
  String title,
  bool value,
  ValueChanged<bool> onChanged, {
  String? subtitle,
}) {
  return SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    value: value,
    subtitle:
        subtitle != null
            ? LNDText.regular(
              text: subtitle,
              fontSize: 12.0,
              color: Get.context?.lndTheme.textMuted,
              overflow: TextOverflow.visible,
            )
            : null,
    title: LNDText.medium(text: title, overflow: TextOverflow.visible),
    onChanged: onChanged,
  );
}

Widget buildControllerStepper(
  String label,
  TextEditingController controller, {
  int minimum = 0,
  String subtitle = '',
}) {
  final value = controllerInt(controller, fallback: minimum);
  return CreateListingNumberStepper(
    label: label,
    subtitle: subtitle,
    value: value,
    minimum: minimum,
    onChanged: (next) => controller.text = next.toString(),
  );
}

int controllerInt(TextEditingController controller, {required int fallback}) {
  return int.tryParse(controller.text.replaceAll(',', '').trim()) ?? fallback;
}

bool isControllerFilled(TextEditingController controller) {
  return controller.text.trim().isNotEmpty;
}

bool areControllersFilled(Iterable<TextEditingController> controllers) {
  return controllers.every(isControllerFilled);
}

bool hasPositiveControllerInt(TextEditingController controller) {
  return controllerInt(controller, fallback: 0) >= 1;
}

bool havePositiveControllerInts(Iterable<TextEditingController> controllers) {
  return controllers.every(hasPositiveControllerInt);
}

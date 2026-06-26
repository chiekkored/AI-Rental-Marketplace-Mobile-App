import 'package:flutter/material.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class FormOption {
  final String value;
  final String label;

  const FormOption(this.value, this.label);
}

Widget formTextField({
  required TextEditingController controller,
  String label = '',
  String? hintText,
  bool required = false,
  bool number = false,
  int maxLength = 100,
  int maxLines = 1,
  FormFieldValidator<String>? validator,
}) {
  return LNDTextField.regular(
    controller: controller,
    labelText: label.isNotEmpty ? label : null,
    hintText: hintText,
    required: required,
    borderRadius: 12,
    keyboardType: number ? TextInputType.number : TextInputType.text,
    textCapitalization:
        number ? TextCapitalization.none : TextCapitalization.sentences,
    maxLength: maxLength,
    maxLines: maxLines,
    displayCommas: false,
    validator: (value) {
      if (required && (value == null || value.trim().isEmpty)) {
        return '$label is required';
      }
      return validator?.call(value);
    },
  );
}

Widget formTextBox({
  required TextEditingController controller,
  String label = '',
  String? hintText,
  bool required = false,
  int maxLength = 100,
  int maxLines = 4,
}) {
  return LNDTextField.textBox(
    controller: controller,
    labelText: label.isNotEmpty ? label : null,
    hintText: hintText,
    required: required,
    borderRadius: 12,
    maxLength: maxLength,
    maxLines: maxLines,
    validator:
        required
            ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
            : null,
  );
}

Widget formDropdown({
  required BuildContext context,
  required String label,
  required String value,
  required List<FormOption> options,
  required ValueChanged<String?> onChanged,
}) {
  final colors = context.lndTheme;
  final hasValue = options.any((option) => option.value == value);
  return DropdownButtonFormField<String>(
    initialValue: hasValue ? value : options.first.value,
    decoration: LNDTextField.inputDecoration(
      colors: colors,
      labelText: label,
      borderRadius: 12,
    ),
    items:
        options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.value,
                child: LNDText.regular(text: option.label),
              ),
            )
            .toList(),
    onChanged: onChanged,
  );
}

Widget formSwitch({
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: LNDText.medium(text: title),
    value: value,
    onChanged: onChanged,
  );
}

Widget formChipEditor({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required List<String> values,
  required ValueChanged<List<String>> onChanged,
  String? hintText = 'Add item',
}) {
  final colors = context.lndTheme;
  return StatefulBuilder(
    builder: (context, setState) {
      void addValue() {
        final value = controller.text.trim();
        if (value.isEmpty || values.contains(value)) return;
        controller.clear();
        onChanged([...values, value]);
        setState(() {});
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) LNDText.medium(text: label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LNDTextField.regular(
                  controller: controller,
                  hintText: hintText,
                  borderRadius: 12,
                  maxLength: 40,
                  onFieldSubmitted: (_) => addValue(),
                ),
              ),
              const SizedBox(width: 8),
              LNDButton.icon(
                icon: Icons.add_rounded,
                size: 32.0,
                onPressed: addValue,
                enabled: true,
                color: colors.primary,
              ),
            ],
          ),
          if (values.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  values
                      .map(
                        (value) => InputChip(
                          label: Text(value),
                          backgroundColor: colors.surfaceMuted,
                          onDeleted: () {
                            onChanged(
                              values
                                  .where((item) => item != value)
                                  .toList(growable: false),
                            );
                            setState(() {});
                          },
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      );
    },
  );
}

List<Widget> spaced(List<Widget> children) {
  return [
    for (var index = 0; index < children.length; index++) ...[
      if (index > 0) const SizedBox(height: 14),
      children[index],
    ],
  ];
}

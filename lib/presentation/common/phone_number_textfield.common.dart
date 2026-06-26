import 'package:flutter/material.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class LNDPhoneNumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String prefixText;
  final VoidCallback onPrefixPressed;
  final String? Function(String?)? validator;

  const LNDPhoneNumberTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixText,
    required this.onPrefixPressed,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return LNDTextField.regular(
      labelText: 'Phone number',
      hintText: hintText,
      controller: controller,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      required: true,
      prefixWidget: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: LNDButton.text(
          text: prefixText,
          enabled: true,
          hasPadding: false,
          color: colors.primary,
          onPressed: onPrefixPressed,
        ),
      ),
      validator: validator,
    );
  }
}

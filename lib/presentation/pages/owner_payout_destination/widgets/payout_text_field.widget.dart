import 'package:flutter/material.dart';
import 'package:lend/presentation/common/textfields.common.dart';

class PayoutTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const PayoutTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.enabled,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: LNDTextField.regular(
        controller: controller,
        required: true,
        labelText: label,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        borderRadius: 8.0,
        readOnly: !enabled,
        maxLength: 120,
        displayCommas: false,
      ),
    );
  }
}

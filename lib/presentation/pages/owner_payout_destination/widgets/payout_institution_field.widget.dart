import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';

class PayoutInstitutionField
    extends GetWidget<OwnerPayoutDestinationController> {
  final String label;
  final String hintText;
  final bool enabled;

  const PayoutInstitutionField({
    super.key,
    required this.label,
    required this.hintText,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: LNDTextField.regular(
        controller: controller.bankNameController,
        labelText: label,
        hintText: hintText,
        borderRadius: 8.0,
        readOnly: true,
        onTap: enabled ? controller.selectInstitution : null,
        suffixIcon: enabled ? Icons.chevron_right_rounded : null,
        maxLength: 120,
      ),
    );
  }
}

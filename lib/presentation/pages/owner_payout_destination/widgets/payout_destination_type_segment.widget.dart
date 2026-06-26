import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PayoutDestinationTypeSegment
    extends GetWidget<OwnerPayoutDestinationController> {
  const PayoutDestinationTypeSegment({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(
      () => SegmentedButton<String>(
        showSelectedIcon: false,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? colors.primary
                    : colors.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? colors.textInverse
                    : colors.textPrimary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: colors.outline)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        segments: const [
          ButtonSegment(value: 'bank', label: Text('Bank Account')),
          ButtonSegment(value: 'ewallet', label: Text('E-wallet')),
        ],
        selected: {controller.destinationType.value},
        onSelectionChanged:
            controller.fieldsEnabled
                ? (values) => controller.setDestinationType(values.first)
                : null,
      ),
    );
  }
}

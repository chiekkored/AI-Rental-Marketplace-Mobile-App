import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class RateModeSegment extends GetWidget<CalendarPickerController> {
  const RateModeSegment({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final availableRateModes = controller.availableRateModes;
    if (availableRateModes.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: SegmentedButton<BookingRateMode>(
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
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            segments:
                availableRateModes
                    .map(
                      (mode) => ButtonSegment<BookingRateMode>(
                        value: mode,
                        label: Text(mode.label),
                      ),
                    )
                    .toList(),
            selected: {controller.selectedRateMode},
            onSelectionChanged:
                controller.args.isReadOnly
                    ? null
                    : (values) => controller.onRateModeChanged(values.first),
          ),
        ),
      ),
    );
  }
}

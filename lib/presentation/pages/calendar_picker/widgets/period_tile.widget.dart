import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PeriodTile extends GetWidget<CalendarPickerController> {
  const PeriodTile({super.key, required this.period});

  final DateTime period;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(() {
      final isSelected = _isPeriodInSelectedRange();
      final label =
          controller.selectedRateMode == BookingRateMode.monthly
              ? DateFormat('MMM yyyy').format(period)
              : period.year.toString();

      return InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () => controller.onPeriodSelected(period),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surface,
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: LNDText.regular(
              text: label,
              color: isSelected ? colors.textInverse : colors.textPrimary,
              fontSize: 14.0,
            ),
          ),
        ),
      );
    });
  }

  bool _isPeriodInSelectedRange() {
    if (controller.periodDates.isEmpty) return false;

    final periodIndex = _periodIndex(period);
    final startIndex = _periodIndex(controller.periodDates.first);
    if (controller.periodDates.length < 2) return periodIndex == startIndex;

    final endIndex = _periodIndex(controller.periodDates.last);
    return periodIndex >= startIndex && periodIndex <= endIndex;
  }

  int _periodIndex(DateTime date) {
    return controller.selectedRateMode == BookingRateMode.monthly
        ? date.year * 12 + date.month
        : date.year;
  }
}

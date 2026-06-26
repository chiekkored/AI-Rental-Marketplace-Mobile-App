import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class DayRangeCalendar extends GetWidget<CalendarPickerController> {
  const DayRangeCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(
      () => CalendarDatePicker2(
        value: controller.selectedDates,
        onValueChanged: controller.onCalendarChanged,
        config: CalendarDatePicker2Config(
          disableVibration: false,
          allowSameValueSelection: false,
          calendarType: CalendarDatePicker2Type.range,
          calendarViewMode: CalendarDatePicker2Mode.scroll,
          dayModeScrollDirection: Axis.vertical,
          firstDate: controller.firstSelectableDate,
          lastDate: controller.lastSelectableDate,
          todayTextStyle: LNDText.boldStyle.copyWith(color: colors.textPrimary),
          selectedDayHighlightColor: colors.primary,
          selectedRangeHighlightColor: colors.primary.withValues(alpha: 0.3),
          daySplashColor: colors.primary.withValues(alpha: 0.5),
          selectableDayPredicate:
              (day) =>
                  controller.checkAvailability(day) &&
                  !controller.args.isReadOnly,
          dayBuilder: ({
            required date,
            decoration,
            isDisabled,
            isSelected,
            isToday,
            textStyle,
          }) {
            Color color = colors.textPrimary;
            if (isDisabled ?? false) color = colors.textMuted;
            if (isSelected ?? false) color = colors.onPrimary;
            final isBooked = !controller.checkAvailability(date);

            return Container(
              decoration: decoration,
              child: Center(
                child:
                    (isToday ?? false)
                        ? LNDText.bold(
                          text: date.day.toString(),
                          fontSize: 18.0,
                          color: colors.danger,
                        )
                        : LNDText.regular(
                          text: date.day.toString(),
                          fontSize: 16.0,
                          color: isBooked ? colors.primary : color,
                          textDecoration:
                              isBooked ? TextDecoration.lineThrough : null,
                        ),
              ),
            );
          },
        ),
      ),
    );
  }
}

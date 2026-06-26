import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/day_range_calendar.widget.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/extra_days_tile.widget.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/period_range_calendar.widget.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/rate_mode_segment.widget.dart';

class CalendarView extends GetWidget<CalendarPickerController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const RateModeSegment(),
          Expanded(
            child: Obx(
              () =>
                  controller.isDayRangeMode
                      ? const DayRangeCalendar()
                      : const PeriodRangeCalendar(),
            ),
          ),
          Obx(
            () =>
                controller.canShowExtraDays
                    ? const ExtraDaysTile()
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

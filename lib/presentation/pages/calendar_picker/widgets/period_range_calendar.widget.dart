import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/period_tile.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PeriodRangeCalendar extends GetWidget<CalendarPickerController> {
  const PeriodRangeCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rateMode = controller.selectedRateMode;
      final periods =
          rateMode == BookingRateMode.monthly
              ? _buildMonths(
                controller.firstSelectableDate,
                controller.lastSelectableDate,
              )
              : _buildYears(
                controller.firstSelectableDate,
                controller.lastSelectableDate,
              );
      final canShowMore = controller.canShowMorePeriods;

      return GridView.builder(
        key: ValueKey(rateMode),
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 52.0,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: periods.length + (canShowMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == periods.length) {
            return _MorePeriodTile(key: ValueKey('${rateMode.name}-more'));
          }

          final period = periods[index];
          return PeriodTile(
            key: ValueKey('${rateMode.name}-${period.year}-${period.month}'),
            period: period,
          );
        },
      );
    });
  }

  static List<DateTime> _buildMonths(DateTime firstDate, DateTime lastDate) {
    final periods = <DateTime>[];
    var current = DateTime(firstDate.year, firstDate.month);
    final last = DateTime(lastDate.year, lastDate.month);
    while (!current.isAfter(last)) {
      periods.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return periods;
  }

  static List<DateTime> _buildYears(DateTime firstDate, DateTime lastDate) {
    return [
      for (var year = firstDate.year; year <= lastDate.year; year++)
        DateTime(year, DateTime.january),
    ];
  }
}

class _MorePeriodTile extends GetWidget<CalendarPickerController> {
  const _MorePeriodTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: controller.onTapShowMorePeriods,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: LNDText.regular(
            text: 'More',
            color: colors.primary,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}

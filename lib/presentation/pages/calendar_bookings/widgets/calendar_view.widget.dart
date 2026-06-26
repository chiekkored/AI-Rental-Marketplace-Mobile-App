import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/calendar_bookings/calendar_bookings.controller.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/extensions/bookingStatus.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class CalendarView extends GetWidget<CalendarBookingsController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Column(
      children: [
        Expanded(
          child: Obx(
            () => CalendarDatePicker2(
              value: controller.selectedDates,
              onValueChanged: controller.onCalendarChanged,
              config: CalendarDatePicker2Config(
                disableVibration: false,
                allowSameValueSelection: false,
                calendarType: CalendarDatePicker2Type.single,
                calendarViewMode: CalendarDatePicker2Mode.scroll,
                dayModeScrollDirection: Axis.vertical,
                firstDate: controller.calendarFirstDate,
                lastDate: controller.calendarLastDate,
                todayTextStyle: LNDText.boldStyle.copyWith(
                  color: colors.textPrimary,
                ),
                selectedDayHighlightColor: colors.primary,
                selectedRangeHighlightColor: colors.primary.withValues(
                  alpha: 0.3,
                ),
                daySplashColor: colors.primary.withValues(alpha: 0.5),
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
                  final bookingColors = controller.getBookingColors(date);
                  final isBooked = controller.checkAvailability(date);

                  return Container(
                    decoration: decoration,
                    child: Center(
                      child:
                          (isToday ?? false)
                              ? LNDText.bold(
                                text: date.day.toString(),
                                fontSize: 16.0,
                                color: colors.danger,
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LNDText.regular(
                                    text: date.day.toString(),
                                    fontSize: 12.0,
                                    color: color,
                                    textDecoration:
                                        isBooked
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        bookingColors.reversed.map((color) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          height: Get.height / 3,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outline)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Visibility(
                    visible: controller.selectedDate != null,
                    child: LNDText.bold(
                      text: controller.selectedDate.toMonthDayYear(),
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              Obx(() {
                // ignore: prefer_is_empty
                if (controller.selectedDayBookings.length == 0) {
                  return Expanded(
                    child: Center(
                      child: LNDText.regular(
                        text: 'Select a date',
                        color: colors.textMuted,
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.selectedDayBookings.length,
                    separatorBuilder: (_, _) => Divider(color: colors.outline),
                    itemBuilder: (_, index) {
                      final coloredBooking =
                          controller.selectedDayBookings[index];

                      final booking = coloredBooking.booking;
                      final color = coloredBooking.color;

                      final dates = LNDUtils.getDateRange(
                        start: LNDUtils.bookingDateFromTimestamp(
                          booking.startDate,
                        ),
                        end: LNDUtils.bookingDateFromTimestamp(booking.endDate),
                      );

                      final isPending = booking.status == BookingStatus.pending;

                      return ListTile(
                        dense: true,
                        onTap: () => controller.goToBookingDetails(booking),
                        leading: CircleAvatar(
                          backgroundColor: color,
                          radius: 10.0,
                        ),
                        title: LNDVerifiedName(
                          name: booking.renter?.getName ?? 'Unknown user',
                          verificationLevel: booking.renter?.verified,
                          showBusinessBadge:
                              booking.renter?.hasDisplayName == true,
                          weight: LNDVerifiedNameWeight.medium,
                        ),
                        subtitle: LNDText.regular(
                          text: dates,
                          fontSize: 12.0,
                          color: colors.textMuted,
                          textParts: [
                            LNDText.regular(
                              text: ' • ',
                              color: colors.textMuted,
                            ),
                            LNDText.regular(
                              text: booking.status?.label ?? '',
                              fontSize: 12.0,
                              color:
                                  booking.status?.themedColor(colors) ??
                                  colors.textMuted,
                            ),
                          ],
                        ),
                        trailing: Row(
                          spacing: 4.0,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.outline,
                              ),
                              child: Center(
                                child: LNDButton.icon(
                                  icon: Icons.inbox_rounded,
                                  size: 25.0,
                                  onPressed:
                                      () => controller.onTapGoToChat(booking),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isPending,
                              child: Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.outline,
                                ),
                                child: Center(
                                  child: LNDButton.icon(
                                    icon: Icons.check_circle_rounded,
                                    color: colors.success,
                                    size: 25.0,
                                    onPressed:
                                        () => controller.onTapBooking(booking),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

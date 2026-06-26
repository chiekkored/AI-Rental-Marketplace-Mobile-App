import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/calendar_bookings/calendar_bookings.controller.dart';
import 'package:lend/presentation/pages/calendar_bookings/widgets/booking_list_view.widget.dart';
import 'package:lend/presentation/pages/calendar_bookings/widgets/calendar_bookings_view_sheet.widget.dart';
import 'package:lend/presentation/pages/calendar_bookings/widgets/calendar_view.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CalendarBookingsPage extends GetView<CalendarBookingsController> {
  static const routeName = '/calendar-bookings';
  const CalendarBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: LNDButton.back(),
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: LNDText.semibold(
                    text: 'All Bookings',
                    color: colors.textMuted,
                    fontSize: 13.0,
                  ),
                ),
                Obx(
                  () => IconButton(
                    icon: Icon(controller.viewModeIcon),
                    onPressed: _showViewModeSheet,
                    tooltip: 'Change view',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () =>
                  controller.viewMode == CalendarBookingsViewMode.calendar
                      ? const CalendarView()
                      : const BookingListView(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showViewModeSheet() async {
    final selected = await LNDShow.bottomSheet<CalendarBookingsViewMode>(
      CalendarBookingsViewSheet(selectedMode: controller.viewMode),
    );
    if (selected == null) return;
    controller.setViewMode(selected);
  }
}

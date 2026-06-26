import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/calendar_bookings/calendar_bookings.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CalendarBookingsViewSheet extends StatelessWidget {
  const CalendarBookingsViewSheet({super.key, required this.selectedMode});

  final CalendarBookingsViewMode selectedMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(text: 'View bookings as', fontSize: 18.0),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewModeTile(
                    icon: Icons.calendar_month_outlined,
                    isSelected:
                        selectedMode == CalendarBookingsViewMode.calendar,
                    label: 'Calendar',
                    mode: CalendarBookingsViewMode.calendar,
                  ),
                  Divider(height: 1.0, color: colors.outline),
                  _ViewModeTile(
                    icon: Icons.list_rounded,
                    isSelected: selectedMode == CalendarBookingsViewMode.list,
                    label: 'List',
                    mode: CalendarBookingsViewMode.list,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeTile extends StatelessWidget {
  const _ViewModeTile({
    required this.icon,
    required this.isSelected,
    required this.label,
    required this.mode,
  });

  final IconData icon;
  final bool isSelected;
  final String label;
  final CalendarBookingsViewMode mode;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ListTile(
      leading: Icon(icon, color: colors.textPrimary),
      onTap: () => Get.back(result: mode),
      title: LNDText.medium(text: label),
      trailing:
          isSelected
              ? Icon(Icons.check_rounded, color: colors.primary)
              : const SizedBox(width: 24.0),
    );
  }
}

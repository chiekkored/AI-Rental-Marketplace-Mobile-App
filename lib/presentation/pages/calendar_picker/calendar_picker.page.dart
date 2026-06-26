import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/bottom_nav.widget.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/calendar_view.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CalendarPickerPage extends GetView<CalendarPickerController> {
  static const routeName = '/calendar-picker';
  const CalendarPickerPage({super.key});

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
      body: const CalendarView(),
      bottomNavigationBar:
          controller.args.isReadOnly ? null : const CalendarBottomNav(),
    );
  }
}

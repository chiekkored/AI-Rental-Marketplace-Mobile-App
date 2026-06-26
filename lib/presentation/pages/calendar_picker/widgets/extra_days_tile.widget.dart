import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ExtraDaysTile extends GetWidget<CalendarPickerController> {
  const ExtraDaysTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outline, width: 0.5)),
      ),
      child: ListTile(
        dense: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.regular(text: 'Add extra days'),
            Obx(
              () =>
                  controller.selectedExtraDateRangeText.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: LNDText.regular(
                          text: controller.selectedExtraDateRangeText,
                          color: colors.textMuted,
                          fontSize: 13.0,
                        ),
                      ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
        onTap: controller.onTapAddExtraDays,
      ),
    );
  }
}

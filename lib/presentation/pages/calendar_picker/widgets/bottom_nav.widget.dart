import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:pluralize/pluralize.dart';

class CalendarBottomNav extends GetWidget<CalendarPickerController> {
  const CalendarBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outline, width: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.minimumNights case final minimumNights?
                    when minimumNights > 1) ...[
                  LNDWarningBanner(
                    content: LNDText.regular(
                      text:
                          'This listing requires a minimum stay of $minimumNights ${Pluralize().pluralize('night', minimumNights, false)}.',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
                const _SelectedDateRangeCards(),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              LNDText.bold(
                                text:
                                    '${LNDMoney.formatRate(controller.totalPrice, controller.args.rates)} ',
                                fontSize: 18.0,
                              ),
                              if (controller.totalDays > 0 &&
                                  controller.totalDays <= 7)
                                LNDText.regular(
                                  text:
                                      '(${Pluralize().pluralize('day', controller.totalDays, true)})',
                                  fontSize: 12.0,
                                  color: colors.textMuted,
                                ),
                            ],
                          ),
                          if (controller.totalDays > 7)
                            LNDButton.text(
                              text: 'Breakdown',
                              enabled: true,
                              onPressed: () => _showBreakdownSheet(),
                              hasPadding: false,
                              size: 12.0,
                              isBold: true,
                            ),
                        ],
                      ),
                    ),
                    Obx(
                      () => LNDButton.primary(
                        text: 'Proceed Payment',
                        enabled: controller.canSubmit,
                        onPressed: controller.onTapSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBreakdownSheet() {
    if (!controller.hasSelectedDateRange) return;

    final lines = BookingPriceBreakdown.calculate(
      rates: controller.args.rates,
      startDate: controller.selectedDates.first,
      endDate: controller.selectedDates.last,
    );
    LNDShow.bottomSheet(
      _CalendarRateBreakdownSheet(lines: lines, total: controller.totalPrice),
      expand: false,
    );
  }
}

class _CalendarRateBreakdownSheet extends GetWidget<CalendarPickerController> {
  const _CalendarRateBreakdownSheet({required this.lines, required this.total});

  final List<BookingPriceBreakdownLine> lines;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final displayLines = BookingPriceBreakdown.displayLines(lines);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(text: 'Breakdown', fontSize: 18.0),
            const SizedBox(height: 8.0),
            for (final line in displayLines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LNDText.regular(
                        text:
                            '${line.label} ${LNDMoney.formatRate(line.rate, controller.args.rates)}',
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    LNDText.semibold(
                      text: LNDMoney.formatRate(
                        line.amount,
                        controller.args.rates,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LNDText.bold(text: 'Total'),
                LNDText.bold(
                  text: LNDMoney.formatRate(total, controller.args.rates),
                  color: colors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDateRangeCards extends GetWidget<CalendarPickerController> {
  const _SelectedDateRangeCards();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(() {
      if (!controller.hasSelectedDateRange) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: _DateRangeCard(
                label: 'Start',
                value: controller.selectedStartDateText,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(8.0),
                ),
              ),
            ),
            Container(width: 1.0, height: 48.0, color: colors.outline),
            Expanded(
              child: _DateRangeCard(
                label: 'End',
                value: controller.selectedEndDateText,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({
    required this.label,
    required this.value,
    required this.borderRadius,
  });

  final String label;
  final String value;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.outline),
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LNDText.regular(
              text: label,
              color: colors.textMuted,
              fontSize: 11.0,
            ),
            const SizedBox(height: 2.0),
            LNDText.bold(text: value, fontSize: 13.0, maxLines: 1),
          ],
        ),
      ),
    );
  }
}

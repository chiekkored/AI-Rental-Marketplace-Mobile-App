import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

enum BookingRateMode { daily, weekly, monthly, yearly }

extension BookingRateModeLabel on BookingRateMode {
  String get label {
    return switch (this) {
      BookingRateMode.daily => 'Daily',
      BookingRateMode.weekly => 'Weekly',
      BookingRateMode.monthly => 'Monthly',
      BookingRateMode.yearly => 'Yearly',
    };
  }
}

class CalendarPickerPageArgs {
  final bool isReadOnly;
  final List<DateTime> dates;
  final Rates rates;
  final int? minimumNights;
  final void Function(List<DateTime> dates, int total) onSubmit;

  CalendarPickerPageArgs({
    required this.isReadOnly,
    required this.dates,
    required this.rates,
    this.minimumNights,
    required this.onSubmit,
  });
}

class CalendarPickerController extends GetxController {
  static CalendarPickerController get instance =>
      Get.find<CalendarPickerController>();

  final args = Get.arguments as CalendarPickerPageArgs;

  final RxList<DateTime> _selectedDates = <DateTime>[].obs;
  List<DateTime> get selectedDates => _selectedDates;

  final RxList<DateTime> _periodDates = <DateTime>[].obs;
  List<DateTime> get periodDates => _periodDates;

  final RxList<DateTime> _extraDates = <DateTime>[].obs;
  List<DateTime> get extraDates => _extraDates;

  final Rxn<DateTime> _basePeriodEndDate = Rxn<DateTime>();
  DateTime? get basePeriodEndDate => _basePeriodEndDate.value;

  late final Rx<BookingRateMode> _selectedRateMode = defaultRateMode.obs;
  BookingRateMode get selectedRateMode => _selectedRateMode.value;

  late final RxList<DateTime> _blockedDates = args.dates.obs;
  List<DateTime> get blockedDates => _blockedDates;

  final RxInt _totalPrice = 0.obs;
  int get totalPrice => _totalPrice.value;

  final RxInt _totalDays = 0.obs;
  int get totalDays => _totalDays.value;

  late final Rx<DateTime> _lastSelectableDate = _initialLastSelectableDate.obs;
  DateTime get lastSelectableDate => _lastSelectableDate.value;

  int? get minimumNights {
    final value = args.minimumNights;
    return value != null && value > 0 ? value : null;
  }

  bool get meetsMinimumNights =>
      minimumNights == null || totalDays >= minimumNights!;

  bool get canSubmit => totalDays > 0 && meetsMinimumNights;

  DateTime get firstSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  DateTime get _initialLastSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year + 1, now.month, now.day);
  }

  DateTime get maxSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year + 5, now.month, now.day);
  }

  bool get canShowMorePeriods =>
      isPeriodRangeMode &&
      !args.isReadOnly &&
      lastSelectableDate.isBefore(maxSelectableDate);

  List<BookingRateMode> get availableRateModes {
    final modes = <BookingRateMode>[];
    if (args.rates.daily != null) modes.add(BookingRateMode.daily);
    if (args.rates.weekly != null) modes.add(BookingRateMode.weekly);
    if (args.rates.monthly != null) modes.add(BookingRateMode.monthly);
    if (args.rates.annually != null) modes.add(BookingRateMode.yearly);
    return modes;
  }

  BookingRateMode get defaultRateMode {
    final modes = availableRateModes;
    if (modes.contains(BookingRateMode.daily)) return BookingRateMode.daily;
    return modes.firstOrNull ?? BookingRateMode.daily;
  }

  bool get isDayRangeMode =>
      selectedRateMode == BookingRateMode.daily ||
      selectedRateMode == BookingRateMode.weekly;

  bool get isPeriodRangeMode =>
      selectedRateMode == BookingRateMode.monthly ||
      selectedRateMode == BookingRateMode.yearly;

  bool get hasSelectedDateRange =>
      selectedDates.length >= 2 && selectedDates.first != selectedDates.last;

  bool get canShowExtraDays => isPeriodRangeMode && basePeriodEndDate != null;

  String get selectedStartDateText {
    if (!hasSelectedDateRange) {
      return '';
    }
    return selectedDates.first.toAbbrMonthDayYear();
  }

  String get selectedEndDateText {
    if (!hasSelectedDateRange) {
      return '';
    }
    return selectedDates.last.toAbbrMonthDayYear();
  }

  String get selectedExtraDateRangeText {
    if (extraDates.length < 2 || extraDates.first == extraDates.last) {
      return '';
    }
    return '${extraDates.first.toAbbrMonthDayYear()} -> ${extraDates.last.toAbbrMonthDayYear()}';
  }

  @override
  void onClose() {
    _selectedDates.close();
    _periodDates.close();
    _extraDates.close();
    _basePeriodEndDate.close();
    _selectedRateMode.close();
    _blockedDates.close();
    _totalPrice.close();
    _totalDays.close();
    _lastSelectableDate.close();

    super.onClose();
  }

  void onTapSubmit() {
    if (!canSubmit) return;
    args.onSubmit.call(selectedDates, totalPrice);
  }

  void onTapShowMorePeriods() {
    if (!canShowMorePeriods) return;

    final nextDate = DateTime(
      lastSelectableDate.year,
      lastSelectableDate.month + 12,
      lastSelectableDate.day,
    );
    _lastSelectableDate.value =
        nextDate.isAfter(maxSelectableDate) ? maxSelectableDate : nextDate;
  }

  void onRateModeChanged(BookingRateMode mode) {
    if (args.isReadOnly || selectedRateMode == mode) return;
    _selectedRateMode.value = mode;
    _clearSelection(resetSelectableWindow: true);
  }

  void _clearSelection({bool resetSelectableWindow = false}) {
    _selectedDates.clear();
    _periodDates.clear();
    _extraDates.clear();
    _basePeriodEndDate.value = null;
    _totalPrice.value = 0;
    _totalDays.value = 0;
    if (resetSelectableWindow) {
      _lastSelectableDate.value = _initialLastSelectableDate;
    }
  }

  void onCalendarChanged(List<DateTime> dates) async {
    if (args.isReadOnly) return;
    if (dates.isEmpty) return;

    if (dates.first == dates.last) {
      _selectedDates.value = [dates.last];
      _extraDates.clear();
      _totalPrice.value = 0;
      _totalDays.value = 0;
      return;
    }

    final startDate = LNDUtils.normalizeToDay(dates.first);
    final endDate = LNDUtils.normalizeToDay(dates.last);
    final days = LNDUtils.exclusiveDayCount(startDate, endDate);

    if (selectedRateMode == BookingRateMode.weekly && days < 7) {
      _selectedRateMode.value = BookingRateMode.daily;
    } else if (selectedRateMode == BookingRateMode.daily &&
        days >= 7 &&
        availableRateModes.contains(BookingRateMode.weekly)) {
      _selectedRateMode.value = BookingRateMode.weekly;
    }

    if (!_isRangeAvailable(startDate, endDate)) {
      _applySelectedRange(startDate, endDate, fallbackAnchor: dates.last);
      return;
    }

    if (_shouldConfirmMonthlyShift(startDate, endDate)) {
      final applied = await _confirmMonthlyShiftIfNeeded(startDate, endDate);
      if (applied) return;
    }

    _applySelectedRange(startDate, endDate, fallbackAnchor: dates.last);
  }

  Future<void> onPeriodSelected(DateTime periodDate) async {
    if (args.isReadOnly || !isPeriodRangeMode) return;

    final normalizedPeriod = _normalizePeriod(periodDate);

    if (periodDates.isEmpty || periodDates.length > 1) {
      final startDate = await _pickPeriodStartDate(normalizedPeriod);
      if (startDate == null) return;
      _startPeriodSelection(normalizedPeriod, startDate);
      return;
    }

    if (normalizedPeriod.isBefore(periodDates.first)) {
      final startDate = await _pickPeriodStartDate(normalizedPeriod);
      if (startDate == null) return;
      _startPeriodSelection(normalizedPeriod, startDate);
      return;
    }

    final startDate = selectedDates.isEmpty ? null : selectedDates.first;
    if (startDate == null) return;

    final endDate = _sameDayInPeriod(startDate, normalizedPeriod);
    _periodDates.value = [periodDates.first, normalizedPeriod];
    _extraDates.clear();
    _basePeriodEndDate.value =
        _isRangeAvailable(startDate, endDate)
            ? LNDUtils.normalizeToDay(endDate)
            : null;
    _applySelectedRange(startDate, endDate, fallbackAnchor: startDate);
  }

  Future<void> onTapAddExtraDays() async {
    final extraStartDate = basePeriodEndDate;
    if (!canShowExtraDays || extraStartDate == null || !hasSelectedDateRange) {
      return;
    }

    final result = await _pickExtraEndDate(
      LNDUtils.normalizeToDay(extraStartDate),
    );
    if (result == null) return;

    if (result.clear) {
      _extraDates.clear();
      _applySelectedRange(
        selectedDates.first,
        extraStartDate,
        fallbackAnchor: extraStartDate,
      );
      return;
    }

    final pickedDate = result.endDate;
    if (pickedDate == null) return;

    final endDate = LNDUtils.normalizeToDay(pickedDate);
    if (!endDate.isAfter(extraStartDate)) return;
    if (!_isRangeAvailable(extraStartDate, endDate)) {
      LNDSnackbar.showWarning('Selected extra dates are unavailable.');
      return;
    }

    _extraDates.value = [extraStartDate, endDate];
    _applySelectedRange(
      selectedDates.first,
      endDate,
      fallbackAnchor: extraStartDate,
    );
  }

  bool checkAvailability(DateTime date) {
    final normalizedDate = LNDUtils.normalizeToDay(date);

    return !(blockedDates.any(
      (av) => LNDUtils.normalizeToDay(av) == normalizedDate,
    ));
  }

  void setBlockedDates(List<DateTime> dates, {bool clearSelection = true}) {
    _blockedDates.value = dates.map(LNDUtils.normalizeToDay).toList();
    if (clearSelection) {
      _selectedDates.clear();
      _periodDates.clear();
      _extraDates.clear();
      _basePeriodEndDate.value = null;
      _totalPrice.value = 0;
      _totalDays.value = 0;
    }
  }

  Future<bool> _confirmMonthlyShiftIfNeeded(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final confirmed = await LNDShow.alertDialog<bool>(
      title: 'Use monthly rate?',
      content:
          'This booking is 30 days or longer. Continue with monthly date selection?',
      cancelText: 'Keep Dates',
      confirmText: 'Use Monthly',
    );
    if (confirmed != true) return false;

    _selectedRateMode.value = BookingRateMode.monthly;
    _periodDates.value = [DateTime(startDate.year, startDate.month)];
    _selectedDates.value = [startDate];
    _extraDates.clear();
    _basePeriodEndDate.value = null;
    _totalPrice.value = 0;
    _totalDays.value = 0;
    return true;
  }

  bool _shouldConfirmMonthlyShift(DateTime startDate, DateTime endDate) {
    if (Get.testMode) return false;
    final canShiftToMonthly = availableRateModes.contains(
      BookingRateMode.monthly,
    );
    if (!canShiftToMonthly || selectedRateMode == BookingRateMode.monthly) {
      return false;
    }

    final days = LNDUtils.exclusiveDayCount(startDate, endDate);
    return days >= 30;
  }

  void _applySelectedRange(
    DateTime startDate,
    DateTime endDate, {
    required DateTime fallbackAnchor,
  }) {
    final normalizedStart = LNDUtils.normalizeToDay(startDate);
    final normalizedEnd = LNDUtils.normalizeToDay(endDate);

    if (!normalizedEnd.isAfter(normalizedStart)) {
      _selectedDates.value = [fallbackAnchor];
      _extraDates.clear();
      if (isDayRangeMode) _basePeriodEndDate.value = null;
      _totalPrice.value = 0;
      _totalDays.value = 0;
      return;
    }

    if (!_isRangeAvailable(normalizedStart, normalizedEnd)) {
      _selectedDates.value = [fallbackAnchor];
      _extraDates.clear();
      if (isDayRangeMode) _basePeriodEndDate.value = null;
      _totalPrice.value = 0;
      _totalDays.value = 0;
      return;
    }

    _selectedDates.value = [normalizedStart, normalizedEnd];
    _calculateTotalPrice();
  }

  void _startPeriodSelection(DateTime normalizedPeriod, DateTime startDate) {
    _periodDates.value = [normalizedPeriod];
    _selectedDates.value = [startDate];
    _extraDates.clear();
    _basePeriodEndDate.value = null;
    _totalPrice.value = 0;
    _totalDays.value = 0;
  }

  bool _isRangeAvailable(DateTime startDate, DateTime endDate) {
    return !blockedDates.any(
      (date) => LNDUtils.isDateWithinExclusiveEndRange(
        date: date,
        start: startDate,
        end: endDate,
      ),
    );
  }

  DateTime _normalizePeriod(DateTime date) {
    return switch (selectedRateMode) {
      BookingRateMode.monthly => DateTime(date.year, date.month),
      BookingRateMode.yearly => DateTime(date.year),
      _ => LNDUtils.normalizeToDay(date),
    };
  }

  DateTime _sameDayInPeriod(DateTime startDate, DateTime periodDate) {
    final targetYear = periodDate.year;
    final targetMonth =
        selectedRateMode == BookingRateMode.yearly
            ? startDate.month
            : periodDate.month;
    final maxDay = DateUtils.getDaysInMonth(targetYear, targetMonth);
    return DateTime(
      targetYear,
      targetMonth,
      startDate.day.clamp(1, maxDay).toInt(),
    );
  }

  Future<DateTime?> _pickPeriodStartDate(DateTime periodDate) {
    final periodFirstDate =
        selectedRateMode == BookingRateMode.yearly
            ? DateTime(periodDate.year)
            : DateTime(periodDate.year, periodDate.month);
    final periodLastDate =
        selectedRateMode == BookingRateMode.yearly
            ? DateTime(periodDate.year, 12, 31)
            : DateTime(
              periodDate.year,
              periodDate.month,
              DateUtils.getDaysInMonth(periodDate.year, periodDate.month),
            );

    final firstDate =
        firstSelectableDate.isAfter(periodFirstDate)
            ? firstSelectableDate
            : periodFirstDate;
    final lastDate =
        lastSelectableDate.isBefore(periodLastDate)
            ? lastSelectableDate
            : periodLastDate;

    if (firstDate.isAfter(lastDate)) return Future.value();

    return _showSingleDateSheet(
      title:
          selectedRateMode == BookingRateMode.yearly
              ? 'Choose start date'
              : 'Choose month start date',
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: firstDate,
      confirmText: 'Select',
    );
  }

  Future<({bool clear, DateTime? endDate})?> _pickExtraEndDate(
    DateTime baseEndDate,
  ) {
    return _showExtraDateRangeSheet(
      fixedStartDate: baseEndDate,
      initialEndDate:
          extraDates.length >= 2 && extraDates.last.isAfter(baseEndDate)
              ? extraDates.last
              : null,
    );
  }

  Future<({bool clear, DateTime? endDate})?> _showExtraDateRangeSheet({
    required DateTime fixedStartDate,
    DateTime? initialEndDate,
  }) {
    final fixedStart = LNDUtils.normalizeToDay(fixedStartDate);
    var selectedEndDate =
        initialEndDate == null ? null : LNDUtils.normalizeToDay(initialEndDate);

    return LNDShow.bottomSheet<({bool clear, DateTime? endDate})>(
      StatefulBuilder(
        builder: (context, setState) {
          final colors = context.lndTheme;
          final canClear =
              selectedEndDate != null ||
              (extraDates.length >= 2 && extraDates.last.isAfter(fixedStart));
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add extra days',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 360.0,
                    child: CalendarDatePicker2(
                      value: [
                        fixedStart,
                        if (selectedEndDate case final endDate?) endDate,
                      ],
                      onValueChanged: (dates) {
                        final pickedDate =
                            dates
                                .map(LNDUtils.normalizeToDay)
                                .where((date) => date != fixedStart)
                                .lastOrNull;
                        if (pickedDate == null ||
                            !pickedDate.isAfter(fixedStart)) {
                          return;
                        }
                        setState(() {
                          selectedEndDate = pickedDate;
                        });
                      },
                      config: CalendarDatePicker2Config(
                        calendarType: CalendarDatePicker2Type.range,
                        calendarViewMode: CalendarDatePicker2Mode.scroll,
                        dayModeScrollDirection: Axis.vertical,
                        firstDate: fixedStart,
                        lastDate: lastSelectableDate,
                        selectedRangeHighlightColor: colors.primary.withValues(
                          alpha: 0.3,
                        ),
                        selectedDayHighlightColor: colors.primary,
                        selectableDayPredicate:
                            (date) =>
                                LNDUtils.normalizeToDay(date) == fixedStart ||
                                checkAvailability(date),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: LNDButton.outlined(
                          text: 'Clear',
                          enabled: canClear,
                          onPressed:
                              canClear
                                  ? () => Get.back(
                                    result: (clear: true, endDate: null),
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: LNDButton.primary(
                          text: 'Add',
                          enabled:
                              selectedEndDate != null &&
                              selectedEndDate!.isAfter(fixedStart) &&
                              _isRangeAvailable(fixedStart, selectedEndDate!),
                          onPressed:
                              selectedEndDate == null
                                  ? null
                                  : () => Get.back(
                                    result: (
                                      clear: false,
                                      endDate: selectedEndDate,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      expand: false,
    );
  }

  Future<DateTime?> _showSingleDateSheet({
    required String title,
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime initialDate,
    required String confirmText,
  }) {
    var selectedDate = LNDUtils.normalizeToDay(initialDate);

    return LNDShow.bottomSheet<DateTime>(
      StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 360.0,
                    child: CalendarDatePicker2(
                      value: [selectedDate],
                      onValueChanged: (dates) {
                        final date = dates.isEmpty ? null : dates.first;
                        if (date == null) return;
                        setState(() {
                          selectedDate = LNDUtils.normalizeToDay(date);
                        });
                      },
                      config: CalendarDatePicker2Config(
                        calendarType: CalendarDatePicker2Type.single,
                        calendarViewMode: CalendarDatePicker2Mode.scroll,
                        dayModeScrollDirection: Axis.vertical,
                        firstDate: firstDate,
                        lastDate: lastDate,
                        selectableDayPredicate: checkAvailability,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: double.infinity,
                    child: LNDButton.primary(
                      text: confirmText,
                      enabled: checkAvailability(selectedDate),
                      onPressed: () => Get.back(result: selectedDate),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      expand: false,
    );
  }

  void _calculateTotalPrice() {
    try {
      if (selectedDates.length < 2 ||
          selectedDates.first == selectedDates.last) {
        _totalPrice.value = 0;
        _totalDays.value = 0;
        return;
      }

      DateTime startDate = LNDUtils.normalizeToDay(selectedDates.first);
      DateTime endDate = LNDUtils.normalizeToDay(selectedDates.last);
      _totalDays.value = LNDUtils.exclusiveDayCount(startDate, endDate);
      _totalPrice.value = BookingPriceBreakdown.calculate(
        rates: args.rates,
        startDate: startDate,
        endDate: endDate,
      ).fold<int>(0, (sum, line) => sum + line.amount);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }
}

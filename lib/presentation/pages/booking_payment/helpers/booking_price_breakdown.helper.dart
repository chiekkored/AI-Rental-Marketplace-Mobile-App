import 'package:flutter/material.dart';
import 'package:lend/core/models/rates.model.dart';

class BookingPriceBreakdownLine {
  final int count;
  final String unit;
  final int rate;
  final int amount;
  final List<DateTime> cycleStartDates;

  const BookingPriceBreakdownLine({
    required this.count,
    required this.unit,
    required this.rate,
    required this.amount,
    this.cycleStartDates = const [],
  });

  String get unitLabel => count == 1 ? unit : '${unit}s';
}

class BookingEnabledRateLine {
  final String label;
  final String unit;
  final int amount;

  const BookingEnabledRateLine({
    required this.label,
    required this.unit,
    required this.amount,
  });
}

class BookingBreakdownDisplayLine {
  final String label;
  final int rate;
  final int amount;

  const BookingBreakdownDisplayLine({
    required this.label,
    required this.rate,
    required this.amount,
  });
}

class BookingUpfrontSplitLine {
  final String label;
  final int amount;

  const BookingUpfrontSplitLine({required this.label, required this.amount});
}

class BookingSubscriptionSplit {
  final bool hasRecurringBilling;
  final int dueTodayRentalSubtotal;
  final int scheduledRentalSubtotal;
  final String? subscriptionUnit;
  final DateTime? nextBillingDate;
  final int? nextBillingAmount;
  final List<BookingUpfrontSplitLine> upfrontLines;

  const BookingSubscriptionSplit({
    required this.hasRecurringBilling,
    required this.dueTodayRentalSubtotal,
    required this.scheduledRentalSubtotal,
    required this.subscriptionUnit,
    required this.nextBillingDate,
    required this.nextBillingAmount,
    required this.upfrontLines,
  });
}

class BookingPriceBreakdown {
  BookingPriceBreakdown._();

  static const int minimumSubscriptionRemainingCycles = 2;

  static List<BookingPriceBreakdownLine> calculate({
    required Rates? rates,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final totalDays =
        _normalize(endDate).difference(_normalize(startDate)).inDays;
    if (rates == null || totalDays <= 0) return const [];

    final lines = <BookingPriceBreakdownLine>[];
    var currentDate = _normalize(startDate);
    final normalizedEndDate = _normalize(endDate);

    while (currentDate.isBefore(normalizedEndDate)) {
      if (rates.annually != null) {
        final nextYear = _addYearsClamped(currentDate, 1);
        if (!nextYear.isAfter(normalizedEndDate)) {
          _addLine(
            lines,
            unit: 'year',
            rate: rates.annually!,
            cycleStartDate: currentDate,
          );
          currentDate = nextYear;
          continue;
        }
      }

      if (rates.monthly != null) {
        final nextMonth = _addMonthsClamped(currentDate, 1);
        if (!nextMonth.isAfter(normalizedEndDate)) {
          _addLine(
            lines,
            unit: 'month',
            rate: rates.monthly!,
            cycleStartDate: currentDate,
          );
          currentDate = nextMonth;
          continue;
        }
      }

      if (rates.weekly != null) {
        final nextWeek = currentDate.add(const Duration(days: 7));
        if (!nextWeek.isAfter(normalizedEndDate)) {
          _addLine(
            lines,
            unit: 'week',
            rate: rates.weekly!,
            cycleStartDate: currentDate,
          );
          currentDate = nextWeek;
          continue;
        }
      }

      if (rates.daily == null) break;
      _addLine(
        lines,
        unit: 'day',
        rate: rates.daily!,
        cycleStartDate: currentDate,
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return lines;
  }

  static List<BookingEnabledRateLine> enabledRates(
    Rates? rates, {
    bool includeDaily = true,
  }) {
    if (rates == null) return const [];

    final lines = <BookingEnabledRateLine>[];
    if (includeDaily && rates.daily != null && rates.daily! > 0) {
      lines.add(
        BookingEnabledRateLine(
          label: 'Daily',
          unit: 'day',
          amount: rates.daily!,
        ),
      );
    }
    if (rates.weekly != null && rates.weekly! > 0) {
      lines.add(
        BookingEnabledRateLine(
          label: 'Weekly',
          unit: 'week',
          amount: rates.weekly!,
        ),
      );
    }
    if (rates.monthly != null && rates.monthly! > 0) {
      lines.add(
        BookingEnabledRateLine(
          label: 'Monthly',
          unit: 'month',
          amount: rates.monthly!,
        ),
      );
    }
    if (rates.annually != null && rates.annually! > 0) {
      lines.add(
        BookingEnabledRateLine(
          label: 'Yearly',
          unit: 'year',
          amount: rates.annually!,
        ),
      );
    }
    return lines;
  }

  static List<BookingBreakdownDisplayLine> displayLines(
    List<BookingPriceBreakdownLine> lines,
  ) {
    return [
      for (final line in lines)
        BookingBreakdownDisplayLine(
          label: '${line.count} ${line.unitLabel} x',
          rate: line.rate,
          amount: line.amount,
        ),
    ];
  }

  static String normalizedDurationLabel(
    List<BookingPriceBreakdownLine> lines, {
    int? fallbackDays,
  }) {
    final parts = [
      for (final line in lines)
        if (line.count > 0) '${line.count} ${line.unitLabel}',
    ];

    if (parts.isEmpty && fallbackDays != null && fallbackDays > 0) {
      parts.add('$fallbackDays ${fallbackDays == 1 ? 'day' : 'days'}');
    }

    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    if (parts.length == 2) return '${parts.first} and ${parts.last}';
    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }

  static BookingSubscriptionSplit subscriptionSplit(
    List<BookingPriceBreakdownLine> lines,
  ) {
    if (lines.isEmpty) {
      return const BookingSubscriptionSplit(
        hasRecurringBilling: false,
        dueTodayRentalSubtotal: 0,
        scheduledRentalSubtotal: 0,
        subscriptionUnit: null,
        nextBillingDate: null,
        nextBillingAmount: null,
        upfrontLines: [],
      );
    }

    final recurringLines = lines.where((line) => line.unit != 'day').toList();
    if (recurringLines.isEmpty) {
      return BookingSubscriptionSplit(
        hasRecurringBilling: false,
        dueTodayRentalSubtotal: _subtotal(lines),
        scheduledRentalSubtotal: 0,
        subscriptionUnit: null,
        nextBillingDate: null,
        nextBillingAmount: null,
        upfrontLines: const [],
      );
    }

    final selectedLine = recurringLines.reduce(
      (best, current) =>
          _unitPriority(current.unit) > _unitPriority(best.unit)
              ? current
              : best,
    );
    final upfrontLines = <BookingUpfrontSplitLine>[];
    var dueTodayRentalSubtotal = 0;
    var scheduledRentalSubtotal = 0;
    DateTime? nextBillingDate;
    int? nextBillingAmount;

    for (final line in lines) {
      if (line.unit == 'day') {
        dueTodayRentalSubtotal += line.amount;
        upfrontLines.add(
          BookingUpfrontSplitLine(
            label: '${line.unitLabel.capitalizeFirst()} remainder',
            amount: line.amount,
          ),
        );
        continue;
      }

      if (line.unit != selectedLine.unit || line.rate != selectedLine.rate) {
        dueTodayRentalSubtotal += line.amount;
        upfrontLines.add(
          BookingUpfrontSplitLine(
            label: '${line.unitLabel.capitalizeFirst()} remainder',
            amount: line.amount,
          ),
        );
        continue;
      }

      final remainingCycles = line.count - 1;
      if (remainingCycles < minimumSubscriptionRemainingCycles) {
        dueTodayRentalSubtotal += line.amount;
        upfrontLines.add(
          BookingUpfrontSplitLine(
            label: '${line.count} ${line.unitLabel}',
            amount: line.amount,
          ),
        );
        continue;
      }

      dueTodayRentalSubtotal += line.rate;
      scheduledRentalSubtotal += remainingCycles * line.rate;
      nextBillingDate =
          line.cycleStartDates.length > 1 ? line.cycleStartDates[1] : null;
      nextBillingAmount = line.rate;
      upfrontLines.add(
        BookingUpfrontSplitLine(
          label: 'First ${line.unit} cycle',
          amount: line.rate,
        ),
      );
    }

    final hasRecurringBilling = scheduledRentalSubtotal > 0;
    return BookingSubscriptionSplit(
      hasRecurringBilling: hasRecurringBilling,
      dueTodayRentalSubtotal: dueTodayRentalSubtotal,
      scheduledRentalSubtotal: scheduledRentalSubtotal,
      subscriptionUnit: hasRecurringBilling ? selectedLine.unit : null,
      nextBillingDate: hasRecurringBilling ? nextBillingDate : null,
      nextBillingAmount: hasRecurringBilling ? nextBillingAmount : null,
      upfrontLines: upfrontLines,
    );
  }

  static void _addLine(
    List<BookingPriceBreakdownLine> lines, {
    required String unit,
    required int rate,
    required DateTime cycleStartDate,
  }) {
    if (lines.isNotEmpty &&
        lines.last.unit == unit &&
        lines.last.rate == rate) {
      final previous = lines.removeLast();
      lines.add(
        BookingPriceBreakdownLine(
          count: previous.count + 1,
          unit: previous.unit,
          rate: previous.rate,
          amount: previous.amount + rate,
          cycleStartDates: [...previous.cycleStartDates, cycleStartDate],
        ),
      );
      return;
    }

    lines.add(
      BookingPriceBreakdownLine(
        count: 1,
        unit: unit,
        rate: rate,
        amount: rate,
        cycleStartDates: [cycleStartDate],
      ),
    );
  }

  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _addMonthsClamped(DateTime date, int months) {
    final targetMonthIndex = date.month + months - 1;
    final targetYear = date.year + targetMonthIndex ~/ 12;
    final targetMonth = targetMonthIndex % 12 + 1;
    final maxDay = DateUtils.getDaysInMonth(targetYear, targetMonth);
    return DateTime(targetYear, targetMonth, date.day.clamp(1, maxDay).toInt());
  }

  static DateTime _addYearsClamped(DateTime date, int years) {
    final targetYear = date.year + years;
    final maxDay = DateUtils.getDaysInMonth(targetYear, date.month);
    return DateTime(targetYear, date.month, date.day.clamp(1, maxDay).toInt());
  }

  static int _subtotal(List<BookingPriceBreakdownLine> lines) {
    return lines.fold<int>(0, (sum, line) => sum + line.amount);
  }

  static int _unitPriority(String unit) {
    return switch (unit) {
      'year' => 3,
      'month' => 2,
      'week' => 1,
      _ => 0,
    };
  }
}

extension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/bottom_nav.widget.dart';
import 'package:lend/presentation/pages/calendar_picker/widgets/calendar_view.widget.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.testMode = false;
  });

  testWidgets('minimum nights banner blocks payment until requirement is met', (
    tester,
  ) async {
    var submitted = false;
    final args = CalendarPickerPageArgs(
      isReadOnly: false,
      dates: const [],
      rates: Rates(daily: 100),
      minimumNights: 3,
      onSubmit: (_, _) => submitted = true,
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    Get.to(() {
      Get.put(CalendarPickerController());
      return const Scaffold(bottomNavigationBar: CalendarBottomNav());
    }, arguments: args);
    await tester.pumpAndSettle();

    final controller = Get.find<CalendarPickerController>();
    expect(
      find.text('This listing requires a minimum stay of 3 nights.'),
      findsOneWidget,
    );
    expect(_proceedButton(tester).onPressed, isNull);

    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 10),
      DateTime.utc(2026, 6, 12),
    ]);
    await tester.pump();
    expect(controller.totalDays, 2);
    expect(controller.canSubmit, isFalse);
    expect(_proceedButton(tester).onPressed, isNull);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('Jun 10, 2026'), findsOneWidget);
    expect(find.text('Jun 12, 2026'), findsOneWidget);

    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 10),
      DateTime.utc(2026, 6, 13),
    ]);
    await tester.pump();
    expect(controller.totalDays, 3);
    expect(controller.canSubmit, isTrue);
    expect(_proceedButton(tester).onPressed, isNotNull);
    expect(find.text('(3 days)'), findsOneWidget);
    expect(find.text('Breakdown'), findsNothing);

    await tester.tap(find.text('Proceed Payment'));
    expect(submitted, isTrue);
  });

  testWidgets('assets without minimum nights do not show the banner', (
    tester,
  ) async {
    final args = CalendarPickerPageArgs(
      isReadOnly: false,
      dates: const [],
      rates: Rates(daily: 100),
      onSubmit: (_, _) {},
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    Get.to(() {
      Get.put(CalendarPickerController());
      return const Scaffold(bottomNavigationBar: CalendarBottomNav());
    }, arguments: args);
    await tester.pumpAndSettle();

    expect(find.textContaining('minimum stay'), findsNothing);
  });

  testWidgets('calculates monthly weekly and daily rate chunks', (
    tester,
  ) async {
    final args = CalendarPickerPageArgs(
      isReadOnly: false,
      dates: const [],
      rates: Rates(daily: 500, weekly: 3000, monthly: 10000),
      onSubmit: (_, _) {},
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    Get.to(() {
      Get.put(CalendarPickerController());
      return const Scaffold(bottomNavigationBar: CalendarBottomNav());
    }, arguments: args);
    await tester.pumpAndSettle();

    final controller = Get.find<CalendarPickerController>();
    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2026, 7, 11),
    ]);

    expect(controller.totalDays, 40);
    expect(controller.totalPrice, 14500);
    await tester.pump();

    expect(find.text('(40 days)'), findsNothing);
    expect(find.text('Breakdown'), findsOneWidget);

    await tester.tap(find.text('Breakdown'));
    await tester.pumpAndSettle();

    expect(find.text('1 month x PHP 10,000.00'), findsOneWidget);
    expect(find.text('1 week x PHP 3,000.00'), findsOneWidget);
    expect(find.text('3 days x PHP 500.00'), findsOneWidget);
    expect(find.text('PHP 14,500.00'), findsAtLeastNWidgets(1));
  });

  testWidgets('calculates annual rate without double counting', (tester) async {
    final args = CalendarPickerPageArgs(
      isReadOnly: false,
      dates: const [],
      rates: Rates(daily: 500, weekly: 3000, monthly: 10000, annually: 100000),
      onSubmit: (_, _) {},
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    Get.to(() {
      Get.put(CalendarPickerController());
      return const Scaffold(bottomNavigationBar: CalendarBottomNav());
    }, arguments: args);
    await tester.pumpAndSettle();

    final controller = Get.find<CalendarPickerController>();
    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2027, 6, 1),
    ]);

    expect(controller.totalDays, 365);
    expect(controller.totalPrice, 100000);
  });

  testWidgets('yearly mode shows distinct selectable years', (tester) async {
    final controller = await _pumpCalendarView(
      tester,
      rates: Rates(daily: 500, monthly: 10000, annually: 100000),
    );

    await tester.tap(find.text(BookingRateMode.monthly.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(BookingRateMode.yearly.label));
    await tester.pumpAndSettle();

    final firstYear = controller.firstSelectableDate.year.toString();
    final lastYear = controller.lastSelectableDate.year.toString();

    expect(controller.selectedRateMode, BookingRateMode.yearly);
    expect(firstYear, isNot(lastYear));
    expect(find.text(firstYear), findsOneWidget);
    expect(find.text(lastYear), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('yearly more extends the selectable window by twelve months', (
    tester,
  ) async {
    final controller = await _pumpCalendarView(
      tester,
      rates: Rates(daily: 500, annually: 100000),
    );

    await tester.tap(find.text(BookingRateMode.yearly.label));
    await tester.pumpAndSettle();

    final initialLastDate = controller.lastSelectableDate;
    final expectedLastDate = DateTime(
      initialLastDate.year,
      initialLastDate.month + 12,
      initialLastDate.day,
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(controller.selectedRateMode, BookingRateMode.yearly);
    expect(controller.lastSelectableDate, expectedLastDate);
    expect(find.text(expectedLastDate.year.toString()), findsOneWidget);
  });

  testWidgets('monthly more extends visible months by twelve months', (
    tester,
  ) async {
    final controller = await _pumpCalendarView(
      tester,
      rates: Rates(daily: 500, monthly: 10000),
    );

    await tester.tap(find.text(BookingRateMode.monthly.label));
    await tester.pumpAndSettle();

    final initialLastDate = controller.lastSelectableDate;
    final expectedLastDate = DateTime(
      initialLastDate.year,
      initialLastDate.month + 12,
      initialLastDate.day,
    );
    final expectedMonthLabel = DateFormat(
      'MMM yyyy',
    ).format(DateTime(expectedLastDate.year, expectedLastDate.month));

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(GridView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(controller.selectedRateMode, BookingRateMode.monthly);
    expect(controller.lastSelectableDate, expectedLastDate);
    expect(find.text(expectedMonthLabel), findsOneWidget);
  });

  testWidgets('more stops at the five year selectable cap', (tester) async {
    final controller = await _pumpCalendarView(
      tester,
      rates: Rates(daily: 500, annually: 100000),
    );

    await tester.tap(find.text(BookingRateMode.yearly.label));
    await tester.pumpAndSettle();

    while (controller.canShowMorePeriods) {
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
    }

    expect(controller.lastSelectableDate, controller.maxSelectableDate);
    expect(controller.canShowMorePeriods, isFalse);
    expect(find.text('More'), findsNothing);
  });

  testWidgets('monthly range calculates after choosing two periods', (
    tester,
  ) async {
    final controller = await _pumpCalendarWithViewAndBottomNav(
      tester,
      rates: Rates(daily: 500, monthly: 10000),
    );

    await tester.tap(find.text(BookingRateMode.monthly.label));
    await tester.pumpAndSettle();

    final firstMonth = DateTime(
      controller.firstSelectableDate.year,
      controller.firstSelectableDate.month,
    );
    final secondMonth = DateTime(firstMonth.year, firstMonth.month + 1);
    final firstMonthLabel = DateFormat('MMM yyyy').format(firstMonth);
    final secondMonthLabel = DateFormat('MMM yyyy').format(secondMonth);

    await tester.tap(find.text(firstMonthLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(controller.selectedRateMode, BookingRateMode.monthly);
    expect(controller.periodDates, [firstMonth]);
    expect(controller.totalDays, 0);
    expect(controller.totalPrice, 0);
    expect(controller.canSubmit, isFalse);
    expect(_proceedButton(tester).onPressed, isNull);

    await tester.tap(find.text(secondMonthLabel));
    await tester.pumpAndSettle();

    expect(controller.periodDates, [firstMonth, secondMonth]);
    expect(controller.totalDays, greaterThanOrEqualTo(28));
    expect(controller.totalPrice, 10000);
    expect(controller.canSubmit, isTrue);
    expect(_proceedButton(tester).onPressed, isNotNull);
  });

  testWidgets('yearly range calculates after choosing two periods', (
    tester,
  ) async {
    final controller = await _pumpCalendarWithViewAndBottomNav(
      tester,
      rates: Rates(daily: 500, annually: 100000),
    );

    await tester.tap(find.text(BookingRateMode.yearly.label));
    await tester.pumpAndSettle();

    final firstYear = controller.firstSelectableDate.year;
    final secondYear = firstYear + 1;

    await tester.tap(find.text(firstYear.toString()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(controller.selectedRateMode, BookingRateMode.yearly);
    expect(controller.periodDates, [DateTime(firstYear)]);
    expect(controller.totalDays, 0);
    expect(controller.totalPrice, 0);
    expect(controller.canSubmit, isFalse);
    expect(_proceedButton(tester).onPressed, isNull);

    await tester.tap(find.text(secondYear.toString()));
    await tester.pumpAndSettle();

    expect(controller.periodDates, [DateTime(firstYear), DateTime(secondYear)]);
    expect(controller.totalDays, greaterThanOrEqualTo(365));
    expect(controller.totalPrice, 100000);
    expect(controller.canSubmit, isTrue);
    expect(_proceedButton(tester).onPressed, isNotNull);
  });

  testWidgets('rate mode changes clear selection and more extensions', (
    tester,
  ) async {
    final controller = await _pumpCalendarView(
      tester,
      rates: Rates(daily: 500, weekly: 3000, monthly: 10000, annually: 100000),
    );

    final initialLastDate = controller.lastSelectableDate;
    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2026, 6, 8),
    ]);
    await tester.pump();
    controller.onRateModeChanged(BookingRateMode.monthly);
    controller.onTapShowMorePeriods();

    expect(controller.lastSelectableDate, isNot(initialLastDate));

    controller.onRateModeChanged(BookingRateMode.yearly);

    expect(controller.selectedRateMode, BookingRateMode.yearly);
    expect(controller.selectedDates, isEmpty);
    expect(controller.periodDates, isEmpty);
    expect(controller.extraDates, isEmpty);
    expect(controller.basePeriodEndDate, isNull);
    expect(controller.totalDays, 0);
    expect(controller.totalPrice, 0);
    expect(controller.canSubmit, isFalse);
    expect(controller.lastSelectableDate, initialLastDate);
  });

  testWidgets('daily only listings hide rate mode segment', (tester) async {
    await _pumpCalendarView(tester, rates: Rates(daily: 100));

    expect(find.byType(SegmentedButton<BookingRateMode>), findsNothing);
    expect(find.text(BookingRateMode.daily.label), findsNothing);
  });

  testWidgets('multiple rates show rate mode segment', (tester) async {
    await _pumpCalendarView(tester, rates: Rates(daily: 100, weekly: 700));

    expect(find.byType(SegmentedButton<BookingRateMode>), findsOneWidget);
    expect(find.text(BookingRateMode.daily.label), findsOneWidget);
    expect(find.text(BookingRateMode.weekly.label), findsOneWidget);
  });

  testWidgets('weekly mode does not auto-select a 7 day range', (tester) async {
    final controller = await _pumpCalendar(
      tester,
      rates: Rates(daily: 100, weekly: 700),
    );

    controller.onRateModeChanged(BookingRateMode.weekly);
    controller.onCalendarChanged([DateTime.utc(2026, 6, 1)]);
    await tester.pump();

    expect(controller.selectedRateMode, BookingRateMode.weekly);
    expect(controller.selectedDates, [DateTime.utc(2026, 6, 1)]);
    expect(controller.totalDays, 0);
    expect(controller.totalPrice, 0);
  });

  testWidgets('weekly mode reverts to daily for ranges under 7 days', (
    tester,
  ) async {
    final controller = await _pumpCalendar(
      tester,
      rates: Rates(daily: 100, weekly: 700),
    );

    controller.onRateModeChanged(BookingRateMode.weekly);
    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2026, 6, 7),
    ]);
    await tester.pump();

    expect(controller.selectedRateMode, BookingRateMode.daily);
    expect(controller.totalDays, 6);
    expect(controller.totalPrice, 600);
  });

  testWidgets('daily mode switches to weekly for a full 7 day range', (
    tester,
  ) async {
    final controller = await _pumpCalendar(
      tester,
      rates: Rates(daily: 100, weekly: 700),
    );

    expect(controller.selectedRateMode, BookingRateMode.daily);

    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2026, 6, 8),
    ]);
    await tester.pump();

    expect(controller.selectedRateMode, BookingRateMode.weekly);
    expect(controller.totalDays, 7);
    expect(controller.totalPrice, 700);
  });

  testWidgets('weekly mode stays active from a full 7 day range', (
    tester,
  ) async {
    final controller = await _pumpCalendar(
      tester,
      rates: Rates(daily: 100, weekly: 700),
    );

    controller.onRateModeChanged(BookingRateMode.weekly);
    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2026, 6, 8),
    ]);
    await tester.pump();

    expect(controller.selectedRateMode, BookingRateMode.weekly);
    expect(controller.totalDays, 7);
    expect(controller.totalPrice, 700);
  });

  testWidgets('weekly mode prices weekly chunk plus daily remainder', (
    tester,
  ) async {
    final controller = await _pumpCalendar(
      tester,
      rates: Rates(daily: 100, weekly: 700),
    );

    controller.onRateModeChanged(BookingRateMode.weekly);
    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2026, 6, 9),
    ]);
    await tester.pump();

    expect(controller.selectedRateMode, BookingRateMode.weekly);
    expect(controller.totalDays, 8);
    expect(controller.totalPrice, 800);
  });

  testWidgets('daily mode switches to weekly for ranges over 7 days', (
    tester,
  ) async {
    final controller = await _pumpCalendar(
      tester,
      rates: Rates(daily: 100, weekly: 700),
    );

    expect(controller.selectedRateMode, BookingRateMode.daily);

    controller.onCalendarChanged([
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2026, 6, 9),
    ]);
    await tester.pump();

    expect(controller.selectedRateMode, BookingRateMode.weekly);
    expect(controller.totalDays, 8);
    expect(controller.totalPrice, 800);
  });
}

OutlinedButton _proceedButton(WidgetTester tester) {
  return tester.widget<OutlinedButton>(
    find.widgetWithText(OutlinedButton, 'Proceed Payment'),
  );
}

Future<CalendarPickerController> _pumpCalendar(
  WidgetTester tester, {
  required Rates rates,
}) async {
  final args = CalendarPickerPageArgs(
    isReadOnly: false,
    dates: const [],
    rates: rates,
    onSubmit: (_, _) {},
  );

  await tester.pumpWidget(
    GetMaterialApp(
      theme: LNDAppTheme.light,
      home: const Scaffold(body: SizedBox.shrink()),
    ),
  );
  Get.to(() {
    Get.put(CalendarPickerController());
    return const Scaffold(bottomNavigationBar: CalendarBottomNav());
  }, arguments: args);
  await tester.pumpAndSettle();

  return Get.find<CalendarPickerController>();
}

Future<CalendarPickerController> _pumpCalendarView(
  WidgetTester tester, {
  required Rates rates,
}) async {
  final args = CalendarPickerPageArgs(
    isReadOnly: false,
    dates: const [],
    rates: rates,
    onSubmit: (_, _) {},
  );

  await tester.pumpWidget(
    GetMaterialApp(
      theme: LNDAppTheme.light,
      home: const Scaffold(body: SizedBox.shrink()),
    ),
  );
  Get.to(() {
    Get.put(CalendarPickerController());
    return const Scaffold(body: CalendarView());
  }, arguments: args);
  await tester.pumpAndSettle();

  return Get.find<CalendarPickerController>();
}

Future<CalendarPickerController> _pumpCalendarWithViewAndBottomNav(
  WidgetTester tester, {
  required Rates rates,
}) async {
  final args = CalendarPickerPageArgs(
    isReadOnly: false,
    dates: const [],
    rates: rates,
    onSubmit: (_, _) {},
  );

  await tester.pumpWidget(
    GetMaterialApp(
      theme: LNDAppTheme.light,
      home: const Scaffold(body: SizedBox.shrink()),
    ),
  );
  Get.to(() {
    Get.put(CalendarPickerController());
    return const Scaffold(
      body: CalendarView(),
      bottomNavigationBar: CalendarBottomNav(),
    );
  }, arguments: args);
  await tester.pumpAndSettle();

  return Get.find<CalendarPickerController>();
}

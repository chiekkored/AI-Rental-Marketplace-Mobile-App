import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

enum CalendarBookingsViewMode { calendar, list }

class CalendarBookingsPageArgs {
  final bool isReadOnly;
  final List<Booking> bookings;
  final Rates rates;
  final String assetControllerTag;

  CalendarBookingsPageArgs({
    required this.isReadOnly,
    required this.bookings,
    required this.rates,
    required this.assetControllerTag,
  });
}

class CalendarBookingsController extends GetxController {
  static CalendarBookingsController get instance =>
      Get.find<CalendarBookingsController>();

  final args = Get.arguments as CalendarBookingsPageArgs;
  AssetController? get assetController {
    if (!Get.isRegistered<AssetController>(tag: args.assetControllerTag)) {
      return null;
    }
    return Get.find<AssetController>(tag: args.assetControllerTag);
  }

  final RxList<Booking> _bookings = <Booking>[].obs;
  List<Booking> get bookings => _bookings;

  final Rx<CalendarBookingsViewMode> _viewMode =
      CalendarBookingsViewMode.calendar.obs;
  CalendarBookingsViewMode get viewMode => _viewMode.value;

  final RxList<DateTime> _selectedDates = <DateTime>[].obs;
  DateTime? get selectedDate =>
      _selectedDates.isNotEmpty ? _selectedDates.first : null;

  /// For Calendar Widget. It only accepts list of dates
  List<DateTime> get selectedDates => _selectedDates;

  final Map<String, Color> _bookingColorMap = {};

  /// Assign a unique color to each booking
  List<ColoredBookings> get _coloredBookings {
    return _bookings.map((booking) {
      final bookingId = booking.id ?? '';
      if (!_bookingColorMap.containsKey(bookingId)) {
        _bookingColorMap[bookingId] = _getRandomColor(bookingId);
      }
      return ColoredBookings(
        booking: booking,
        color: _bookingColorMap[bookingId]!,
      );
    }).toList();
  }

  /// Gets bookings for the selected day
  List<ColoredBookings> get selectedDayBookings {
    if (selectedDate == null) return [];

    return _coloredBookings.where((colored) {
      final booking = colored.booking;
      final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
      final endDate = LNDUtils.bookingDateFromTimestamp(booking.endDate);

      if (startDate == null || endDate == null || selectedDate == null) {
        return false;
      }

      return LNDUtils.isDateWithinExclusiveEndRange(
        date: selectedDate!,
        start: startDate,
        end: endDate,
      );
    }).toList();
  }

  List<BookingDateSection> get bookingDateSections {
    final sortedBookings = [..._bookings];
    sortedBookings.sort((a, b) {
      final aStart = LNDUtils.bookingDateFromTimestamp(a.startDate);
      final bStart = LNDUtils.bookingDateFromTimestamp(b.startDate);
      if (aStart == null && bStart == null) {
        return _bookingFallbackLabel(a).compareTo(_bookingFallbackLabel(b));
      }
      if (aStart == null) return 1;
      if (bStart == null) return -1;

      final startCompare = aStart.compareTo(bStart);
      if (startCompare != 0) return startCompare;
      return _bookingFallbackLabel(a).compareTo(_bookingFallbackLabel(b));
    });

    final sections = <String, BookingDateSection>{};
    for (final booking in sortedBookings) {
      final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
      final normalized = _normalizeDate(startDate);
      final key = normalized?.toIso8601String() ?? 'unscheduled';
      sections.putIfAbsent(
        key,
        () => BookingDateSection(startDate: normalized, bookings: []),
      );
      sections[key]!.bookings.add(booking);
    }

    return sections.values.toList();
  }

  DateTime get calendarFirstDate {
    final dates =
        _bookings
            .map(
              (booking) => _normalizeDate(
                LNDUtils.bookingDateFromTimestamp(booking.startDate),
              ),
            )
            .whereType<DateTime>()
            .toList();
    if (dates.isEmpty) return DateTime.now().add(const Duration(days: 1));
    dates.sort();
    return dates.first;
  }

  DateTime get calendarLastDate {
    final dates =
        _bookings
            .map(
              (booking) => _normalizeDate(
                LNDUtils.bookingDateFromTimestamp(booking.endDate),
              ),
            )
            .whereType<DateTime>()
            .toList();
    if (dates.isEmpty) return DateTime.now().add(const Duration(days: 365));
    dates.sort();
    final last = dates.last;
    return last.isBefore(calendarFirstDate) ? calendarFirstDate : last;
  }

  final renterColors = [
    const Color(0xFFE57373), // red
    const Color(0xFF64B5F6), // blue
    const Color(0xFF81C784), // green
    const Color(0xFFFFB74D), // orange
    const Color(0xFFBA68C8), // purple
    const Color(0xFF4DB6AC), // teal
    const Color(0xFFFF8A65), // coral
    const Color(0xFF7986CB), // indigo
  ];

  @override
  void onInit() {
    _bookings.assignAll(args.bookings);
    _viewMode.value = _readSavedViewMode();
    super.onInit();
  }

  @override
  void onClose() {
    _bookings.close();
    _selectedDates.close();
    _viewMode.close();

    super.onClose();
  }

  /// Generates random color
  Color _getRandomColor(String id) {
    // final random = Random();

    // Limit values between 0 and 180 to avoid very bright colors
    // const min = 0;
    // const max = 180;

    // return Color.fromARGB(
    //   255,
    //   min + random.nextInt(max - min),
    //   min + random.nextInt(max - min),
    //   min + random.nextInt(max - min),
    // );

    if (id.isEmpty) return renterColors.first;

    // Convert id string to a numeric hash
    final bytes = utf8.encode(id);
    final hash = bytes.fold<int>(0, (prev, byte) => (prev + byte) % 100000);

    // Use hash to pick a color deterministically
    final index = hash % renterColors.length;
    return renterColors[index];
  }

  void onCalendarChanged(List<DateTime> dates) async {
    _selectedDates.value = dates;
  }

  void setViewMode(CalendarBookingsViewMode mode) {
    _viewMode.value = mode;
    LNDStorageService.write(
      LNDStorageConstants.calendarBookingsViewMode,
      mode.name,
    );
  }

  IconData get viewModeIcon {
    return viewMode == CalendarBookingsViewMode.calendar
        ? Icons.calendar_month_outlined
        : Icons.list_rounded;
  }

  /// Gets the designated colors to display dots on the calendar day
  List<Color> getBookingColors(DateTime date) {
    List<Color> colors = [];

    for (var colored in _coloredBookings) {
      final booking = colored.booking;
      final color = colored.color;
      final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
      final endDate = LNDUtils.bookingDateFromTimestamp(booking.endDate);

      if (startDate != null && endDate != null) {
        final isBookingDay =
            LNDUtils.isDateWithinExclusiveEndRange(
              date: date,
              start: startDate,
              end: endDate,
            ) ||
            (booking.asset?.blocksEndDate == true &&
                LNDUtils.normalizeToDay(date) ==
                    LNDUtils.normalizeToDay(endDate));
        if (isBookingDay) {
          colors.add(color);
        }
      }
    }

    return colors;
  }

  bool checkAvailability(DateTime date) {
    for (var booking in _bookings) {
      final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
      final endDate = LNDUtils.bookingDateFromTimestamp(booking.endDate);

      if (startDate != null &&
          endDate != null &&
          BookingStatus.dateBlocking.contains(booking.status)) {
        final isBookingDay =
            LNDUtils.isDateWithinExclusiveEndRange(
              date: date,
              start: startDate,
              end: endDate,
            ) ||
            (booking.asset?.blocksEndDate == true &&
                LNDUtils.normalizeToDay(date) ==
                    LNDUtils.normalizeToDay(endDate));
        if (isBookingDay) {
          return true;
        }
      }
    }
    return false;
  }

  void updateBookings(List<Booking> bookings) {
    _bookings.assignAll(bookings);
  }

  void goToBookingDetails(Booking booking) {
    LNDNavigate.toBookingDetailsPage(
      args: BookingDetailsPageArgs(booking: booking),
    );
  }

  void onTapGoToChat(Booking booking) {
    if (booking.id == null) return;

    try {
      final chat = MessagesController.instance.findChatByBookingId(booking.id!);

      if (chat == null) throw 'Cannot find chat for this booking';

      LNDNavigate.toChatPage(chat: chat);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Something went wrong');
    }
  }

  Future<void> onTapBooking(Booking booking) async {
    final result = await LNDShow.alertDialog<bool?>(
      title: 'Accept this booking?',
      content:
          'Are you sure you want to accept this booking request? '
          'All other pending bookings for the same day will be declined.',
    );

    if (result == null || !result) return;

    try {
      LNDLoading.show();
      final isAvailable = await _isBookingStillAvailable(booking);
      if (!isAvailable) {
        await _refreshBookingsFromAsset();
        LNDLoading.hide();
        LNDSnackbar.showError(
          'This booking overlaps an active booking and can no longer be accepted.',
        );
        return;
      }

      final result = await LNDBookingService.confirmBookingViaFunction(
        bookingId: booking.id!,
        assetId: booking.asset?.id ?? '',
        renterId: booking.renter?.uid ?? '',
      );

      result.fold(
        ifLeft: (response) async {
          await _refreshBookingsFromAsset();
          LNDLoading.hide();
          await MessagesController.instance.openAcceptedBookingChat(booking);
        },
        ifRight: (error) {
          throw error;
        },
      );
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      if (assetController != null) {
        await _refreshBookingsFromAsset();
      }
      LNDSnackbar.showError(e.toString());
    }
  }

  Future<bool> _isBookingStillAvailable(Booking booking) async {
    final assetId = booking.asset?.id;
    final startDate = booking.startDate;
    final endDate = booking.endDate;

    if (assetId == null ||
        assetId.isEmpty ||
        startDate == null ||
        endDate == null) {
      throw 'Unable to validate booking dates.';
    }

    final result = await LNDBookingService.isAssetAvailable(
      assetId: assetId,
      startDate: Timestamp(startDate.seconds, startDate.nanoseconds),
      endDate: Timestamp(endDate.seconds, endDate.nanoseconds),
      blocksEndDate: booking.asset?.blocksEndDate ?? false,
    );

    return result.fold(
      ifLeft: (isAvailable) => isAvailable,
      ifRight: (error) => throw error,
    );
  }

  Future<void> _refreshBookingsFromAsset() async {
    final assetController = this.assetController;
    if (assetController == null) return;

    await assetController.getBookings();
    updateBookings(assetController.bookingDates);
  }
}

CalendarBookingsViewMode _readSavedViewMode() {
  final saved = LNDStorageService.read<String>(
    LNDStorageConstants.calendarBookingsViewMode,
  );
  return CalendarBookingsViewMode.values.firstWhere(
    (mode) => mode.name == saved,
    orElse: () => CalendarBookingsViewMode.calendar,
  );
}

class ColoredBookings {
  final Booking booking;
  final Color color;

  ColoredBookings({required this.booking, required this.color});
}

class BookingDateSection {
  final DateTime? startDate;
  final List<Booking> bookings;

  BookingDateSection({required this.startDate, required this.bookings});
}

DateTime? _normalizeDate(DateTime? date) {
  if (date == null) return null;
  return DateTime(date.year, date.month, date.day);
}

String _bookingFallbackLabel(Booking booking) {
  return [
    booking.asset?.title,
    booking.renter?.getName,
    booking.id,
  ].whereType<String>().join(' ');
}

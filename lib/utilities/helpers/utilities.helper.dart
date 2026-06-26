import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/utilities/enums/user_status.enum.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/extensions/string.extension.dart';

class LNDUtils {
  static DateTime normalizeToDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime normalizeToUtcDay(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  static int bookingDateMillisecondsSinceEpoch(DateTime date) {
    return normalizeToUtcDay(date).millisecondsSinceEpoch;
  }

  static DateTime bookingDateFromMillisecondsSinceEpoch(int milliseconds) {
    final utcDate = DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    );
    return DateTime(utcDate.year, utcDate.month, utcDate.day);
  }

  static DateTime? bookingDateFromTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return null;
    final utcDate = timestamp.toDate().toUtc();
    return DateTime(utcDate.year, utcDate.month, utcDate.day);
  }

  static List<DateTime> daysInInclusiveRange(DateTime start, DateTime end) {
    final normalizedStart = normalizeToDay(start);
    final normalizedEnd = normalizeToDay(end);

    if (normalizedStart.isAfter(normalizedEnd)) {
      return const [];
    }

    final days = <DateTime>[];
    var current = normalizedStart;

    while (!current.isAfter(normalizedEnd)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  static int exclusiveDayCount(DateTime start, DateTime end) {
    final normalizedStart = normalizeToDay(start);
    final normalizedEnd = normalizeToDay(end);

    if (!normalizedEnd.isAfter(normalizedStart)) {
      return 0;
    }

    return normalizedEnd.difference(normalizedStart).inDays;
  }

  static List<DateTime> daysInExclusiveEndRange(DateTime start, DateTime end) {
    final normalizedStart = normalizeToDay(start);
    final normalizedEnd = normalizeToDay(end);

    if (!normalizedEnd.isAfter(normalizedStart)) {
      return const [];
    }

    final days = <DateTime>[];
    var current = normalizedStart;

    while (current.isBefore(normalizedEnd)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  static bool isDateWithinExclusiveEndRange({
    required DateTime date,
    required DateTime start,
    required DateTime end,
  }) {
    final normalizedDate = normalizeToDay(date);
    final normalizedStart = normalizeToDay(start);
    final normalizedEnd = normalizeToDay(end);

    return !normalizedDate.isBefore(normalizedStart) &&
        normalizedDate.isBefore(normalizedEnd);
  }

  static bool rangesOverlapExclusiveEnd({
    required DateTime start,
    required DateTime end,
    required DateTime otherStart,
    required DateTime otherEnd,
  }) {
    final normalizedStart = normalizeToDay(start);
    final normalizedEnd = normalizeToDay(end);
    final normalizedOtherStart = normalizeToDay(otherStart);
    final normalizedOtherEnd = normalizeToDay(otherEnd);

    return normalizedStart.isBefore(normalizedOtherEnd) &&
        normalizedOtherStart.isBefore(normalizedEnd);
  }

  static bool isDateWithinInclusiveRange({
    required DateTime date,
    required DateTime start,
    required DateTime end,
  }) {
    final normalizedDate = normalizeToDay(date);
    final normalizedStart = normalizeToDay(start);
    final normalizedEnd = normalizeToDay(end);

    return !normalizedDate.isBefore(normalizedStart) &&
        !normalizedDate.isAfter(normalizedEnd);
  }

  static bool isTodayInRange({
    required DateTime start,
    required DateTime end,
    DateTime? today,
  }) {
    return isDateWithinExclusiveEndRange(
      date: today ?? DateTime.now(),
      start: start,
      end: end,
    );
  }

  static String formatFullName({
    required String? firstName,
    required String? lastName,
    bool? addLastName = false,
  }) {
    if (firstName == null || lastName == null) return 'No name';
    if (addLastName == true) {
      return '$firstName $lastName';
    } else {
      return firstName;
    }
  }

  static String formatSimpleUserName(
    SimpleUserModel? user, {
    bool addLastName = false,
  }) {
    if (user?.status == UserStatus.deactivated) {
      return 'Deactivated User';
    }
    if (user?.status == UserStatus.deleted) {
      return 'Deleted User';
    }

    final preferredName = user?.displayName?.trim();
    if (preferredName != null && preferredName.isNotEmpty) {
      return preferredName;
    }

    return formatFullName(
      firstName: user?.firstName,
      lastName: user?.lastName,
      addLastName: addLastName,
    );
  }

  static String getDateRange({
    required DateTime? start,
    required DateTime? end,
  }) {
    if (start == null || end == null) return '';

    String startMonth = start.toAbbrMonth();
    String endMonth = end.toAbbrMonth();

    if (startMonth == endMonth) {
      return '$startMonth ${start.day} - ${end.day}, ${end.year}';
    } else {
      return '$startMonth ${start.day} - $endMonth ${end.day}, ${end.year}';
    }
  }

  static String getBookingDateRange({
    required Timestamp? start,
    required Timestamp? end,
  }) {
    return getDateRange(
      start: bookingDateFromTimestamp(start),
      end: bookingDateFromTimestamp(end),
    );
  }

  /// Generates a random LatLng within the specified radius (in meters) from the center point
  static LatLng getRandomLocationWithinRadius(LatLng center, double radius) {
    // Generate a random distance from center (0 to radius)
    final random = math.Random();
    final randomRadius = radius * math.sqrt(random.nextDouble());

    // Generate random angle
    final randomAngle = random.nextDouble() * 2 * math.pi;

    // Calculate offset in meters
    final xOffset = randomRadius * math.cos(randomAngle);
    final yOffset = randomRadius * math.sin(randomAngle);

    // Convert meter offsets to latitude/longitude offsets
    // 111,111 meters is approximately 1 degree of latitude
    // Longitude degrees vary based on latitude
    final latOffset = yOffset / 111111;
    final lngOffset =
        xOffset / (111111 * math.cos(center.latitude * math.pi / 180));

    return LatLng(center.latitude + latOffset, center.longitude + lngOffset);
  }

  // Helper method to conditionally show address based on useSpecificLocation
  static String getAddressText({
    required Location? location,
    required bool toObscure,
  }) {
    if (location == null) return '';

    final address = location.formattedAddress;

    // Return full address if useSpecificLocation is true
    if (location.useSpecificLocation == true ||
        address == null ||
        address.isEmpty) {
      if (toObscure) return (address ?? '').toObscure();

      return address ?? '';
    }

    // Otherwise show only last two components
    final components = address.split(', ');

    if (toObscure) {
      if (components.length <= 2) return address.toObscure();

      return components.sublist(components.length - 2).join(', ').toObscure();
    }

    if (components.length <= 2) return address;

    return components.sublist(components.length - 2).join(', ');
  }

  static String getLocationText({
    required Location? location,
    required bool showFullAddress,
  }) {
    if (location == null) return '';

    final address = location.formattedAddress ?? '';
    final cityCountry = [location.locality, location.country]
        .whereType<String>()
        .map((component) => component.trim())
        .where((component) => component.isNotEmpty)
        .toSet()
        .join(', ');

    if (showFullAddress) {
      if (address.trim().isNotEmpty) return address;
      return cityCountry;
    }

    if (cityCountry.isNotEmpty) return cityCountry;

    if (address.trim().isEmpty) return '';

    final components =
        address
            .split(',')
            .map((component) => component.trim())
            .where((component) => component.isNotEmpty)
            .toList();
    if (components.length >= 2) {
      return components.sublist(components.length - 2).join(', ');
    }

    return address;
  }

  static bool isTodayInTimestamps(List<Timestamp> timestamps) {
    final today = normalizeToDay(DateTime.now());

    // Check if today's date is in the list
    for (var ts in timestamps) {
      final timestampDate = normalizeToDay(ts.toDate());

      if (timestampDate == today) {
        return true;
      }
    }

    return false;
  }

  static bool canShowName(
    String? recipientUid,
    String? assetOwnerUid,
    Booking? booking,
  ) {
    final isBookingActiveOrCompleted =
        booking?.canViewActiveOwnerInfo == true || booking?.isCompleted == true;

    final isRecipientOwner = recipientUid == assetOwnerUid;

    return isRecipientOwner && !isBookingActiveOrCompleted;
  }

  static String ratingLabel(double rating) {
    if (rating == rating.roundToDouble()) {
      return rating.toStringAsFixed(0);
    }

    return rating.toStringAsFixed(1);
  }
}

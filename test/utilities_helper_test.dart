import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

void main() {
  group('LNDUtils date helpers', () {
    test('daysInInclusiveRange returns each normalized day in range', () {
      final days = LNDUtils.daysInInclusiveRange(
        DateTime(2026, 4, 10, 15, 30),
        DateTime(2026, 4, 12, 8, 0),
      );

      expect(days, [
        DateTime(2026, 4, 10),
        DateTime(2026, 4, 11),
        DateTime(2026, 4, 12),
      ]);
    });

    test('daysInExclusiveEndRange excludes the return boundary day', () {
      final days = LNDUtils.daysInExclusiveEndRange(
        DateTime(2026, 4, 10, 15, 30),
        DateTime(2026, 4, 12, 8, 0),
      );

      expect(days, [DateTime(2026, 4, 10), DateTime(2026, 4, 11)]);
    });

    test('exclusiveDayCount counts booked nights, not boundary dates', () {
      final totalDays = LNDUtils.exclusiveDayCount(
        DateTime(2026, 4, 10, 15, 30),
        DateTime(2026, 4, 12, 8, 0),
      );

      expect(totalDays, 2);
    });

    test('bookingDateMillisecondsSinceEpoch serializes date-only UTC days', () {
      final milliseconds = LNDUtils.bookingDateMillisecondsSinceEpoch(
        DateTime(2026, 6, 1, 15, 30),
      );

      expect(milliseconds, DateTime.utc(2026, 6, 1).millisecondsSinceEpoch);
    });

    test('bookingDateFromTimestamp reads UTC calendar dates', () {
      final timestamp = Timestamp.fromDate(DateTime.utc(2026, 6, 1));

      expect(
        LNDUtils.bookingDateFromTimestamp(timestamp),
        DateTime(2026, 6, 1),
      );
    });

    test('isDateWithinExclusiveEndRange allows next booking on end date', () {
      expect(
        LNDUtils.isDateWithinExclusiveEndRange(
          date: DateTime(2026, 4, 11, 20, 0),
          start: DateTime(2026, 4, 10),
          end: DateTime(2026, 4, 12),
        ),
        isTrue,
      );
      expect(
        LNDUtils.isDateWithinExclusiveEndRange(
          date: DateTime(2026, 4, 12),
          start: DateTime(2026, 4, 10),
          end: DateTime(2026, 4, 12),
        ),
        isFalse,
      );
    });

    test(
      'rangesOverlapExclusiveEnd treats touching boundaries as available',
      () {
        expect(
          LNDUtils.rangesOverlapExclusiveEnd(
            start: DateTime(2026, 4, 10),
            end: DateTime(2026, 4, 12),
            otherStart: DateTime(2026, 4, 12),
            otherEnd: DateTime(2026, 4, 14),
          ),
          isFalse,
        );
        expect(
          LNDUtils.rangesOverlapExclusiveEnd(
            start: DateTime(2026, 4, 10),
            end: DateTime(2026, 4, 12),
            otherStart: DateTime(2026, 4, 11),
            otherEnd: DateTime(2026, 4, 13),
          ),
          isTrue,
        );
      },
    );

    test('isTodayInTimestamps compares by normalized day', () {
      final now = DateTime.now();
      final timestamps = [
        Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59)),
      ];

      expect(LNDUtils.isTodayInTimestamps(timestamps), isTrue);
    });

    test('isDateWithinInclusiveRange handles same-day boundaries', () {
      final result = LNDUtils.isDateWithinInclusiveRange(
        date: DateTime(2026, 4, 15, 20, 0),
        start: DateTime(2026, 4, 15, 0, 1),
        end: DateTime(2026, 4, 15, 23, 0),
      );

      expect(result, isTrue);
    });
  });

  group('LNDUtils location helpers', () {
    test('Location writes new geocoded fields only', () {
      final location = Location(
        formattedAddress: 'Makati City',
        locality: 'Makati',
        country: 'Philippines',
        countryShortName: 'PH',
        lat: 14.5547,
        lng: 121.0244,
        useSpecificLocation: true,
      );

      final map = location.toMap();

      expect(map['formattedAddress'], 'Makati City');
      expect(map['locality'], 'Makati');
      expect(map['countryShortName'], 'PH');
      expect(map['lat'], 14.5547);
      expect(map['lng'], 121.0244);
      expect(map['geohash'], isA<String>());
      expect(map.containsKey('description'), isFalse);
      expect(map.containsKey('cityState'), isFalse);
      expect(map.containsKey('latLng'), isFalse);
      expect(map.containsKey('useSpecificLocation'), isFalse);
    });

    test('Location reads legacy fields for old records', () {
      final location = Location.fromMap({
        'description': '123 Main St, Makati, Philippines',
        'cityState': 'Makati',
        'country': 'Philippines',
        'latLng': {'latitude': 14.5547, 'longitude': 121.0244},
        'useSpecificLocation': false,
      });

      expect(location.formattedAddress, '123 Main St, Makati, Philippines');
      expect(location.locality, 'Makati');
      expect(location.lat, 14.5547);
      expect(location.lng, 121.0244);
      expect(location.geohash, isA<String>());
      expect(location.useSpecificLocation, isFalse);
    });

    test(
      'getLocationText returns city and country when address is limited',
      () {
        final location = Location(
          formattedAddress: '123 Main St, Makati, Philippines',
          locality: 'Makati',
          country: 'Philippines',
        );

        expect(
          LNDUtils.getLocationText(location: location, showFullAddress: false),
          'Makati, Philippines',
        );
        expect(
          LNDUtils.getLocationText(location: location, showFullAddress: true),
          '123 Main St, Makati, Philippines',
        );
      },
    );
  });

  group('LNDUtils simple user name helpers', () {
    test('formatSimpleUserName prefers displayName when present', () {
      final user = SimpleUserModel(
        firstName: 'Jamie',
        lastName: 'Reyes',
        displayName: 'Jamie Rentals OPC',
      );

      expect(LNDUtils.formatSimpleUserName(user), 'Jamie Rentals OPC');
    });

    test('formatSimpleUserName falls back to personal full name', () {
      final user = SimpleUserModel(firstName: 'Jamie', lastName: 'Reyes');

      expect(
        LNDUtils.formatSimpleUserName(user, addLastName: true),
        'Jamie Reyes',
      );
    });
  });
}

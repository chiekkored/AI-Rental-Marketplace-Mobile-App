import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/controllers/rental_history/rental_history.controller.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';

void main() {
  group('RentalHistoryController', () {
    test('loads rental history statuses', () {
      expect(RentalHistoryController.historyStatusLabels, [
        BookingStatus.declined.label,
        BookingStatus.cancelled.label,
        BookingStatus.completed.label,
      ]);
    });

    test('uses cache only for fresh existing bookings', () {
      final now = DateTime(2026, 6, 2, 12);

      expect(
        RentalHistoryController.shouldUseCache(
          forceRefresh: false,
          lastFetchedAt: now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        isTrue,
      );
    });

    test('uses cache for fresh empty results', () {
      final now = DateTime(2026, 6, 2, 12);

      expect(
        RentalHistoryController.shouldUseCache(
          forceRefresh: false,
          lastFetchedAt: now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        isTrue,
      );
    });

    test('skips cache when force refreshing, not fetched, or stale', () {
      final now = DateTime(2026, 6, 2, 12);

      expect(
        RentalHistoryController.shouldUseCache(
          forceRefresh: true,
          lastFetchedAt: now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        isFalse,
      );
      expect(
        RentalHistoryController.shouldUseCache(
          forceRefresh: false,
          lastFetchedAt: null,
          now: now,
        ),
        isFalse,
      );
      expect(
        RentalHistoryController.shouldUseCache(
          forceRefresh: false,
          lastFetchedAt: now.subtract(const Duration(minutes: 3)),
          now: now,
        ),
        isFalse,
      );
    });
  });
}

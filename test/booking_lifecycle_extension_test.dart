import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/extensions/bookingStatus.extension.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

void main() {
  group('BookingLifecycle', () {
    test('derives pending lifecycle', () {
      final booking = _booking(status: BookingStatus.pending);

      expect(booking.lifecyclePhase, BookingLifecyclePhase.pending);
      expect(booking.canAccept, true);
      expect(booking.rentalProgressStep, 1);
    });

    test('allows only the renter to cancel pending bookings', () {
      final pending = _booking(
        status: BookingStatus.pending,
        renterId: 'renter-1',
      );
      final confirmed = _booking(
        status: BookingStatus.confirmed,
        renterId: 'renter-1',
      );

      expect(pending.canCancelPendingBy('renter-1'), true);
      expect(pending.canCancelPendingBy('owner-1'), false);
      expect(pending.canCancelPendingBy(null), false);
      expect(confirmed.canCancelPendingBy('renter-1'), false);
    });

    test('derives confirmed lifecycle before handover', () {
      final booking = _booking(status: BookingStatus.confirmed);

      expect(booking.lifecyclePhase, BookingLifecyclePhase.confirmed);
      expect(booking.canStartHandover, true);
      expect(booking.canStartReturn, false);
      expect(booking.canViewConfirmedOwnerInfo, true);
      expect(booking.canViewActiveOwnerInfo, true);
    });

    test('derives handed-over lifecycle', () {
      final booking = _booking(status: BookingStatus.handedOver);

      expect(booking.lifecyclePhase, BookingLifecyclePhase.handedOver);
      expect(booking.canStartHandover, false);
      expect(booking.canStartReturn, true);
    });

    test('derives returned and completed lifecycle', () {
      final returned = _booking(status: BookingStatus.returned);
      final completed = _booking(status: BookingStatus.completed);

      expect(returned.lifecyclePhase, BookingLifecyclePhase.returned);
      expect(returned.canStartReturn, false);
      expect(returned.rentalProgressFinalLabel, 'Returned');
      expect(returned.canViewActiveOwnerInfo, true);
      expect(completed.lifecyclePhase, BookingLifecyclePhase.completed);
      expect(completed.rentalProgressFinalLabel, 'Completed');
      expect(completed.canViewActiveOwnerInfo, false);
    });

    test('detects support review from dispute and deposit flow statuses', () {
      final disputeSupportReview = _booking(
        status: BookingStatus.returned,
        disputeFlow: const BookingDisputeFlow(
          status: 'support_review',
          supportStatus: 'pending',
        ),
      );
      final depositSupportReview = _booking(
        status: BookingStatus.returned,
        depositFlow: const BookingDepositFlow(status: 'support_review'),
      );

      expect(disputeSupportReview.isAwaitingAdminSettlementReview, true);
      expect(depositSupportReview.isAwaitingAdminSettlementReview, true);
    });

    test('derives failed terminal lifecycle', () {
      final declined = _booking(status: BookingStatus.declined);
      final cancelled = _booking(status: BookingStatus.cancelled);

      expect(declined.lifecyclePhase, BookingLifecyclePhase.declined);
      expect(declined.rentalProgressFinalLabel, 'Declined');
      expect(declined.canViewActiveOwnerInfo, false);
      expect(cancelled.lifecyclePhase, BookingLifecyclePhase.cancelled);
      expect(cancelled.rentalProgressFinalLabel, 'Cancelled');
      expect(cancelled.canViewActiveOwnerInfo, false);
    });

    test(
      'identifies bookings that still require blocked-pair coordination',
      () {
        for (final status in [
          null,
          BookingStatus.pending,
          BookingStatus.confirmed,
          BookingStatus.handedOver,
          BookingStatus.returned,
          BookingStatus.cancellationRequested,
        ]) {
          expect(
            _booking(status: status).requiresBlockedPairCoordination,
            true,
            reason: '$status should preserve coordination',
          );
        }

        for (final status in [
          BookingStatus.completed,
          BookingStatus.cancelled,
          BookingStatus.declined,
        ]) {
          expect(
            _booking(status: status).requiresBlockedPairCoordination,
            false,
            reason: '$status should be terminal',
          );
        }
      },
    );

    test('resolves lifecycle colors from the active theme', () {
      expect(
        _booking(
          status: BookingStatus.pending,
        ).themedLifecycleColor(LNDTheme.light),
        LNDTheme.light.primary,
      );
      expect(
        _booking(
          status: BookingStatus.completed,
        ).themedLifecycleColor(LNDTheme.dark),
        LNDTheme.dark.success,
      );
      expect(
        _booking(
          status: BookingStatus.declined,
        ).themedLifecycleColor(LNDTheme.dark),
        LNDTheme.dark.danger,
      );
    });
  });

  group('BookingStatusColor', () {
    test('resolves status colors from the active theme', () {
      expect(
        BookingStatus.pending.themedColor(LNDTheme.dark),
        LNDTheme.dark.warning,
      );
      expect(
        BookingStatus.confirmed.themedColor(LNDTheme.light),
        LNDTheme.light.success,
      );
      expect(
        BookingStatus.cancelled.themedColor(LNDTheme.dark),
        LNDTheme.dark.danger,
      );
    });
  });
}

Booking _booking({
  BookingStatus? status,
  String? renterId,
  BookingDepositFlow? depositFlow,
  BookingDisputeFlow? disputeFlow,
}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: null,
    startDate: null,
    endDate: null,
    numDays: null,
    payment: null,
    renter: renterId == null ? null : SimpleUserModel(uid: renterId),
    status: status,
    totalPrice: null,
    tokens: null,
    depositFlow: depositFlow,
    disputeFlow: disputeFlow,
  );
}

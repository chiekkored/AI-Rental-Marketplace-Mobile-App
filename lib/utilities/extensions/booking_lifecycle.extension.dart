import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

enum BookingLifecyclePhase {
  pending,
  confirmed,
  handedOver,
  returned,
  completed,
  declined,
  cancelled,
  cancellationRequested,
  unknown,
}

extension BookingLifecycle on Booking {
  BookingLifecyclePhase get lifecyclePhase {
    switch (status) {
      case BookingStatus.pending:
        return BookingLifecyclePhase.pending;
      case BookingStatus.declined:
        return BookingLifecyclePhase.declined;
      case BookingStatus.cancelled:
        return BookingLifecyclePhase.cancelled;
      case BookingStatus.cancellationRequested:
        return BookingLifecyclePhase.cancellationRequested;
      case BookingStatus.confirmed:
        return BookingLifecyclePhase.confirmed;
      case BookingStatus.handedOver:
        return BookingLifecyclePhase.handedOver;
      case BookingStatus.returned:
        return BookingLifecyclePhase.returned;
      case BookingStatus.completed:
        return BookingLifecyclePhase.completed;
      case null:
        return BookingLifecyclePhase.unknown;
    }
  }

  bool get canAccept => lifecyclePhase == BookingLifecyclePhase.pending;

  bool get canStartHandover =>
      lifecyclePhase == BookingLifecyclePhase.confirmed;

  bool get canStartReturn => lifecyclePhase == BookingLifecyclePhase.handedOver;

  String? get settlementStatus =>
      disputeFlow?.status ?? depositFlow?.status ?? settlement?.status;

  String? get renterDepositResponse =>
      disputeFlow?.renterResponse ??
      depositFlow?.renterResponse ??
      settlement?.renterResponse;

  bool get hasSecurityDeposit =>
      depositFlow?.required == true ||
      securityDeposit.enabled ||
      (depositFlow?.amount ?? securityDeposit.amount) > 0;

  bool get isAwaitingOwnerSettlementAction =>
      lifecyclePhase == BookingLifecyclePhase.returned &&
      (depositFlow == null ||
          settlementStatus == 'awaiting_owner_action' ||
          settlementStatus == 'held' ||
          (!hasSecurityDeposit && settlementStatus == 'none'));

  bool get hasDamageDeductionRequest =>
      disputeFlow != null || settlementStatus == 'damage_deduction_requested';

  bool get isAwaitingAdminSettlementReview =>
      disputeFlow?.supportStatus == 'pending' ||
      disputeFlow?.supportStatus == 'in_progress' ||
      settlementStatus == 'admin_review_required' ||
      settlementStatus == 'support_pending' ||
      settlementStatus == 'support_review';

  bool get canViewConfirmedOwnerInfo =>
      status == BookingStatus.confirmed ||
      lifecyclePhase == BookingLifecyclePhase.handedOver ||
      lifecyclePhase == BookingLifecyclePhase.returned ||
      lifecyclePhase == BookingLifecyclePhase.completed;

  bool get isCompleted => status == BookingStatus.completed;

  bool get canViewActiveOwnerInfo =>
      status != null && BookingStatus.active.contains(status);

  bool get requiresBlockedPairCoordination =>
      lifecyclePhase == BookingLifecyclePhase.pending ||
      lifecyclePhase == BookingLifecyclePhase.confirmed ||
      lifecyclePhase == BookingLifecyclePhase.handedOver ||
      lifecyclePhase == BookingLifecyclePhase.returned ||
      lifecyclePhase == BookingLifecyclePhase.cancellationRequested ||
      lifecyclePhase == BookingLifecyclePhase.unknown;

  bool canCancelPendingBy(String? userId) {
    return canRequestCancellationBy(userId);
  }

  bool canRequestCancellationBy(String? userId, {DateTime? now}) {
    if (userId == null || userId.isEmpty) {
      return false;
    }

    if (asset?.owner?.uid == userId) {
      return lifecyclePhase == BookingLifecyclePhase.confirmed;
    }

    if (renter?.uid != userId) return false;

    final phase = lifecyclePhase;
    if (phase != BookingLifecyclePhase.pending &&
        phase != BookingLifecyclePhase.confirmed) {
      return false;
    }

    final startTimestamp = startDate;
    final start =
        startTimestamp == null
            ? null
            : _bookingDateFromTimestamp(startTimestamp);
    if (start == null) return false;

    return (now ?? DateTime.now()).isBefore(start);
  }

  int get rentalProgressStep {
    switch (lifecyclePhase) {
      case BookingLifecyclePhase.pending:
        return 1;
      case BookingLifecyclePhase.confirmed:
      case BookingLifecyclePhase.handedOver:
      case BookingLifecyclePhase.returned:
      case BookingLifecyclePhase.completed:
      case BookingLifecyclePhase.cancellationRequested:
      case BookingLifecyclePhase.declined:
      case BookingLifecyclePhase.cancelled:
        return 2;
      case BookingLifecyclePhase.unknown:
        return 0;
    }
  }

  String get rentalProgressFinalLabel {
    switch (lifecyclePhase) {
      case BookingLifecyclePhase.declined:
        return 'Declined';
      case BookingLifecyclePhase.cancelled:
        return 'Cancelled';
      case BookingLifecyclePhase.cancellationRequested:
        return 'Cancellation requested';
      case BookingLifecyclePhase.handedOver:
        return 'Handed over';
      case BookingLifecyclePhase.returned:
        return 'Returned';
      case BookingLifecyclePhase.completed:
        return 'Completed';
      default:
        return 'Confirmed';
    }
  }

  Color themedLifecycleColor(LNDTheme colors) {
    switch (lifecyclePhase) {
      case BookingLifecyclePhase.pending:
      case BookingLifecyclePhase.cancellationRequested:
        return colors.primary;
      case BookingLifecyclePhase.confirmed:
      case BookingLifecyclePhase.handedOver:
      case BookingLifecyclePhase.returned:
      case BookingLifecyclePhase.completed:
        return colors.success;
      case BookingLifecyclePhase.declined:
      case BookingLifecyclePhase.cancelled:
        return colors.danger;
      case BookingLifecyclePhase.unknown:
        return colors.textPrimary;
    }
  }
}

DateTime _bookingDateFromTimestamp(Timestamp timestamp) {
  final utcDate = timestamp.toDate().toUtc();
  return DateTime(utcDate.year, utcDate.month, utcDate.day);
}

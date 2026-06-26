import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';

void main() {
  group('Booking.fromMap', () {
    test('round trips the complete booking asset snapshot', () {
      final booking = Booking.fromMap({
        'id': 'booking-with-asset',
        'asset': {
          'id': 'asset-1',
          'ownerId': 'owner-1',
          'title': 'Camera',
          'description': 'A camera available for events.',
          'images': ['image-1'],
          'showcase': ['showcase-1'],
          'inclusions': ['Battery'],
          'listingKind': 'vehicle',
          'detailSchemaKey': 'vehicle',
          'details': {'make': 'Toyota', 'model': 'Vios', 'year': 2023},
          'averageRating': 4.5,
          'reviewCount': 2,
        },
      });

      final asset = booking.asset;
      final serializedAsset = booking.toMap()['asset'] as Map<String, dynamic>;

      expect(asset?.ownerId, 'owner-1');
      expect(asset?.description, 'A camera available for events.');
      expect(asset?.showcase, ['showcase-1']);
      expect(asset?.inclusions, ['Battery']);
      expect(asset?.listingDetails.details, isA<VehicleListingDetails>());
      expect(asset?.averageRating, 4.5);
      expect(asset?.reviewCount, 2);
      expect(serializedAsset['description'], 'A camera available for events.');
      expect(serializedAsset['details'], isA<Map<String, dynamic>>());
    });

    test('uses explicit start/end fields when present', () {
      final booking = Booking.fromMap({
        'id': 'booking-1',
        'chatId': 'chat-1',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'startDate': Timestamp.fromDate(DateTime(2026, 4, 10, 16, 0)),
        'endDate': Timestamp.fromDate(DateTime(2026, 4, 12, 9, 0)),
        'numDays': 3,
        'status': BookingStatus.pending.label,
        'totalPrice': 1500,
      });

      expect(booking.startDate?.toDate(), DateTime(2026, 4, 10, 16, 0));
      expect(booking.endDate?.toDate(), DateTime(2026, 4, 12, 9, 0));
      expect(booking.numDays, 3);
      expect(booking.status, BookingStatus.pending);
    });

    test('derives numDays with exclusive end-date semantics', () {
      final booking = Booking.fromMap({
        'id': 'booking-no-num-days',
        'chatId': 'chat-no-num-days',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'startDate': Timestamp.fromDate(DateTime(2026, 4, 10, 16, 0)),
        'endDate': Timestamp.fromDate(DateTime(2026, 4, 12, 9, 0)),
        'status': BookingStatus.pending.label,
        'totalPrice': 1500,
      });

      expect(booking.numDays, 2);
    });

    test('parses PayMongo pricing breakdown fields', () {
      final booking = Booking.fromMap({
        'id': 'booking-with-payment',
        'chatId': 'chat-with-payment',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'status': BookingStatus.confirmed.label,
        'totalPrice': 1500,
        'payment': {
          'provider': 'paymongo',
          'method': 'gcash',
          'details': {'source': 'wallet'},
          'amount': 1660,
          'paymongoAmount': 1660,
          'rentalSubtotal': 1500,
          'pricingBreakdown': {
            'rentalSubtotal': 1500,
            'renterPlatformFee': 75,
            'renterProcessingFee': 60,
            'securityDepositAmount': 100,
            'ownerSecurityDepositPaymentFee': 20,
            'paymentAmount': 1660,
            'ownerWalletTransferFee': 10,
            'ownerDepositReturnWalletFee': 10,
            'ownerPayoutAmount': 1405,
          },
          'currency': 'php',
          'status': 'paid',
          'ownerPayoutAmount': 1405,
          'payoutStatus': 'pending',
        },
      });

      final payment = booking.payment;

      expect(payment?.details, {'source': 'wallet'});
      expect(payment?.amount, 1660);
      expect(payment?.paymongoAmount, 1660);
      expect(payment?.rentalSubtotal, 1500);
      expect(payment?.pricingBreakdown?['renterPlatformFee'], 75);
      expect(payment?.pricingBreakdown?['renterProcessingFee'], 60);
      expect(payment?.pricingBreakdown?['ownerSecurityDepositPaymentFee'], 20);
      expect(payment?.pricingBreakdown?['ownerPayoutAmount'], 1405);
      expect(payment?.currency, 'php');
      expect(payment?.ownerPayoutAmount, 1405);
      expect(payment?.payoutStatus, 'pending');
    });

    test('parses settlement into typed model', () {
      final updatedAt = Timestamp.fromDate(DateTime(2026, 4, 15));
      final booking = Booking.fromMap({
        'id': 'booking-with-settlement',
        'chatId': 'chat-with-settlement',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'status': BookingStatus.returned.label,
        'totalPrice': 1500,
        'settlement': {
          'status': 'support_pending',
          'depositStatus': 'support_pending',
          'renterResponse': 'disputed',
          'approvedDamageDeductionAmount': 1200,
          'depositCoveredDamageAmount': 1000,
          'outstandingDamageAmount': 200,
          'depositReturnAmount': 0,
          'ownerPayoutAmount': 1400,
          'supportStatus': 'pending',
          'renterSupportChatId': 'renter-chat',
          'ownerSupportChatId': 'owner-chat',
          'damageBalancePaymentStatus': 'pending',
          'ownerDamageBalancePayoutStatus': 'pending_admin_release',
          'finalOwnerPayoutAmount': 1720,
          'finalOwnerPayoutGrossAmount': 1730,
          'finalOwnerPayoutWalletTransferFee': 10,
          'finalOwnerPayoutReleasedComponents': {
            'baseOwnerGrossAmount': 980,
            'depositCoveredDamageAmount': 500,
            'depositReturnAmount': 0,
            'paidOutstandingDamageAmount': 250,
          },
          'damageBalancePaymentRequests': {
            'request-1': {'amount': 200},
          },
          'updatedAt': updatedAt,
        },
      });

      final settlement = booking.settlement;

      expect(settlement?.status, 'support_pending');
      expect(settlement?.depositStatus, 'support_pending');
      expect(settlement?.renterResponse, 'disputed');
      expect(settlement?.approvedDamageDeductionAmount, 1200);
      expect(settlement?.depositCoveredDamageAmount, 1000);
      expect(settlement?.outstandingDamageAmount, 200);
      expect(settlement?.depositReturnAmount, 0);
      expect(settlement?.ownerPayoutAmount, 1400);
      expect(settlement?.supportStatus, 'pending');
      expect(settlement?.renterSupportChatId, 'renter-chat');
      expect(settlement?.ownerSupportChatId, 'owner-chat');
      expect(settlement?.damageBalancePaymentStatus, 'pending');
      expect(
        settlement?.ownerDamageBalancePayoutStatus,
        'pending_admin_release',
      );
      expect(settlement?.finalOwnerPayoutAmount, 1720);
      expect(settlement?.finalOwnerPayoutGrossAmount, 1730);
      expect(settlement?.finalOwnerPayoutWalletTransferFee, 10);
      expect(
        settlement?.finalOwnerPayoutReleasedComponents?['baseOwnerGrossAmount'],
        980,
      );
      expect(
        settlement?.damageBalancePaymentRequests?['request-1']['amount'],
        200,
      );
      expect(settlement?.updatedAt, updatedAt);
    });

    test('parses owner penalty payout flow fields', () {
      final booking = Booking.fromMap({
        'id': 'booking-with-payout-flow',
        'chatId': 'chat-with-payout-flow',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'status': BookingStatus.completed.label,
        'totalPrice': 1500,
        'payoutFlow': {
          'ownerPayoutStatus': 'succeeded',
          'ownerPayoutAmountBeforePenalty': 1400,
          'ownerPenaltyDeductionAmount': 500,
          'ownerPayoutAmount': 900,
          'ownerPenaltyApplications': [
            {
              'penaltyId': 'penalty-1',
              'appliedAmount': 500,
              'remainingAmountAfter': 0,
              'status': 'applied',
            },
          ],
        },
      });

      final payoutFlow = booking.payoutFlow;

      expect(payoutFlow?.ownerPayoutStatus, 'succeeded');
      expect(payoutFlow?.ownerPayoutAmountBeforePenalty, 1400);
      expect(payoutFlow?.ownerPenaltyDeductionAmount, 500);
      expect(payoutFlow?.ownerPayoutAmount, 900);
      expect(payoutFlow?.ownerPenaltyApplications, [
        {
          'penaltyId': 'penalty-1',
          'appliedAmount': 500,
          'remainingAmountAfter': 0,
          'status': 'applied',
        },
      ]);
      expect(payoutFlow?.toMap()['ownerPenaltyDeductionAmount'], 500);
      expect(
        payoutFlow?.toMap()['ownerPenaltyApplications'],
        isA<List<Map<String, dynamic>>>(),
      );
    });

    test('parses cancellation request into typed model', () {
      final booking = Booking.fromMap({
        'id': 'booking-with-cancellation',
        'chatId': 'chat-with-cancellation',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'status': BookingStatus.cancelled.label,
        'totalPrice': 1500,
        'cancellationRequest': {
          'status': 'Approved',
          'requestedByRole': 'renter',
          'reason': 'Schedule changed',
          'refundStatus': 'succeeded',
          'adminNotes': 'Approved by support',
          'renterPenalty': {'refundAmount': 1500, 'retainedOwnerAmount': 0},
          'ownerPenalty': {'penaltyAmount': 500},
        },
      });

      final request = booking.cancellationRequest;

      expect(request?.status, 'Approved');
      expect(request?.requestedByRole, 'renter');
      expect(request?.reason, 'Schedule changed');
      expect(request?.refundStatus, 'succeeded');
      expect(request?.adminNotes, 'Approved by support');
      expect(request?.renterPenalty?['refundAmount'], 1500);
      expect(request?.renterPenalty?['retainedOwnerAmount'], 0);
      expect(request?.ownerPenalty?['penaltyAmount'], 500);
      expect(request?.toMap()['renterPenalty'], isA<Map<String, dynamic>>());
    });

    test('parses damage deduction request into typed model', () {
      final requestedAt = Timestamp.fromDate(DateTime(2026, 4, 15));
      final booking = Booking.fromMap({
        'id': 'booking-with-damage-request',
        'chatId': 'chat-with-damage-request',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'status': BookingStatus.returned.label,
        'totalPrice': 1500,
        'damageDeductionRequest': {
          'status': 'requested',
          'requestedAmount': 1200,
          'approvedAmount': 1000,
          'reason': 'Scratch',
          'notes': 'Visible scratch on the body',
          'evidenceUrls': ['https://example.test/photo.jpg'],
          'requiresSupportReview': true,
          'overDepositRequested': true,
          'requestedBy': 'owner-1',
          'requestedAt': requestedAt,
          'renterResponse': 'awaiting_renter_response',
          'adminNotes': 'Needs review',
          'renterSupportChatId': 'renter-chat',
          'ownerSupportChatId': 'owner-chat',
          'depositCoveredAmount': 1000,
          'outstandingAmount': 200,
          'paidOutstandingAmount': 200,
          'resolvedBy': 'admin-1',
        },
      });

      final request = booking.damageDeductionRequest;

      expect(request?.status, 'requested');
      expect(request?.requestedAmount, 1200);
      expect(request?.approvedAmount, 1000);
      expect(request?.reason, 'Scratch');
      expect(request?.notes, 'Visible scratch on the body');
      expect(request?.evidenceUrls, ['https://example.test/photo.jpg']);
      expect(request?.requiresSupportReview, true);
      expect(request?.overDepositRequested, true);
      expect(request?.requestedBy, 'owner-1');
      expect(request?.requestedAt, requestedAt);
      expect(request?.renterResponse, 'awaiting_renter_response');
      expect(request?.adminNotes, 'Needs review');
      expect(request?.renterSupportChatId, 'renter-chat');
      expect(request?.ownerSupportChatId, 'owner-chat');
      expect(request?.depositCoveredAmount, 1000);
      expect(request?.outstandingAmount, 200);
      expect(request?.paidOutstandingAmount, 200);
      expect(request?.resolvedBy, 'admin-1');
    });

    test(
      'serializes typed settlement and damage request as Firestore maps',
      () {
        final booking = Booking(
          id: 'booking-to-map',
          chatId: 'chat-to-map',
          asset: null,
          createdAt: null,
          payment: null,
          renter: null,
          status: BookingStatus.returned,
          totalPrice: 1500,
          settlement: Settlement(
            status: 'admin_review_required',
            depositStatus: 'admin_review_required',
            approvedDamageDeductionAmount: 900,
            finalOwnerPayoutAmount: 1720,
            finalOwnerPayoutReleasedComponents: {
              'depositCoveredDamageAmount': 500,
            },
          ),
          damageDeductionRequest: DamageDeductionRequest(
            status: 'requested',
            requestedAmount: 900,
            evidenceUrls: ['https://example.test/photo.jpg'],
          ),
        );

        final map = booking.toMap();

        expect(map['settlement'], {
          'status': 'admin_review_required',
          'depositStatus': 'admin_review_required',
          'approvedDamageDeductionAmount': 900,
          'finalOwnerPayoutAmount': 1720,
          'finalOwnerPayoutReleasedComponents': {
            'depositCoveredDamageAmount': 500,
          },
        });
        expect(map['damageDeductionRequest'], {
          'status': 'requested',
          'requestedAmount': 900,
          'evidenceUrls': ['https://example.test/photo.jpg'],
        });
      },
    );

    test('defaults missing damage evidence URLs to empty list', () {
      final request = DamageDeductionRequest.fromMap({
        'status': 'requested',
        'requestedAmount': 900,
      });

      expect(request.evidenceUrls, isEmpty);
    });

    test('booking equality includes deposit flow changes', () {
      final before = _bookingWithFlow(
        depositFlow: const BookingDepositFlow(status: 'awaiting_owner_action'),
      );
      final after = _bookingWithFlow(
        depositFlow: const BookingDepositFlow(status: 'support_review'),
      );

      expect(after, isNot(before));
      expect(after.hashCode, isNot(before.hashCode));
    });

    test('booking equality includes dispute flow changes', () {
      final before = _bookingWithFlow(
        disputeFlow: const BookingDisputeFlow(
          status: 'requested',
          supportStatus: null,
        ),
      );
      final after = _bookingWithFlow(
        disputeFlow: const BookingDisputeFlow(
          status: 'support_review',
          supportStatus: 'pending',
        ),
      );

      expect(after, isNot(before));
      expect(after.hashCode, isNot(before.hashCode));
    });

    test('payout flow preserves deposit return movement timestamps', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 4, 15, 10, 30));
      final booking = Booking.fromMap({
        'id': 'booking-with-payout-flow',
        'chatId': 'chat-with-payout-flow',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'status': BookingStatus.completed.label,
        'totalPrice': 1500,
        'payoutFlow': {
          'depositReturnStatus': 'processing',
          'depositReturnAmount': 400,
          'movements': {
            'deposit_return': {
              'amount': 400,
              'status': 'processing',
              'createdAt': createdAt,
            },
          },
        },
      });

      final depositReturn =
          booking.payoutFlow?.movements?['deposit_return']
              as Map<String, dynamic>?;

      expect(booking.payoutFlow?.depositReturnStatus, 'processing');
      expect(booking.payoutFlow?.depositReturnAmount, 400);
      expect(depositReturn?['createdAt'], createdAt);
      expect(
        booking
            .toMap()['payoutFlow']['movements']['deposit_return']['createdAt'],
        createdAt,
      );
    });
  });
}

Booking _bookingWithFlow({
  BookingDepositFlow? depositFlow,
  BookingDisputeFlow? disputeFlow,
}) {
  return Booking(
    id: 'booking-1',
    chatId: 'chat-1',
    asset: null,
    createdAt: null,
    payment: null,
    renter: null,
    status: BookingStatus.returned,
    totalPrice: 1500,
    depositFlow: depositFlow,
    disputeFlow: disputeFlow,
  );
}

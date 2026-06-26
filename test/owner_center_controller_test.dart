import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/presentation/controllers/owner_center/owner_center.controller.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';

void main() {
  group('OwnerCenterController summaries', () {
    test('counts listings by availability status', () {
      final assets = [
        _asset(id: 'available-1', status: Availability.available),
        _asset(id: 'available-2', status: Availability.available),
        _asset(id: 'maintenance-1', status: Availability.underMaintenance),
        _asset(id: 'hidden-1', status: Availability.hidden),
      ];

      expect(
        OwnerCenterController.listingCountFor(assets, Availability.available),
        2,
      );
      expect(
        OwnerCenterController.listingCountFor(
          assets,
          Availability.underMaintenance,
        ),
        1,
      );
      expect(
        OwnerCenterController.listingCountFor(assets, Availability.hidden),
        1,
      );
    });

    test('sums only completed owner payout amounts', () {
      final bookings = [
        _booking(payoutAmount: 500, payoutStatus: 'succeeded'),
        _booking(payoutAmount: 250, payoutStatus: 'paid'),
        _booking(payoutAmount: 100, payoutStatus: 'released'),
        _booking(payoutAmount: 50, payoutStatus: 'completed'),
      ];

      expect(OwnerCenterController.completedOwnerPayoutTotal(bookings), 900);
    });

    test('ignores pending failed missing and zero payout amounts', () {
      final bookings = [
        _booking(payoutAmount: 500, payoutStatus: 'pending'),
        _booking(payoutAmount: 250, payoutStatus: 'failed'),
        _booking(payoutAmount: 0, payoutStatus: 'succeeded'),
        _booking(payoutAmount: null, payoutStatus: 'paid'),
        _booking(payoutAmount: 100, payoutStatus: null),
      ];

      expect(OwnerCenterController.completedOwnerPayoutTotal(bookings), 0);
    });
  });
}

SimpleAsset _asset({required String id, required Availability status}) {
  return SimpleAsset(
    id: id,
    owner: null,
    title: id,
    images: const [],
    categoryId: 'cameras',
    categoryName: 'Cameras',
    createdAt: null,
    status: status.label,
    location: null,
  );
}

Booking _booking({required num? payoutAmount, required String? payoutStatus}) {
  return Booking(
    id: 'booking-${payoutStatus ?? 'missing'}-${payoutAmount ?? 'none'}',
    chatId: null,
    asset: null,
    createdAt: null,
    payment: null,
    paymentFlow: const BookingPaymentFlow(currency: 'PHP'),
    payoutFlow: BookingPayoutFlow(
      ownerPayoutAmount: payoutAmount,
      ownerPayoutStatus: payoutStatus,
    ),
    renter: null,
    status: BookingStatus.completed,
    totalPrice: null,
  );
}

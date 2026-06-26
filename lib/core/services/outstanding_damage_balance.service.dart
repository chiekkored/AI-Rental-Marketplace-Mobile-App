import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/outstanding_damage_balance.model.dart';
import 'package:lend/utilities/constants/collections.constant.dart';

class LNDOutstandingDamageBalanceService {
  LNDOutstandingDamageBalanceService._();

  static Stream<List<OutstandingDamageBalance>> watchOutstandingBalances(
    String renterId,
  ) {
    return FirebaseFirestore.instance
        .collection(LNDCollections.users.name)
        .doc(renterId)
        .collection(LNDCollections.bookings.name)
        .where('settlement.outstandingDamageAmount', isGreaterThan: 0)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] ??= doc.id;
                return OutstandingDamageBalance.fromBooking(
                  Booking.fromMap(data),
                );
              })
              .where((item) => item.amount > 0)
              .toList(growable: false),
        );
  }
}

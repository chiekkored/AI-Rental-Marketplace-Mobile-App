import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class OwnerCenterController extends GetxController {
  static const completedOwnerPayoutStatuses = {
    'completed',
    'paid',
    'released',
    'succeeded',
  };

  final RxList<SimpleAsset> _ownedAssets = <SimpleAsset>[].obs;
  final RxNum _ownerPayoutTotal = RxNum(0);
  final RxString _ownerPayoutCurrency = LNDMoney.currentCurrencyCode().obs;
  StreamSubscription? _ownedAssetsSubscription;
  final Map<String, StreamSubscription> _ownerPayoutSubscriptions = {};
  final Map<String, List<Booking>> _ownerPayoutBookingsByAssetId = {};

  List<SimpleAsset> get ownedAssets => _ownedAssets;
  int get availableListingCount =>
      listingCountFor(_ownedAssets, Availability.available);
  int get underMaintenanceListingCount =>
      listingCountFor(_ownedAssets, Availability.underMaintenance);
  int get hiddenListingCount =>
      listingCountFor(_ownedAssets, Availability.hidden);
  num get ownerPayoutTotal => _ownerPayoutTotal.value;
  String get ownerPayoutCurrency => _ownerPayoutCurrency.value;
  num get outstandingBalanceTotal =>
      ProfileController.instance.outstandingDamageBalanceTotal;
  String get outstandingBalanceCurrency =>
      ProfileController.instance.outstandingDamageBalanceCurrency;
  bool get shouldShowBusinessRegistration =>
      ProfileController.instance.user?.isBusinessRegistrationVisible == true;

  @override
  void onInit() {
    super.onInit();
    listenToOwnerCenter();
  }

  @override
  void onClose() {
    cancelSubscriptions();
    _ownedAssets.close();
    _ownerPayoutTotal.close();
    _ownerPayoutCurrency.close();
    super.onClose();
  }

  void listenToOwnerCenter() {
    final userId = AuthController.instance.uid;
    cancelSubscriptions();

    if (userId == null || userId.isEmpty) {
      _ownedAssets.clear();
      _setPayoutSummary(const []);
      return;
    }

    if (!ProfileController.instance.canList) return;

    LNDLogger.dNoStack('🟢 Owner Center Subscription Started');
    _ownedAssetsSubscription = LNDAssetService.watchOwnerAssets(userId).listen(
      (assets) {
        final supportedAssets = assets
            .where(_hasSupportedStatus)
            .toList(growable: false);

        _ownedAssets.assignAll(supportedAssets);
        _syncOwnerPayoutSubscriptions(
          supportedAssets
              .map((asset) => asset.id)
              .where((id) => id.isNotEmpty)
              .toSet(),
        );
      },
      onError: (e, st) {
        LNDLogger.e(
          'Error listening to owner center assets',
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  void cancelSubscriptions() {
    _ownedAssetsSubscription?.cancel();
    _ownedAssetsSubscription = null;

    for (final subscription in _ownerPayoutSubscriptions.values) {
      subscription.cancel();
    }
    _ownerPayoutSubscriptions.clear();
    _ownerPayoutBookingsByAssetId.clear();
    _setPayoutSummary(const []);
    LNDLogger.dNoStack('🔴 Owner Center subscriptions cancelled');
  }

  void openOwnListings() {
    LNDNavigate.toMyAssetPage();
  }

  void goToCreateListing() {
    YourListingController.instance.goToCreateListing();
  }

  void openOutstandingBalances() {
    ProfileController.instance.goToOutstandingDamageBalances();
  }

  void openPayoutDestination() {
    LNDNavigate.toOwnerPayoutDestinationPage();
  }

  void openBusinessRegistration() {
    LNDNavigate.toBusinessRegistrationPage();
  }

  void _syncOwnerPayoutSubscriptions(Set<String> assetIds) {
    final removedAssetIds =
        _ownerPayoutSubscriptions.keys
            .where((assetId) => !assetIds.contains(assetId))
            .toList();

    for (final assetId in removedAssetIds) {
      _ownerPayoutSubscriptions.remove(assetId)?.cancel();
      _ownerPayoutBookingsByAssetId.remove(assetId);
    }

    for (final assetId in assetIds) {
      if (_ownerPayoutSubscriptions.containsKey(assetId)) continue;

      _ownerPayoutSubscriptions[assetId] = FirebaseFirestore.instance
          .collection(LNDCollections.assets.name)
          .doc(assetId)
          .collection(LNDCollections.bookings.name)
          .where(
            'payoutFlow.ownerPayoutStatus',
            whereIn: completedOwnerPayoutStatuses.toList(),
          )
          .snapshots()
          .listen(
            (snapshot) {
              _ownerPayoutBookingsByAssetId[assetId] = snapshot.docs
                  .map((doc) {
                    final data = doc.data();
                    data['id'] ??= doc.id;
                    return Booking.fromMap(data);
                  })
                  .toList(growable: false);
              _rebuildOwnerPayoutSummary();
            },
            onError: (e, st) {
              LNDLogger.e(
                'Error listening to owner payout bookings for asset $assetId',
                error: e,
                stackTrace: st,
              );
            },
          );
    }

    if (removedAssetIds.isNotEmpty || assetIds.isEmpty) {
      _rebuildOwnerPayoutSummary();
    }
  }

  void _rebuildOwnerPayoutSummary() {
    _setPayoutSummary(
      _ownerPayoutBookingsByAssetId.values.expand((bookings) => bookings),
    );
  }

  void _setPayoutSummary(Iterable<Booking> bookings) {
    final bookingList = bookings.toList(growable: false);
    _ownerPayoutTotal.value = completedOwnerPayoutTotal(bookingList);
    _ownerPayoutCurrency.value =
        firstOwnerPayoutCurrency(bookingList) ?? LNDMoney.currentCurrencyCode();
  }

  static bool _hasSupportedStatus(SimpleAsset asset) {
    return Availability.values.any((status) => status.label == asset.status);
  }

  static int listingCountFor(
    Iterable<SimpleAsset> assets,
    Availability status,
  ) {
    return assets.where((asset) => asset.status == status.label).length;
  }

  static num completedOwnerPayoutTotal(Iterable<Booking> bookings) {
    return bookings.fold<num>(0, (total, booking) {
      if (!isCompletedOwnerPayoutStatus(
        booking.payoutFlow?.ownerPayoutStatus,
      )) {
        return total;
      }

      final amount = booking.payoutFlow?.ownerPayoutAmount;
      if (amount == null || amount <= 0) return total;
      return total + amount;
    });
  }

  static String? firstOwnerPayoutCurrency(Iterable<Booking> bookings) {
    for (final booking in bookings) {
      if (!isCompletedOwnerPayoutStatus(
        booking.payoutFlow?.ownerPayoutStatus,
      )) {
        continue;
      }
      final amount = booking.payoutFlow?.ownerPayoutAmount;
      if (amount == null || amount <= 0) continue;

      final currency =
          booking.paymentFlow?.currency ??
          booking.priceBreakdown.currency ??
          booking.payment?.currency ??
          booking.asset?.rates?.currency;
      final trimmed = currency?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  static bool isCompletedOwnerPayoutStatus(String? status) {
    final normalized = status?.trim().toLowerCase();
    return normalized != null &&
        completedOwnerPayoutStatuses.contains(normalized);
  }
}

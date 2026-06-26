import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/mixins/scroll.mixin.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

enum NowBookingRole { renter, owner }

class NowBookingItem {
  const NowBookingItem({required this.booking, required this.role});

  final Booking booking;
  final NowBookingRole role;

  String get roleLabel =>
      role == NowBookingRole.owner ? 'Your Unit' : 'To Rent';
}

class NowController extends GetxController with AuthMixin, LNDScrollMixin {
  static NowController get instance => Get.find<NowController>();

  final RxBool _isNowLoading = false.obs;
  bool get isNowLoading => _isNowLoading.value;

  final RxList<Booking> _renterBookings = <Booking>[].obs;
  List<Booking> get renterBookings => _renterBookings;

  final RxList<NowBookingItem> _nowBookings = <NowBookingItem>[].obs;
  List<NowBookingItem> get todayNowBookings =>
      _nowBookings.where((item) => _isTodayBooking(item.booking)).toList()
        ..sort(_sortNowBookings);
  bool get hasHappeningToday => todayNowBookings.isNotEmpty;
  List<NowBookingItem> get incomingNowBookings =>
      _nowBookings.where((item) => _isIncomingConfirmed(item.booking)).toList()
        ..sort(_sortNowBookings);

  StreamSubscription? _renterBookingsSubscription;
  StreamSubscription? _ownedAssetsSubscription;
  final Map<String, StreamSubscription> _ownerBookingSubscriptions = {};
  final Map<String, List<NowBookingItem>> _ownerBookingsByAssetId = {};
  int _nowRefreshToken = 0;

  @override
  void onClose() {
    cancelSubscriptions();
    _isNowLoading.close();
    _renterBookings.close();
    _nowBookings.close();

    super.onClose();
  }

  void cancelSubscriptions() {
    if (_renterBookingsSubscription != null) {
      _renterBookingsSubscription?.cancel();
      _renterBookingsSubscription = null;
      LNDLogger.dNoStack('🔴 Now renter subscription cancelled');
    }

    if (_ownedAssetsSubscription != null) {
      _ownedAssetsSubscription?.cancel();
      _ownedAssetsSubscription = null;
      LNDLogger.dNoStack('🔴 Now owned assets subscription cancelled');
    }

    if (_ownerBookingSubscriptions.isNotEmpty) {
      for (final subscription in _ownerBookingSubscriptions.values) {
        subscription.cancel();
      }
      _ownerBookingSubscriptions.clear();
      _ownerBookingsByAssetId.clear();
      LNDLogger.dNoStack('🔴 Now owner booking subscriptions cancelled');
    }
  }

  void listenToNow() {
    final userId = AuthController.instance.uid;

    try {
      cancelSubscriptions();

      if (userId == null) {
        clearNow();
        return;
      }

      LNDLogger.dNoStack('🟢 Now Subscription Started');
      _renterBookingsSubscription = FirebaseFirestore.instance
          .collection(LNDCollections.users.name)
          .doc(userId)
          .collection(LNDCollections.bookings.name)
          .where('status', whereIn: BookingStatus.activeLabels)
          .limit(20)
          .snapshots()
          .listen(
            (snapshot) async {
              try {
                final refreshToken = ++_nowRefreshToken;
                final bookingList =
                    snapshot.docs
                        .map((doc) => Booking.fromMap(doc.data()))
                        .toList();

                _renterBookings.assignAll(bookingList);
                _rebuildNowBookings(refreshToken: refreshToken);
              } catch (e, st) {
                LNDLogger.e(
                  'Error refreshing now bookings',
                  error: e,
                  stackTrace: st,
                );
              }
            },
            onError: (e, st) {
              LNDLogger.e(
                'Error listening to rentals',
                error: e,
                stackTrace: st,
              );
            },
          );

      _listenToOwnedAssets(userId);
    } catch (e, st) {
      LNDLogger.e('Error setting up now listener', error: e, stackTrace: st);
    }
  }

  Future<void> getNowBookings({bool showLoading = true}) async {
    try {
      final userId = AuthController.instance.uid;
      if (userId == null) {
        _renterBookings.clear();
        _ownerBookingsByAssetId.clear();
        _nowBookings.clear();
        return;
      }

      if (showLoading) _isNowLoading.value = true;
      final refreshToken = ++_nowRefreshToken;

      final bookingsDocs =
          await FirebaseFirestore.instance
              .collection(LNDCollections.users.name)
              .doc(userId)
              .collection(LNDCollections.bookings.name)
              .get();

      final rentalsList =
          bookingsDocs.docs.map((e) => Booking.fromMap(e.data())).toList();

      _renterBookings.assignAll(rentalsList);
      final ownerItemsByAssetId = await _getOwnerBookingItemsByAssetId(userId);
      if (refreshToken != _nowRefreshToken) return;

      _ownerBookingsByAssetId
        ..clear()
        ..addAll(ownerItemsByAssetId);
      _rebuildNowBookings(refreshToken: refreshToken);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      _isNowLoading.value = false;
    }
  }

  void clearNow() {
    _renterBookings.clear();
    _ownerBookingsByAssetId.clear();
    _nowBookings.clear();
  }

  Future<void> refreshNow() async {
    _renterBookings.clear();
    await getNowBookings();
  }

  void _rebuildNowBookings({int? refreshToken}) {
    if (refreshToken != null && refreshToken != _nowRefreshToken) return;

    final renterItems = _renterBookings
        .where((booking) => BookingStatus.active.contains(booking.status))
        .map(
          (booking) =>
              NowBookingItem(booking: booking, role: NowBookingRole.renter),
        );

    final ownerItems = _dedupedOwnerItems();
    _nowBookings.assignAll([...renterItems, ...ownerItems]);
  }

  void _listenToOwnedAssets(String userId) {
    _ownedAssetsSubscription = LNDAssetService.watchOwnerAssets(userId).listen(
      (assets) {
        final assetIds =
            assets
                .map((asset) => asset.id)
                .where((id) => id.isNotEmpty)
                .toSet();

        _syncOwnerBookingSubscriptions(assetIds);
      },
      onError: (e, st) {
        LNDLogger.e(
          'Error listening to owner assets',
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  void _syncOwnerBookingSubscriptions(Set<String> assetIds) {
    final removedAssetIds =
        _ownerBookingSubscriptions.keys
            .where((assetId) => !assetIds.contains(assetId))
            .toList();

    for (final assetId in removedAssetIds) {
      _ownerBookingSubscriptions.remove(assetId)?.cancel();
      _ownerBookingsByAssetId.remove(assetId);
    }

    for (final assetId in assetIds) {
      if (_ownerBookingSubscriptions.containsKey(assetId)) continue;

      _ownerBookingSubscriptions[assetId] = FirebaseFirestore.instance
          .collection(LNDCollections.assets.name)
          .doc(assetId)
          .collection(LNDCollections.bookings.name)
          .where('status', whereIn: BookingStatus.activeLabels)
          .snapshots()
          .listen(
            (snapshot) {
              _ownerBookingsByAssetId[assetId] =
                  snapshot.docs
                      .map((doc) => Booking.fromMap(doc.data()))
                      .map(
                        (booking) => NowBookingItem(
                          booking: booking,
                          role: NowBookingRole.owner,
                        ),
                      )
                      .toList();
              _rebuildNowBookings();
            },
            onError: (e, st) {
              LNDLogger.e(
                'Error listening to owner bookings for asset $assetId',
                error: e,
                stackTrace: st,
              );
            },
          );
    }

    if (removedAssetIds.isNotEmpty || assetIds.isEmpty) {
      _rebuildNowBookings();
    }
  }

  Future<Map<String, List<NowBookingItem>>> _getOwnerBookingItemsByAssetId(
    String userId,
  ) async {
    final assets = await LNDAssetService.getOwnerAssets(userId);
    final bookingQueries = assets.map((asset) async {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(LNDCollections.assets.name)
              .doc(asset.id)
              .collection(LNDCollections.bookings.name)
              .where('status', whereIn: BookingStatus.activeLabels)
              .get();

      return MapEntry(
        asset.id,
        snapshot.docs
            .map((doc) => Booking.fromMap(doc.data()))
            .map(
              (booking) =>
                  NowBookingItem(booking: booking, role: NowBookingRole.owner),
            )
            .toList(),
      );
    });

    return Map.fromEntries(await Future.wait(bookingQueries));
  }

  List<NowBookingItem> _dedupedOwnerItems() {
    final seenBookingIds = <String>{};
    final items = <NowBookingItem>[];

    for (final assetItems in _ownerBookingsByAssetId.values) {
      for (final item in assetItems) {
        final bookingId = item.booking.id;
        if (bookingId != null &&
            bookingId.isNotEmpty &&
            !seenBookingIds.add(bookingId)) {
          continue;
        }

        items.add(item);
      }
    }

    return items;
  }

  static bool _isTodayBooking(Booking booking) {
    if (booking.status != BookingStatus.confirmed &&
        booking.status != BookingStatus.handedOver) {
      return false;
    }

    final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
    final endDate = LNDUtils.bookingDateFromTimestamp(booking.endDate);
    if (startDate == null || endDate == null) return false;

    return LNDUtils.isDateWithinExclusiveEndRange(
      date: DateTime.now(),
      start: startDate,
      end: endDate,
    );
  }

  static bool _isIncomingConfirmed(Booking booking) {
    if (booking.status != BookingStatus.confirmed) return false;

    final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
    if (startDate == null) return false;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    return normalizedStart.isAfter(normalizedToday);
  }

  static int _sortNowBookings(NowBookingItem a, NowBookingItem b) {
    final aStart =
        LNDUtils.bookingDateFromTimestamp(a.booking.startDate) ?? DateTime(0);
    final bStart =
        LNDUtils.bookingDateFromTimestamp(b.booking.startDate) ?? DateTime(0);
    return aStart.compareTo(bStart);
  }
}

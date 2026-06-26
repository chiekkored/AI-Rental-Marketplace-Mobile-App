import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/scroll.mixin.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class RentalHistoryController extends GetxController
    with AuthMixin, LNDScrollMixin {
  final RxList<Booking> _bookings = <Booking>[].obs;
  final RxBool _isLoading = true.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;

  DocumentSnapshot? _lastDocument;
  DateTime? _lastFetchedAt;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value;

  static const List<BookingStatus> _historyStatuses = [
    BookingStatus.declined,
    BookingStatus.cancelled,
    BookingStatus.completed,
  ];
  static const int pageSize = 20;
  static const Duration cacheDuration = Duration(minutes: 2);
  static const double _loadMoreThreshold = 240.0;

  static List<String> get historyStatusLabels =>
      _historyStatuses.map((status) => status.label).toList(growable: false);

  @override
  void onReady() {
    scrollController.addListener(_onScroll);
    getBookings();
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _bookings.close();
    _isLoading.close();
    _isLoadingMore.close();
    _hasMore.close();
    super.onClose();
  }

  Future<void> getBookings({bool forceRefresh = false}) async {
    if (shouldUseCache(
      forceRefresh: forceRefresh,
      lastFetchedAt: _lastFetchedAt,
      now: DateTime.now(),
    )) {
      _isLoading.value = false;
      return;
    }

    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) {
      _resetBookings();
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;
      _isLoadingMore.value = false;
      _hasMore.value = true;
      _lastDocument = null;
      final snapshot =
          await _query(uid: uid, lastDocument: null, limit: pageSize).get();

      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore.value = snapshot.docs.length >= pageSize;
      _lastFetchedAt = DateTime.now();

      _bookings.assignAll(_bookingsFromSnapshot(snapshot));
    } catch (e, st) {
      _resetBookings();
      LNDLogger.e('Error loading rental history', error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to load rental history.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreBookings() async {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) return;
    if (_isLoading.value || _isLoadingMore.value || !_hasMore.value) return;

    try {
      _isLoadingMore.value = true;
      final snapshot =
          await _query(
            uid: uid,
            lastDocument: _lastDocument,
            limit: pageSize,
          ).get();

      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore.value = snapshot.docs.length >= pageSize;
      _lastFetchedAt = DateTime.now();

      _bookings.addAll(_bookingsFromSnapshot(snapshot));
    } catch (e, st) {
      LNDLogger.e(
        'Error loading more rental history',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to load more rental history.');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  Future<void> refreshAfterBookingCompleted() async {
    _lastFetchedAt = null;
    await getBookings(forceRefresh: true);
  }

  Future<void> openChat(Booking booking) async {
    try {
      final chat = await MessagesController.instance.findFreshChatForBooking(
        booking,
      );
      if (chat == null) throw 'Cannot find chat for this booking';

      await LNDNavigate.toChatPage(chat: chat);
    } catch (e, st) {
      LNDLogger.e(
        'Unable to open rental history chat',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to open this booking chat.');
    }
  }

  static bool shouldUseCache({
    required bool forceRefresh,
    required DateTime? lastFetchedAt,
    required DateTime now,
  }) {
    if (forceRefresh || lastFetchedAt == null) return false;
    return now.difference(lastFetchedAt) < cacheDuration;
  }

  Query<Map<String, dynamic>> _query({
    required String uid,
    required DocumentSnapshot? lastDocument,
    required int limit,
  }) {
    var query = FirebaseFirestore.instance
        .collection(LNDCollections.users.name)
        .doc(uid)
        .collection(LNDCollections.bookings.name)
        .where('status', whereIn: historyStatusLabels)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query;
  }

  List<Booking> _bookingsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) => Booking.fromMap(doc.data())).toList();
  }

  void _resetBookings() {
    _bookings.clear();
    _lastDocument = null;
    _lastFetchedAt = null;
    _hasMore.value = false;
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    final distanceToBottom = position.maxScrollExtent - position.pixels;

    if (distanceToBottom <= _loadMoreThreshold) {
      loadMoreBookings();
    }
  }
}

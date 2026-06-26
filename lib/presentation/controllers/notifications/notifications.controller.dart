import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/mixins/scroll.mixin.dart';
import 'package:lend/core/models/notification.model.dart';
import 'package:lend/core/services/notification.service.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class NotificationsController extends GetxController
    with AuthMixin, LNDScrollMixin {
  static NotificationsController get instance =>
      Get.find<NotificationsController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<LNDNotification> _notifications = <LNDNotification>[].obs;
  List<LNDNotification> get notifications => _notifications;
  bool get hasUnreadNotifications =>
      _notifications.where((notification) => notification.isUnread).isNotEmpty;

  final RxBool _isNotificationsLoading = false.obs;
  bool get isNotificationsLoading => _isNotificationsLoading.value;

  StreamSubscription? _notificationsSubscription;

  @override
  void onClose() {
    cancelSubscriptions();
    _notifications.close();
    _isNotificationsLoading.close();
    super.onClose();
  }

  void cancelSubscriptions() {
    if (_notificationsSubscription != null) {
      _notificationsSubscription?.cancel();
      _notificationsSubscription = null;
      LNDLogger.dNoStack('🔴 Notification Subscription Cancelled');
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _isNotificationsLoading.value = false;
  }

  void listenToNotifications() {
    _isNotificationsLoading.value = true;
    final uid = currentUid;
    if (uid == null || uid.isEmpty) {
      cancelSubscriptions();
      clearNotifications();
      return;
    }

    try {
      cancelSubscriptions();

      LNDLogger.dNoStack('🟢 Notification Subscription Started');
      _notificationsSubscription = _firestore
          .collection(LNDCollections.users.name)
          .doc(uid)
          .collection(LNDCollections.notifications.name)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .listen(
            (snapshot) {
              _notifications.value =
                  snapshot.docs.map(LNDNotification.fromDoc).toList();
              _isNotificationsLoading.value = false;
            },
            onError: (e, st) {
              LNDLogger.e(
                'Error listening to notifications',
                error: e,
                stackTrace: st,
              );
              _isNotificationsLoading.value = false;
            },
          );
    } catch (e, st) {
      LNDLogger.e(
        'Error setting up notification listener',
        error: e,
        stackTrace: st,
      );
      _isNotificationsLoading.value = false;
    }
  }

  Future<void> openNotification(LNDNotification notification) async {
    await LNDNotificationService.handleNotificationData(notification.data);
  }

  Future<void> markUnreadNotificationsAsReadOnPageOpen() async {
    final uid = currentUid;
    if (uid == null || uid.isEmpty) return;

    try {
      // Delay before marking notifications as read
      await Future.delayed(const Duration(seconds: 2));

      final snapshot =
          await _firestore
              .collection(LNDCollections.users.name)
              .doc(uid)
              .collection(LNDCollections.notifications.name)
              .where('readAt', isNull: true)
              .get();

      if (snapshot.docs.isEmpty) return;

      for (var index = 0; index < snapshot.docs.length; index += 450) {
        final batch = _firestore.batch();
        final end =
            index + 450 > snapshot.docs.length
                ? snapshot.docs.length
                : index + 450;

        for (final doc in snapshot.docs.sublist(index, end)) {
          batch.update(doc.reference, {'readAt': FieldValue.serverTimestamp()});
        }

        await batch.commit();
      }
    } catch (e, st) {
      LNDLogger.e(
        'Unable to mark notifications as read',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> markAsRead(LNDNotification notification) async {
    if (!notification.isUnread) return;

    await LNDNotificationService.markNotificationAsRead(notification.id);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await LNDNotificationService.markNotificationAsRead(notificationId);
  }
}

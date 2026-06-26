import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/notification_preferences.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/notification.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class NotificationSettingsController extends GetxController with AuthMixin {
  static NotificationSettingsController get instance =>
      Get.find<NotificationSettingsController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<LNDNotificationPreferences> _preferences =
      const LNDNotificationPreferences().obs;
  LNDNotificationPreferences get preferences => _preferences.value;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isSaving = false.obs;
  bool get isSaving => _isSaving.value;

  bool get pushEnabled => preferences.pushEnabled;
  bool get messagesPushEnabled => preferences.messagesPushEnabled;
  bool get bookingsPushEnabled => preferences.bookingsPushEnabled;
  bool get paymentsPushEnabled => preferences.paymentsPushEnabled;
  bool get listingsPushEnabled => preferences.listingsPushEnabled;
  bool get verificationPushEnabled => preferences.verificationPushEnabled;
  bool get bookingEmailsEnabled => preferences.bookingEmailsEnabled;
  bool get paymentEmailsEnabled => preferences.paymentEmailsEnabled;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadPreferences());
  }

  @override
  void onClose() {
    _preferences.close();
    _isLoading.close();
    _isSaving.close();
    super.onClose();
  }

  Future<void> loadPreferences() async {
    final uid = currentUid;
    if (uid == null || uid.isEmpty) {
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;
      final snapshot =
          await _firestore
              .collection(LNDCollections.users.name)
              .doc(uid)
              .collection('private')
              .doc('notificationPreferences')
              .get();

      _preferences.value = LNDNotificationPreferences.fromMap(snapshot.data());
    } catch (e, st) {
      LNDLogger.e(
        'Unable to load notification preferences',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to load notification settings.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> setPushEnabled(bool value) async {
    final next = preferences.copyWith(pushEnabled: value);
    await _savePreferences(
      next,
      afterSave: () async {
        if (value) {
          await LNDNotificationService.requestPermission();
          await LNDNotificationService.registerCurrentToken();
        } else {
          await LNDNotificationService.unregisterCurrentToken();
        }
      },
    );
  }

  Future<void> setMessagesPushEnabled(bool value) {
    return _savePreferences(preferences.copyWith(messagesPushEnabled: value));
  }

  Future<void> setBookingsPushEnabled(bool value) {
    return _savePreferences(preferences.copyWith(bookingsPushEnabled: value));
  }

  Future<void> setPaymentsPushEnabled(bool value) {
    return _savePreferences(preferences.copyWith(paymentsPushEnabled: value));
  }

  Future<void> setListingsPushEnabled(bool value) {
    return _savePreferences(preferences.copyWith(listingsPushEnabled: value));
  }

  Future<void> setVerificationPushEnabled(bool value) {
    return _savePreferences(
      preferences.copyWith(verificationPushEnabled: value),
    );
  }

  Future<void> setBookingEmailsEnabled(bool value) {
    return _savePreferences(preferences.copyWith(bookingEmailsEnabled: value));
  }

  Future<void> setPaymentEmailsEnabled(bool value) {
    return _savePreferences(preferences.copyWith(paymentEmailsEnabled: value));
  }

  Future<void> _savePreferences(
    LNDNotificationPreferences next, {
    Future<void> Function()? afterSave,
  }) async {
    if (_isSaving.value) return;

    final previous = preferences;
    _preferences.value = next;
    _isSaving.value = true;

    try {
      final response = await LNDCloudFunctionsService.instance
          .httpsCallable(LNDFunctions.updateNotificationPreferences)
          .call({'preferences': next.toMap()});

      final data = response.data;
      if (data is Map && data['preferences'] is Map) {
        _preferences.value = LNDNotificationPreferences.fromMap(
          Map<String, dynamic>.from(data['preferences'] as Map),
        );
      }

      await afterSave?.call();
    } catch (e, st) {
      _preferences.value = previous;
      LNDLogger.e(
        'Unable to update notification preferences',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to update notification settings.');
    } finally {
      _isSaving.value = false;
    }
  }
}

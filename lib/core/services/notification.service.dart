import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/firebase_options.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/chat/chat.controller.dart';
import 'package:lend/presentation/controllers/foreground_notification/foreground_notification.controller.dart';
import 'package:lend/presentation/controllers/listing_review_result/listing_review_result.controller.dart';
import 'package:lend/presentation/controllers/verification_rejection/verification_rejection.controller.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/controllers/deleted_listing_notice/deleted_listing_notice.controller.dart';
import 'package:lend/presentation/pages/chat/chat.page.dart';
import 'package:lend/presentation/pages/eligibility/eligibility.page.dart';
import 'package:lend/presentation/pages/navigation/navigation.page.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/chat_status.enum.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class LNDNotificationService {
  LNDNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.setAutoInitEnabled(true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (_) => registerCurrentToken(),
      onError:
          (error, stackTrace) => LNDLogger.e(
            'FCM token refresh failed',
            error: error,
            stackTrace: stackTrace,
          ),
    );

    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    _openedSubscription?.cancel();
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      handleMessageNavigation,
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      unawaited(_deferNavigation(initialMessage));
    }
  }

  static Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static Future<void> registerCurrentToken() async {
    if (!Get.isRegistered<AuthController>()) return;
    if (!AuthController.instance.isAuthenticated) return;

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      LNDLogger.iNoStack('FCM: $token');

      await LNDCloudFunctionsService.instance
          .httpsCallable(LNDFunctions.registerFcmToken)
          .call({'token': token, 'platform': _platform});
    } catch (e, st) {
      LNDLogger.e('Unable to register FCM token', error: e, stackTrace: st);
    }
  }

  static Future<void> unregisterCurrentToken() async {
    if (!Get.isRegistered<AuthController>()) return;
    if (!AuthController.instance.isAuthenticated) return;

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await LNDCloudFunctionsService.instance
          .httpsCallable(LNDFunctions.unregisterFcmToken)
          .call({'token': token});
    } catch (e, st) {
      LNDLogger.e('Unable to unregister FCM token', error: e, stackTrace: st);
    }
  }

  static Future<void> handleMessageNavigation(RemoteMessage message) async {
    await openNotificationData(message.data);
  }

  static Future<void> openNotificationData(Map<String, dynamic> data) async {
    await markNotificationAsRead(data['notificationId']?.toString());
    await handleNotificationData(data);
  }

  static Future<void> handleNotificationData(Map<String, dynamic> data) async {
    final type = data['type']?.toString();
    final chatId = data['chatId']?.toString();

    if (!Get.isRegistered<AuthController>() ||
        !AuthController.instance.isAuthenticated) {
      Get.offAllNamed(NavigationPage.routeName);
      return;
    }

    if (type == 'verification') {
      if (data['target']?.toString() == 'verificationRejection') {
        final submissionId = data['submissionId']?.toString();
        if (submissionId != null && submissionId.isNotEmpty) {
          await LNDNavigate.toVerificationRejectionPage(
            args: VerificationRejectionPageArgs(submissionId: submissionId),
          );
          return;
        }
      }

      Get.toNamed(EligibilityPage.routeName);
      return;
    }

    if (type == 'business_registration') {
      final target = data['target']?.toString();
      final status = data['status']?.toString();
      if (target == 'businessRegistrationRejection' ||
          (target == 'businessRegistration' && status == 'Rejected')) {
        await LNDNavigate.toBusinessRegistrationRejectionPage();
        return;
      }

      if (target == 'businessRegistration') {
        await LNDNavigate.toBusinessRegistrationPage();
        return;
      }

      return;
    }

    if (type == 'booking' && data['target']?.toString() == 'bookingDetails') {
      final didOpen = await _openBookingDetails(data);
      if (didOpen) return;
    }

    if (type == 'listing_review' &&
        data['target']?.toString() == 'listingReviewResult') {
      final submissionId = data['submissionId']?.toString();
      if (submissionId != null && submissionId.isNotEmpty) {
        await LNDNavigate.toListingReviewResultPage(
          args: ListingReviewResultPageArgs(submissionId: submissionId),
        );
        return;
      }
    }

    if (type == 'listing_review' && data['target']?.toString() == 'asset') {
      final didOpen = await _openAsset(data);
      if (didOpen) return;
    }

    if (type == 'listing_moderation' && data['target']?.toString() == 'asset') {
      final didOpen = await _openAsset(data);
      if (didOpen) return;
    }

    if (type == 'listing_moderation' &&
        data['target']?.toString() == 'deletedListing') {
      final eventId = data['eventId']?.toString();
      if (eventId != null && eventId.isNotEmpty) {
        await LNDNavigate.toDeletedListingNoticePage(
          args: DeletedListingNoticePageArgs(eventId: eventId),
        );
        return;
      }
    }

    if (chatId == null || chatId.isEmpty) {
      Get.offAllNamed(NavigationPage.routeName);
      return;
    }

    try {
      final uid = AuthController.instance.uid;
      final snapshot =
          await FirebaseFirestore.instance
              .collection(LNDCollections.userChats.name)
              .doc(uid)
              .collection(LNDCollections.chats.name)
              .doc(chatId)
              .get();

      final data = snapshot.data();
      if (data == null) {
        Get.offAllNamed(NavigationPage.routeName);
        return;
      }

      final chat = Chat.fromMap(data);
      if (chat.status == ChatStatus.deleted) {
        Get.offAllNamed(NavigationPage.routeName);
        LNDSnackbar.showWarning('This chat has been deleted.');
        return;
      }

      LNDNavigate.toChatPage(chat: chat);
    } catch (e, st) {
      LNDLogger.e(
        'Unable to open notification target',
        error: e,
        stackTrace: st,
      );
      Get.offAllNamed(NavigationPage.routeName);
    }
  }

  static Future<bool> _openAsset(Map<String, dynamic> data) async {
    final assetId = data['assetId']?.toString();
    if (assetId == null || assetId.isEmpty) return false;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(LNDCollections.assets.name)
              .doc(assetId)
              .get();
      final assetData = snapshot.data();
      if (assetData == null) {
        LNDSnackbar.showWarning('This listing is no longer available.');
        return false;
      }

      final asset = Asset.fromMap(assetData);
      await LNDNavigate.toAssetPage(args: asset);
      return true;
    } catch (e, st) {
      LNDLogger.e(
        'Unable to open listing notification target',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  static Future<bool> _openBookingDetails(Map<String, dynamic> data) async {
    final bookingId = data['bookingId']?.toString();
    if (bookingId == null || bookingId.isEmpty) return false;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(LNDCollections.bookings.name)
              .doc(bookingId)
              .get();
      final bookingData = snapshot.data();
      if (bookingData == null) return false;

      final booking = Booking.fromMap(bookingData);
      await LNDNavigate.toBookingDetailsPage(
        args: BookingDetailsPageArgs(booking: booking),
      );
      return true;
    } catch (e, st) {
      LNDLogger.e(
        'Unable to open booking details notification target',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  static Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundSubscription = null;
    _openedSubscription = null;
  }

  static Future<void> _deferNavigation(RemoteMessage message) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await handleMessageNavigation(message);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    if (_shouldSuppressForegroundMessage(message.data)) return;

    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    ForegroundNotificationController.instance.show(
      title: title ?? 'Notification',
      body: body ?? '',
      notificationType: message.data['type']?.toString() ?? 'general',
      imageUrl: message.data['imageUrl']?.toString(),
      onTap: () => unawaited(openNotificationData(message.data)),
    );
  }

  static bool _shouldSuppressForegroundMessage(Map<String, dynamic> data) {
    if (data['type']?.toString() != 'chat') return false;

    final uid =
        Get.isRegistered<AuthController>() ? AuthController.instance.uid : null;
    final senderId = data['senderId']?.toString();
    if (uid != null && uid.isNotEmpty && senderId == uid) return true;

    final chatId = data['chatId']?.toString();
    if (chatId == null || chatId.isEmpty) return false;
    if (Get.currentRoute != ChatPage.routeName) return false;
    if (!Get.isRegistered<ChatController>()) return false;

    final activeChat = ChatController.instance.chat;
    return activeChat.chatId == chatId || activeChat.id == chatId;
  }

  static Future<void> markNotificationAsRead(String? notificationId) async {
    if (notificationId == null || notificationId.isEmpty) return;
    if (!Get.isRegistered<AuthController>()) return;
    if (!AuthController.instance.isAuthenticated) return;

    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection(LNDCollections.users.name)
          .doc(uid)
          .collection(LNDCollections.notifications.name)
          .doc(notificationId)
          .update({'readAt': FieldValue.serverTimestamp()});
    } catch (e, st) {
      LNDLogger.e(
        'Unable to mark notification as read',
        error: e,
        stackTrace: st,
      );
    }
  }

  static String get _platform {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}

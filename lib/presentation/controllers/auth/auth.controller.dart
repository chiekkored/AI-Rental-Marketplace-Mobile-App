import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/notification.service.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/core/services/secure_storage.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/presentation/controllers/notifications/notifications.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/controllers/payment_return/payment_return.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/saved/saved.controller.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/email_verification_request_outcome.enum.dart';

class AuthController extends GetxController {
  static final instance = Get.find<AuthController>();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // final LocalAuthentication auth = LocalAuthentication();

  // Observable User
  final Rxn<User> firebaseUser = Rxn<User>();
  final RxString _token = ''.obs;

  String get token => _token.value;
  User? get currentUser => firebaseAuth.currentUser ?? firebaseUser.value;
  String? get uid => currentUser?.uid;
  bool get isAuthenticated => currentUser != null;

  @override
  void onInit() {
    // Listen to auth state changes
    firebaseUser.bindStream(firebaseAuth.authStateChanges());
    ever(firebaseUser, _handleAuthChanged);

    super.onInit();
  }

  @override
  void onClose() {
    firebaseUser.close();
    _token.close();

    super.onClose();
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      UserBlockController.instance.listenForUser(user.uid);
      HomeController.instance.getAssets();
      ProfileController.instance.listenToUserData();
      NowController.instance.getNowBookings();
      NowController.instance.listenToNow();
      YourListingController.instance.listenToMyAssets(userId: user.uid);
      MessagesController.instance.listenToChats();
      NotificationsController.instance.listenToNotifications();
      SavedController.instance.getSaved();
      OwnerPayoutDestinationController.instance.loadDestination();
      unawaited(
        PaymentReturnController.instance.startSilentPendingPaymentRecovery(),
      );
      unawaited(LNDNotificationService.registerCurrentToken());
    } else {
      final onboardingComplete =
          LNDStorageService.read<bool>(
            LNDStorageConstants.onboardingComplete,
          ) ==
          true;
      if (!onboardingComplete) return;

      HomeController.instance.clearFeed();
      ProfileController.instance.cancelSubscriptions();
      ProfileController.instance.removeUserData();
      YourListingController.instance.cancelMyAssetsSubscription();
      MessagesController.instance.cancelSubscriptions();
      MessagesController.instance.clearChats();
      NotificationsController.instance.cancelSubscriptions();
      NotificationsController.instance.clearNotifications();
      NowController.instance.cancelSubscriptions();
      NowController.instance.clearNow();
      SavedController.instance.clearSaved();
      UserBlockController.instance.clear();
      unawaited(LNDPaymentService.clearPayoutDestinationsCache());

      _token.value = '';
      unawaited(LNDStorageService.clearSessionData());
      LNDLoading.hide();
      Get.until((page) => page.isFirst);
    }
  }

  // Sign Out
  Future<void> signOut({bool clearBiometricCredentials = false}) async {
    if (clearBiometricCredentials) {
      await LNDSecureStorageService.clearBiometricCredentials();
      await LNDStorageService.write(
        LNDStorageConstants.enableBiometrics,
        false,
      );
    }

    if (firebaseAuth.currentUser == null) return;

    LNDLoading.show();

    await LNDNotificationService.unregisterCurrentToken();
    await firebaseAuth.signOut();
    await LNDPaymentService.clearPayoutDestinationsCache();
    await LNDStorageService.clearSessionData();
    _token.value = '';

    LNDLoading.hide();
    Get.until((page) => page.isFirst);
  }

  Future<EmailVerificationRequestOutcome> requestEmailVerification() async {
    final user = currentUser;
    if (user == null || user.emailVerified) {
      return EmailVerificationRequestOutcome.alreadyVerified;
    }

    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.requestEmailVerification,
    );
    final result = await callable.call();
    final outcome = EmailVerificationRequestOutcome.fromResponse(result.data);
    if (outcome == EmailVerificationRequestOutcome.autoVerified ||
        outcome == EmailVerificationRequestOutcome.alreadyVerified) {
      await firebaseAuth.currentUser?.reload();
      if (Get.isRegistered<ProfileController>()) {
        await ProfileController.instance.syncEmailVerification();
      }
    }
    return outcome;
  }

  Future<EmailVerificationRequestOutcome> resendEmailVerification() {
    return requestEmailVerification();
  }

  Future<void> registerToFirestore({required UserModel user}) async {
    final userCollection = FirebaseFirestore.instance.collection(
      LNDCollections.users.name,
    );

    await userCollection.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

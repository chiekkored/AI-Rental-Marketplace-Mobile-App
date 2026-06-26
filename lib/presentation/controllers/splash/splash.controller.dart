import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/main.service.dart';
import 'package:lend/core/services/notification.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/amenity/amenity.controller.dart';
import 'package:lend/presentation/controllers/category/category.controller.dart';
import 'package:lend/presentation/pages/navigation/navigation.page.dart';
import 'package:lend/presentation/pages/onboarding/onboarding.page.dart';
import 'package:lend/presentation/pages/reactivate_account/reactivate_account.page.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/user_status.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class SplashController extends GetxController {
  final RxBool _isLoading = true.obs;

  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    unawaited(initializeStartup(force: true));
  }

  @override
  void onClose() {
    _isLoading.close();
    super.onClose();
  }

  Future<void> initializeStartup({bool force = false}) async {
    if (_isLoading.value && !force) return;

    _isLoading.value = true;

    const env = String.fromEnvironment('ENV', defaultValue: 'prod');
    try {
      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 900)),
        MainService.initializeRemoteConfig(env: env),
        _warmCategories(),
        _warmAmenities(),
      ]);
      unawaited(_initializeNotifications());
      await _routeAfterSplash();
    } catch (e, st) {
      LNDLogger.e(
        'Startup Remote Config gate failed',
        error: e,
        stackTrace: st,
      );
      _isLoading.value = false;
      LNDSnackbar.showError('Please check your connection and try again.');
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await LNDNotificationService.initialize();
    } catch (e, st) {
      LNDLogger.e(
        'Notification initialization failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _warmCategories() async {
    try {
      await CategoryController.instance.bootstrap().timeout(
        const Duration(seconds: 4),
      );
    } catch (e, st) {
      LNDLogger.e('Category startup warm failed', error: e, stackTrace: st);
    }
  }

  Future<void> _warmAmenities() async {
    try {
      await AmenityController.instance.bootstrap().timeout(
        const Duration(seconds: 4),
      );
    } catch (e, st) {
      LNDLogger.e('Amenity startup warm failed', error: e, stackTrace: st);
    }
  }

  Future<void> _routeAfterSplash() async {
    final onboardingComplete =
        LNDStorageService.read<bool>(LNDStorageConstants.onboardingComplete) ==
        true;

    if (!onboardingComplete) {
      await Get.offAllNamed(OnboardingPage.routeName);
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final accountState = await _getAccountState(firebaseUser.uid);
      if (accountState == UserStatus.deleted) {
        await AuthController.instance.signOut(clearBiometricCredentials: true);
        LNDSnackbar.showError('This account has been closed.');
        return;
      }
      if (accountState == UserStatus.deactivated) {
        await Get.offAllNamed(ReactivateAccountPage.routeName);
        return;
      }
    }

    await Get.offAllNamed(NavigationPage.routeName);
  }

  Future<UserStatus?> _getAccountState(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromMap(snap.data() ?? {}).status;
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/notification.service.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/pages/navigation/navigation.page.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt _currentPage = 0.obs;
  final RxBool _isRequestingLocation = false.obs;
  final RxBool _isRequestingNotifications = false.obs;

  int get currentPage => _currentPage.value;
  bool get isRequestingLocation => _isRequestingLocation.value;
  bool get isRequestingNotifications => _isRequestingNotifications.value;

  bool get isLastPage => currentPage == 3;

  @override
  void onClose() {
    pageController.dispose();
    _currentPage.close();
    _isRequestingLocation.close();
    _isRequestingNotifications.close();
    super.onClose();
  }

  void onPageChanged(int index) {
    _currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      finishOnboarding();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void previousPage() {
    if (currentPage == 0) return;
    pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> requestLocation() async {
    if (_isRequestingLocation.value) return;

    _isRequestingLocation.value = true;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (Get.isRegistered<HomeController>()) {
        HomeController.instance.ensureBrowseLocation();
      }
    } finally {
      _isRequestingLocation.value = false;
    }

    nextPage();
  }

  Future<void> requestNotifications() async {
    if (_isRequestingNotifications.value) return;

    _isRequestingNotifications.value = true;
    try {
      await LNDNotificationService.requestPermission();
      await LNDNotificationService.registerCurrentToken();
    } finally {
      _isRequestingNotifications.value = false;
    }

    nextPage();
  }

  Future<void> finishOnboarding() async {
    await LNDStorageService.write(LNDStorageConstants.onboardingComplete, true);

    if (Get.isRegistered<HomeController>()) {
      HomeController.instance.startInitialLoad();
    }

    Get.offAllNamed(NavigationPage.routeName);
  }
}

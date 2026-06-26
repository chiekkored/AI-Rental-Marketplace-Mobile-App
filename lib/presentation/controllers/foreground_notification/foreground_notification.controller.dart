import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ForegroundNotificationController extends GetxController {
  static ForegroundNotificationController get instance =>
      Get.find<ForegroundNotificationController>();

  final RxBool isVisible = false.obs;
  final RxString title = ''.obs;
  final RxString body = ''.obs;
  final RxString notificationType = 'general'.obs;
  final RxnString imageUrl = RxnString();

  VoidCallback? _onTap;
  Timer? _hideTimer;

  void show({
    required String title,
    required String body,
    String notificationType = 'general',
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    this.title.value = title;
    this.body.value = body;
    this.notificationType.value = notificationType;
    this.imageUrl.value =
        imageUrl == null || imageUrl.trim().isEmpty ? null : imageUrl.trim();
    _onTap = onTap;
    isVisible.value = true;

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), hide);
  }

  void tap() {
    final callback = _onTap;
    hide();
    callback?.call();
  }

  void hide() {
    _hideTimer?.cancel();
    _hideTimer = null;
    isVisible.value = false;
    _onTap = null;
  }

  @override
  void onClose() {
    _hideTimer?.cancel();
    isVisible.close();
    title.close();
    body.close();
    notificationType.close();
    imageUrl.close();
    super.onClose();
  }
}

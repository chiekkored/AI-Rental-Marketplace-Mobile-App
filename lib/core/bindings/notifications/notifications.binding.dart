import 'package:get/get.dart';
import 'package:lend/presentation/controllers/notifications/notifications.controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut<NotificationsController>(() => NotificationsController());
    }
  }
}

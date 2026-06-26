import 'package:get/get.dart';
import 'package:lend/presentation/controllers/notification_settings/notification_settings.controller.dart';

class NotificationSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NotificationSettingsController());
  }
}

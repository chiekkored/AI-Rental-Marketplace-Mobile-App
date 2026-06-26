import 'package:get/get.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';

class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MessagesController>()) {
      Get.lazyPut<MessagesController>(() => MessagesController());
    }
  }
}

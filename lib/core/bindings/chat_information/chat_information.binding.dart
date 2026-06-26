import 'package:get/get.dart';
import 'package:lend/presentation/controllers/chat_information/chat_information.controller.dart';

class ChatInformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatInformationController());
  }
}

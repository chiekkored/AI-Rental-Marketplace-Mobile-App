import 'package:get/get.dart';
import 'package:lend/presentation/controllers/blocked_users/blocked_users.controller.dart';

class BlockedUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BlockedUsersController());
  }
}

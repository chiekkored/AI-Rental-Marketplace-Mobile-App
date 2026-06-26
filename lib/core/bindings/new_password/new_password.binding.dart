import 'package:get/get.dart';
import 'package:lend/presentation/controllers/new_password/new_password.controller.dart';

class NewPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NewPasswordController());
  }
}

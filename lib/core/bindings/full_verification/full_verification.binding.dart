import 'package:get/get.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';

class FullVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FullVerificationController());
  }
}

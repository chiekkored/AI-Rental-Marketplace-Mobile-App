import 'package:get/get.dart';
import 'package:lend/presentation/controllers/verification_rejection/verification_rejection.controller.dart';

class VerificationRejectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(VerificationRejectionController());
  }
}

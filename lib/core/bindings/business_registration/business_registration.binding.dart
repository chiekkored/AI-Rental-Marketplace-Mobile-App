import 'package:get/get.dart';
import 'package:lend/presentation/controllers/business_registration/business_registration.controller.dart';

class BusinessRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BusinessRegistrationController());
  }
}

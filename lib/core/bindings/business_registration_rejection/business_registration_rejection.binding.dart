import 'package:get/get.dart';
import 'package:lend/presentation/controllers/business_registration_rejection/business_registration_rejection.controller.dart';

class BusinessRegistrationRejectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BusinessRegistrationRejectionController());
  }
}

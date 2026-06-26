import 'package:get/get.dart';
import 'package:lend/presentation/controllers/damage_fee_request/damage_fee_request.controller.dart';

class DamageFeeRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DamageFeeRequestController());
  }
}

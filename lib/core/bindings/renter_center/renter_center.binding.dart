import 'package:get/get.dart';
import 'package:lend/presentation/controllers/renter_center/renter_center.controller.dart';

class RenterCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RenterCenterController());
  }
}

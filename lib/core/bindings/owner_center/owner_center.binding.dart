import 'package:get/get.dart';
import 'package:lend/presentation/controllers/owner_center/owner_center.controller.dart';

class OwnerCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OwnerCenterController());
  }
}

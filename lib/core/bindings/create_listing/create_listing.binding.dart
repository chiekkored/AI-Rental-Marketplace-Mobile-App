import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';

class CreateListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CreateListingController());
  }
}

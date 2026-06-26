import 'package:get/get.dart';
import 'package:lend/presentation/controllers/publish_listing_disclaimer/publish_listing_disclaimer.controller.dart';

class PublishListingDisclaimerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PublishListingDisclaimerController());
  }
}

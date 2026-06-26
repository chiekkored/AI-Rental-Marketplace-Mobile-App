import 'package:get/get.dart';
import 'package:lend/presentation/controllers/category_listing/category_listing.controller.dart';

class CategoryListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CategoryListingController());
  }
}

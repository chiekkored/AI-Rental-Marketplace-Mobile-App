import 'package:get/get.dart';
import 'package:lend/presentation/controllers/recently_viewed/recently_viewed.controller.dart';

class RecentlyViewedBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RecentlyViewedController());
  }
}

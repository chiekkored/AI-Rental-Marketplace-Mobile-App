import 'package:get/get.dart';
import 'package:lend/presentation/controllers/about/about.controller.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AboutController());
  }
}

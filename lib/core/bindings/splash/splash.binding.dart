import 'package:get/get.dart';
import 'package:lend/presentation/controllers/splash/splash.controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}

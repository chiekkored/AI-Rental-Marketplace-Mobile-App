import 'package:get/get.dart';
import 'package:lend/presentation/controllers/onboarding/onboarding.controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OnboardingController());
  }
}

import 'package:get/get.dart';
import 'package:lend/presentation/controllers/navigation/navigation.controller.dart';
import 'package:lend/utilities/enums/bottom_nav_page.enum.dart';

class BookingInstructionsPageArgs {
  final String instructions;
  final String? ownerPhotoUrl;

  const BookingInstructionsPageArgs({
    required this.instructions,
    this.ownerPhotoUrl,
  });
}

class BookingInstructionsController extends GetxController {
  final BookingInstructionsPageArgs args =
      Get.arguments as BookingInstructionsPageArgs;

  String get instructions => args.instructions.trim();
  String? get ownerPhotoUrl => args.ownerPhotoUrl;

  void confirm() {
    if (Get.isRegistered<NavigationController>()) {
      NavigationController.instance.changeTab(LNDBottomNavPage.messages.indexx);
    }
    Get.until((page) => page.isFirst);
  }
}

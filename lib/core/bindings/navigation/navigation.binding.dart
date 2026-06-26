import 'package:get/get.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/presentation/controllers/navigation/navigation.controller.dart';
import 'package:lend/presentation/controllers/notifications/notifications.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/presentation/controllers/payment_return/payment_return.controller.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavigationController());

    Get.put(AuthController(), permanent: true);

    Get.put(ProfileController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(NowController(), permanent: true);
    Get.put(YourListingController(), permanent: true);
    Get.put(MessagesController(), permanent: true);
    Get.put(NotificationsController(), permanent: true);
    Get.put(UserBlockController(), permanent: true);
    Get.put(PaymentReturnController(), permanent: true);
  }
}

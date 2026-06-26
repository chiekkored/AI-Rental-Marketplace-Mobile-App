import 'package:get/get.dart';
import 'package:lend/presentation/controllers/amenity/amenity.controller.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/presentation/controllers/category/category.controller.dart';
import 'package:lend/presentation/controllers/foreground_notification/foreground_notification.controller.dart';
import 'package:lend/presentation/controllers/loading/loading.controller.dart';
import 'package:lend/presentation/controllers/maintenance/maintenance.controller.dart';
import 'package:lend/presentation/controllers/owner_invite_link/owner_invite_link.controller.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/controllers/saved/saved.controller.dart';
import 'package:lend/presentation/controllers/settings/settings.controller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoadingController(), permanent: true);
    Get.put(ForegroundNotificationController(), permanent: true);
    Get.put(MaintenanceController(), permanent: true);
    Get.put(OwnerInviteLinkController(), permanent: true);

    Get.put(SettingsController(), permanent: true);
    Get.put(CountryPreferenceController(), permanent: true);
    Get.put(CategoryController(), permanent: true);
    Get.put(AmenityController(), permanent: true);
    Get.put(SavedController(), permanent: true);

    Get.put(OwnerPayoutDestinationController());
  }
}

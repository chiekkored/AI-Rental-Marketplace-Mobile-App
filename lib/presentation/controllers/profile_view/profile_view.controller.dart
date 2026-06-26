import 'package:get/get.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class ProfileViewController extends GetxController {
  static ProfileViewController get instance =>
      Get.find<ProfileViewController>();

  ProfileController get _profileController => ProfileController.instance;

  UserModel? get user => _profileController.user;
  bool get isLoading => _profileController.isLoading;

  String get fullName => LNDUtils.formatFullName(
    firstName: user?.firstName,
    lastName: user?.lastName,
    addLastName: true,
  );
  bool get hasBusinessProfile => user?.approvedBusinessName != null;
  String? get businessName => user?.approvedBusinessName;
  String? get businessType => user?.businessRegistration?.businessType;
  String? get businessAddress => user?.businessRegistration?.businessAddress;
}

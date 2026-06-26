import 'package:get/get.dart';
import 'package:lend/presentation/controllers/account_information/account_information.controller.dart';

class AccountInformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AccountInformationController());
  }
}

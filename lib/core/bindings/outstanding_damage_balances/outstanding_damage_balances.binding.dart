import 'package:get/get.dart';
import 'package:lend/presentation/controllers/outstanding_damage_balances/outstanding_damage_balances.controller.dart';

class OutstandingDamageBalancesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OutstandingDamageBalancesController());
  }
}

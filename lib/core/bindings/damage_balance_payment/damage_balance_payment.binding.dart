import 'package:get/get.dart';
import 'package:lend/presentation/controllers/damage_balance_payment/damage_balance_payment.controller.dart';

class DamageBalancePaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DamageBalancePaymentController());
  }
}

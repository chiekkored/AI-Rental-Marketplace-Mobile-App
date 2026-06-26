import 'package:get/get.dart';
import 'package:lend/presentation/controllers/payment_holding/payment_holding.controller.dart';

class PaymentHoldingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PaymentHoldingController());
  }
}

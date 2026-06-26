import 'package:get/get.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';

class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PaymentMethodsController());
  }
}

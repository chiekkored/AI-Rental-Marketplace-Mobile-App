import 'package:get/get.dart';
import 'package:lend/presentation/controllers/booking_payment/booking_payment.controller.dart';

class BookingPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BookingPaymentController());
  }
}

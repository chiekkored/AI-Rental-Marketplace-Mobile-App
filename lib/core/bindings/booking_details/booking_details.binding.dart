import 'package:get/get.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';

class BookingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BookingDetailsController());
  }
}

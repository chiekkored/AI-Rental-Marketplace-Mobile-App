import 'package:get/get.dart';
import 'package:lend/presentation/controllers/booking_instructions/booking_instructions.controller.dart';

class BookingInstructionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BookingInstructionsController());
  }
}

import 'package:get/get.dart';
import 'package:lend/presentation/controllers/rental_history/rental_history.controller.dart';

class RentalHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RentalHistoryController());
  }
}

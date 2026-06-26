import 'package:get/get.dart';
import 'package:lend/presentation/controllers/country_picker/country_picker.controller.dart';

class CountryPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CountryPickerController());
  }
}

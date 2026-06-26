import 'package:get/get.dart';
import 'package:lend/presentation/controllers/payout_institution_picker/payout_institution_picker.controller.dart';

class PayoutInstitutionPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PayoutInstitutionPickerController());
  }
}

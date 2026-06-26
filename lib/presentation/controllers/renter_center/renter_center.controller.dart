import 'package:get/get.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class RenterCenterController extends GetxController {
  Future<void> openRentalHistory() async {
    await LNDNavigate.toRentalHistoryPage();
  }

  Future<void> openDepositReturnDestination() async {
    await LNDNavigate.toDepositReturnDestinationPage();
  }
}

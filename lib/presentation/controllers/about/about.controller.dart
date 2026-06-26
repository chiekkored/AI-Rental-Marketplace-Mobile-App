import 'package:get/get.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';

class AboutController extends GetxController {
  Future<void> openPrivacyPolicy() {
    return LNDLegalLinks.openPrivacyPolicy();
  }

  Future<void> openTermsAndConditions() {
    return LNDLegalLinks.openTermsAndConditions();
  }
}

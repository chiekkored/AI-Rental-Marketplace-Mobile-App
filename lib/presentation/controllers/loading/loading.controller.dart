import 'package:get/get.dart';

class LoadingController extends GetxController {
  static LoadingController get instance => Get.find<LoadingController>();

  var isLoading = false.obs;
  final RxnString text = RxnString();

  void show({String? text}) {
    this.text.value = text;
    isLoading.value = true;
  }

  void hide() {
    isLoading.value = false;
    text.value = null;
  }

  @override
  void onClose() {
    isLoading.close();
    text.close();

    super.onClose();
  }
}

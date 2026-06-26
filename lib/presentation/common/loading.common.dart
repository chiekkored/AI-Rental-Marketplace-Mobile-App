import 'package:lend/presentation/controllers/loading/loading.controller.dart';

class LNDLoading {
  static void show({String? text, bool allowDismiss = false}) {
    LoadingController.instance.show(text: text);
  }

  static void hide() {
    LoadingController.instance.hide();
  }
}

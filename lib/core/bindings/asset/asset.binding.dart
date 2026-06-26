import 'package:get/get.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';

class AssetBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as AssetPageArgs;
    Get.put(AssetController(args), tag: args.controllerTag);
  }
}

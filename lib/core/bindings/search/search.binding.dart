import 'package:get/get.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AssetSearchController());
  }
}

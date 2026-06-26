import 'package:get/get.dart';
import 'package:lend/presentation/controllers/all_reviews/all_reviews.controller.dart';

class AllReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllReviewsController());
  }
}

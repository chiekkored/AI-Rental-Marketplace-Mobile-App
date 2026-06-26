import 'package:get/get.dart';
import 'package:lend/presentation/controllers/rating_review/rating_review.controller.dart';

class RatingReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RatingReviewController>(() => RatingReviewController());
  }
}

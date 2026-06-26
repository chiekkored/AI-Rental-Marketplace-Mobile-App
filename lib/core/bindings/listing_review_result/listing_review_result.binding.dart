import 'package:get/get.dart';
import 'package:lend/presentation/controllers/listing_review_result/listing_review_result.controller.dart';

class ListingReviewResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ListingReviewResultController());
  }
}

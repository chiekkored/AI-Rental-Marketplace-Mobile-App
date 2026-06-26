import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/rating.model.dart';
import 'package:lend/presentation/pages/all_reviews/all_reviews.page.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class AllReviewsController extends GetxController {
  final RxList<Rating> ratings = <Rating>[].obs;
  final RxBool isLoading = false.obs;
  late final String assetId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as AllReviewsPageArgs;
    assetId = args.assetId;
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    try {
      isLoading.value = true;
      final ratingsCollection = FirebaseFirestore.instance
          .collection(LNDCollections.assets.name)
          .doc(assetId)
          .collection(LNDCollections.ratings.name)
          .orderBy('timestamp', descending: true);

      final result = await ratingsCollection.get();
      ratings.value =
          result.docs.map((doc) => Rating.fromMap(doc.data())).toList();
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }
}

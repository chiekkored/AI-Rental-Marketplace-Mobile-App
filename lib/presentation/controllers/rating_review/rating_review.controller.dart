import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/pages/rating_review/rating_review.page.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class RatingReviewController extends GetxController {
  final RatingReviewArguments args = Get.arguments as RatingReviewArguments;

  final rating = 0.obs;
  final reviewController = TextEditingController();

  void setRating(int newRating) {
    rating.value = newRating;
  }

  Future<void> submitRatingAndReview() async {
    if (rating.value == 0) {
      LNDSnackbar.showError('Please select a rating');
      return;
    }

    LNDLoading.show();

    final result = await LNDBookingService.rateAndReviewBooking(
      chatId: args.chatId,
      assetId: args.assetId,
      bookingId: args.bookingId,
      rating: rating.value,
      review: reviewController.text,
    );

    LNDLoading.hide();

    result.fold(
      ifLeft: (success) async {
        LNDNavigate.toHomePage();
        LNDSnackbar.showSuccess(
          'Thank you for your review! Your chat has been archived.',
          buttonText: 'Go to Archive',
          buttonOnPressed: () {
            LNDNavigate.toArchivedMessagesPage();
          },
          showButton: true,
        );
      },
      ifRight: (error) => Get.snackbar('Error', error),
    );
  }
}

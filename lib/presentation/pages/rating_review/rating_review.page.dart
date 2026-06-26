import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/rating_review/rating_review.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class RatingReviewArguments {
  final String chatId;
  final String assetId;
  final String bookingId;
  RatingReviewArguments({
    required this.chatId,
    required this.assetId,
    required this.bookingId,
  });
}

class RatingReviewPage extends GetView<RatingReviewController> {
  static const String routeName = '/rating-review';
  const RatingReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: colors.surface,
          backgroundColor: colors.surface,
          leading: LNDButton.back(),
          title: LNDText.bold(text: 'Rate and Review', fontSize: 18.0),
        ),
        backgroundColor: colors.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LNDText.medium(text: 'Rating', fontSize: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Obx(
                        () => LNDButton.icon(
                          icon:
                              index < controller.rating.value
                                  ? Icons.star
                                  : Icons.star_border,
                          onPressed: () => controller.setRating(index + 1),
                          color: colors.primary,
                          size: 48.0,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                LNDText.medium(text: 'Review', fontSize: 18),
                const SizedBox(height: 8),
                LNDTextField.textBox(
                  controller: controller.reviewController,
                  maxLines: 5,
                  hintText: 'Write your review here...',
                ),
                const SizedBox(height: 30),
                LNDButton.primary(
                  text: 'Submit',
                  enabled: true,
                  onPressed: controller.submitRatingAndReview,
                  hasPadding: false,
                ),
              ],
            ).withSpacing(8.0),
          ),
        ),
      ),
    );
  }
}

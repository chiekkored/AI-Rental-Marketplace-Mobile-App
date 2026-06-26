import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/all_reviews/all_reviews.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllReviewsPageArgs {
  final String assetId;

  AllReviewsPageArgs({required this.assetId});
}

class AllReviewsPage extends GetView<AllReviewsController> {
  static const routeName = '/all-reviews';
  const AllReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(
          onPressed: canPop ? () => Navigator.of(context).pop() : null,
        ),
        title: LNDText.bold(text: 'Reviews', fontSize: 18.0),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: LNDSpinner(color: colors.textPrimary));
        }
        if (controller.ratings.isEmpty) {
          return Center(child: LNDText.regular(text: 'No reviews yet.'));
        }
        return ListView.builder(
          itemCount: controller.ratings.length,
          itemBuilder: (context, index) {
            final rating = controller.ratings[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < rating.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: colors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        LNDText.regular(
                          text: timeago.format(rating.timestamp.toDate()),
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LNDText.regular(text: rating.review),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

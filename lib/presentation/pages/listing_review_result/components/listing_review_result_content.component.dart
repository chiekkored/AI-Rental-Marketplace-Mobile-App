import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/listing_review_result/listing_review_result.controller.dart';
import 'package:lend/presentation/pages/listing_review_result/widgets/listing_review_card.widget.dart';
import 'package:lend/presentation/pages/listing_review_result/widgets/listing_review_reasons.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ListingReviewResultContent
    extends GetView<ListingReviewResultController> {
  const ListingReviewResultContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = context.lndTheme;
      final submission = controller.submission!;

      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListingReviewCard(
            submission: submission,
            imageUrl: controller.imageUrl,
          ),
          const SizedBox(height: 16.0),
          ListingReviewReasons(review: submission.aiReview),
          if (!submission.isRejected) ...[
            const SizedBox(height: 16.0),
            LNDText.regular(
              text: 'This listing review is currently ${submission.status}.',
              color: colors.textMuted,
            ),
          ],
          const SizedBox(height: 24.0),
          LNDButton.primary(
            text: 'Edit Listing',
            enabled: submission.isRejected,
            onPressed: submission.isRejected ? controller.editListing : null,
          ),
          const SizedBox(height: 24.0),
          LNDButton.text(
            text: 'Delete',
            enabled: submission.isRejected && !controller.isDeleting,
            color: colors.danger,
            onPressed:
                submission.isRejected && !controller.isDeleting
                    ? controller.deleteSubmission
                    : null,
          ),
        ],
      );
    });
  }
}

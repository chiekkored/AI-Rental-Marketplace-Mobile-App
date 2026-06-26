import 'package:flutter/material.dart';
import 'package:lend/core/models/listing_review_submission.model.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ListingReviewReasons extends StatelessWidget {
  final ListingAiReview? review;

  const ListingReviewReasons({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final reasons =
        review?.reasons.where((reason) => reason.trim().isNotEmpty).toList() ??
        const <String>[];

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(
              text: 'Reject Reason',
              color: colors.textPrimary,
              fontSize: 16.0,
            ),
            const SizedBox(height: 8.0),
            if (reasons.isEmpty)
              LNDText.regular(
                text: 'This listing did not meet marketplace policy.',
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              )
            else
              ...reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colors.danger,
                        size: 18.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: LNDText.regular(
                          text: reason,
                          color: colors.textPrimary,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

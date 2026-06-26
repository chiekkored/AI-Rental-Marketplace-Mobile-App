import 'package:flutter/material.dart';
import 'package:lend/core/models/listing_review_submission.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class ListingReviewCard extends StatelessWidget {
  final ListingReviewSubmission submission;
  final String? imageUrl;

  const ListingReviewCard({
    super.key,
    required this.submission,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final listing = submission.listing;
    final dailyRate = listing.rates.daily;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDImage.square(imageUrl: imageUrl, size: 88.0, borderRadius: 8.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDText.bold(
                    text:
                        listing.title.isEmpty
                            ? 'Untitled listing'
                            : listing.title,
                    color: colors.textPrimary,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 4.0),
                  LNDText.regular(
                    text: listing.categoryName,
                    color: colors.textMuted,
                    fontSize: 13.0,
                  ),
                  const SizedBox(height: 8.0),
                  if (dailyRate != null)
                    LNDText.semibold(
                      text:
                          '${LNDMoney.formatRate(dailyRate, listing.rates)} / day',
                      color: colors.primary,
                      fontSize: 14.0,
                    ),
                  const SizedBox(height: 8.0),
                  LNDText.regular(
                    text: listing.description,
                    color: colors.textMuted,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lend/presentation/common/asset_rating_badge.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SmallAssetCard extends StatelessWidget {
  const SmallAssetCard({
    super.key,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.onTap,
    this.averageRating,
    this.reviewCount,
  });

  final String title;
  final String category;
  final String? imageUrl;
  final VoidCallback onTap;
  final double? averageRating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 132.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96.0,
              width: 132.0,
              child: Stack(
                children: [
                  LNDImage.custom(
                    imageUrl: imageUrl,
                    height: 96.0,
                    width: 132.0,
                    borderRadius: 8.0,
                  ),
                  Positioned(
                    top: 6.0,
                    left: 6.0,
                    child: AssetRatingBadge(
                      averageRating: averageRating,
                      reviewCount: reviewCount,
                      compact: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6.0),
            LNDText.semibold(
              text: title,
              fontSize: 12.0,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            LNDText.regular(
              text: category,
              fontSize: 11.0,
              color: colors.textMuted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset_search_result.model.dart';
import 'package:lend/presentation/common/asset_rating_badge.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class SearchResultCard extends GetWidget<AssetSearchController> {
  const SearchResultCard({required this.result, super.key});

  final AssetSearchResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final dailyRate = result.dailyRate;

    return InkWell(
      onTap: () => controller.openAsset(result),
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                LNDImage.custom(
                  imageUrl: result.imageUrl,
                  height: double.infinity,
                  width: double.infinity,
                  borderRadius: 8.0,
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: AssetRatingBadge(
                    averageRating: result.averageRating,
                    reviewCount: result.reviewCount,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          LNDText.medium(
            text: result.title,
            fontSize: 13.0,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3.0),
          LNDText.regular(
            text: result.categoryName,
            color: colors.textMuted,
            fontSize: 11.0,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (dailyRate != null) ...[
            const SizedBox(height: 4.0),
            LNDText.medium(
              text:
                  '${LNDMoney.format(dailyRate, currencyCode: result.currency)} / day',
              color: colors.primary,
              fontSize: 13.0,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

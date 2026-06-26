import 'package:flutter/material.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/common/asset_rating_badge.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class AssetListTile extends StatelessWidget {
  const AssetListTile({super.key, required this.asset, required this.onTap});

  final Asset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: onTap,
      leading: SizedBox(
        height: 56.0,
        width: 56.0,
        child: Stack(
          children: [
            LNDImage.square(imageUrl: asset.images.firstImageUrl, size: 56.0),
            Positioned(
              top: 4.0,
              left: 4.0,
              child: AssetRatingBadge(
                averageRating: asset.averageRating,
                reviewCount: asset.reviewCount,
                compact: true,
              ),
            ),
          ],
        ),
      ),
      title: LNDText.semibold(
        text: asset.title ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: LNDText.regular(
        text: asset.categoryName ?? '',
        color: colors.textMuted,
      ),
      trailing: LNDText.bold(
        text: LNDMoney.formatRate(asset.rates?.daily, asset.rates),
      ),
    );
  }
}

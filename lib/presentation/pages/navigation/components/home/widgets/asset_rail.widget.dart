import 'package:flutter/material.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/common/shimmer.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/small_asset_card.widget.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class AssetRail extends StatelessWidget {
  const AssetRail({
    super.key,
    required this.title,
    required this.assets,
    required this.controller,
    this.isLoading = false,
  });

  final String title;
  final List<Asset> assets;
  final HomeController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && assets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LNDShimmer(
                child: LNDShimmerBox(height: 20.0, width: 60.0),
              ),
            ),
            SizedBox(
              height: 135.0,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, __) => const _AssetRailShimmerItem(),
                separatorBuilder: (_, __) => const SizedBox(width: 10.0),
                itemCount: 4,
              ),
            ),
          ],
        ),
      );
    }

    if (assets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          SizedBox(
            height: 135.0,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final asset = assets[index];
                return SmallAssetCard(
                  title: asset.title ?? '',
                  category:
                      '${LNDMoney.formatRate(asset.rates?.daily, asset.rates)} / day',
                  imageUrl: asset.images.firstImageUrl,
                  averageRating: asset.averageRating,
                  reviewCount: asset.reviewCount,
                  onTap: () => controller.openAssetPage(asset),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10.0),
              itemCount: assets.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetRailShimmerItem extends StatelessWidget {
  const _AssetRailShimmerItem();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 132.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDShimmer(child: LNDShimmerBox(height: 96.0, width: 132.0)),
          SizedBox(height: 8.0),
          LNDShimmer(child: LNDShimmerBox(height: 12.0, width: 112.0)),
          SizedBox(height: 6.0),
          LNDShimmer(child: LNDShimmerBox(height: 11.0, width: 82.0)),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: LNDText.bold(text: title, fontSize: 16.0),
  );
}

import 'package:flutter/material.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/pages/navigation/components/home/widgets/asset_list_tile.widget.dart';

class AssetListingSection extends StatelessWidget {
  const AssetListingSection({
    super.key,
    required this.title,
    required this.assets,
    required this.controller,
  });

  final String title;
  final List<Asset> assets;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LNDText.bold(text: title, fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          ...assets.map(
            (asset) => AssetListTile(
              asset: asset,
              onTap: () => controller.openAssetPage(asset),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SavedAssetCard extends StatelessWidget {
  const SavedAssetCard({
    super.key,
    required this.asset,
    required this.onTap,
    required this.onOptionsTap,
  });

  final SimpleAsset asset;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  _buildImage(),
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Container(
                      height: 25.0,
                      width: 25.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceMuted,
                      ),
                      child: Center(
                        child: LNDButton.icon(
                          icon: Icons.more_vert_rounded,
                          size: 20.0,
                          onPressed: onOptionsTap,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    LNDText.bold(
                      text: asset.title ?? '',
                      fontSize: 14.0,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    LNDText.regular(
                      text: asset.categoryName ?? '',
                      fontSize: 12.0,
                      color: colors.textMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildImage() {
    final imageUrl =
        asset.images != null && asset.images!.isNotEmpty
            ? asset.images![0]
            : null;

    if (imageUrl == null) {
      return Image.asset(
        'assets/generated/app_icon.png',
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder:
          (context, error, stackTrace) => Image.asset(
            'assets/generated/app_icon.png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
    );
  }
}

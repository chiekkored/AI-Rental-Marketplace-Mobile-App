import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class AssetProductShowcase extends GetView<AssetController> {
  const AssetProductShowcase({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SliverToBoxAdapter(
      child: Obx(() {
        final showcase = controller.asset?.showcase ?? [];
        final description = controller.asset?.description ?? '';

        // Determine if either section should be shown
        final hasShowcase = showcase.isNotEmpty;
        final hasDescription = description.trim().isNotEmpty;
        final shouldShow = hasShowcase || hasDescription;
        return Visibility(
          visible: shouldShow,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            color: colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasShowcase) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LNDText.medium(
                          text: 'Product Showcase',
                          color: colors.textMuted,
                        ),
                        if (showcase.length > 5)
                          LNDButton.text(
                            text: 'See More',
                            onPressed: controller.openSeeAllShowcase,
                            enabled: true,
                            size: 12.0,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 125.0,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: showcase.length > 5 ? 5 : showcase.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 6.0),
                      itemBuilder: (_, index) {
                        final imageUrl = showcase[index];
                        return GestureDetector(
                          onTap: () => controller.openPhotoShowcase(index),
                          child: Hero(
                            tag: '$imageUrl $index',
                            child: LNDImage.square(
                              imageUrl: imageUrl,
                              size: 125.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (hasDescription)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Divider(),
                    ),
                ],
                if (hasDescription)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: colors.primary,
                            ),
                          ),
                          Expanded(
                            child: LNDText.regular(
                              text: description,
                              overflow: TextOverflow.visible,
                              isSelectable: true,
                            ),
                          ),
                        ],
                      ).withSpacing(16.0),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

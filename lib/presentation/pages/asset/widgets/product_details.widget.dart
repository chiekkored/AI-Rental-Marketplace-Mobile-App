import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/shimmer.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/saved/saved.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';
import 'package:pluralize/pluralize.dart';

class AssetProductDetails extends GetView<AssetController> {
  const AssetProductDetails({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SliverToBoxAdapter(
      child: Obx(() {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          margin: const EdgeInsets.only(bottom: 4.0),
          color: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: LNDText.bold(
                          text: controller.asset?.title ?? '',
                          fontSize: 24.0,
                          overflow: TextOverflow.visible,
                          isSelectable: true,
                        ),
                      ),
                      if (!controller.isBookingSnapshot)
                        Obx(() {
                          if (SavedController.instance.checkIsSaved(
                            controller.asset?.id,
                          )) {
                            return LNDButton.icon(
                              icon: Icons.bookmark_added_rounded,
                              size: 30.0,
                              color: colors.primary,
                              onPressed: controller.removeBookmark,
                            );
                          } else {
                            return LNDButton.icon(
                              icon: Icons.bookmark_add_outlined,
                              size: 30.0,
                              color: colors.textMuted,
                              onPressed: controller.addBookmark,
                            );
                          }
                        }),
                    ],
                  ),
                  LNDText.regular(
                    text: controller.asset?.categoryName ?? '',
                    color: colors.textMuted,
                  ),
                ],
              ),
              Obx(() {
                final reviewCount = controller.asset?.reviewCount ?? 0;
                return GestureDetector(
                  onTap:
                      controller.isBookingSnapshot
                          ? null
                          : controller.goToAllReviewsPage,
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.solidStar,
                        color: colors.primary,
                        size: 20.0,
                      ),
                      if (controller.isAssetLoading)
                        const LNDShimmer(
                          child: LNDShimmerBox(height: 20.0, width: 100.0),
                        )
                      else ...[
                        LNDText.bold(
                          text:
                              controller.asset?.averageRating?.toStringAsFixed(
                                1,
                              ) ??
                              'N/A',
                          color: colors.primary,
                        ),
                        LNDText.regular(
                          text:
                              '(${Pluralize().pluralize('review', reviewCount, true)})',
                          color: colors.textMuted,
                        ),
                      ],
                    ],
                  ).withSpacing(6.0),
                );
              }),
            ],
          ).withSpacing(16.0),
        );
      }),
    );
  }
}

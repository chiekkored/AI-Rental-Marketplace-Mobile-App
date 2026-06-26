import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class AssetAppBar extends GetView<AssetController> {
  const AssetAppBar({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return SliverAppBar(
      leadingWidth: 52.0,
      backgroundColor: colors.surface,
      leading: Container(
        height: 40.0,
        width: 40.0,
        margin: const EdgeInsets.only(left: 12.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
        ),
        child: Center(child: LNDButton.back()),
      ),
      title: Obx(() {
        final status = controller.asset?.status ?? '';

        return Visibility(
          visible: !controller.isAssetCurrentlyAvailable,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: colors.warningSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: LNDText.semibold(
              text: status,
              fontSize: 9.0,
              color: colors.warning,
            ),
          ),
        );
      }),
      centerTitle: true,
      actions:
          controller.isBookingSnapshot
              ? const []
              : [
                Container(
                  height: 40.0,
                  width: 40.0,
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface,
                  ),
                  child: LNDButton.icon(
                    icon:
                        Platform.isAndroid
                            ? Icons.share_rounded
                            : Icons.ios_share_rounded,
                    size: 25.0,
                    onPressed: controller.onTapShare,
                  ),
                ),
                Obx(() {
                  if (controller.isAssetLoading ||
                      controller.isCurrentUserOwner) {
                    return const SizedBox.shrink();
                  }

                  if (!AuthController.instance.isAuthenticated) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    height: 40.0,
                    width: 40.0,
                    margin: const EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                    ),
                    child: LNDButton.icon(
                      icon: Icons.more_vert_rounded,
                      size: 25.0,
                      onPressed: controller.showReportOptionsBottomSheet,
                    ),
                  );
                }),
              ],
      expandedHeight: 300.0,
      surfaceTintColor: colors.surface,
      stretch: true,
      pinned: true,
      shadowColor: colors.surfaceMuted,
      flexibleSpace: LayoutBuilder(
        builder: (_, constraints) {
          // This is for displaying widgets when appbar is collapsed

          // final top = constraints.biggest.height;

          return FlexibleSpaceBar(
            // title: Opacity(
            //   opacity: top == Get.mediaQuery.padding.top + kToolbarHeight
            //       ? 1.0
            //       : 0.0,
            //   child: LNDText.bold(
            //     text: controller.asset?.title ?? '',
            //     fontSize: 24.0,
            //   ),
            // ),
            centerTitle: false,
            background: Stack(
              children: [
                FlutterCarousel(
                  items:
                      controller.asset?.images?.isNotEmpty == true
                          ? controller.asset!.images!
                              .asMap()
                              .entries
                              .map(
                                (entry) => GestureDetector(
                                  onTap:
                                      () =>
                                          controller.openPhotoAsset(entry.key),
                                  child: LNDImage.custom(
                                    imageUrl: entry.value,
                                    height: double.infinity,
                                    width: double.infinity,
                                    borderRadius: 0.0,
                                  ),
                                ),
                              )
                              .toList()
                          : [
                            LNDImage.custom(
                              imageUrl: null,
                              height: double.infinity,
                              width: double.infinity,
                              borderRadius: 0.0,
                            ),
                          ],
                  options: FlutterCarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1.0,
                    enableInfiniteScroll:
                        (controller.asset?.images?.length ?? 0) > 1,
                    autoPlay: (controller.asset?.images?.length ?? 0) > 1,
                    autoPlayInterval: const Duration(seconds: 4),
                    indicatorMargin: 12.0,
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.surface, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            stretchModes: const [
              StretchMode.fadeTitle,
              StretchMode.zoomBackground,
            ],
          );
        },
      ),
    );
  }
}

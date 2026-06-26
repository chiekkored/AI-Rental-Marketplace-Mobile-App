import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class AssetInclusions extends GetView<AssetController> {
  const AssetInclusions({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SliverToBoxAdapter(
      child: Obx(
        () => Visibility(
          visible: controller.asset?.inclusions?.isNotEmpty ?? false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            color: colors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LNDText.semibold(
                        text: 'What\'s Included',
                        fontSize: 18.0,
                      ),
                    ],
                  ),
                  ...controller.asset?.inclusions?.map(
                        (inclusion) => Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: colors.primary,
                            ),
                            LNDText.regular(
                              text: inclusion,
                              isSelectable: true,
                            ),
                          ],
                        ).withSpacing(8.0),
                      ) ??
                      [],
                ],
              ).withSpacing(8.0),
            ),
          ),
        ),
      ),
    );
  }
}

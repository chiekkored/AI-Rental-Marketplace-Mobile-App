import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/search/components/search_field.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class DiscoverHeader extends GetView<HomeController> {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: SearchFieldComponent.outerPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchFieldComponent(
                      readOnly: true,
                      onTap: controller.goToSearchPage,
                    ),
                  ],
                ),
              ),
              Obx(
                () =>
                    ProfileController.instance.canList
                        ? Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: LNDButton.icon(
                            icon: Icons.add_rounded,
                            size: 28.0,
                            color: colors.primary,
                            onPressed: controller.goToCreateListing,
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
          Obx(() {
            final locationText = LNDUtils.getLocationText(
              location: controller.activeBrowseLocation,
              showFullAddress: false,
            );

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15.0,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 6.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LNDButton.text(
                      text:
                          locationText.isEmpty
                              ? 'Select location'
                              : locationText,
                      enabled: true,
                      color: colors.textMuted,
                      size: 12.0,
                      maxLines: 1,
                      onPressed: controller.openBrowseLocationPicker,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class LocationStep extends GetView<CreateListingController> {
  const LocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: controller.locationStepIndex,
        title: 'Where is your item located?',
        description:
            'Choose whether to use your current location or set a custom location for this listing.',
        secondaryText: 'Back',
        secondaryAction: () => controller.goToStep(controller.pricingStepIndex),
        primaryText: 'Continue',
        primaryAction: controller.continueFromLocation,
        primaryEnabled: controller.canContinueLocation.value,
        child: Form(
          key: controller.locationFormKey,
          child: Column(
            children: [
              CreateListingSection(
                title: 'Use my registered location',
                required: true,
                description:
                    'When enabled, your listing will use your registered profile location by default.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile.adaptive(
                      value: controller.useCurrentLocation.value,
                      contentPadding: EdgeInsets.zero,
                      title: LNDText.medium(text: 'Use my registered location'),
                      onChanged: controller.toggleCurrentLocation,
                    ),
                    Obx(() {
                      if (!controller.useCurrentLocation.value) {
                        return const SizedBox.shrink();
                      }

                      final locationText = LNDUtils.getLocationText(
                        location: ProfileController.instance.user?.location,
                        showFullAddress: false,
                      );

                      if (locationText.isEmpty) return const SizedBox.shrink();

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
                              child: LNDText.regular(
                                text: locationText,
                                color: colors.textMuted,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (controller.currentLocationDenied.value)
                      LNDText.regular(
                        text:
                            'Location permission was denied. Choose a custom location instead.',
                        color: colors.danger,
                        fontSize: 12,
                        textAlign: TextAlign.start,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              controller.useCurrentLocation.value
                  ? const SizedBox.shrink()
                  : CreateListingSection(
                    title: 'Custom Location',
                    required: true,
                    description:
                        'Choose a different location if the item is stored somewhere else.',
                    child: Obx(
                      () => CreateListingTappableField(
                        label: 'Custom Location',
                        required: true,
                        value: controller.locationText.value,
                        icon: Icons.location_on_outlined,
                        placeholder: 'Choose a listing location',
                        onTap: controller.openLocationPicker,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

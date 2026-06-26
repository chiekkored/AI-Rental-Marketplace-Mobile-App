import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class EndDateRuleStep extends GetView<CreateListingController> {
  const EndDateRuleStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: controller.endDateRuleStepIndex,
        title: 'End-date booking rule',
        description:
            'Choose whether the return date should also be unavailable for new booking starts.',
        secondaryText: 'Back',
        secondaryAction: () => controller.goToStep(controller.photosStepIndex),
        primaryText: 'Continue',
        primaryAction: controller.continueFromEndDateRule,
        child: Column(
          children: [
            CreateListingSection(
              title: 'Block the end date',
              description:
                  'Use this when you need the return day for inspection, cleaning, charging, or turnover.',
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: controller.blocksEndDate.value,
                title: LNDText.medium(
                  text: 'Make the booking end date non-bookable',
                  overflow: TextOverflow.visible,
                ),
                onChanged: controller.setBlocksEndDate,
              ),
            ),
            const SizedBox(height: 16),
            LNDInfoBanner(
              content: LNDText.regular(
                text:
                    'e.g.,if a renter books Jan 10 to Jan 12, enabling this keeps Jan 12 unavailable for another renter to start a booking. If disabled, another booking can start on Jan 12.',
                color: colors.textMuted,
                fontSize: 12,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

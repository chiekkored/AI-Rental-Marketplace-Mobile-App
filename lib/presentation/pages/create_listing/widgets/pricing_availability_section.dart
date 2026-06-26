import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PricingAvailabilitySection extends GetWidget<CreateListingController> {
  const PricingAvailabilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return CreateListingSection(
      title: 'Availability',
      description:
          'Choose the listing visibility and availability status renters should see.',
      child: Obx(
        () => Column(
          children:
              Availability.values
                  .map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PricingAvailabilityCard(
                        status: status,
                        selected: controller.availability.value == status,
                        onTap: () => controller.availability.value = status,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class PricingAvailabilityCard extends StatelessWidget {
  final Availability status;
  final bool selected;
  final VoidCallback onTap;

  const PricingAvailabilityCard({
    super.key,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? colors.primary : colors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDText.medium(text: status.label),
                  if (status.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    LNDText.regular(
                      text: status.subtitle,
                      fontSize: 12,
                      color: colors.textMuted,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

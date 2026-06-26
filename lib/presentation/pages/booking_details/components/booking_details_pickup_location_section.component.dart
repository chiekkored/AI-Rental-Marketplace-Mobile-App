import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_info_section.widget.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_location_map.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingDetailsPickupLocationSection
    extends GetView<BookingDetailsController> {
  const BookingDetailsPickupLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final locationText = controller.locationText;

    if (locationText.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: BookingDetailsInfoSection(
        title: 'Pickup address',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.regular(
              text: locationText,
              color: colors.textPrimary,
              overflow: TextOverflow.visible,
              isSelectable: true,
            ),
            if (controller.mapCenter != null) ...[
              const SizedBox(height: 12.0),
              const BookingDetailsLocationMap(),
            ],
          ],
        ),
      ),
    );
  }
}

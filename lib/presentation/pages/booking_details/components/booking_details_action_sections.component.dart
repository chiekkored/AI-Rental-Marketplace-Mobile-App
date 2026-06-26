import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_action_row.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingDetailsActionSections extends GetView<BookingDetailsController> {
  const BookingDetailsActionSections({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              BookingDetailsActionRow(
                icon: Icons.message_outlined,
                text: 'Message',
                color:
                    controller.canOpenChat
                        ? colors.textPrimary
                        : colors.disabled,
                onTap: controller.canOpenChat ? controller.openChat : null,
              ),
              BookingDetailsActionRow(
                icon: Icons.inventory_2_outlined,
                text: 'Show listing',
                color:
                    controller.canShowListing
                        ? colors.textPrimary
                        : colors.disabled,
                onTap:
                    controller.canShowListing ? controller.showListing : null,
              ),
              if (controller.canViewReceipt)
                BookingDetailsActionRow(
                  icon: Icons.receipt_long_outlined,
                  text: 'View Receipt',
                  color: colors.textPrimary,
                  onTap: controller.viewReceipt,
                ),
              if (controller.canViewEarnings)
                BookingDetailsActionRow(
                  icon: Icons.payments_outlined,
                  text: 'View Earnings',
                  color: colors.textPrimary,
                  onTap: controller.viewEarnings,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
              controller.canRequestBookingCancellation
                  ? BookingDetailsActionRow(
                    icon: Icons.event_busy_rounded,
                    text: 'Request Cancellation',
                    color: colors.danger,
                    onTap: controller.requestBookingCancellation,
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

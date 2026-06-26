import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_action_sections.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_cancellation_summary_section.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_counterparty_section.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_dispute_summary_section.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_handover_actions.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_payment_summary_section.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_pickup_location_section.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_receipt_section.component.dart';
import 'package:lend/presentation/pages/booking_details/components/booking_details_security_deposit_summary_section.component.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_action_row.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingDetailsPage extends GetView<BookingDetailsController> {
  static const routeName = '/booking-details';

  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: 'Booking Details', fontSize: 18.0),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          children: [
            const BookingDetailsReceiptSection(),
            const SizedBox(height: 16.0),
            if (controller.booking.asset?.ownerInstructions
                    ?.trim()
                    .isNotEmpty ==
                true) ...[
              _ListingInstructionsItem(
                instructions: controller.booking.asset!.ownerInstructions!,
              ),
              const SizedBox(height: 16.0),
            ],
            const BookingDetailsPaymentSummarySection(),
            const SizedBox(height: 16.0),
            const BookingDetailsCancellationSummarySection(),
            const BookingDetailsDisputeSummarySection(),
            const BookingDetailsSecurityDepositSummarySection(),
            const BookingDetailsCounterpartySection(),
            const BookingDetailsPickupLocationSection(),
            const BookingDetailsHandoverActions(),
            const SizedBox(height: 16.0),
            const BookingDetailsActionSections(),
          ],
        ),
      ),
    );
  }
}

class _ListingInstructionsItem extends StatelessWidget {
  const _ListingInstructionsItem({required this.instructions});

  final String instructions;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: BookingDetailsActionRow(
        icon: Icons.info_outline_rounded,
        text: 'Listing Instructions',
        color: colors.textPrimary,
        onTap: () {
          LNDShow.bottomSheetInfo(
            [
              LNDText.regular(
                text: instructions.trim(),
                overflow: TextOverflow.visible,
                isSelectable: true,
              ),
            ],
            title: 'Listing Instructions',
            isMoreInfoVisible: false,
          );
        },
      ),
    );
  }
}

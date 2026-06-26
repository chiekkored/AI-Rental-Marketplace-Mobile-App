import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_listing_meta_row.widget.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_receipt.widget.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_role_chip.widget.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/timestamp.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class BookingDetailsReceiptSection extends GetView<BookingDetailsController> {
  const BookingDetailsReceiptSection({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = controller.booking;

    return BookingDetailsReceiptContainer(
      children: [
        _ListingSummary(booking: booking),
        const BookingDetailsReceiptDivider(),
        BookingDetailsReceiptRow(label: 'Booking ID', value: booking.id ?? ''),
        BookingDetailsReceiptRow(
          label: 'Status',
          value: booking.status?.label ?? '',
        ),
        BookingDetailsReceiptRow(
          label: 'Date',
          value: LNDUtils.getDateRange(
            start: LNDUtils.bookingDateFromTimestamp(booking.startDate),
            end: LNDUtils.bookingDateFromTimestamp(booking.endDate),
          ),
        ),
        BookingDetailsReceiptRow(
          label: 'Duration',
          value:
              booking.numDays == null
                  ? ''
                  : '${booking.numDays} ${booking.numDays == 1 ? 'day' : 'days'}',
        ),
        BookingDetailsReceiptRow(
          label: 'Created',
          value: booking.createdAt.toFormattedStringWithTime(),
        ),
      ],
    );
  }
}

class _ListingSummary extends GetView<BookingDetailsController> {
  const _ListingSummary({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final roleLabel = controller.roleLabel;
    final ratesLabel = _formatRates(booking.asset?.rates);
    final securityDeposit = _securityDepositAmount();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LNDImage.square(
          imageUrl: booking.asset?.images.firstImageUrl,
          size: 100.0,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (roleLabel != null) ...[
                BookingDetailsRoleChip(label: roleLabel),
                const SizedBox(height: 8.0),
              ],
              LNDText.semibold(
                text: booking.asset?.title ?? 'Listing',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              LNDText.regular(
                text: booking.asset?.categoryName ?? '',
                color: colors.textMuted,
                fontSize: 12.0,
                overflow: TextOverflow.visible,
              ),
              if (ratesLabel.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                BookingDetailsListingMetaRow(label: 'Rate', value: ratesLabel),
              ],
              if (securityDeposit != null) ...[
                const SizedBox(height: 4.0),
                BookingDetailsListingMetaRow(
                  label: 'Security deposit',
                  value: LNDMoney.formatRate(
                    securityDeposit,
                    booking.asset?.rates,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatRates(Rates? rates) {
    if (rates == null) return '';

    final labels = <String>[
      if (rates.daily != null) '${LNDMoney.formatRate(rates.daily, rates)}/day',
      if (rates.weekly != null)
        '${LNDMoney.formatRate(rates.weekly, rates)}/week',
      if (rates.monthly != null)
        '${LNDMoney.formatRate(rates.monthly, rates)}/month',
      if (rates.annually != null)
        '${LNDMoney.formatRate(rates.annually, rates)}/year',
    ];

    return labels.join(' · ');
  }

  int? _securityDepositAmount() {
    if (booking.securityDeposit.enabled && booking.securityDeposit.amount > 0) {
      return booking.securityDeposit.amount;
    }

    final assetDeposit = booking.asset?.securityDeposit;
    if (assetDeposit?.enabled == true && assetDeposit!.amount > 0) {
      return assetDeposit.amount;
    }

    return null;
  }
}

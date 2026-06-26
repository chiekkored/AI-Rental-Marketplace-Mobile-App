import 'package:flutter/material.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/pages/navigation/components/now/widgets/now_role_chip.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class TodayBookingCard extends StatelessWidget {
  const TodayBookingCard({super.key, required this.item});

  final NowBookingItem item;

  Booking get booking => item.booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap:
          () => LNDNavigate.toBookingDetailsPage(
            args: BookingDetailsPageArgs(booking: booking, role: item.role),
          ),
      child: Container(
        width: 220.0,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: colors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDImage.custom(
              imageUrl: booking.asset?.images.firstImageUrl,
              height: 150.0,
              width: 220.0,
              borderRadius: 0.0,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NowRoleChip(item: item),
                  const SizedBox(height: 8.0),
                  LNDText.semibold(
                    text: booking.asset?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  LNDText.regular(
                    text: _dateRange(booking),
                    color: colors.textMuted,
                    fontSize: 12.0,
                  ),
                  const SizedBox(height: 4.0),
                  LNDText.bold(
                    text: LNDMoney.formatRate(
                      booking.totalPrice,
                      booking.asset?.rates,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _dateRange(Booking booking) {
  return LNDUtils.getDateRange(
    start: LNDUtils.bookingDateFromTimestamp(booking.startDate),
    end: LNDUtils.bookingDateFromTimestamp(booking.endDate),
  );
}

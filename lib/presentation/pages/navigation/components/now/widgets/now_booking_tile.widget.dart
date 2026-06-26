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

class NowBookingTile extends StatelessWidget {
  const NowBookingTile({super.key, required this.item});

  final NowBookingItem item;

  Booking get booking => item.booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap:
          () => LNDNavigate.toBookingDetailsPage(
            args: BookingDetailsPageArgs(
              booking: item.booking,
              role: item.role,
            ),
          ),
      leading: LNDImage.square(
        imageUrl: booking.asset?.images.firstImageUrl,
        size: 56.0,
      ),
      title: LNDText.semibold(
        text: booking.asset?.title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: LNDText.regular(
        text: _dateRange(booking),
        color: colors.textMuted,
        fontSize: 12.0,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          NowRoleChip(item: item),
          LNDText.bold(
            text: LNDMoney.formatRate(booking.totalPrice, booking.asset?.rates),
          ),
        ],
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

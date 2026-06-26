import 'package:flutter/material.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/bookingStatus.extension.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class RentalHistoryBookingTile extends StatelessWidget {
  const RentalHistoryBookingTile({
    super.key,
    required this.booking,
    required this.onTap,
  });

  final Booking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final status = booking.status;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: onTap,
      leading: LNDImage.square(
        imageUrl: booking.asset?.images.firstImageUrl,
        size: 56.0,
      ),
      title: LNDText.semibold(
        text: booking.asset?.title ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: LNDText.regular(
        text: _dateRange,
        color: colors.textMuted,
        fontSize: 12.0,
        textParts: [
          if (status != null) ...[
            LNDText.regular(text: ' • ', color: colors.textMuted),
            LNDText.regular(
              text: status.label,
              fontSize: 12.0,
              color: status.themedColor(colors),
            ),
          ],
        ],
      ),
      trailing: LNDText.bold(
        text: LNDMoney.formatRate(booking.totalPrice, booking.asset?.rates),
      ),
    );
  }

  String get _dateRange {
    return LNDUtils.getDateRange(
      start: LNDUtils.bookingDateFromTimestamp(booking.startDate),
      end: LNDUtils.bookingDateFromTimestamp(booking.endDate),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/calendar_bookings/calendar_bookings.controller.dart';
import 'package:lend/utilities/extensions/bookingStatus.extension.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class BookingListView extends GetWidget<CalendarBookingsController> {
  const BookingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(() {
      final sections = controller.bookingDateSections;
      if (sections.isEmpty) {
        return Center(
          child: LNDText.regular(
            text: 'No bookings yet',
            color: colors.textMuted,
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16.0),
        itemBuilder: (_, sectionIndex) {
          final section = sections[sectionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDText.semibold(
                text: _sectionTitle(section.startDate),
                color: colors.textMuted,
                fontSize: 13.0,
              ),
              const SizedBox(height: 8.0),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < section.bookings.length;
                      index++
                    )
                      _BookingListTile(
                        booking: section.bookings[index],
                        isLast: index == section.bookings.length - 1,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class _BookingListTile extends GetWidget<CalendarBookingsController> {
  const _BookingListTile({required this.booking, required this.isLast});

  final Booking booking;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final status = booking.status;
    final amount = LNDMoney.formatRate(
      booking.totalPrice,
      booking.asset?.rates,
    );

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0,
          ),
          onTap: () => controller.goToBookingDetails(booking),
          leading: LNDImage.square(
            imageUrl: booking.asset?.images.firstImageUrl,
            size: 52.0,
          ),
          title: LNDText.semibold(
            text: booking.asset?.title ?? 'Untitled listing',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: LNDText.regular(
            text: _subtitle,
            color: colors.textMuted,
            fontSize: 12.0,
            overflow: TextOverflow.visible,
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
          trailing:
              amount.isEmpty
                  ? null
                  : LNDText.bold(text: amount, fontSize: 13.0),
        ),
        if (!isLast) Divider(color: colors.outline, height: 1.0, indent: 76.0),
      ],
    );
  }

  String get _subtitle {
    final renterName = booking.renter?.getName ?? 'Unknown user';
    final dateRange = LNDUtils.getDateRange(
      start: LNDUtils.bookingDateFromTimestamp(booking.startDate),
      end: LNDUtils.bookingDateFromTimestamp(booking.endDate),
    );
    if (dateRange.trim().isEmpty) return renterName;
    return '$renterName • $dateRange';
  }
}

String _sectionTitle(DateTime? date) {
  if (date == null) return 'Unscheduled';
  return DateFormat('MMMM d, y').format(date);
}

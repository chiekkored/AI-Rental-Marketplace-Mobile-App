import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/pulsing_dot.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/pages/chat/chat.page.dart';
import 'package:lend/utilities/enums/token.enum.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class TokenViewArgs {
  final Booking booking;
  final TokenType tokenType;
  final String token;

  TokenViewArgs({
    required this.booking,
    required this.tokenType,
    required this.token,
  });
}

class TokenViewPage extends StatelessWidget {
  static const routeName = '/token-view';
  const TokenViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as TokenViewArgs;
    final colors = context.lndTheme;
    final booking = args.booking;
    final isHandover = args.tokenType == TokenType.handOver;
    final actionLabel = isHandover ? 'handover' : 'return';
    final title = isHandover ? 'Confirm handover' : 'Confirm return';
    final description =
        isHandover
            ? 'Review the booking details before marking this item as handed over.'
            : 'Review the booking details before marking this item as returned.';

    void markBooking() async {
      LNDLoading.show();
      final result = await LNDBookingService.markBooking(token: args.token);
      result.fold(
        ifLeft: (data) async {
          NowController.instance.refreshNow();
          LNDLoading.hide();
          Get.until((a) {
            return a.settings.name == ChatPage.routeName || a.isFirst;
          });
        },
        ifRight: (error) {
          LNDLoading.hide();
          LNDSnackbar.showError('Something went wrong');
        },
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: LNDText.bold(text: args.tokenType.label, fontSize: 18.0),
        leading: LNDButton.close(),
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 24.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44.0,
                    width: 44.0,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      isHandover
                          ? Icons.output_rounded
                          : Icons.assignment_return_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  LNDText.bold(
                    text: title,
                    fontSize: 24.0,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 8.0),
                  LNDText.regular(
                    text: description,
                    color: colors.textSecondary,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            _BookingDetailsCard(booking: booking),
            const SizedBox(height: 24.0),
            LNDButton.primary(
              text: 'Confirm $actionLabel',
              enabled: true,
              onPressed: markBooking,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDetailsCard extends StatelessWidget {
  const _BookingDetailsCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final locationText = LNDUtils.getAddressText(
      location: booking.asset?.location,
      toObscure: false,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160.0,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  child: LNDImage.custom(
                    height: double.infinity,
                    width: double.infinity,
                    imageUrl: booking.asset?.images.firstImageUrl,
                    borderRadius: 0.0,
                  ),
                ),
                if (_isBookingActiveToday(booking))
                  Positioned(
                    top: 12.0,
                    left: 12.0,
                    child: LNDPulsingDot(color: colors.success),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LNDText.bold(
                  text: booking.asset?.title ?? 'Booking',
                  fontSize: 18.0,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                ),
                const SizedBox(height: 14.0),
                _TokenDetailRow(
                  label: 'Total paid',
                  value: _formatTotalPaid(booking),
                  isEmphasized: true,
                ),
                _TokenDetailRow(
                  label: 'Dates',
                  value: LNDUtils.getDateRange(
                    start: LNDUtils.bookingDateFromTimestamp(booking.startDate),
                    end: LNDUtils.bookingDateFromTimestamp(booking.endDate),
                  ),
                ),
                if (locationText.trim().isNotEmpty)
                  _TokenDetailRow(label: 'Location', value: locationText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isBookingActiveToday(Booking booking) {
    final start = LNDUtils.bookingDateFromTimestamp(booking.startDate);
    final end = LNDUtils.bookingDateFromTimestamp(booking.endDate);
    if (start == null || end == null) return false;
    return LNDUtils.isTodayInRange(start: start, end: end);
  }

  String _formatTotalPaid(Booking booking) {
    final amount =
        booking.priceBreakdown.paymentAmount ??
        booking.paymentFlow?.amount ??
        booking.totalPrice;
    final currency =
        booking.paymentFlow?.currency?.trim() ??
        booking.priceBreakdown.currency?.trim();
    if (currency?.isNotEmpty == true) {
      return LNDMoney.format(amount, currencyCode: currency!.toUpperCase());
    }
    return LNDMoney.formatRate(amount, booking.asset?.rates);
  }
}

class _TokenDetailRow extends StatelessWidget {
  const _TokenDetailRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LNDText.regular(
              text: label,
              color: colors.textMuted,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child:
                isEmphasized
                    ? LNDText.bold(
                      text: value,
                      textAlign: TextAlign.end,
                      fontSize: 16.0,
                      overflow: TextOverflow.visible,
                    )
                    : LNDText.regular(
                      text: value,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.visible,
                    ),
          ),
        ],
      ),
    );
  }
}

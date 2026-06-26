import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class OutstandingDamageBalance {
  final Booking booking;
  final String bookingId;
  final String? chatId;
  final String? damagePaymentRequestId;
  final String listingTitle;
  final num amount;
  final String currency;

  const OutstandingDamageBalance({
    required this.booking,
    required this.bookingId,
    required this.chatId,
    required this.damagePaymentRequestId,
    required this.listingTitle,
    required this.amount,
    required this.currency,
  });

  bool get canPay =>
      chatId?.trim().isNotEmpty == true &&
      damagePaymentRequestId?.trim().isNotEmpty == true &&
      amount > 0;

  Chat get paymentChat => Chat(
    id: chatId,
    chatId: chatId,
    bookingId: bookingId,
    renterId: booking.renter?.uid,
    asset:
        booking.asset != null
            ? SimpleAsset.fromMap(booking.asset!.toMap())
            : null,
    participants: [
      if (booking.asset?.owner != null) booking.asset!.owner!,
      if (booking.renter != null) booking.renter!,
    ],
    bookingStartDate: booking.startDate,
    bookingEndDate: booking.endDate,
    bookingStatus: booking.status,
    createdAt: booking.createdAt,
  );

  factory OutstandingDamageBalance.fromBooking(Booking booking) {
    final amount = booking.disputeFlow?.outstandingAmount ?? 0;
    final requestId = _nonEmpty(
      booking.disputeFlow?.outstandingPaymentRequestId,
    );

    return OutstandingDamageBalance(
      booking: booking,
      bookingId: booking.id ?? '',
      chatId:
          _nonEmpty(booking.disputeFlow?.renterSupportChatId) ??
          _nonEmpty(booking.chatId),
      damagePaymentRequestId: requestId,
      listingTitle: _nonEmpty(booking.asset?.title) ?? 'Booking',
      amount: amount,
      currency:
          _nonEmpty(booking.paymentFlow?.currency) ??
          _nonEmpty(booking.priceBreakdown.currency) ??
          _nonEmpty(booking.asset?.rates?.currency) ??
          LNDMoney.currentCurrencyCode(),
    );
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

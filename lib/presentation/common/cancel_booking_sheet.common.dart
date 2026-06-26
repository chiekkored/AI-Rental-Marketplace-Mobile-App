import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class LNDCancelBookingSheet extends StatefulWidget {
  const LNDCancelBookingSheet({
    super.key,
    this.booking,
    this.isOwner = false,
    this.renterCancellationPolicy,
    this.now,
  });

  final Booking? booking;
  final bool isOwner;
  final LNDRenterCancellationPolicy? renterCancellationPolicy;
  final DateTime? now;

  @override
  State<LNDCancelBookingSheet> createState() => _LNDCancelBookingSheetState();
}

class _LNDCancelBookingSheetState extends State<LNDCancelBookingSheet> {
  static const List<String> _reasons = [
    'I no longer need this item',
    'I chose different dates',
    'I found another listing',
    'The booking was made by mistake',
    'Other',
  ];

  static const List<String> _ownerReasons = [
    'Item is unavailable',
    'Item needs repair',
    'Safety concern',
    'Emergency',
    'Availability was incorrect',
    'Other',
  ];

  late String _reason = _availableReasons.first;

  List<String> get _availableReasons =>
      widget.isOwner ? _ownerReasons : _reasons;

  String? get _currentRefundPolicyText {
    if (widget.isOwner) return null;

    final booking = widget.booking;
    final createdAt = booking?.createdAt?.toDate();
    final startDate = booking?.startDate?.toDate();
    final policy =
        widget.renterCancellationPolicy ??
        (LNDRemoteConfigService.isReady
            ? LNDRemoteConfigService.pricingPolicy.renterCancellationPolicy
            : null);
    if (createdAt == null || startDate == null || policy == null) return null;

    try {
      final tier = currentRenterCancellationRefundTier(
        policy: policy,
        createdAt: createdAt,
        startDate: startDate,
        now: widget.now,
      );
      return currentRenterCancellationRefundPolicyText(tier);
    } catch (_) {
      return null;
    }
  }

  _OwnerCancellationPenaltyPreview? get _ownerPenaltyPreview {
    final booking = widget.booking;
    if (booking == null) return null;

    final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
    final isWithinCutoff =
        startDate != null && startDate.difference(DateTime.now()).inHours <= 48;
    final rate = isWithinCutoff ? 1.0 : 0.5;
    final payoutBase =
        booking.payoutFlow?.ownerPayoutAmount ??
        booking.priceBreakdown.ownerPayoutAmount ??
        booking.totalPrice;
    final currencyCode = LNDMoney.currencyCodeFromRates(booking.asset?.rates);

    return _OwnerCancellationPenaltyPreview(
      ratePercent: isWithinCutoff ? 100 : 50,
      amount: payoutBase != null ? payoutBase * rate : null,
      currencyCode: currencyCode,
    );
  }

  String get _ownerPenaltyWarningText {
    final preview = _ownerPenaltyPreview;
    if (preview?.amount == null) {
      return 'If approved, the renter may be refunded and a penalty will be deducted from future payouts for this listing.';
    }

    final amount = _formatExactMoney(preview!.amount, preview.currencyCode);
    return 'Potential penalty: $amount (${preview.ratePercent}% of expected owner payout) if approved. This will be deducted from future payouts for this listing.';
  }

  String get _ownerPenaltyConfirmationText {
    final preview = _ownerPenaltyPreview;
    final penaltyText =
        preview?.amount == null
            ? 'a penalty may be deducted from future payouts for this listing.'
            : 'the estimated penalty is ${_formatExactMoney(preview!.amount, preview.currencyCode)} (${preview.ratePercent}% of expected owner payout), deducted from future payouts for this listing.';

    return 'This request will be sent for Lend review. If approved, the renter may be refunded and $penaltyText';
  }

  Future<void> _submit() async {
    if (widget.isOwner) {
      final confirmed = await LNDShow.alertDialog<bool?>(
        title: 'Submit cancellation request?',
        content: _ownerPenaltyConfirmationText,
        cancelText: 'Close',
        confirmText: 'Submit request',
        confirmColor: Get.context?.lndTheme.danger,
      );
      if (confirmed != true) return;
    }

    Get.back(result: _reason);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final currentRefundPolicyText = _currentRefundPolicyText;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LNDText.bold(text: 'Request cancellation', fontSize: 18.0),
              if (widget.isOwner) ...[
                const SizedBox(height: 12.0),
                LNDWarningBanner(
                  content: LNDText.regular(
                    text: _ownerPenaltyWarningText,
                    fontSize: 12.0,
                    overflow: TextOverflow.visible,
                    color: colors.textPrimary,
                  ),
                ),
              ],
              if (currentRefundPolicyText != null) ...[
                const SizedBox(height: 12.0),
                LNDInfoBanner(
                  content: LNDText.regular(
                    text: currentRefundPolicyText,
                    fontSize: 12.0,
                    overflow: TextOverflow.visible,
                    color: colors.textPrimary,
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              LNDText.semibold(text: 'Reason', fontSize: 14.0),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children:
                      _availableReasons
                          .map(
                            (reason) => InkWell(
                              onTap: () => setState(() => _reason = reason),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _reason == reason
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color:
                                          _reason == reason
                                              ? colors.primary
                                              : colors.textMuted,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: LNDText.regular(text: reason),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 20.0),
              LNDButton.primary(
                text: 'Submit request',
                enabled: true,
                color: colors.danger,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerCancellationPenaltyPreview {
  const _OwnerCancellationPenaltyPreview({
    required this.ratePercent,
    required this.amount,
    required this.currencyCode,
  });

  final int ratePercent;
  final num? amount;
  final String currencyCode;
}

String _formatExactMoney(num? amount, String currencyCode) {
  if (amount == null) return '';
  return '$currencyCode ${amount.toString()}';
}

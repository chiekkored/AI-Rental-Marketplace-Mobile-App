import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_info_section.widget.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_receipt.widget.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class BookingDetailsDisputeSummarySection
    extends GetView<BookingDetailsController> {
  const BookingDetailsDisputeSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = controller.booking;
    if (!BookingDetailsDisputeSummaryCard.shouldShow(booking)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        BookingDetailsDisputeSummaryCard(
          booking: booking,
          isOwner: controller.isOwner,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

class BookingDetailsDisputeSummaryCard extends StatelessWidget {
  const BookingDetailsDisputeSummaryCard({
    required this.booking,
    required this.isOwner,
    super.key,
  });

  final Booking booking;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    if (!shouldShow(booking)) return const SizedBox.shrink();

    if (booking.disputeFlow != null) {
      return _buildPaymentFlowDisputeSummary();
    }

    final request = booking.damageDeductionRequest;
    final settlement = booking.settlement;
    final outstandingBalancePaid = _outstandingBalancePaid();
    final renterProcessingFee = _renterProcessingFee();
    final renterOutstandingBalancePaidTotal =
        _renterOutstandingBalancePaidTotal();
    final ownerPayoutCalculation = _ownerPayoutCalculation();
    final ownerDisputeAmount = _ownerDisputeAmount();
    final depositReturnFeeRemoved = _depositReturnFeeRemovedAmount(
      ownerDisputeAmount,
    );

    final caseRows = <Widget>[
      if (request?.requestedAmount != null)
        BookingDetailsReceiptRow(
          label: 'Requested deduction',
          value: _formatMoney(request!.requestedAmount),
        ),
      if (_firstText([request?.reason]) case final reason?)
        BookingDetailsReceiptRow(label: 'Damage reason', value: reason),
      // if (_firstText([settlement?.renterResponse, request?.renterResponse])
      //     case final renterResponse?)
      //   BookingDetailsReceiptRow(
      //     label: isOwner ? 'Renter response' : 'Your response',
      //     value: _formatStatus(renterResponse),
      //   ),
      if (_firstText([
            request?.status,
            request?.supportStatus,
            settlement?.supportStatus,
            settlement?.status,
          ])
          case final status?)
        BookingDetailsReceiptRow(
          label: 'Dispute status',
          value: _formatStatus(status),
        ),
    ];
    final outcomeRows = <Widget>[
      if (_depositCoveredAmount() case final amount?)
        BookingDetailsReceiptRow(
          label:
              isOwner
                  ? 'Security deposit deducted'
                  : 'Your security deposit used',
          value: _formatMoney(amount),
        ),
      if (outstandingBalancePaid != null)
        BookingDetailsReceiptRow(
          label:
              isOwner
                  ? "Renter's outstanding balance paid"
                  : 'Your outstanding balance',
          value: _formatMoney(outstandingBalancePaid),
          isTotal: isOwner,
        ),
      if (!isOwner && renterProcessingFee != null && renterProcessingFee > 0)
        BookingDetailsReceiptRow(
          label: 'Dispute processing fee',
          value: _formatMoney(renterProcessingFee),
        ),
      if (!isOwner && renterOutstandingBalancePaidTotal != null)
        BookingDetailsReceiptRow(
          label: 'Your outstanding balance paid',
          value: _formatMoney(renterOutstandingBalancePaidTotal),
          isTotal: true,
        ),
      if (settlement?.depositReturnAmount != null)
        BookingDetailsReceiptRow(
          label:
              isOwner
                  ? 'Security deposit returned'
                  : 'Your security deposit returned',
          value: _formatMoney(settlement!.depositReturnAmount),
        ),
      if (isOwner && _hasPositiveAmount(ownerDisputeAmount))
        BookingDetailsReceiptRow(
          label: 'Dispute amount',
          value: _formatMoney(ownerDisputeAmount),
        ),
      if (isOwner && _hasPositiveAmount(depositReturnFeeRemoved))
        BookingDetailsReceiptRow(
          label: 'Deposit return fee removed',
          value: _formatMoney(depositReturnFeeRemoved),
        ),
      if (isOwner && ownerPayoutCalculation != null)
        BookingDetailsReceiptRow(
          label: 'Your final payout',
          value: _formatMoney(ownerPayoutCalculation.total),
          infoTooltip: 'View payout calculation',
          onInfoTap:
              () => _showOwnerPayoutCalculationSheet(ownerPayoutCalculation),
        ),
      if (_firstText([settlement?.damageBalancePaymentStatus])
          case final status?)
        BookingDetailsReceiptRow(label: 'Status', value: _formatStatus(status)),
    ];

    return BookingDetailsInfoSection(
      title: 'Dispute summary',
      child: Column(
        children: [
          ...caseRows,
          if (caseRows.isNotEmpty && outcomeRows.isNotEmpty)
            const BookingDetailsReceiptDivider(),
          ...outcomeRows,
        ],
      ),
    );
  }

  static bool shouldShow(Booking booking) {
    if (_hasDisputeFlowSignal(booking.disputeFlow)) return true;
    if (!booking.isCompleted) return false;

    final request = booking.damageDeductionRequest;
    final settlement = booking.settlement;
    if (request == null && settlement == null) return false;

    return _hasDamageRequestSignal(request) ||
        _hasDamageSettlementSignal(settlement);
  }

  String _formatMoney(num? amount) {
    final currency =
        booking.paymentFlow?.currency?.trim() ??
        booking.priceBreakdown.currency?.trim() ??
        booking.payment?.currency?.trim();
    if (currency?.isNotEmpty == true) {
      return LNDMoney.format(amount, currencyCode: currency!.toUpperCase());
    }
    return LNDMoney.formatRate(amount, booking.asset?.rates);
  }

  Widget _buildPaymentFlowDisputeSummary() {
    final dispute = booking.disputeFlow!;
    final depositAmount =
        booking.depositFlow?.amount ??
        (booking.securityDeposit.enabled ? booking.securityDeposit.amount : 0);
    final requestedAmount = dispute.requestedAmount;
    final outstandingAmount = dispute.outstandingAmount;
    final remainingDeposit =
        dispute.remainingSecurityDeposit ??
        booking.depositFlow?.depositReturnAmount ??
        (depositAmount > 0 &&
                (dispute.depositCoveredAmount ?? 0) <= depositAmount
            ? depositAmount - (dispute.depositCoveredAmount ?? 0)
            : null);
    final outstandingPayment = dispute.outstandingPayment;
    final outstandingProcessingFee = _numValue(
      outstandingPayment,
      'renterProcessingFee',
    );
    final outstandingPaymentTotal =
        _numValue(outstandingPayment, 'paymentAmount') ??
        ((outstandingAmount != null && outstandingProcessingFee != null)
            ? outstandingAmount + outstandingProcessingFee
            : null);
    final ownerDisputeAmount = _paymentFlowOwnerDisputeAmount(dispute);
    final depositReturnFeeRemoved = _depositReturnFeeRemovedAmount(
      ownerDisputeAmount,
      depositReturnAmount: remainingDeposit,
    );

    return BookingDetailsInfoSection(
      title: 'Dispute summary',
      child: Column(
        children: [
          if (requestedAmount != null)
            BookingDetailsReceiptRow(
              label:
                  isOwner
                      ? 'Requested deduction'
                      : outstandingAmount != null && outstandingAmount > 0
                      ? 'Outstanding balance'
                      : 'Requested deduction',
              value: _formatMoney(requestedAmount),
            ),
          if (_hasText(dispute.reason))
            BookingDetailsReceiptRow(
              label: 'Damage reason',
              value: dispute.reason!,
            ),
          // if (_hasText(dispute.renterResponse))
          //   BookingDetailsReceiptRow(
          //     label: isOwner ? 'Renter response' : 'Your response',
          //     value: _formatStatus(dispute.renterResponse!),
          //   ),
          if (isOwner) ...[
            BookingDetailsReceiptRow(
              label: 'Payout before dispute',
              value: _formatMoney(booking.priceBreakdown.ownerPayoutAmount),
            ),
            if (_hasPositiveAmount(ownerDisputeAmount))
              BookingDetailsReceiptRow(
                label: 'Dispute amount',
                value: _formatMoney(ownerDisputeAmount),
              ),
            if (_hasPositiveAmount(depositReturnFeeRemoved))
              BookingDetailsReceiptRow(
                label: 'Deposit return fee removed',
                value: _formatMoney(depositReturnFeeRemoved),
              ),
            BookingDetailsReceiptRow(
              label: 'Your final payout',
              value: _formatMoney(
                booking.payoutFlow?.ownerPayoutAmount ??
                    booking.priceBreakdown.ownerPayoutAmount,
              ),
              isTotal: true,
            ),
          ] else ...[
            if (outstandingAmount != null && outstandingAmount > 0) ...[
              BookingDetailsReceiptRow(
                label: 'Outstanding balance',
                value: _formatMoney(outstandingAmount),
              ),
              if (outstandingProcessingFee != null)
                BookingDetailsReceiptRow(
                  label: 'Outstanding balance processing fee',
                  value: _formatMoney(outstandingProcessingFee),
                ),
              BookingDetailsReceiptRow(
                label: 'Total penalty',
                value: _formatMoney(
                  outstandingPaymentTotal ?? outstandingAmount,
                ),
                isTotal: true,
              ),
            ] else if (remainingDeposit != null)
              BookingDetailsReceiptRow(
                label: 'Remaining security deposit',
                value: _formatMoney(remainingDeposit),
                isTotal: true,
              ),
          ],
          if (_hasText(dispute.status))
            BookingDetailsReceiptRow(
              label: 'Dispute status',
              value: _formatStatus(dispute.status!),
            ),
        ],
      ),
    );
  }

  num? _renterOutstandingBalancePaidTotal() {
    final settlement = booking.settlement;
    final payment = settlement?.damageBalancePayment;
    final directPaymentAmount = _numValue(payment, 'paymentAmount');
    if (directPaymentAmount != null) return directPaymentAmount;

    final paidAmount = _outstandingBalancePaid();
    if (paidAmount != null) {
      return paidAmount + (_renterProcessingFee() ?? 0);
    }

    return null;
  }

  num? _outstandingBalancePaid() {
    final settlement = booking.settlement;
    final request = booking.damageDeductionRequest;
    final payment = settlement?.damageBalancePayment;
    final paidAmount = _numValue(payment, 'amount');
    if (paidAmount != null) return paidAmount;

    return _firstAmount([
      settlement?.damageBalanceRequestedAmount,
      _numValue(
        settlement?.damageBalancePayment,
        'paidOutstandingDamageAmount',
      ),
      _numValue(settlement?.damageBalancePayment, 'paidOutstandingAmount'),
      request?.paidOutstandingAmount,
      settlement?.outstandingDamageAmount,
      request?.outstandingAmount,
    ]);
  }

  num? _renterProcessingFee() {
    return _numValue(
      booking.settlement?.damageBalancePayment,
      'renterProcessingFee',
    );
  }

  _OwnerPayoutCalculation? _ownerPayoutCalculation() {
    final settlement = booking.settlement;
    if (settlement?.finalOwnerPayoutAmount != null) {
      final components = settlement!.finalOwnerPayoutReleasedComponents;
      final basePayout = _numValue(components, 'baseOwnerGrossAmount');
      final depositCovered =
          _numValue(components, 'depositCoveredDamageAmount') ??
          _depositCoveredAmount();
      final paidOutstanding =
          _numValue(components, 'paidOutstandingDamageAmount') ??
          _paidOutstandingDamageAmount();
      final grossAmount =
          settlement.finalOwnerPayoutGrossAmount ??
          _positiveSum([basePayout, depositCovered, paidOutstanding]);
      final walletTransferFee = settlement.finalOwnerPayoutWalletTransferFee;

      return _OwnerPayoutCalculation(
        total: settlement.finalOwnerPayoutAmount!,
        rows: [
          if (basePayout != null)
            _OwnerPayoutCalculationRow(
              label: 'Base owner payout',
              amount: basePayout,
            ),
          if (_hasPositiveAmount(depositCovered))
            _OwnerPayoutCalculationRow(
              label: 'Security deposit deducted',
              amount: depositCovered!,
            ),
          if (_hasPositiveAmount(paidOutstanding))
            _OwnerPayoutCalculationRow(
              label: "Renter's outstanding balance paid",
              amount: paidOutstanding!,
            ),
          if (grossAmount != null)
            _OwnerPayoutCalculationRow(
              label: 'Gross payout',
              amount: grossAmount,
            ),
          if (_hasPositiveAmount(walletTransferFee))
            _OwnerPayoutCalculationRow(
              label: 'Wallet transfer fee',
              amount: walletTransferFee!,
              isDeduction: true,
            ),
          _OwnerPayoutCalculationRow(
            label: 'Your final payout',
            amount: settlement.finalOwnerPayoutAmount!,
            isTotal: true,
          ),
        ],
      );
    }

    final pricingBreakdown = booking.payment?.pricingBreakdown;
    final rentalSubtotal = _numValue(pricingBreakdown, 'rentalSubtotal');
    final processingFee = _numValue(
      pricingBreakdown,
      'ownerSecurityDepositPaymentFee',
    );
    final basePayout =
        _baseOwnerPayoutAmount() ??
        settlement?.ownerPayoutAmount ??
        booking.payment?.ownerPayoutAmount ??
        _numValue(booking.payment?.pricingBreakdown, 'ownerPayoutAmount');
    final depositCovered = _depositCoveredAmount();
    final paidOutstanding = _paidOutstandingDamageAmount();

    final total = <num?>[
      basePayout,
      depositCovered,
      paidOutstanding,
    ].whereType<num>().fold<num>(0, (sum, amount) => sum + amount);
    if (total <= 0) return null;

    return _OwnerPayoutCalculation(
      total: total,
      rows: [
        if (rentalSubtotal != null)
          _OwnerPayoutCalculationRow(
            label: 'Rental subtotal',
            amount: rentalSubtotal,
          ),
        if (_hasPositiveAmount(processingFee))
          _OwnerPayoutCalculationRow(
            label: 'Processing fee',
            amount: processingFee!,
          ),
        if (basePayout != null)
          _OwnerPayoutCalculationRow(
            label: 'Base payout subtotal',
            amount: basePayout,
          ),
        if (_hasPositiveAmount(depositCovered))
          _OwnerPayoutCalculationRow(
            label: 'Security deposit deducted',
            amount: depositCovered!,
          ),
        if (_hasPositiveAmount(paidOutstanding))
          _OwnerPayoutCalculationRow(
            label: "Renter's outstanding balance paid",
            amount: paidOutstanding!,
          ),
        _OwnerPayoutCalculationRow(
          label: 'Your final payout',
          amount: total,
          isTotal: true,
        ),
      ],
    );
  }

  num? _baseOwnerPayoutAmount() {
    final pricingBreakdown = booking.payment?.pricingBreakdown;
    final rentalSubtotal = _numValue(pricingBreakdown, 'rentalSubtotal');
    if (rentalSubtotal == null) return null;

    final securityDepositFee =
        _numValue(pricingBreakdown, 'ownerSecurityDepositPaymentFee') ?? 0;
    final base = rentalSubtotal + securityDepositFee;
    return base > 0 ? base : 0;
  }

  num? _depositCoveredAmount() {
    final settlement = booking.settlement;
    final request = booking.damageDeductionRequest;
    final amount = _firstAmount([
      settlement?.depositCoveredDamageAmount,
      request?.depositCoveredAmount,
      settlement?.approvedDamageDeductionAmount,
      request?.approvedAmount,
      request?.requestedAmount,
    ]);

    return _capToSecurityDeposit(amount);
  }

  num? _capToSecurityDeposit(num? amount) {
    if (amount == null || amount <= 0) return amount;

    final depositAmount =
        booking.securityDeposit.enabled ? booking.securityDeposit.amount : 0;
    if (depositAmount <= 0) return null;

    return amount > depositAmount ? depositAmount : amount;
  }

  num? _paidOutstandingDamageAmount() {
    final settlement = booking.settlement;
    return _firstAmount([
      _numValue(settlement?.damageBalancePayment, 'amount'),
      _numValue(
        settlement?.damageBalancePayment,
        'paidOutstandingDamageAmount',
      ),
      _numValue(settlement?.damageBalancePayment, 'paidOutstandingAmount'),
      booking.damageDeductionRequest?.paidOutstandingAmount,
    ]);
  }

  num? _ownerDisputeAmount() {
    final settlement = booking.settlement;
    final components = settlement?.finalOwnerPayoutReleasedComponents;
    final componentTotal = _positiveSum([
      _numValue(components, 'depositCoveredDamageAmount'),
      _numValue(components, 'paidOutstandingDamageAmount'),
    ]);
    if (_hasPositiveAmount(componentTotal)) return componentTotal;

    final splitTotal = _positiveSum([
      _depositCoveredAmount(),
      _paidOutstandingDamageAmount(),
    ]);
    if (_hasPositiveAmount(splitTotal)) return splitTotal;

    return _firstAmount([
      settlement?.approvedDamageDeductionAmount,
      booking.damageDeductionRequest?.approvedAmount,
      booking.damageDeductionRequest?.requestedAmount,
    ]);
  }

  num? _paymentFlowOwnerDisputeAmount(BookingDisputeFlow dispute) {
    final paidOutstanding =
        dispute.paidOutstandingAmount ??
        _numValue(dispute.outstandingPayment, 'amount') ??
        _numValue(dispute.outstandingPayment, 'paidOutstandingDamageAmount') ??
        _numValue(dispute.outstandingPayment, 'paidOutstandingAmount');
    final splitTotal = _positiveSum([
      dispute.depositCoveredAmount,
      paidOutstanding,
    ]);
    if (_hasPositiveAmount(splitTotal)) return splitTotal;

    return _firstAmount([dispute.approvedAmount, dispute.requestedAmount]);
  }

  num? _depositReturnFeeRemovedAmount(
    num? ownerDisputeAmount, {
    num? depositReturnAmount,
  }) {
    if (!_hasPositiveAmount(ownerDisputeAmount)) return null;
    if (!booking.securityDeposit.enabled ||
        booking.securityDeposit.amount <= 0) {
      return null;
    }

    final remainingDeposit =
        depositReturnAmount ?? booking.settlement?.depositReturnAmount;
    if (_hasPositiveAmount(remainingDeposit)) return null;

    final fee =
        booking.priceBreakdown.renterDepositReturnTransferFee ??
        _numValue(
          booking.payment?.pricingBreakdown,
          'renterDepositReturnTransferFee',
        );
    return _hasPositiveAmount(fee) ? fee : null;
  }

  void _showOwnerPayoutCalculationSheet(_OwnerPayoutCalculation calculation) {
    LNDShow.bottomSheet<void>(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDText.bold(text: 'Your payout calculation', fontSize: 18.0),
              const SizedBox(height: 8.0),
              LNDText.regular(
                text:
                    'This shows how the dispute-adjusted payout is calculated from the booking payout and approved damage settlement.',
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 16.0),
              BookingDetailsReceiptContainer(
                children:
                    calculation.rows
                        .map(
                          (row) => BookingDetailsReceiptRow(
                            label: row.label,
                            value:
                                row.isDeduction
                                    ? '-${_formatMoney(row.amount)}'
                                    : _formatMoney(row.amount),
                            isTotal: row.isTotal,
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static num? _positiveSum(Iterable<num?> values) {
    final amounts = values.whereType<num>().toList();
    if (amounts.isEmpty) return null;
    final total = amounts.fold<num>(0, (sum, amount) => sum + amount);
    return total > 0 ? total : null;
  }

  static bool _hasPositiveAmount(num? value) => value != null && value > 0;

  static bool _hasAmount(num? value) => value != null;

  static bool _hasNonEmptyMap(Map<String, dynamic>? value) {
    return value != null && value.isNotEmpty;
  }

  static bool _hasDisputeFlowSignal(BookingDisputeFlow? dispute) {
    if (dispute == null) return false;

    return _hasText(dispute.reason) ||
        _hasText(dispute.notes) ||
        dispute.evidenceUrls.isNotEmpty ||
        _hasText(dispute.renterResponse) ||
        _hasText(dispute.supportStatus) ||
        _hasText(dispute.adminNotes) ||
        _hasDamageStatus(dispute.status) ||
        _hasAmount(dispute.requestedAmount) ||
        _hasAmount(dispute.approvedAmount) ||
        _hasAmount(dispute.depositCoveredAmount) ||
        _hasAmount(dispute.outstandingAmount) ||
        _hasAmount(dispute.paidOutstandingAmount) ||
        _hasText(dispute.outstandingPaymentStatus) ||
        _hasText(dispute.outstandingPaymentRequestId) ||
        _hasNonEmptyMap(dispute.outstandingPayment);
  }

  static bool _hasDamageRequestSignal(DamageDeductionRequest? request) {
    if (request == null) return false;

    return _hasText(request.reason) ||
        request.evidenceUrls.isNotEmpty ||
        _hasText(request.renterResponse) ||
        _hasText(request.supportStatus) ||
        _hasText(request.adminNotes) ||
        _hasDamageStatus(request.status) ||
        _hasAmount(request.requestedAmount) ||
        _hasAmount(request.approvedAmount) ||
        _hasAmount(request.depositCoveredAmount) ||
        _hasAmount(request.outstandingAmount) ||
        _hasAmount(request.paidOutstandingAmount) ||
        request.requiresSupportReview == true ||
        request.overDepositRequested == true;
  }

  static bool _hasDamageSettlementSignal(Settlement? settlement) {
    if (settlement == null) return false;

    return _hasText(settlement.renterResponse) ||
        _hasText(settlement.adminNotes) ||
        _hasAmount(settlement.approvedDamageDeductionAmount) &&
            settlement.approvedDamageDeductionAmount != 0 ||
        _hasAmount(settlement.depositCoveredDamageAmount) &&
            settlement.depositCoveredDamageAmount != 0 ||
        _hasAmount(settlement.outstandingDamageAmount) &&
            settlement.outstandingDamageAmount != 0 ||
        _hasAmount(settlement.damageBalanceRequestedAmount) ||
        _hasText(settlement.damageBalancePaymentStatus) ||
        _hasText(settlement.damageBalancePaymentRequestId) ||
        _hasText(settlement.ownerDamageBalancePayoutStatus) ||
        _hasNonEmptyMap(settlement.damageBalancePayment) ||
        _hasNonEmptyMap(settlement.damageBalancePaymentRequests) ||
        _hasDamageComponentMap(settlement.finalOwnerPayoutReleasedComponents);
  }

  static bool _hasDamageComponentMap(Map<String, dynamic>? components) {
    if (components == null || components.isEmpty) return false;
    return _hasPositiveAmount(
          _numValue(components, 'depositCoveredDamageAmount'),
        ) ||
        _hasPositiveAmount(
          _numValue(components, 'paidOutstandingDamageAmount'),
        );
  }

  static bool _hasDamageStatus(String? value) {
    final status = value?.trim().toLowerCase();
    if (status == null || status.isEmpty) return false;
    return !{
      'completed',
      'complete',
      'resolved',
      'closed',
      'none',
      'not_required',
      'return_processing',
      'returned',
    }.contains(status);
  }

  static String _formatStatus(String value) {
    return value
        .trim()
        .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String? _firstText(Iterable<String?> values) {
    for (final value in values) {
      if (_hasText(value)) return value!.trim();
    }
    return null;
  }

  static num? _firstAmount(Iterable<num?> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  static num? _numValue(Map<String, dynamic>? map, String key) {
    final value = map?[key];
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  static bool _hasText(String? value) => value?.trim().isNotEmpty == true;
}

class _OwnerPayoutCalculation {
  const _OwnerPayoutCalculation({required this.total, required this.rows});

  final num total;
  final List<_OwnerPayoutCalculationRow> rows;
}

class _OwnerPayoutCalculationRow {
  const _OwnerPayoutCalculationRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isDeduction = false,
  });

  final String label;
  final num amount;
  final bool isTotal;
  final bool isDeduction;
}

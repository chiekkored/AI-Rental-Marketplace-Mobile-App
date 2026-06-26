import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/pricing_fee_helpers.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/country_data.helper.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class PricingFeeCalculatorSheet extends StatefulWidget {
  final String initialDailyRate;
  final String initialWeeklyRate;
  final String initialMonthlyRate;
  final String initialYearlyRate;
  final String initialDeposit;

  const PricingFeeCalculatorSheet({
    super.key,
    required this.initialDailyRate,
    required this.initialWeeklyRate,
    required this.initialMonthlyRate,
    required this.initialYearlyRate,
    required this.initialDeposit,
  });

  @override
  State<PricingFeeCalculatorSheet> createState() =>
      _PricingFeeCalculatorSheetState();
}

enum _PricingCalculatorRateMode {
  daily(label: 'Daily', inputLabel: 'Daily rate', quantityLabel: 'Days'),
  weekly(label: 'Weekly', inputLabel: 'Weekly rate', quantityLabel: 'Weeks'),
  monthly(
    label: 'Monthly',
    inputLabel: 'Monthly rate',
    quantityLabel: 'Months',
  ),
  yearly(label: 'Yearly', inputLabel: 'Yearly rate', quantityLabel: 'Years');

  final String label;
  final String inputLabel;
  final String quantityLabel;

  const _PricingCalculatorRateMode({
    required this.label,
    required this.inputLabel,
    required this.quantityLabel,
  });
}

class _PricingFeeCalculatorSheetState extends State<PricingFeeCalculatorSheet> {
  late final Map<_PricingCalculatorRateMode, TextEditingController>
  _rateControllers;
  late final TextEditingController _depositController;
  _PricingCalculatorRateMode _selectedRateMode =
      _PricingCalculatorRateMode.daily;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _rateControllers = {
      _PricingCalculatorRateMode.daily: TextEditingController(
        text: widget.initialDailyRate,
      ),
      _PricingCalculatorRateMode.weekly: TextEditingController(
        text: widget.initialWeeklyRate,
      ),
      _PricingCalculatorRateMode.monthly: TextEditingController(
        text: widget.initialMonthlyRate,
      ),
      _PricingCalculatorRateMode.yearly: TextEditingController(
        text: widget.initialYearlyRate,
      ),
    };
    _depositController = TextEditingController(text: widget.initialDeposit);
    for (final controller in _rateControllers.values) {
      controller.addListener(_refresh);
    }
    _depositController.addListener(_refresh);
  }

  @override
  void dispose() {
    for (final controller in _rateControllers.values) {
      controller
        ..removeListener(_refresh)
        ..dispose();
    }
    _depositController.removeListener(_refresh);
    _depositController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final policy = LNDRemoteConfigService.pricingPolicy;
    final rateController = _rateControllers[_selectedRateMode]!;
    final rate = _parseAmount(rateController.text);
    final rentalSubtotal = rate * _quantity;
    final deposit = _parseAmount(_depositController.text);
    final renterPlatformFee = policy.platformFee.calculate(rentalSubtotal);
    final totalBeforeProcessingFee =
        rentalSubtotal + renterPlatformFee + deposit;
    final ownerPayoutWalletFee = policy.walletTransferFee.calculate(
      rentalSubtotal,
    );
    final depositReturnWalletFee =
        deposit > 0 ? policy.walletTransferFee.calculate(deposit) : 0;
    final estimatedPayout = (rentalSubtotal -
            ownerPayoutWalletFee -
            depositReturnWalletFee)
        .clamp(0.0, rentalSubtotal);
    final depositPaymentFeeEstimates = pricingDepositPaymentFeeEstimates(
      deposit,
    );
    final rates = Rates(currency: LNDMoney.currentCurrencyCode());

    double minDepositFee = 0;
    double maxDepositFee = 0;
    double minFinalPayout = estimatedPayout;
    double maxFinalPayout = estimatedPayout;

    if (depositPaymentFeeEstimates.isNotEmpty) {
      minDepositFee = depositPaymentFeeEstimates
          .map((e) => e.amount)
          .reduce(min);
      maxDepositFee = depositPaymentFeeEstimates
          .map((e) => e.amount)
          .reduce(max);

      minFinalPayout = max(0, estimatedPayout - maxDepositFee);
      maxFinalPayout = max(0, estimatedPayout - minDepositFee);
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LNDText.bold(text: 'Owner fee calculator', fontSize: 18),
                const SizedBox(height: 8),
                LNDText.regular(
                  text:
                      'Processing fees help cover payment charges. Renters pay the booking processing fee and platform fee. Owners shoulder payment fees for collecting an enabled security deposit.',
                  color: colors.textMuted,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 16),
                _PricingRateModeSegment(
                  selected: _selectedRateMode,
                  onChanged: _setSelectedRateMode,
                ),
                const SizedBox(height: 12),
                LNDTextField.regular(
                  controller: rateController,
                  labelText: _selectedRateMode.inputLabel,
                  prefixText: _currencyPrefix(),
                  borderRadius: 12,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                PricingQuantityStepper(
                  label: _selectedRateMode.quantityLabel,
                  quantity: _quantity,
                  onDecrement: _decrementQuantity,
                  onIncrement: _incrementQuantity,
                ),
                const SizedBox(height: 12),
                LNDTextField.regular(
                  controller: _depositController,
                  labelText: 'Security deposit amount',
                  prefixText: _currencyPrefix(),
                  borderRadius: 12,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                LNDText.semibold(text: 'Renter fees'),
                const SizedBox(height: 8),

                if (deposit > 0) ...[
                  PricingCalculatorRow(
                    label: 'Rental subtotal',
                    value: LNDMoney.formatRate(rentalSubtotal, rates),
                  ),
                  PricingCalculatorRow(
                    label: 'Security deposit',
                    value: LNDMoney.formatRate(deposit, rates),
                  ),
                ],
                if (renterPlatformFee > 0)
                  PricingCalculatorRow(
                    label: 'Renter-paid platform fee',
                    value: LNDMoney.formatRate(renterPlatformFee, rates),
                  ),
                PricingCalculatorRow(
                  label: 'Total before processing fee',
                  value: LNDMoney.formatRate(totalBeforeProcessingFee, rates),
                  labelTrailing: LNDShow.tooltip(
                    message:
                        'Processing fees are calculated by renter\'s payment method',
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                LNDText.semibold(text: 'Your fees (Owner-paid)'),
                const SizedBox(height: 6),
                PricingCalculatorRow(
                  label: 'Owner payout fee',
                  value: '-${LNDMoney.formatRate(ownerPayoutWalletFee, rates)}',
                ),
                if (deposit > 0) ...[
                  PricingCalculatorRow(
                    label: 'Deposit return fee',
                    value:
                        '-${LNDMoney.formatRate(depositReturnWalletFee, rates)}',
                  ),
                  if (depositPaymentFeeEstimates.isNotEmpty)
                    PricingCalculatorRow(
                      label: 'Deposit processing fee',
                      value:
                          '-${LNDMoney.formatRate(minDepositFee, rates)} - '
                          '${LNDMoney.formatRate(maxDepositFee, rates)}',
                      labelTrailing: LNDShow.tooltip(
                        message:
                            'You, as the owner, will shoulder the payment '
                            'processing fee for the security deposit when you '
                            'return it to the renter. The actual fee amount '
                            'depends on the renter\'s payment method.',
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                PricingCalculatorRow(
                  label: 'Estimated payout',
                  value:
                      depositPaymentFeeEstimates.isNotEmpty
                          ? '${LNDMoney.formatRate(minFinalPayout, rates)} - '
                              '${LNDMoney.formatRate(maxFinalPayout, rates)}'
                          : LNDMoney.formatRate(estimatedPayout, rates),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _parseAmount(String value) {
    return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }

  String _currencyPrefix() {
    if (Get.isRegistered<CountryPreferenceController>()) {
      final prefix =
          CountryPreferenceController
              .instance
              .currencyCountry
              .value
              .currencyPrefix;
      if (prefix.trim().isNotEmpty) return prefix;
    }
    return LNDCountryData.fallbackCountry.currencyPrefix;
  }

  void _setSelectedRateMode(_PricingCalculatorRateMode mode) {
    setState(() {
      _selectedRateMode = mode;
      _quantity = 1;
    });
  }

  void _decrementQuantity() {
    if (_quantity <= 1) return;
    setState(() => _quantity--);
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }
}

class _PricingRateModeSegment extends StatelessWidget {
  final _PricingCalculatorRateMode selected;
  final ValueChanged<_PricingCalculatorRateMode> onChanged;

  const _PricingRateModeSegment({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<_PricingCalculatorRateMode>(
        showSelectedIcon: false,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? colors.primary
                    : colors.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? colors.textInverse
                    : colors.textPrimary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: colors.outline)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        segments:
            _PricingCalculatorRateMode.values
                .map(
                  (mode) => ButtonSegment<_PricingCalculatorRateMode>(
                    value: mode,
                    label: Text(mode.label),
                  ),
                )
                .toList(),
        selected: {selected},
        onSelectionChanged: (values) => onChanged(values.first),
      ),
    );
  }
}

class PricingQuantityStepper extends StatelessWidget {
  final String label;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const PricingQuantityStepper({
    super.key,
    required this.label,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: LNDText.regular(
              text: label,
              color: colors.textMuted,
              textAlign: TextAlign.start,
            ),
          ),
          _PricingStepperButton(
            icon: Icons.remove_rounded,
            enabled: quantity > 1,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 56,
            child: Center(
              child: LNDText.medium(text: quantity.toString(), fontSize: 18),
            ),
          ),
          _PricingStepperButton(
            icon: Icons.add_rounded,
            enabled: true,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _PricingStepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PricingStepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Material(
      color:
          enabled
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceMuted,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 36,
          width: 36,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? colors.primary : colors.textMuted,
          ),
        ),
      ),
    );
  }
}

class PricingCalculatorRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Widget? labelTrailing;

  const PricingCalculatorRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.labelTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: LNDText.regular(
                    text: label,
                    color: isTotal ? colors.textPrimary : colors.textMuted,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.visible,
                  ),
                ),
                if (labelTrailing != null) ...[
                  const SizedBox(width: 4),
                  labelTrailing!,
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          LNDText.medium(
            text: value,
            color: isTotal ? colors.textPrimary : colors.textMuted,
          ),
        ],
      ),
    );
  }
}

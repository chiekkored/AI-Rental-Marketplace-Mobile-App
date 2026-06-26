import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';
import 'package:lend/utilities/extensions/string.extension.dart';

class CreateListingPricingChunk implements CreateListingChunk {
  static const int weeklyRateMultiplier = 7;
  static const int monthlyRateMultiplier = 30;
  static const int annualRateMultiplier = 365;

  final formKey = GlobalKey<FormState>();

  final dailyPriceController = TextEditingController();
  final weeklyPriceController = TextEditingController();
  final monthlyPriceController = TextEditingController();
  final annualPriceController = TextEditingController();
  final securityDepositController = TextEditingController();

  final weeklyRateEnabled = false.obs;
  final monthlyRateEnabled = false.obs;
  final annualRateEnabled = false.obs;
  final securityDepositEnabled = false.obs;
  final canContinue = false.obs;

  bool _weeklyRateAutoFilled = false;
  bool _monthlyRateAutoFilled = false;
  bool _annualRateAutoFilled = false;
  bool _isApplyingAutoFill = false;

  late final List<Worker> _workers;

  @override
  void onInit() {
    dailyPriceController.addListener(_handleDailyRateChanged);
    weeklyPriceController.addListener(_handleWeeklyRateChanged);
    monthlyPriceController.addListener(_handleMonthlyRateChanged);
    annualPriceController.addListener(_handleAnnualRateChanged);
    securityDepositController.addListener(_updateCanContinue);

    _workers = [
      ever<bool>(weeklyRateEnabled, (_) => _updateCanContinue()),
      ever<bool>(monthlyRateEnabled, (_) => _updateCanContinue()),
      ever<bool>(annualRateEnabled, (_) => _updateCanContinue()),
      ever<bool>(securityDepositEnabled, (_) => _updateCanContinue()),
    ];

    _updateCanContinue();
  }

  bool get hasDailyRate => dailyRate != null;

  bool get hasWeeklyRate => weeklyRate != null;

  bool get hasMonthlyRate => monthlyRate != null;

  bool get hasAnnualRate => annualRate != null;

  bool get hasSecurityDepositAmount {
    final amount = securityDepositAmount;
    return amount != null && amount > 0;
  }

  int? get dailyRate => _parseOptionalRate(dailyPriceController);

  int? get weeklyRate => _parseOptionalRate(weeklyPriceController);

  int? get monthlyRate => _parseOptionalRate(monthlyPriceController);

  int? get annualRate => _parseOptionalRate(annualPriceController);

  int? get securityDepositAmount =>
      _parseOptionalRate(securityDepositController);

  bool validate() {
    return formKey.currentState?.validate() != false;
  }

  void setWeeklyRateEnabled(bool value) {
    weeklyRateEnabled.value = value;
    if (value) {
      _autoFillOptionalRateIfEmpty(
        controller: weeklyPriceController,
        multiplier: weeklyRateMultiplier,
        rateKind: _RateKind.weekly,
      );
    }
  }

  void setMonthlyRateEnabled(bool value) {
    monthlyRateEnabled.value = value;
    if (value) {
      _autoFillOptionalRateIfEmpty(
        controller: monthlyPriceController,
        multiplier: monthlyRateMultiplier,
        rateKind: _RateKind.monthly,
      );
    }
  }

  void setAnnualRateEnabled(bool value) {
    annualRateEnabled.value = value;
    if (value) {
      _autoFillOptionalRateIfEmpty(
        controller: annualPriceController,
        multiplier: annualRateMultiplier,
        rateKind: _RateKind.annual,
      );
    }
  }

  void _updateCanContinue() {
    canContinue.value =
        hasDailyRate &&
        (!weeklyRateEnabled.value || hasWeeklyRate) &&
        (!monthlyRateEnabled.value || hasMonthlyRate) &&
        (!annualRateEnabled.value || hasAnnualRate) &&
        (!securityDepositEnabled.value || hasSecurityDepositAmount);
  }

  void _handleDailyRateChanged() {
    _refreshAutoFilledRate(
      enabled: weeklyRateEnabled.value,
      shouldRefresh: _weeklyRateAutoFilled,
      controller: weeklyPriceController,
      multiplier: weeklyRateMultiplier,
    );
    _refreshAutoFilledRate(
      enabled: monthlyRateEnabled.value,
      shouldRefresh: _monthlyRateAutoFilled,
      controller: monthlyPriceController,
      multiplier: monthlyRateMultiplier,
    );
    _refreshAutoFilledRate(
      enabled: annualRateEnabled.value,
      shouldRefresh: _annualRateAutoFilled,
      controller: annualPriceController,
      multiplier: annualRateMultiplier,
    );
    _updateCanContinue();
  }

  void _handleOptionalRateChanged({required _RateKind rateKind}) {
    if (!_isApplyingAutoFill) {
      _setAutoFilled(rateKind, false);
    }
    _updateCanContinue();
  }

  void _handleWeeklyRateChanged() {
    _handleOptionalRateChanged(rateKind: _RateKind.weekly);
  }

  void _handleMonthlyRateChanged() {
    _handleOptionalRateChanged(rateKind: _RateKind.monthly);
  }

  void _handleAnnualRateChanged() {
    _handleOptionalRateChanged(rateKind: _RateKind.annual);
  }

  void _autoFillOptionalRateIfEmpty({
    required TextEditingController controller,
    required int multiplier,
    required _RateKind rateKind,
  }) {
    if (controller.text.trim().isNotEmpty) {
      _setAutoFilled(rateKind, false);
      _updateCanContinue();
      return;
    }

    final rate = dailyRate;
    if (rate == null) {
      _setAutoFilled(rateKind, true);
      _updateCanContinue();
      return;
    }

    _setAutoFilled(rateKind, true);
    _setControllerText(controller, _formatRateText(rate * multiplier));
    _updateCanContinue();
  }

  void _refreshAutoFilledRate({
    required bool enabled,
    required bool shouldRefresh,
    required TextEditingController controller,
    required int multiplier,
  }) {
    if (!enabled || !shouldRefresh) return;

    final rate = dailyRate;
    if (rate == null) {
      _setControllerText(controller, '');
      return;
    }

    _setControllerText(controller, _formatRateText(rate * multiplier));
  }

  void _setControllerText(TextEditingController controller, String text) {
    _isApplyingAutoFill = true;
    controller.text = text;
    controller.selection = TextSelection.collapsed(offset: text.length);
    _isApplyingAutoFill = false;
  }

  String _formatRateText(int value) {
    return value.toString().toMoney();
  }

  void _setAutoFilled(_RateKind rateKind, bool value) {
    switch (rateKind) {
      case _RateKind.weekly:
        _weeklyRateAutoFilled = value;
      case _RateKind.monthly:
        _monthlyRateAutoFilled = value;
      case _RateKind.annual:
        _annualRateAutoFilled = value;
    }
  }

  int? _parseOptionalRate(TextEditingController controller) {
    final value = controller.text.toNumber().trim();
    if (value.isEmpty) return null;
    final parsed = int.tryParse(value);
    return parsed != null && parsed > 0 ? parsed : null;
  }

  void populateFromAsset(Asset asset) {
    dailyPriceController.text = asset.rates?.daily?.toString() ?? '';
    _weeklyRateAutoFilled = false;
    _monthlyRateAutoFilled = false;
    _annualRateAutoFilled = false;
    weeklyRateEnabled.value = (asset.rates?.weekly ?? 0) > 0;
    weeklyPriceController.text =
        weeklyRateEnabled.value ? asset.rates!.weekly.toString() : '';
    monthlyRateEnabled.value = (asset.rates?.monthly ?? 0) > 0;
    monthlyPriceController.text =
        monthlyRateEnabled.value ? asset.rates!.monthly.toString() : '';
    annualRateEnabled.value = (asset.rates?.annually ?? 0) > 0;
    annualPriceController.text =
        annualRateEnabled.value ? asset.rates!.annually.toString() : '';
    securityDepositEnabled.value = asset.securityDeposit.enabled;
    securityDepositController.text =
        asset.securityDeposit.enabled
            ? asset.securityDeposit.amount.toString()
            : '';
  }

  Map<String, dynamic> toDraftMap() {
    return {
      'dailyPrice': dailyPriceController.text.trim(),
      'weeklyRateEnabled': weeklyRateEnabled.value,
      'weeklyPrice': weeklyPriceController.text.trim(),
      'weeklyRateAutoFilled': _weeklyRateAutoFilled,
      'monthlyRateEnabled': monthlyRateEnabled.value,
      'monthlyPrice': monthlyPriceController.text.trim(),
      'monthlyRateAutoFilled': _monthlyRateAutoFilled,
      'annualRateEnabled': annualRateEnabled.value,
      'annualPrice': annualPriceController.text.trim(),
      'annualRateAutoFilled': _annualRateAutoFilled,
      'securityDepositEnabled': securityDepositEnabled.value,
      'securityDepositAmount': securityDepositController.text.trim(),
    };
  }

  void loadFromDraft(Map<String, dynamic> draft) {
    dailyPriceController.text = draft['dailyPrice'] as String? ?? '';
    weeklyRateEnabled.value = draft['weeklyRateEnabled'] as bool? ?? false;
    weeklyPriceController.text = draft['weeklyPrice'] as String? ?? '';
    _weeklyRateAutoFilled = draft['weeklyRateAutoFilled'] as bool? ?? false;
    monthlyRateEnabled.value = draft['monthlyRateEnabled'] as bool? ?? false;
    monthlyPriceController.text = draft['monthlyPrice'] as String? ?? '';
    _monthlyRateAutoFilled = draft['monthlyRateAutoFilled'] as bool? ?? false;
    annualRateEnabled.value = draft['annualRateEnabled'] as bool? ?? false;
    annualPriceController.text = draft['annualPrice'] as String? ?? '';
    _annualRateAutoFilled = draft['annualRateAutoFilled'] as bool? ?? false;
    securityDepositEnabled.value =
        draft['securityDepositEnabled'] as bool? ?? false;
    securityDepositController.text =
        draft['securityDepositAmount'] as String? ?? '';
  }

  @override
  void onClose() {
    dailyPriceController.removeListener(_handleDailyRateChanged);
    weeklyPriceController.removeListener(_handleWeeklyRateChanged);
    monthlyPriceController.removeListener(_handleMonthlyRateChanged);
    annualPriceController.removeListener(_handleAnnualRateChanged);
    securityDepositController.removeListener(_updateCanContinue);

    for (final worker in _workers) {
      worker.dispose();
    }

    canContinue.close();
    weeklyRateEnabled.close();
    monthlyRateEnabled.close();
    annualRateEnabled.close();
    securityDepositEnabled.close();

    dailyPriceController.dispose();
    weeklyPriceController.dispose();
    monthlyPriceController.dispose();
    annualPriceController.dispose();
    securityDepositController.dispose();
  }
}

enum _RateKind { weekly, monthly, annual }

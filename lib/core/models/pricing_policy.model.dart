import 'dart:convert';
import 'dart:math';

class LNDFeeRule {
  final double rateBps;
  final double fixedAmount;
  final String calculation;
  final String? label;

  const LNDFeeRule({
    required this.rateBps,
    required this.fixedAmount,
    required this.calculation,
    this.label,
  });

  factory LNDFeeRule.fromMap(Map<String, dynamic> map) {
    return LNDFeeRule(
      rateBps: (map['rate_bps'] as num?)?.toDouble() ?? 0,
      fixedAmount: (map['fixed_amount'] as num?)?.toDouble() ?? 0,
      calculation: map['calculation'] as String? ?? 'rate_plus_fixed',
      label: map['label'] as String?,
    );
  }

  double calculate(num amount) {
    final rateAmount = (amount * rateBps) / 10000;
    final fixed = fixedAmount;
    return switch (calculation) {
      'rate_only' => rateAmount,
      'fixed_only' => fixed,
      'max_rate_or_fixed' => max(rateAmount, fixed).toDouble(),
      _ => rateAmount + fixed,
    };
  }

  String get percentLabel {
    final percent = rateBps / 100;
    if (percent == percent.roundToDouble()) {
      return '${percent.toStringAsFixed(0)}%';
    }
    return '${percent.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')}%';
  }
}

class LNDWalletTransferFee {
  final LNDFeeRule providerFee;
  final LNDFeeRule lendMarkup;

  const LNDWalletTransferFee({
    required this.providerFee,
    required this.lendMarkup,
  });

  factory LNDWalletTransferFee.fromMap(Map<String, dynamic> map) {
    final usesSplitShape =
        map['provider_fee'] is Map || map['lend_markup'] is Map;
    return LNDWalletTransferFee(
      providerFee: LNDFeeRule.fromMap(
        usesSplitShape && map['provider_fee'] is Map
            ? Map<String, dynamic>.from(map['provider_fee'] as Map)
            : map,
      ),
      lendMarkup:
          usesSplitShape && map['lend_markup'] is Map
              ? LNDFeeRule.fromMap(
                Map<String, dynamic>.from(map['lend_markup'] as Map),
              )
              : const LNDFeeRule(
                rateBps: 0,
                fixedAmount: 0,
                calculation: 'fixed_only',
              ),
    );
  }

  double calculate(num amount) =>
      providerFee.calculate(amount) + lendMarkup.calculate(amount);

  double get fixedAmount => providerFee.fixedAmount + lendMarkup.fixedAmount;

  double get rateBps => providerFee.rateBps + lendMarkup.rateBps;

  String get calculation =>
      providerFee.calculation == lendMarkup.calculation
          ? providerFee.calculation
          : 'rate_plus_fixed';
}

class LNDMethodFeeConfig {
  final String label;
  final LNDFeeRule? rule;
  final LNDFeeRule? domestic;
  final LNDFeeRule? international;
  final LNDFeeRule? defaultRule;
  final Map<String, LNDFeeRule> banks;

  const LNDMethodFeeConfig({
    required this.label,
    this.rule,
    this.domestic,
    this.international,
    this.defaultRule,
    this.banks = const {},
  });

  factory LNDMethodFeeConfig.fromMap(String method, Map<String, dynamic> map) {
    final label = map['label'] as String? ?? method;
    if (map['default'] is Map || map['banks'] is Map) {
      final rawBanks =
          map['banks'] is Map
              ? Map<String, dynamic>.from(map['banks'] as Map)
              : const <String, dynamic>{};
      return LNDMethodFeeConfig(
        label: label,
        defaultRule:
            map['default'] is Map
                ? LNDFeeRule.fromMap(
                  Map<String, dynamic>.from(map['default'] as Map),
                )
                : const LNDFeeRule(
                  rateBps: 0,
                  fixedAmount: 0,
                  calculation: 'rate_plus_fixed',
                ),
        banks: rawBanks.map(
          (key, value) => MapEntry(
            key,
            LNDFeeRule.fromMap(Map<String, dynamic>.from(value as Map)),
          ),
        ),
      );
    }

    if (map['domestic'] is Map || map['international'] is Map) {
      return LNDMethodFeeConfig(
        label: label,
        domestic:
            map['domestic'] is Map
                ? LNDFeeRule.fromMap(
                  Map<String, dynamic>.from(map['domestic'] as Map),
                )
                : null,
        international:
            map['international'] is Map
                ? LNDFeeRule.fromMap(
                  Map<String, dynamic>.from(map['international'] as Map),
                )
                : null,
      );
    }

    return LNDMethodFeeConfig(label: label, rule: LNDFeeRule.fromMap(map));
  }

  LNDFeeRule resolve({String? bankCode, bool useInternationalCard = false}) {
    final normalizedBankCode = bankCode?.trim().toLowerCase();
    if (normalizedBankCode != null && normalizedBankCode.isNotEmpty) {
      final bankRule = banks[normalizedBankCode];
      if (bankRule != null) return bankRule;
    }
    if (useInternationalCard) {
      return international ??
          domestic ??
          rule ??
          defaultRule ??
          const LNDFeeRule(
            rateBps: 0,
            fixedAmount: 0,
            calculation: 'rate_plus_fixed',
          );
    }
    return rule ??
        defaultRule ??
        domestic ??
        const LNDFeeRule(
          rateBps: 0,
          fixedAmount: 0,
          calculation: 'rate_plus_fixed',
        );
  }
}

class LNDResolvedPaymentFee {
  final String method;
  final String label;
  final String? bankCode;
  final LNDFeeRule rule;

  const LNDResolvedPaymentFee({
    required this.method,
    required this.label,
    required this.rule,
    this.bankCode,
  });
}

class LNDCancellationWindow {
  final double leadTimeRateBps;
  final double maxHours;

  const LNDCancellationWindow({
    required this.leadTimeRateBps,
    required this.maxHours,
  });

  factory LNDCancellationWindow.fromMap(Map<String, dynamic> map) {
    return LNDCancellationWindow(
      leadTimeRateBps: (map['lead_time_rate_bps'] as num).toDouble(),
      maxHours: (map['max_hours'] as num).toDouble(),
    );
  }
}

class LNDRetentionRule {
  final String type;
  final double rateBps;
  final double fixedAmount;

  const LNDRetentionRule({
    required this.type,
    required this.rateBps,
    required this.fixedAmount,
  });

  factory LNDRetentionRule.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;
    if (type != 'percentage' && type != 'fixed') {
      throw ArgumentError('Unsupported renter cancellation retention type');
    }
    return LNDRetentionRule(
      type: type,
      rateBps: (map['rate_bps'] as num?)?.toDouble() ?? 0,
      fixedAmount: (map['fixed_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LNDRenterCancellationPolicy {
  final LNDCancellationWindow fullRefundWindow;
  final LNDRetentionRule middleRetention;
  final LNDCancellationWindow noRefundWindow;
  final LNDRetentionRule noRefundRetention;

  const LNDRenterCancellationPolicy({
    required this.fullRefundWindow,
    required this.middleRetention,
    required this.noRefundWindow,
    required this.noRefundRetention,
  });

  factory LNDRenterCancellationPolicy.fromMap(Map<String, dynamic> map) {
    return LNDRenterCancellationPolicy(
      fullRefundWindow: LNDCancellationWindow.fromMap(
        Map<String, dynamic>.from(map['full_refund_window'] as Map),
      ),
      middleRetention: LNDRetentionRule.fromMap(
        Map<String, dynamic>.from(map['middle_retention'] as Map),
      ),
      noRefundWindow: LNDCancellationWindow.fromMap(
        Map<String, dynamic>.from(map['no_refund_window'] as Map),
      ),
      noRefundRetention: LNDRetentionRule.fromMap(
        Map<String, dynamic>.from(map['no_refund_retention'] as Map),
      ),
    );
  }
}

enum LNDRenterCancellationRefundTier { full, partial, none }

LNDRenterCancellationRefundTier currentRenterCancellationRefundTier({
  required LNDRenterCancellationPolicy policy,
  required DateTime createdAt,
  required DateTime startDate,
  DateTime? now,
}) {
  if (!createdAt.isBefore(startDate)) {
    throw ArgumentError('Booking is missing valid cancellation policy dates');
  }

  final policyStartDate = renterCancellationPolicyStartBoundary(startDate);
  final leadTime = max(policyStartDate.difference(createdAt).inMilliseconds, 0);
  final shortLeadNoRefund = leadTime < const Duration(hours: 24).inMilliseconds;
  final fullRefundWindow = policyWindowDuration(
    policy.fullRefundWindow,
    leadTime / Duration.millisecondsPerHour,
  );
  final noRefundWindow =
      shortLeadNoRefund
          ? Duration(milliseconds: leadTime)
          : policyWindowDuration(
            policy.noRefundWindow,
            leadTime / Duration.millisecondsPerHour,
          );
  final requestedAt = now ?? DateTime.now();
  final fullRefundUntil = createdAt.add(fullRefundWindow);
  final noRefundStartsAt = policyStartDate.subtract(noRefundWindow);

  if (shortLeadNoRefund || !requestedAt.isBefore(noRefundStartsAt)) {
    return LNDRenterCancellationRefundTier.none;
  }

  if (!requestedAt.isAfter(fullRefundUntil)) {
    return LNDRenterCancellationRefundTier.full;
  }

  return LNDRenterCancellationRefundTier.partial;
}

DateTime renterCancellationPolicyStartBoundary(DateTime startDate) {
  final utcDate = startDate.toUtc();
  return DateTime.utc(
    utcDate.year,
    utcDate.month,
    utcDate.day,
  ).subtract(const Duration(hours: 8));
}

String currentRenterCancellationRefundPolicyText(
  LNDRenterCancellationRefundTier tier,
) {
  return switch (tier) {
    LNDRenterCancellationRefundTier.full =>
      'Current refund policy: Full rental refund if cancellation is approved. Processing fees are not included in refunds.',
    LNDRenterCancellationRefundTier.partial =>
      'Current refund policy: Partial rental refund if cancellation is approved. Processing fees are not included in refunds.',
    LNDRenterCancellationRefundTier.none =>
      'Current refund policy: No rental refund if cancellation is approved. Processing fees are not included in refunds.',
  };
}

String cancellationPolicyText({
  required LNDRenterCancellationPolicy policy,
  required DateTime startDate,
  required bool isNonRefundableMethod,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final lead = startDate.difference(effectiveNow);
  final leadHours = lead.inMilliseconds / Duration.millisecondsPerHour;

  if (isNonRefundableMethod) {
    return 'Cancellation policy: This payment method is non-refundable. If your cancellation is approved, the owner may keep the rental payment, but your security deposit remains fully refundable through support.';
  }

  if (leadHours < 24) {
    return 'Cancellation policy: This rental starts in less than 24 hours, so the rental payment is non-refundable if cancellation is approved. Security deposit is fully refundable if it exists.';
  }

  final fullRefundWindow = policyWindowDuration(
    policy.fullRefundWindow,
    leadHours,
  );
  final noRefundWindow = policyWindowDuration(policy.noRefundWindow, leadHours);
  final fullRefundLabel = formatPolicyDuration(fullRefundWindow);
  final noRefundLabel = formatPolicyDuration(noRefundWindow);

  return 'Cancellation policy:\n\n· Full refund within $fullRefundLabel after booking.\n· 50% refund after that until the final $noRefundLabel before the rental starts.\n· No rental refund during the final $noRefundLabel.\n· Security deposit is fully refundable if it exists.';
}

Duration policyWindowDuration(LNDCancellationWindow window, double leadHours) {
  final rateHours = leadHours * (window.leadTimeRateBps / 10000);
  final hours = min(rateHours, window.maxHours).clamp(0, double.infinity);
  return Duration(minutes: (hours * 60).round());
}

String formatPolicyDuration(Duration duration) {
  final hours = duration.inMinutes / 60;
  if (hours < 24) {
    final roundedHours = max(hours.round(), 1);
    return '$roundedHours ${roundedHours == 1 ? 'hour' : 'hours'}';
  }
  final days = max((hours / 24).round(), 1);
  return '$days ${days == 1 ? 'day' : 'days'}';
}

class LNDPricingPolicy {
  final Map<String, LNDMethodFeeConfig> paymentMethodFees;
  final double paymentMethodFeeVatRateBps;
  final LNDFeeRule platformFee;
  final LNDRenterCancellationPolicy renterCancellationPolicy;
  final LNDWalletTransferFee walletTransferFee;

  const LNDPricingPolicy({
    required this.paymentMethodFees,
    required this.paymentMethodFeeVatRateBps,
    required this.platformFee,
    required this.renterCancellationPolicy,
    required this.walletTransferFee,
  });

  factory LNDPricingPolicy.fromJson(String value) {
    return LNDPricingPolicy.fromMap(
      Map<String, dynamic>.from(json.decode(value) as Map),
    );
  }

  factory LNDPricingPolicy.fromMap(Map<String, dynamic> map) {
    final rawMethodFees =
        map['payment_method_fees'] is Map
            ? Map<String, dynamic>.from(map['payment_method_fees'] as Map)
            : _legacyMethodFees(map['renter_processing_fee']);
    return LNDPricingPolicy(
      paymentMethodFees: rawMethodFees.map(
        (key, value) => MapEntry(
          key,
          LNDMethodFeeConfig.fromMap(
            key,
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      ),
      paymentMethodFeeVatRateBps:
          (map['payment_method_fee_vat_rate_bps'] as num?)?.toDouble() ?? 1200,
      platformFee:
          map['platform_fee'] is Map
              ? LNDFeeRule.fromMap(
                Map<String, dynamic>.from(map['platform_fee'] as Map),
              )
              : const LNDFeeRule(
                rateBps: 0,
                fixedAmount: 0,
                calculation: 'rate_plus_fixed',
              ),
      renterCancellationPolicy: LNDRenterCancellationPolicy.fromMap(
        Map<String, dynamic>.from(map['renter_cancellation_policy'] as Map),
      ),
      walletTransferFee:
          map['wallet_transfer_fee'] is Map
              ? LNDWalletTransferFee.fromMap(
                Map<String, dynamic>.from(map['wallet_transfer_fee'] as Map),
              )
              : const LNDWalletTransferFee(
                providerFee: LNDFeeRule(
                  rateBps: 0,
                  fixedAmount: 10,
                  calculation: 'fixed_only',
                ),
                lendMarkup: LNDFeeRule(
                  rateBps: 0,
                  fixedAmount: 0,
                  calculation: 'fixed_only',
                ),
              ),
    );
  }

  static Map<String, dynamic> _legacyMethodFees(dynamic renterProcessingFee) {
    final legacy =
        renterProcessingFee is Map
            ? Map<String, dynamic>.from(renterProcessingFee)
            : const {
              'rate_bps': 0,
              'fixed_amount': 0,
              'calculation': 'rate_plus_fixed',
            };
    return {
      'card': {'label': 'Cards', 'domestic': legacy, 'international': legacy},
      'gcash': {'label': 'GCash', ...legacy},
      'paymaya': {'label': 'Maya', ...legacy},
      'grab_pay': {'label': 'GrabPay', ...legacy},
      'shopeepay': {'label': 'ShopeePay', ...legacy},
      'qrph': {'label': 'QR Ph', ...legacy},
      'dob': {'label': 'Direct Online Banking', 'default': legacy, 'banks': {}},
      'brankas': {
        'label': 'Direct Online Banking',
        'default': legacy,
        'banks': {},
      },
    };
  }

  LNDResolvedPaymentFee resolvePaymentMethodFee({
    required String method,
    Map<String, dynamic> details = const {},
    String? payerCountryShortName,
  }) {
    final config = paymentMethodFees[method];
    final bankCode = details['bank_code']?.toString();
    if (config == null) {
      return LNDResolvedPaymentFee(
        method: method,
        label: method,
        bankCode: bankCode,
        rule: const LNDFeeRule(
          rateBps: 0,
          fixedAmount: 0,
          calculation: 'rate_plus_fixed',
        ),
      );
    }

    return LNDResolvedPaymentFee(
      method: method,
      label: config.label,
      bankCode: bankCode,
      rule: config.resolve(
        bankCode: bankCode,
        useInternationalCard: _usesInternationalCardFee(
          method: method,
          payerCountryShortName: payerCountryShortName,
        ),
      ),
    );
  }

  double calculatePaymentMethodFee(num amount, LNDFeeRule rule) {
    final fee = rule.calculate(amount);
    final withVat = fee * (1 + paymentMethodFeeVatRateBps / 10000);
    return (withVat * 100).roundToDouble() / 100;
  }
}

bool _usesInternationalCardFee({
  required String method,
  required String? payerCountryShortName,
}) {
  if (method != 'card') return false;
  final country = payerCountryShortName?.trim().toUpperCase();
  return country != null && country.isNotEmpty && country != 'PH';
}

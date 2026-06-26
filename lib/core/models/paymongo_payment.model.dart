import 'dart:convert';

enum LNDPaymongoPaymentKind { newCard, savedCard, redirect, qr }

class LNDSavedPaymentMethod {
  final String id;
  final String? paymentMethodId;
  final String type;
  final String? sessionType;
  final int? createdAt;
  final String? brand;
  final String? last4;
  final String? cardNumber;
  final int? expMonth;
  final int? expYear;
  final String? subtitle;
  final bool isLocal;
  final bool shouldSaveCard;

  const LNDSavedPaymentMethod({
    required this.id,
    required this.paymentMethodId,
    required this.type,
    required this.sessionType,
    required this.createdAt,
    this.brand,
    this.last4,
    this.cardNumber,
    this.expMonth,
    this.expYear,
    this.subtitle,
    this.isLocal = false,
    this.shouldSaveCard = false,
  });

  factory LNDSavedPaymentMethod.fromMap(Map<String, dynamic> map) {
    final details =
        map['details'] is Map
            ? Map<String, dynamic>.from(map['details'] as Map)
            : const <String, dynamic>{};
    final card =
        map['card'] is Map
            ? Map<String, dynamic>.from(map['card'] as Map)
            : const <String, dynamic>{};

    return LNDSavedPaymentMethod(
      id: map['id'] as String,
      paymentMethodId: map['paymentMethodId'] as String?,
      type: map['type'] as String? ?? 'card',
      sessionType: map['sessionType'] as String?,
      createdAt: map['createdAt'] as int?,
      brand:
          map['brand'] as String? ??
          details['brand'] as String? ??
          card['brand'] as String?,
      last4:
          map['last4'] as String? ??
          details['last4'] as String? ??
          card['last4'] as String?,
      expMonth:
          map['expMonth'] as int? ??
          details['exp_month'] as int? ??
          card['exp_month'] as int?,
      expYear:
          map['expYear'] as int? ??
          details['exp_year'] as int? ??
          card['exp_year'] as int?,
      subtitle: map['subtitle'] as String?,
    );
  }

  factory LNDSavedPaymentMethod.localCard({
    required String localId,
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required bool shouldSaveCard,
    String? subtitle,
  }) {
    final normalized = cardNumber.replaceAll(RegExp(r'\s+'), '');
    return LNDSavedPaymentMethod(
      id: localId,
      paymentMethodId: null,
      type: 'card',
      sessionType: null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      brand: LNDCardBrand.detect(normalized).label,
      last4:
          normalized.length >= 4
              ? normalized.substring(normalized.length - 4)
              : normalized,
      cardNumber: normalized,
      expMonth: expMonth,
      expYear: expYear,
      subtitle: subtitle,
      isLocal: true,
      shouldSaveCard: shouldSaveCard,
    );
  }

  String get displayLabel {
    final normalizedBrand = brand?.trim();
    final resolvedLast4 = last4?.trim();
    if (normalizedBrand != null &&
        normalizedBrand.isNotEmpty &&
        resolvedLast4 != null &&
        resolvedLast4.isNotEmpty) {
      return '$normalizedBrand •••• $resolvedLast4';
    }
    if (resolvedLast4 != null && resolvedLast4.isNotEmpty) {
      return 'Card •••• $resolvedLast4';
    }
    return paymentMethodId ?? id;
  }

  bool get isDebugPayMongoTestCard => id.startsWith('debug_paymongo_');
}

class LNDSelectedPaymentMethod {
  final LNDPaymongoPaymentKind kind;
  final String methodType;
  final String label;
  final Map<String, dynamic> details;
  final bool shouldSaveCard;
  final String? cardNumber;
  final int? expMonth;
  final int? expYear;
  final String? cvc;
  final String? customerPaymentMethodId;
  final String? localCardId;
  final String? brand;
  final String? last4;
  final String? logoAsset;

  const LNDSelectedPaymentMethod({
    required this.kind,
    required this.methodType,
    required this.label,
    this.details = const {},
    this.shouldSaveCard = false,
    this.cardNumber,
    this.expMonth,
    this.expYear,
    this.cvc,
    this.customerPaymentMethodId,
    this.localCardId,
    this.brand,
    this.last4,
    this.logoAsset,
  });

  bool get isCard =>
      kind == LNDPaymongoPaymentKind.newCard ||
      kind == LNDPaymongoPaymentKind.savedCard;

  bool get isDebugPayMongoTestCard =>
      localCardId?.startsWith('debug_paymongo_') == true;

  bool get isRecurringBillingSupported => true;

  Map<String, dynamic> get serverDetails {
    return {
      ...details,
      if (brand != null && brand!.trim().isNotEmpty) 'card_brand': brand,
      if (last4 != null && last4!.trim().isNotEmpty) 'last4': last4,
    };
  }

  static LNDSelectedPaymentMethod newCard({
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
    required bool shouldSaveCard,
    String? localCardId,
  }) {
    final normalized = cardNumber.replaceAll(RegExp(r'\s+'), '');
    return LNDSelectedPaymentMethod(
      kind: LNDPaymongoPaymentKind.newCard,
      methodType: 'card',
      label: 'New card',
      cardNumber: normalized,
      expMonth: expMonth,
      expYear: expYear,
      cvc: cvc,
      shouldSaveCard: shouldSaveCard,
      localCardId: localCardId,
      brand: LNDCardBrand.detect(normalized).label,
      last4:
          normalized.length >= 4
              ? normalized.substring(normalized.length - 4)
              : normalized,
    );
  }

  static LNDSelectedPaymentMethod savedCard({
    required LNDSavedPaymentMethod savedMethod,
    required String cvc,
  }) {
    return LNDSelectedPaymentMethod(
      kind: LNDPaymongoPaymentKind.savedCard,
      methodType: 'card',
      label: savedMethod.displayLabel,
      customerPaymentMethodId: savedMethod.id,
      cvc: cvc,
      brand: savedMethod.brand,
      last4: savedMethod.last4,
    );
  }

  static LNDSelectedPaymentMethod channel({
    required String methodType,
    required String label,
    Map<String, dynamic> details = const {},
    LNDPaymongoPaymentKind kind = LNDPaymongoPaymentKind.redirect,
    String? logoAsset,
  }) {
    return LNDSelectedPaymentMethod(
      kind: kind,
      methodType: methodType,
      label: label,
      details: details,
      logoAsset: logoAsset,
    );
  }

  String get displayLabel {
    if (!isCard) return label;
    final normalizedBrand = brand?.trim();
    final resolvedLast4 =
        last4 ??
        (cardNumber != null && cardNumber!.length >= 4
            ? cardNumber!.substring(cardNumber!.length - 4)
            : null);
    if (normalizedBrand != null &&
        normalizedBrand.isNotEmpty &&
        resolvedLast4 != null &&
        resolvedLast4.isNotEmpty) {
      return '$normalizedBrand •••• $resolvedLast4';
    }
    if (resolvedLast4 != null && resolvedLast4.isNotEmpty) {
      return 'Card •••• $resolvedLast4';
    }
    return label;
  }
}

enum LNDCardBrand {
  visa('Visa'),
  mastercard('Mastercard'),
  amex('Amex'),
  discover('Discover'),
  jcb('JCB'),
  card('Card');

  final String label;

  const LNDCardBrand(this.label);

  static LNDCardBrand detect(String number) {
    final normalized = number.replaceAll(RegExp(r'\D'), '');
    if (normalized.startsWith('4')) return LNDCardBrand.visa;
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(normalized)) {
      return LNDCardBrand.mastercard;
    }
    if (RegExp(r'^3[47]').hasMatch(normalized)) return LNDCardBrand.amex;
    if (RegExp(r'^(6011|65|64[4-9])').hasMatch(normalized)) {
      return LNDCardBrand.discover;
    }
    if (RegExp(r'^35').hasMatch(normalized)) return LNDCardBrand.jcb;
    return LNDCardBrand.card;
  }

  static LNDCardBrand fromLabel(String? label) {
    final normalized = label?.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    return switch (normalized) {
      'visa' => LNDCardBrand.visa,
      'mastercard' || 'master' => LNDCardBrand.mastercard,
      'amex' || 'americanexpress' => LNDCardBrand.amex,
      'discover' => LNDCardBrand.discover,
      'jcb' => LNDCardBrand.jcb,
      _ => LNDCardBrand.card,
    };
  }
}

class LNDPaymentCheckout {
  final String checkoutId;
  final String paymentIntentId;
  final String clientKey;
  final String publicKey;
  final String returnUrl;
  final int? checkoutLockExpiresAtMs;
  final num? amount;
  final num? paymentAmount;
  final num? renterProcessingFee;
  final int? paymongoPaymentAmount;
  final Map<String, dynamic>? pricingBreakdown;
  final Map<String, dynamic>? billingPlan;
  final bool isRecurringBilling;

  const LNDPaymentCheckout({
    required this.checkoutId,
    required this.paymentIntentId,
    required this.clientKey,
    required this.publicKey,
    required this.returnUrl,
    this.checkoutLockExpiresAtMs,
    this.amount,
    this.paymentAmount,
    this.renterProcessingFee,
    this.paymongoPaymentAmount,
    this.pricingBreakdown,
    this.billingPlan,
    this.isRecurringBilling = false,
  });

  factory LNDPaymentCheckout.fromMap(Map<String, dynamic> map) {
    return LNDPaymentCheckout(
      checkoutId: map['checkoutId'] as String,
      paymentIntentId: map['paymentIntentId'] as String,
      clientKey: map['clientKey'] as String,
      publicKey: map['publicKey'] as String,
      returnUrl: map['returnUrl'] as String,
      checkoutLockExpiresAtMs: map['checkoutLockExpiresAtMs'] as int?,
      amount: map['amount'] as num?,
      paymentAmount: map['paymentAmount'] as num?,
      renterProcessingFee: map['renterProcessingFee'] as num?,
      paymongoPaymentAmount: map['paymongoPaymentAmount'] as int?,
      pricingBreakdown:
          map['pricingBreakdown'] is Map
              ? Map<String, dynamic>.from(map['pricingBreakdown'] as Map)
              : null,
      billingPlan:
          map['billingPlan'] is Map
              ? Map<String, dynamic>.from(map['billingPlan'] as Map)
              : null,
      isRecurringBilling: map['isRecurringBilling'] == true,
    );
  }
}

class LNDPendingPaymentMarker {
  final String checkoutId;
  final String assetId;
  final int createdAtMs;
  final int? checkoutLockExpiresAtMs;

  const LNDPendingPaymentMarker({
    required this.checkoutId,
    required this.assetId,
    required this.createdAtMs,
    this.checkoutLockExpiresAtMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'checkoutId': checkoutId,
      'assetId': assetId,
      'createdAtMs': createdAtMs,
      'checkoutLockExpiresAtMs': checkoutLockExpiresAtMs,
    }..removeWhere((key, value) => value == null);
  }

  factory LNDPendingPaymentMarker.fromMap(Map<String, dynamic> map) {
    return LNDPendingPaymentMarker(
      checkoutId: map['checkoutId'] as String,
      assetId: map['assetId'] as String,
      createdAtMs: map['createdAtMs'] as int? ?? 0,
      checkoutLockExpiresAtMs: map['checkoutLockExpiresAtMs'] as int?,
    );
  }
}

class LNDPendingPaymentRecovery {
  final bool hasPendingCheckout;
  final String status;
  final String? paymentStatus;
  final String? bookingId;
  final String? chatId;
  final Map<String, dynamic>? checkout;
  final Map<String, dynamic>? asset;
  final Map<String, dynamic>? nextAction;
  final Map<String, dynamic>? lastPaymentError;

  const LNDPendingPaymentRecovery({
    required this.hasPendingCheckout,
    required this.status,
    this.paymentStatus,
    this.bookingId,
    this.chatId,
    this.checkout,
    this.asset,
    this.nextAction,
    this.lastPaymentError,
  });

  bool get isBooked => status == 'booked' && bookingId != null;
  bool get isPaid => status == 'paid';

  bool get isTerminal =>
      status == 'booked' ||
      status == 'failed' ||
      status == 'expired' ||
      status == 'cancelled';

  factory LNDPendingPaymentRecovery.fromMap(Map<String, dynamic> map) {
    final checkout =
        map['checkout'] is Map
            ? Map<String, dynamic>.from(map['checkout'] as Map)
            : null;
    return LNDPendingPaymentRecovery(
      hasPendingCheckout: map['hasPendingCheckout'] == true,
      status:
          map['status'] as String? ??
          checkout?['status'] as String? ??
          (map['hasPendingCheckout'] == true ? 'processing' : 'none'),
      paymentStatus:
          map['paymentStatus'] as String? ??
          checkout?['paymentStatus'] as String?,
      bookingId: map['bookingId'] as String?,
      chatId: map['chatId'] as String?,
      checkout: checkout,
      asset:
          map['asset'] is Map
              ? Map<String, dynamic>.from(map['asset'] as Map)
              : null,
      nextAction:
          map['nextAction'] is Map
              ? Map<String, dynamic>.from(map['nextAction'] as Map)
              : checkout?['nextAction'] is Map
              ? Map<String, dynamic>.from(checkout?['nextAction'] as Map)
              : null,
      lastPaymentError:
          map['lastPaymentError'] is Map
              ? Map<String, dynamic>.from(map['lastPaymentError'] as Map)
              : null,
    );
  }
}

class LNDPaymentSyncResult {
  final String status;
  final String? paymentStatus;
  final String? bookingId;
  final String? chatId;
  final Map<String, dynamic>? nextAction;
  final Map<String, dynamic>? lastPaymentError;

  const LNDPaymentSyncResult({
    required this.status,
    this.paymentStatus,
    this.bookingId,
    this.chatId,
    this.nextAction,
    this.lastPaymentError,
  });

  bool get isBooked => status == 'booked' && bookingId != null;
  bool get isPaid => status == 'paid';

  factory LNDPaymentSyncResult.fromMap(Map<String, dynamic> map) {
    return LNDPaymentSyncResult(
      status: map['status'] as String? ?? 'unknown',
      paymentStatus: map['paymentStatus'] as String?,
      bookingId: map['bookingId'] as String?,
      chatId: map['chatId'] as String?,
      nextAction:
          map['nextAction'] is Map
              ? Map<String, dynamic>.from(map['nextAction'] as Map)
              : null,
      lastPaymentError:
          map['lastPaymentError'] is Map
              ? Map<String, dynamic>.from(map['lastPaymentError'] as Map)
              : null,
    );
  }
}

class LNDPaymentCheckoutStatus {
  final String id;
  final String status;
  final String? paymentStatus;
  final String? bookingId;
  final String? chatId;
  final Map<String, dynamic>? lastPaymentError;
  final String? lastWebhookEvent;

  const LNDPaymentCheckoutStatus({
    required this.id,
    required this.status,
    this.paymentStatus,
    this.bookingId,
    this.chatId,
    this.lastPaymentError,
    this.lastWebhookEvent,
  });

  bool get isBooked => status == 'booked' && bookingId != null;
  bool get isPaid => status == 'paid';

  bool get isTerminalFailure =>
      status == 'failed' || status == 'expired' || status == 'cancelled';

  factory LNDPaymentCheckoutStatus.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return LNDPaymentCheckoutStatus(
      id: id,
      status: map['status'] as String? ?? 'unknown',
      paymentStatus: map['paymentStatus'] as String?,
      bookingId: map['bookingId'] as String?,
      chatId: map['chatId'] as String?,
      lastPaymentError:
          map['lastPaymentError'] is Map
              ? Map<String, dynamic>.from(map['lastPaymentError'] as Map)
              : null,
      lastWebhookEvent: map['lastWebhookEvent'] as String?,
    );
  }
}

class LNDPayoutDestination {
  final String destinationType;
  final String provider;
  final String bankId;
  final String bankCode;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final List<String> supportedProviders;

  const LNDPayoutDestination({
    this.destinationType = 'bank',
    required this.provider,
    required this.bankId,
    required this.bankCode,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    this.supportedProviders = const <String>[],
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationType': destinationType,
      'provider': provider,
      'bankId': bankId,
      'bankCode': bankCode,
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'supportedProviders': supportedProviders,
    };
  }

  factory LNDPayoutDestination.fromMap(Map<String, dynamic> map) {
    return LNDPayoutDestination(
      destinationType: map['destinationType'] as String? ?? 'bank',
      provider: map['provider'] as String? ?? 'instapay',
      bankId: map['bankId'] as String? ?? '',
      bankCode: map['bankCode'] as String? ?? '',
      bankName: map['bankName'] as String? ?? '',
      accountName: map['accountName'] as String? ?? '',
      accountNumber: map['accountNumber'] as String? ?? '',
      supportedProviders:
          (map['supportedProviders'] as List?)
              ?.map((provider) => provider.toString())
              .toList(growable: false) ??
          const <String>[],
    );
  }

  String toJson() => json.encode(toMap());
}

class LNDPaymentDestinations {
  final LNDPayoutDestination? payoutDestination;
  final LNDPayoutDestination? depositReturnDestination;

  const LNDPaymentDestinations({
    required this.payoutDestination,
    required this.depositReturnDestination,
  });
}

class LNDPayoutInstitution {
  final String id;
  final String code;
  final String name;
  final String destinationType;
  final List<String> supportedProviders;

  const LNDPayoutInstitution({
    required this.id,
    required this.code,
    required this.name,
    required this.destinationType,
    required this.supportedProviders,
  });

  factory LNDPayoutInstitution.fromMap(Map<String, dynamic> map) {
    return LNDPayoutInstitution(
      id: map['id'] as String? ?? '',
      code: map['code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      destinationType: map['destinationType'] as String? ?? 'bank',
      supportedProviders:
          (map['supportedProviders'] as List?)
              ?.map((provider) => provider.toString())
              .toList(growable: false) ??
          const <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'destinationType': destinationType,
      'supportedProviders': supportedProviders,
    };
  }
}

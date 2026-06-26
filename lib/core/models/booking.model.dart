// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/models/token.model.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';

class Booking {
  String? id;
  String? chatId;
  Asset? asset;
  Timestamp? createdAt;
  Timestamp? startDate;
  Timestamp? endDate;
  int? numDays;
  Payment? payment;
  BookingPaymentFlow? paymentFlow;
  Map<String, dynamic>? billingPlan;
  BookingPriceBreakdown priceBreakdown;
  SimpleUserModel? renter;
  BookingStatus? status;
  int? totalPrice;
  Token? tokens;
  SecurityDeposit securityDeposit;
  BookingDepositFlow? depositFlow;
  BookingDisputeFlow? disputeFlow;
  BookingPayoutFlow? payoutFlow;
  BookingCancellationRequest? cancellationRequest;
  Settlement? settlement;
  DamageDeductionRequest? damageDeductionRequest;
  Booking({
    required this.id,
    required this.chatId,
    required this.asset,
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.numDays,
    required this.payment,
    this.paymentFlow,
    this.billingPlan,
    this.priceBreakdown = const BookingPriceBreakdown(),
    required this.renter,
    required this.status,
    required this.totalPrice,
    this.tokens,
    this.securityDeposit = const SecurityDeposit.disabled(),
    this.depositFlow,
    this.disputeFlow,
    this.payoutFlow,
    this.cancellationRequest,
    this.settlement,
    this.damageDeductionRequest,
  });

  Booking copyWith({
    String? id,
    String? chatId,
    Asset? asset,
    Timestamp? createdAt,
    Timestamp? startDate,
    Timestamp? endDate,
    int? numDays,
    Payment? payment,
    BookingPaymentFlow? paymentFlow,
    Map<String, dynamic>? billingPlan,
    BookingPriceBreakdown? priceBreakdown,
    SimpleUserModel? renter,
    BookingStatus? status,
    int? totalPrice,
    Token? tokens,
    SecurityDeposit? securityDeposit,
    BookingDepositFlow? depositFlow,
    BookingDisputeFlow? disputeFlow,
    BookingPayoutFlow? payoutFlow,
    BookingCancellationRequest? cancellationRequest,
    Settlement? settlement,
    DamageDeductionRequest? damageDeductionRequest,
  }) {
    return Booking(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      asset: asset ?? this.asset,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numDays: numDays ?? this.numDays,
      payment: payment ?? this.payment,
      paymentFlow: paymentFlow ?? this.paymentFlow,
      billingPlan: billingPlan ?? this.billingPlan,
      priceBreakdown: priceBreakdown ?? this.priceBreakdown,
      renter: renter ?? this.renter,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      tokens: tokens ?? this.tokens,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      depositFlow: depositFlow ?? this.depositFlow,
      disputeFlow: disputeFlow ?? this.disputeFlow,
      payoutFlow: payoutFlow ?? this.payoutFlow,
      cancellationRequest: cancellationRequest ?? this.cancellationRequest,
      settlement: settlement ?? this.settlement,
      damageDeductionRequest:
          damageDeductionRequest ?? this.damageDeductionRequest,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chatId': chatId,
      'asset': asset?.toMap(),
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds)
              : null,
      'startDate':
          startDate != null
              ? Timestamp(startDate!.seconds, startDate!.nanoseconds)
              : null,
      'endDate':
          endDate != null
              ? Timestamp(endDate!.seconds, endDate!.nanoseconds)
              : null,
      'numDays': numDays,
      'payment': payment?.toMap(),
      'paymentFlow': paymentFlow?.toMap(),
      'billingPlan': billingPlan,
      'priceBreakdown': priceBreakdown.toMap(),
      'renter': renter?.toMap(),
      'status': status?.label,
      'totalPrice': totalPrice,
      'tokens': tokens?.toMap(),
      'securityDeposit': securityDeposit.toMap(),
      'depositFlow': depositFlow?.toMap(),
      'disputeFlow': disputeFlow?.toMap(),
      'payoutFlow': payoutFlow?.toMap(),
      'cancellationRequest': cancellationRequest?.toMap(),
      'settlement': settlement?.toMap(),
      'damageDeductionRequest': damageDeductionRequest?.toMap(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    final startDate =
        map['startDate'] != null
            ? (map['startDate'] is Timestamp
                ? map['startDate'] as Timestamp
                : Timestamp(
                  map['startDate']['_seconds'],
                  map['startDate']['_nanoseconds'],
                ))
            : null;
    final endDate =
        map['endDate'] != null
            ? (map['endDate'] is Timestamp
                ? map['endDate'] as Timestamp
                : Timestamp(
                  map['endDate']['_seconds'],
                  map['endDate']['_nanoseconds'],
                ))
            : null;
    final numDays =
        map['numDays'] ??
        (startDate != null && endDate != null
            ? _bookingDateFromTimestamp(
              endDate,
            ).difference(_bookingDateFromTimestamp(startDate)).inDays
            : null);

    return Booking(
      id: map['id'] != null ? map['id'] as String : null,
      chatId: map['chatId'] != null ? map['chatId'] as String : null,
      asset:
          map['asset'] != null
              ? Asset.fromMap(map['asset'] as Map<String, dynamic>)
              : null,
      createdAt:
          map['createdAt'] != null
              ? map['createdAt'] is Timestamp
                  ? map['createdAt'] as Timestamp
                  : Timestamp(
                    map['createdAt']['_seconds'],
                    map['createdAt']['_nanoseconds'],
                  )
              : null,
      startDate: startDate,
      endDate: endDate,
      numDays: numDays as int?,
      payment:
          map['payment'] != null
              ? Payment.fromMap(map['payment'] as Map<String, dynamic>)
              : null,
      paymentFlow:
          map['paymentFlow'] != null
              ? BookingPaymentFlow.fromMap(
                Map<String, dynamic>.from(map['paymentFlow'] as Map),
              )
              : (map['payment'] != null
                  ? BookingPaymentFlow.fromLegacyPayment(
                    Map<String, dynamic>.from(map['payment'] as Map),
                  )
                  : null),
      billingPlan:
          map['billingPlan'] is Map
              ? Map<String, dynamic>.from(map['billingPlan'] as Map)
              : null,
      priceBreakdown:
          map['priceBreakdown'] != null
              ? BookingPriceBreakdown.fromMap(
                Map<String, dynamic>.from(map['priceBreakdown'] as Map),
              )
              : (map['payment'] != null
                  ? BookingPriceBreakdown.fromLegacyPayment(
                    Map<String, dynamic>.from(map['payment'] as Map),
                  )
                  : const BookingPriceBreakdown()),
      renter:
          map['renter'] != null
              ? SimpleUserModel.fromMap(map['renter'] as Map<String, dynamic>)
              : null,
      status:
          map['status'] != null
              ? BookingStatus.fromString(map['status'])
              : null,
      totalPrice: map['totalPrice'] != null ? map['totalPrice'] as int : null,
      tokens:
          map['tokens'] != null
              ? Token.fromMap(map['tokens'] as Map<String, dynamic>)
              : null,
      securityDeposit:
          map['securityDeposit'] != null
              ? SecurityDeposit.fromMap(
                Map<String, dynamic>.from(map['securityDeposit'] as Map),
              )
              : const SecurityDeposit.disabled(),
      depositFlow:
          map['depositFlow'] != null
              ? BookingDepositFlow.fromMap(
                Map<String, dynamic>.from(map['depositFlow'] as Map),
              )
              : null,
      disputeFlow:
          map['disputeFlow'] != null
              ? BookingDisputeFlow.fromMap(
                Map<String, dynamic>.from(map['disputeFlow'] as Map),
              )
              : null,
      payoutFlow:
          map['payoutFlow'] != null
              ? BookingPayoutFlow.fromMap(
                Map<String, dynamic>.from(map['payoutFlow'] as Map),
              )
              : null,
      cancellationRequest:
          map['cancellationRequest'] != null
              ? BookingCancellationRequest.fromMap(
                Map<String, dynamic>.from(map['cancellationRequest'] as Map),
              )
              : null,
      settlement:
          map['settlement'] != null
              ? Settlement.fromMap(
                Map<String, dynamic>.from(map['settlement'] as Map),
              )
              : null,
      damageDeductionRequest:
          map['damageDeductionRequest'] != null
              ? DamageDeductionRequest.fromMap(
                Map<String, dynamic>.from(map['damageDeductionRequest'] as Map),
              )
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Booking.fromJson(String source) =>
      Booking.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Booking(id: $id, chatId: $chatId, asset: $asset, createdAt: $createdAt, startDate: $startDate, endDate: $endDate, numDays: $numDays, payment: $payment, renter: $renter, status: $status, totalPrice: $totalPrice, tokens: $tokens, securityDeposit: $securityDeposit, cancellationRequest: $cancellationRequest, settlement: $settlement, damageDeductionRequest: $damageDeductionRequest)';
  }

  @override
  bool operator ==(covariant Booking other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.chatId == chatId &&
        other.asset == asset &&
        other.createdAt == createdAt &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.numDays == numDays &&
        other.payment == payment &&
        other.paymentFlow == paymentFlow &&
        mapEquals(other.billingPlan, billingPlan) &&
        other.priceBreakdown == priceBreakdown &&
        other.renter == renter &&
        other.status == status &&
        other.totalPrice == totalPrice &&
        other.tokens == tokens &&
        other.securityDeposit == securityDeposit &&
        other.depositFlow == depositFlow &&
        other.disputeFlow == disputeFlow &&
        other.payoutFlow == payoutFlow &&
        other.cancellationRequest == cancellationRequest &&
        other.settlement == settlement &&
        other.damageDeductionRequest == damageDeductionRequest;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatId.hashCode ^
        asset.hashCode ^
        createdAt.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        numDays.hashCode ^
        payment.hashCode ^
        paymentFlow.hashCode ^
        _mapHash(billingPlan) ^
        priceBreakdown.hashCode ^
        renter.hashCode ^
        status.hashCode ^
        totalPrice.hashCode ^
        tokens.hashCode ^
        securityDeposit.hashCode ^
        depositFlow.hashCode ^
        disputeFlow.hashCode ^
        payoutFlow.hashCode ^
        cancellationRequest.hashCode ^
        settlement.hashCode ^
        damageDeductionRequest.hashCode;
  }
}

DateTime _bookingDateFromTimestamp(Timestamp timestamp) {
  final utcDate = timestamp.toDate().toUtc();
  return DateTime(utcDate.year, utcDate.month, utcDate.day);
}

Map<String, dynamic>? _asMap(dynamic value) {
  return value != null ? Map<String, dynamic>.from(value as Map) : null;
}

List<Map<String, dynamic>>? _asMapList(dynamic value) {
  return value != null
      ? List<Map<String, dynamic>>.from(
        (value as List).map((item) => Map<String, dynamic>.from(item as Map)),
      )
      : null;
}

Map<String, dynamic> _withoutNullValues(Map<String, dynamic> map) {
  return map..removeWhere((_, value) => value == null);
}

int _mapHash(Map<dynamic, dynamic>? map) {
  if (map == null) return 0;
  return Object.hashAllUnordered(
    map.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}

bool _mapListEquals(
  List<Map<String, dynamic>>? first,
  List<Map<String, dynamic>>? second,
) {
  if (identical(first, second)) return true;
  if (first == null || second == null || first.length != second.length) {
    return false;
  }

  for (var i = 0; i < first.length; i += 1) {
    if (!mapEquals(first[i], second[i])) return false;
  }
  return true;
}

int _mapListHash(List<Map<String, dynamic>>? list) {
  if (list == null) return 0;
  return Object.hashAll(list.map(_mapHash));
}

class BookingPaymentFlow {
  final String? provider;
  final String? checkoutId;
  final String? method;
  final Map<String, dynamic> methodDetails;
  final String? transactionId;
  final String? paymongoPaymentIntentId;
  final String? paymongoPaymentId;
  final num? amount;
  final String? currency;
  final String? status;
  final String? refundStatus;
  final String? refundError;
  final num? refundAmount;
  final String? refundType;

  const BookingPaymentFlow({
    this.provider,
    this.checkoutId,
    this.method,
    this.methodDetails = const {},
    this.transactionId,
    this.paymongoPaymentIntentId,
    this.paymongoPaymentId,
    this.amount,
    this.currency,
    this.status,
    this.refundStatus,
    this.refundError,
    this.refundAmount,
    this.refundType,
  });

  factory BookingPaymentFlow.fromMap(Map<String, dynamic> map) {
    return BookingPaymentFlow(
      provider: map['provider'] as String?,
      checkoutId: map['checkoutId'] as String?,
      method: map['method'] as String?,
      methodDetails:
          map['methodDetails'] is Map
              ? Map<String, dynamic>.from(map['methodDetails'] as Map)
              : const {},
      transactionId: map['transactionId'] as String?,
      paymongoPaymentIntentId: map['paymongoPaymentIntentId'] as String?,
      paymongoPaymentId: map['paymongoPaymentId'] as String?,
      amount: map['amount'] as num?,
      currency: map['currency'] as String?,
      status: map['status'] as String?,
      refundStatus: map['refundStatus'] as String?,
      refundError: map['refundError'] as String?,
      refundAmount: map['refundAmount'] as num?,
      refundType: map['refundType'] as String?,
    );
  }

  factory BookingPaymentFlow.fromLegacyPayment(Map<String, dynamic> map) {
    return BookingPaymentFlow(
      provider: map['provider'] as String?,
      checkoutId: map['checkoutId'] as String?,
      method: map['method'] as String?,
      methodDetails:
          map['details'] is Map
              ? Map<String, dynamic>.from(map['details'] as Map)
              : const {},
      transactionId: map['transactionId'] as String?,
      paymongoPaymentIntentId: map['paymongoPaymentIntentId'] as String?,
      paymongoPaymentId: map['paymongoPaymentId'] as String?,
      amount: map['amount'] as num?,
      currency: map['currency'] as String?,
      status: map['status'] as String?,
      refundStatus: map['refundStatus'] as String?,
      refundError: map['refundError'] as String?,
      refundAmount: map['refundAmount'] as num?,
      refundType: map['refundType'] as String?,
    );
  }

  Map<String, dynamic> toMap() => _withoutNullValues({
    'provider': provider,
    'checkoutId': checkoutId,
    'method': method,
    'methodDetails': methodDetails,
    'transactionId': transactionId,
    'paymongoPaymentIntentId': paymongoPaymentIntentId,
    'paymongoPaymentId': paymongoPaymentId,
    'amount': amount,
    'currency': currency,
    'status': status,
    'refundStatus': refundStatus,
    'refundError': refundError,
    'refundAmount': refundAmount,
    'refundType': refundType,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingPaymentFlow &&
            other.provider == provider &&
            other.checkoutId == checkoutId &&
            other.method == method &&
            mapEquals(other.methodDetails, methodDetails) &&
            other.transactionId == transactionId &&
            other.paymongoPaymentIntentId == paymongoPaymentIntentId &&
            other.paymongoPaymentId == paymongoPaymentId &&
            other.amount == amount &&
            other.currency == currency &&
            other.status == status &&
            other.refundStatus == refundStatus &&
            other.refundError == refundError &&
            other.refundAmount == refundAmount &&
            other.refundType == refundType;
  }

  @override
  int get hashCode => Object.hash(
    provider,
    checkoutId,
    method,
    _mapHash(methodDetails),
    transactionId,
    paymongoPaymentIntentId,
    paymongoPaymentId,
    amount,
    currency,
    status,
    refundStatus,
    refundError,
    refundAmount,
    refundType,
  );
}

class BookingPriceBreakdown {
  final num? rentalSubtotal;
  final num? dueNowRentalSubtotal;
  final num? scheduledRentalSubtotal;
  final num? chargeableRentalSubtotal;
  final num? securityDepositAmount;
  final num? renterPlatformFee;
  final num? renterProcessingFee;
  final num? paymentAmount;
  final num? ownerProcessingFee;
  final num? ownerPayoutAmount;
  final num? ownerPayoutTransferFee;
  final num? renterDepositReturnTransferFee;
  final num? securityDepositCollectionProcessingFee;
  final String? currency;

  const BookingPriceBreakdown({
    this.rentalSubtotal,
    this.dueNowRentalSubtotal,
    this.scheduledRentalSubtotal,
    this.chargeableRentalSubtotal,
    this.securityDepositAmount,
    this.renterPlatformFee,
    this.renterProcessingFee,
    this.paymentAmount,
    this.ownerProcessingFee,
    this.ownerPayoutAmount,
    this.ownerPayoutTransferFee,
    this.renterDepositReturnTransferFee,
    this.securityDepositCollectionProcessingFee,
    this.currency,
  });

  factory BookingPriceBreakdown.fromMap(Map<String, dynamic> map) {
    return BookingPriceBreakdown(
      rentalSubtotal: map['rentalSubtotal'] as num?,
      dueNowRentalSubtotal: map['dueNowRentalSubtotal'] as num?,
      scheduledRentalSubtotal: map['scheduledRentalSubtotal'] as num?,
      chargeableRentalSubtotal: map['chargeableRentalSubtotal'] as num?,
      securityDepositAmount: map['securityDepositAmount'] as num?,
      renterPlatformFee: map['renterPlatformFee'] as num?,
      renterProcessingFee: map['renterProcessingFee'] as num?,
      paymentAmount: map['paymentAmount'] as num?,
      ownerProcessingFee: map['ownerProcessingFee'] as num?,
      ownerPayoutAmount: map['ownerPayoutAmount'] as num?,
      ownerPayoutTransferFee: map['ownerPayoutTransferFee'] as num?,
      renterDepositReturnTransferFee:
          map['renterDepositReturnTransferFee'] as num?,
      securityDepositCollectionProcessingFee:
          map['securityDepositCollectionProcessingFee'] as num?,
      currency: map['currency'] as String?,
    );
  }

  factory BookingPriceBreakdown.fromLegacyPayment(Map<String, dynamic> map) {
    final pricing =
        map['pricingBreakdown'] is Map
            ? Map<String, dynamic>.from(map['pricingBreakdown'] as Map)
            : const <String, dynamic>{};
    return BookingPriceBreakdown(
      rentalSubtotal:
          pricing['rentalSubtotal'] as num? ?? map['rentalSubtotal'] as num?,
      dueNowRentalSubtotal: pricing['dueNowRentalSubtotal'] as num?,
      scheduledRentalSubtotal: pricing['scheduledRentalSubtotal'] as num?,
      chargeableRentalSubtotal: pricing['chargeableRentalSubtotal'] as num?,
      securityDepositAmount: pricing['securityDepositAmount'] as num?,
      renterPlatformFee: pricing['renterPlatformFee'] as num?,
      renterProcessingFee: pricing['renterProcessingFee'] as num?,
      paymentAmount: pricing['paymentAmount'] as num? ?? map['amount'] as num?,
      ownerProcessingFee: pricing['ownerProcessingFee'] as num?,
      ownerPayoutAmount:
          pricing['ownerPayoutAmount'] as num? ??
          map['ownerPayoutAmount'] as num?,
      ownerPayoutTransferFee: pricing['ownerPayoutTransferFee'] as num?,
      renterDepositReturnTransferFee:
          pricing['renterDepositReturnTransferFee'] as num?,
      securityDepositCollectionProcessingFee:
          pricing['securityDepositCollectionProcessingFee'] as num?,
      currency: pricing['currency'] as String? ?? map['currency'] as String?,
    );
  }

  num? get renterProcessingTotal {
    final platform = renterPlatformFee ?? 0;
    final processing = renterProcessingFee ?? 0;
    final total = platform + processing;
    return total > 0 ? total : null;
  }

  Map<String, dynamic> toMap() => _withoutNullValues({
    'rentalSubtotal': rentalSubtotal,
    'dueNowRentalSubtotal': dueNowRentalSubtotal,
    'scheduledRentalSubtotal': scheduledRentalSubtotal,
    'chargeableRentalSubtotal': chargeableRentalSubtotal,
    'securityDepositAmount': securityDepositAmount,
    'renterPlatformFee': renterPlatformFee,
    'renterProcessingFee': renterProcessingFee,
    'paymentAmount': paymentAmount,
    'ownerProcessingFee': ownerProcessingFee,
    'ownerPayoutAmount': ownerPayoutAmount,
    'ownerPayoutTransferFee': ownerPayoutTransferFee,
    'renterDepositReturnTransferFee': renterDepositReturnTransferFee,
    'securityDepositCollectionProcessingFee':
        securityDepositCollectionProcessingFee,
    'currency': currency,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingPriceBreakdown &&
            other.rentalSubtotal == rentalSubtotal &&
            other.dueNowRentalSubtotal == dueNowRentalSubtotal &&
            other.scheduledRentalSubtotal == scheduledRentalSubtotal &&
            other.chargeableRentalSubtotal == chargeableRentalSubtotal &&
            other.securityDepositAmount == securityDepositAmount &&
            other.renterPlatformFee == renterPlatformFee &&
            other.renterProcessingFee == renterProcessingFee &&
            other.paymentAmount == paymentAmount &&
            other.ownerProcessingFee == ownerProcessingFee &&
            other.ownerPayoutAmount == ownerPayoutAmount &&
            other.ownerPayoutTransferFee == ownerPayoutTransferFee &&
            other.renterDepositReturnTransferFee ==
                renterDepositReturnTransferFee &&
            other.securityDepositCollectionProcessingFee ==
                securityDepositCollectionProcessingFee &&
            other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(
    rentalSubtotal,
    dueNowRentalSubtotal,
    scheduledRentalSubtotal,
    chargeableRentalSubtotal,
    securityDepositAmount,
    renterPlatformFee,
    renterProcessingFee,
    paymentAmount,
    ownerProcessingFee,
    ownerPayoutAmount,
    ownerPayoutTransferFee,
    renterDepositReturnTransferFee,
    securityDepositCollectionProcessingFee,
    currency,
  );
}

class BookingDepositFlow {
  final bool required;
  final num amount;
  final String? status;
  final num? requestedDeductionAmount;
  final num? approvedDeductionAmount;
  final num? depositCoveredAmount;
  final num? depositReturnAmount;
  final String? renterResponse;

  const BookingDepositFlow({
    this.required = false,
    this.amount = 0,
    this.status,
    this.requestedDeductionAmount,
    this.approvedDeductionAmount,
    this.depositCoveredAmount,
    this.depositReturnAmount,
    this.renterResponse,
  });

  factory BookingDepositFlow.fromMap(Map<String, dynamic> map) {
    return BookingDepositFlow(
      required: map['required'] == true,
      amount: map['amount'] as num? ?? 0,
      status: map['status'] as String?,
      requestedDeductionAmount: map['requestedDeductionAmount'] as num?,
      approvedDeductionAmount: map['approvedDeductionAmount'] as num?,
      depositCoveredAmount: map['depositCoveredAmount'] as num?,
      depositReturnAmount: map['depositReturnAmount'] as num?,
      renterResponse: map['renterResponse'] as String?,
    );
  }

  Map<String, dynamic> toMap() => _withoutNullValues({
    'required': required,
    'amount': amount,
    'status': status,
    'requestedDeductionAmount': requestedDeductionAmount,
    'approvedDeductionAmount': approvedDeductionAmount,
    'depositCoveredAmount': depositCoveredAmount,
    'depositReturnAmount': depositReturnAmount,
    'renterResponse': renterResponse,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingDepositFlow &&
            other.required == required &&
            other.amount == amount &&
            other.status == status &&
            other.requestedDeductionAmount == requestedDeductionAmount &&
            other.approvedDeductionAmount == approvedDeductionAmount &&
            other.depositCoveredAmount == depositCoveredAmount &&
            other.depositReturnAmount == depositReturnAmount &&
            other.renterResponse == renterResponse;
  }

  @override
  int get hashCode => Object.hash(
    required,
    amount,
    status,
    requestedDeductionAmount,
    approvedDeductionAmount,
    depositCoveredAmount,
    depositReturnAmount,
    renterResponse,
  );
}

class BookingDisputeFlow {
  final String? status;
  final num? requestedAmount;
  final num? approvedAmount;
  final String? reason;
  final String? notes;
  final List<String> evidenceUrls;
  final String? renterResponse;
  final String? supportStatus;
  final String? adminNotes;
  final String? renterSupportChatId;
  final String? ownerSupportChatId;
  final num? depositCoveredAmount;
  final num? outstandingAmount;
  final String? outstandingPaymentStatus;
  final String? outstandingPaymentRequestId;
  final num? paidOutstandingAmount;
  final Map<String, dynamic>? outstandingPayment;
  final num? remainingSecurityDeposit;

  const BookingDisputeFlow({
    this.status,
    this.requestedAmount,
    this.approvedAmount,
    this.reason,
    this.notes,
    this.evidenceUrls = const [],
    this.renterResponse,
    this.supportStatus,
    this.adminNotes,
    this.renterSupportChatId,
    this.ownerSupportChatId,
    this.depositCoveredAmount,
    this.outstandingAmount,
    this.outstandingPaymentStatus,
    this.outstandingPaymentRequestId,
    this.paidOutstandingAmount,
    this.outstandingPayment,
    this.remainingSecurityDeposit,
  });

  factory BookingDisputeFlow.fromMap(Map<String, dynamic> map) {
    return BookingDisputeFlow(
      status: map['status'] as String?,
      requestedAmount: map['requestedAmount'] as num?,
      approvedAmount: map['approvedAmount'] as num?,
      reason: map['reason'] as String?,
      notes: map['notes'] as String?,
      evidenceUrls:
          map['evidenceUrls'] is List
              ? List<String>.from(map['evidenceUrls'] as List)
              : const [],
      renterResponse: map['renterResponse'] as String?,
      supportStatus: map['supportStatus'] as String?,
      adminNotes: map['adminNotes'] as String?,
      renterSupportChatId: map['renterSupportChatId'] as String?,
      ownerSupportChatId: map['ownerSupportChatId'] as String?,
      depositCoveredAmount: map['depositCoveredAmount'] as num?,
      outstandingAmount: map['outstandingAmount'] as num?,
      outstandingPaymentStatus: map['outstandingPaymentStatus'] as String?,
      outstandingPaymentRequestId:
          map['outstandingPaymentRequestId'] as String?,
      paidOutstandingAmount: map['paidOutstandingAmount'] as num?,
      outstandingPayment: _asMap(map['outstandingPayment']),
      remainingSecurityDeposit: map['remainingSecurityDeposit'] as num?,
    );
  }

  Map<String, dynamic> toMap() => _withoutNullValues({
    'status': status,
    'requestedAmount': requestedAmount,
    'approvedAmount': approvedAmount,
    'reason': reason,
    'notes': notes,
    'evidenceUrls': evidenceUrls,
    'renterResponse': renterResponse,
    'supportStatus': supportStatus,
    'adminNotes': adminNotes,
    'renterSupportChatId': renterSupportChatId,
    'ownerSupportChatId': ownerSupportChatId,
    'depositCoveredAmount': depositCoveredAmount,
    'outstandingAmount': outstandingAmount,
    'outstandingPaymentStatus': outstandingPaymentStatus,
    'outstandingPaymentRequestId': outstandingPaymentRequestId,
    'paidOutstandingAmount': paidOutstandingAmount,
    'outstandingPayment': outstandingPayment,
    'remainingSecurityDeposit': remainingSecurityDeposit,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingDisputeFlow &&
            other.status == status &&
            other.requestedAmount == requestedAmount &&
            other.approvedAmount == approvedAmount &&
            other.reason == reason &&
            other.notes == notes &&
            listEquals(other.evidenceUrls, evidenceUrls) &&
            other.renterResponse == renterResponse &&
            other.supportStatus == supportStatus &&
            other.adminNotes == adminNotes &&
            other.renterSupportChatId == renterSupportChatId &&
            other.ownerSupportChatId == ownerSupportChatId &&
            other.depositCoveredAmount == depositCoveredAmount &&
            other.outstandingAmount == outstandingAmount &&
            other.outstandingPaymentStatus == outstandingPaymentStatus &&
            other.outstandingPaymentRequestId == outstandingPaymentRequestId &&
            other.paidOutstandingAmount == paidOutstandingAmount &&
            mapEquals(other.outstandingPayment, outstandingPayment) &&
            other.remainingSecurityDeposit == remainingSecurityDeposit;
  }

  @override
  int get hashCode => Object.hash(
    status,
    requestedAmount,
    approvedAmount,
    reason,
    notes,
    Object.hashAll(evidenceUrls),
    renterResponse,
    supportStatus,
    adminNotes,
    renterSupportChatId,
    ownerSupportChatId,
    depositCoveredAmount,
    outstandingAmount,
    outstandingPaymentStatus,
    outstandingPaymentRequestId,
    paidOutstandingAmount,
    _mapHash(outstandingPayment),
    remainingSecurityDeposit,
  );
}

class BookingPayoutFlow {
  final String? ownerPayoutStatus;
  final String? depositReturnStatus;
  final num? ownerPayoutAmount;
  final num? ownerPayoutAmountBeforePenalty;
  final num? ownerPenaltyDeductionAmount;
  final num? ownerPayoutGrossAmount;
  final num? ownerPayoutTransferFee;
  final num? depositReturnAmount;
  final String? ownerPayoutError;
  final List<Map<String, dynamic>>? ownerPenaltyApplications;
  final Map<String, dynamic>? movements;

  const BookingPayoutFlow({
    this.ownerPayoutStatus,
    this.depositReturnStatus,
    this.ownerPayoutAmount,
    this.ownerPayoutAmountBeforePenalty,
    this.ownerPenaltyDeductionAmount,
    this.ownerPayoutGrossAmount,
    this.ownerPayoutTransferFee,
    this.depositReturnAmount,
    this.ownerPayoutError,
    this.ownerPenaltyApplications,
    this.movements,
  });

  factory BookingPayoutFlow.fromMap(Map<String, dynamic> map) {
    return BookingPayoutFlow(
      ownerPayoutStatus: map['ownerPayoutStatus'] as String?,
      depositReturnStatus: map['depositReturnStatus'] as String?,
      ownerPayoutAmount: map['ownerPayoutAmount'] as num?,
      ownerPayoutAmountBeforePenalty:
          map['ownerPayoutAmountBeforePenalty'] as num?,
      ownerPenaltyDeductionAmount: map['ownerPenaltyDeductionAmount'] as num?,
      ownerPayoutGrossAmount: map['ownerPayoutGrossAmount'] as num?,
      ownerPayoutTransferFee: map['ownerPayoutTransferFee'] as num?,
      depositReturnAmount: map['depositReturnAmount'] as num?,
      ownerPayoutError: map['ownerPayoutError'] as String?,
      ownerPenaltyApplications: _asMapList(map['ownerPenaltyApplications']),
      movements: _asMap(map['movements']),
    );
  }

  Map<String, dynamic> toMap() => _withoutNullValues({
    'ownerPayoutStatus': ownerPayoutStatus,
    'depositReturnStatus': depositReturnStatus,
    'ownerPayoutAmount': ownerPayoutAmount,
    'ownerPayoutAmountBeforePenalty': ownerPayoutAmountBeforePenalty,
    'ownerPenaltyDeductionAmount': ownerPenaltyDeductionAmount,
    'ownerPayoutGrossAmount': ownerPayoutGrossAmount,
    'ownerPayoutTransferFee': ownerPayoutTransferFee,
    'depositReturnAmount': depositReturnAmount,
    'ownerPayoutError': ownerPayoutError,
    'ownerPenaltyApplications': ownerPenaltyApplications,
    'movements': movements,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingPayoutFlow &&
            other.ownerPayoutStatus == ownerPayoutStatus &&
            other.depositReturnStatus == depositReturnStatus &&
            other.ownerPayoutAmount == ownerPayoutAmount &&
            other.ownerPayoutAmountBeforePenalty ==
                ownerPayoutAmountBeforePenalty &&
            other.ownerPenaltyDeductionAmount == ownerPenaltyDeductionAmount &&
            other.ownerPayoutGrossAmount == ownerPayoutGrossAmount &&
            other.ownerPayoutTransferFee == ownerPayoutTransferFee &&
            other.depositReturnAmount == depositReturnAmount &&
            other.ownerPayoutError == ownerPayoutError &&
            _mapListEquals(
              other.ownerPenaltyApplications,
              ownerPenaltyApplications,
            ) &&
            mapEquals(other.movements, movements);
  }

  @override
  int get hashCode => Object.hash(
    ownerPayoutStatus,
    depositReturnStatus,
    ownerPayoutAmount,
    ownerPayoutAmountBeforePenalty,
    ownerPenaltyDeductionAmount,
    ownerPayoutGrossAmount,
    ownerPayoutTransferFee,
    depositReturnAmount,
    ownerPayoutError,
    _mapListHash(ownerPenaltyApplications),
    _mapHash(movements),
  );
}

class BookingCancellationRequest {
  final String? status;
  final String? requestedByRole;
  final String? reason;
  final String? adminNotes;
  final String? refundStatus;
  final Map<String, dynamic>? renterPenalty;
  final Map<String, dynamic>? ownerPenalty;

  const BookingCancellationRequest({
    this.status,
    this.requestedByRole,
    this.reason,
    this.adminNotes,
    this.refundStatus,
    this.renterPenalty,
    this.ownerPenalty,
  });

  factory BookingCancellationRequest.fromMap(Map<String, dynamic> map) {
    return BookingCancellationRequest(
      status: map['status'] as String?,
      requestedByRole: map['requestedByRole'] as String?,
      reason: map['reason'] as String?,
      adminNotes: map['adminNotes'] as String?,
      refundStatus: map['refundStatus'] as String?,
      renterPenalty: _asMap(map['renterPenalty']),
      ownerPenalty: _asMap(map['ownerPenalty']),
    );
  }

  Map<String, dynamic> toMap() => _withoutNullValues({
    'status': status,
    'requestedByRole': requestedByRole,
    'reason': reason,
    'adminNotes': adminNotes,
    'refundStatus': refundStatus,
    'renterPenalty': renterPenalty,
    'ownerPenalty': ownerPenalty,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingCancellationRequest &&
            other.status == status &&
            other.requestedByRole == requestedByRole &&
            other.reason == reason &&
            other.adminNotes == adminNotes &&
            other.refundStatus == refundStatus &&
            mapEquals(other.renterPenalty, renterPenalty) &&
            mapEquals(other.ownerPenalty, ownerPenalty);
  }

  @override
  int get hashCode => Object.hash(
    status,
    requestedByRole,
    reason,
    adminNotes,
    refundStatus,
    _mapHash(renterPenalty),
    _mapHash(ownerPenalty),
  );
}

class Settlement {
  String? status;
  String? depositStatus;
  String? renterResponse;
  String? ownerPayoutStatus;
  String? depositReturnStatus;
  bool? riskFlagged;
  num? approvedDamageDeductionAmount;
  num? depositCoveredDamageAmount;
  num? outstandingDamageAmount;
  num? depositReturnAmount;
  num? ownerPayoutAmount;
  String? supportStatus;
  String? adminNotes;
  String? renterSupportChatId;
  String? ownerSupportChatId;
  String? damageBalancePaymentStatus;
  String? damageBalancePaymentRequestId;
  num? damageBalanceRequestedAmount;
  String? ownerDamageBalancePayoutStatus;
  num? finalOwnerPayoutAmount;
  num? finalOwnerPayoutGrossAmount;
  num? finalOwnerPayoutWalletTransferFee;
  Map<String, dynamic>? finalOwnerPayoutReleasedComponents;
  Map<String, dynamic>? damageBalancePayment;
  Map<String, dynamic>? damageBalancePaymentRequests;
  Map<String, dynamic>? movements;
  dynamic updatedAt;
  dynamic completedAt;
  dynamic ownerDamageBalancePayoutReleasedAt;
  String? decision;
  String? completedBy;
  String? ownerDamageBalancePayoutReleasedBy;

  Settlement({
    this.status,
    this.depositStatus,
    this.renterResponse,
    this.ownerPayoutStatus,
    this.depositReturnStatus,
    this.riskFlagged,
    this.approvedDamageDeductionAmount,
    this.depositCoveredDamageAmount,
    this.outstandingDamageAmount,
    this.depositReturnAmount,
    this.ownerPayoutAmount,
    this.supportStatus,
    this.adminNotes,
    this.renterSupportChatId,
    this.ownerSupportChatId,
    this.damageBalancePaymentStatus,
    this.damageBalancePaymentRequestId,
    this.damageBalanceRequestedAmount,
    this.ownerDamageBalancePayoutStatus,
    this.finalOwnerPayoutAmount,
    this.finalOwnerPayoutGrossAmount,
    this.finalOwnerPayoutWalletTransferFee,
    this.finalOwnerPayoutReleasedComponents,
    this.damageBalancePayment,
    this.damageBalancePaymentRequests,
    this.movements,
    this.updatedAt,
    this.completedAt,
    this.ownerDamageBalancePayoutReleasedAt,
    this.decision,
    this.completedBy,
    this.ownerDamageBalancePayoutReleasedBy,
  });

  Settlement copyWith({
    String? status,
    String? depositStatus,
    String? renterResponse,
    String? ownerPayoutStatus,
    String? depositReturnStatus,
    bool? riskFlagged,
    num? approvedDamageDeductionAmount,
    num? depositCoveredDamageAmount,
    num? outstandingDamageAmount,
    num? depositReturnAmount,
    num? ownerPayoutAmount,
    String? supportStatus,
    String? adminNotes,
    String? renterSupportChatId,
    String? ownerSupportChatId,
    String? damageBalancePaymentStatus,
    String? damageBalancePaymentRequestId,
    num? damageBalanceRequestedAmount,
    String? ownerDamageBalancePayoutStatus,
    num? finalOwnerPayoutAmount,
    num? finalOwnerPayoutGrossAmount,
    num? finalOwnerPayoutWalletTransferFee,
    Map<String, dynamic>? finalOwnerPayoutReleasedComponents,
    Map<String, dynamic>? damageBalancePayment,
    Map<String, dynamic>? damageBalancePaymentRequests,
    Map<String, dynamic>? movements,
    dynamic updatedAt,
    dynamic completedAt,
    dynamic ownerDamageBalancePayoutReleasedAt,
    String? decision,
    String? completedBy,
    String? ownerDamageBalancePayoutReleasedBy,
  }) {
    return Settlement(
      status: status ?? this.status,
      depositStatus: depositStatus ?? this.depositStatus,
      renterResponse: renterResponse ?? this.renterResponse,
      ownerPayoutStatus: ownerPayoutStatus ?? this.ownerPayoutStatus,
      depositReturnStatus: depositReturnStatus ?? this.depositReturnStatus,
      riskFlagged: riskFlagged ?? this.riskFlagged,
      approvedDamageDeductionAmount:
          approvedDamageDeductionAmount ?? this.approvedDamageDeductionAmount,
      depositCoveredDamageAmount:
          depositCoveredDamageAmount ?? this.depositCoveredDamageAmount,
      outstandingDamageAmount:
          outstandingDamageAmount ?? this.outstandingDamageAmount,
      depositReturnAmount: depositReturnAmount ?? this.depositReturnAmount,
      ownerPayoutAmount: ownerPayoutAmount ?? this.ownerPayoutAmount,
      supportStatus: supportStatus ?? this.supportStatus,
      adminNotes: adminNotes ?? this.adminNotes,
      renterSupportChatId: renterSupportChatId ?? this.renterSupportChatId,
      ownerSupportChatId: ownerSupportChatId ?? this.ownerSupportChatId,
      damageBalancePaymentStatus:
          damageBalancePaymentStatus ?? this.damageBalancePaymentStatus,
      damageBalancePaymentRequestId:
          damageBalancePaymentRequestId ?? this.damageBalancePaymentRequestId,
      damageBalanceRequestedAmount:
          damageBalanceRequestedAmount ?? this.damageBalanceRequestedAmount,
      ownerDamageBalancePayoutStatus:
          ownerDamageBalancePayoutStatus ?? this.ownerDamageBalancePayoutStatus,
      finalOwnerPayoutAmount:
          finalOwnerPayoutAmount ?? this.finalOwnerPayoutAmount,
      finalOwnerPayoutGrossAmount:
          finalOwnerPayoutGrossAmount ?? this.finalOwnerPayoutGrossAmount,
      finalOwnerPayoutWalletTransferFee:
          finalOwnerPayoutWalletTransferFee ??
          this.finalOwnerPayoutWalletTransferFee,
      finalOwnerPayoutReleasedComponents:
          finalOwnerPayoutReleasedComponents ??
          this.finalOwnerPayoutReleasedComponents,
      damageBalancePayment: damageBalancePayment ?? this.damageBalancePayment,
      damageBalancePaymentRequests:
          damageBalancePaymentRequests ?? this.damageBalancePaymentRequests,
      movements: movements ?? this.movements,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      ownerDamageBalancePayoutReleasedAt:
          ownerDamageBalancePayoutReleasedAt ??
          this.ownerDamageBalancePayoutReleasedAt,
      decision: decision ?? this.decision,
      completedBy: completedBy ?? this.completedBy,
      ownerDamageBalancePayoutReleasedBy:
          ownerDamageBalancePayoutReleasedBy ??
          this.ownerDamageBalancePayoutReleasedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return _withoutNullValues(<String, dynamic>{
      'status': status,
      'depositStatus': depositStatus,
      'renterResponse': renterResponse,
      'ownerPayoutStatus': ownerPayoutStatus,
      'depositReturnStatus': depositReturnStatus,
      'riskFlagged': riskFlagged,
      'approvedDamageDeductionAmount': approvedDamageDeductionAmount,
      'depositCoveredDamageAmount': depositCoveredDamageAmount,
      'outstandingDamageAmount': outstandingDamageAmount,
      'depositReturnAmount': depositReturnAmount,
      'ownerPayoutAmount': ownerPayoutAmount,
      'supportStatus': supportStatus,
      'adminNotes': adminNotes,
      'renterSupportChatId': renterSupportChatId,
      'ownerSupportChatId': ownerSupportChatId,
      'damageBalancePaymentStatus': damageBalancePaymentStatus,
      'damageBalancePaymentRequestId': damageBalancePaymentRequestId,
      'damageBalanceRequestedAmount': damageBalanceRequestedAmount,
      'ownerDamageBalancePayoutStatus': ownerDamageBalancePayoutStatus,
      'finalOwnerPayoutAmount': finalOwnerPayoutAmount,
      'finalOwnerPayoutGrossAmount': finalOwnerPayoutGrossAmount,
      'finalOwnerPayoutWalletTransferFee': finalOwnerPayoutWalletTransferFee,
      'finalOwnerPayoutReleasedComponents': finalOwnerPayoutReleasedComponents,
      'damageBalancePayment': damageBalancePayment,
      'damageBalancePaymentRequests': damageBalancePaymentRequests,
      'movements': movements,
      'updatedAt': updatedAt,
      'completedAt': completedAt,
      'ownerDamageBalancePayoutReleasedAt': ownerDamageBalancePayoutReleasedAt,
      'decision': decision,
      'completedBy': completedBy,
      'ownerDamageBalancePayoutReleasedBy': ownerDamageBalancePayoutReleasedBy,
    });
  }

  factory Settlement.fromMap(Map<String, dynamic> map) {
    return Settlement(
      status: map['status'] != null ? map['status'] as String : null,
      depositStatus:
          map['depositStatus'] != null ? map['depositStatus'] as String : null,
      renterResponse:
          map['renterResponse'] != null
              ? map['renterResponse'] as String
              : null,
      ownerPayoutStatus:
          map['ownerPayoutStatus'] != null
              ? map['ownerPayoutStatus'] as String
              : null,
      depositReturnStatus:
          map['depositReturnStatus'] != null
              ? map['depositReturnStatus'] as String
              : null,
      riskFlagged:
          map['riskFlagged'] != null ? map['riskFlagged'] as bool : null,
      approvedDamageDeductionAmount:
          map['approvedDamageDeductionAmount'] != null
              ? map['approvedDamageDeductionAmount'] as num
              : null,
      depositCoveredDamageAmount:
          map['depositCoveredDamageAmount'] != null
              ? map['depositCoveredDamageAmount'] as num
              : null,
      outstandingDamageAmount:
          map['outstandingDamageAmount'] != null
              ? map['outstandingDamageAmount'] as num
              : null,
      depositReturnAmount:
          map['depositReturnAmount'] != null
              ? map['depositReturnAmount'] as num
              : null,
      ownerPayoutAmount:
          map['ownerPayoutAmount'] != null
              ? map['ownerPayoutAmount'] as num
              : null,
      supportStatus:
          map['supportStatus'] != null ? map['supportStatus'] as String : null,
      adminNotes:
          map['adminNotes'] != null ? map['adminNotes'] as String : null,
      renterSupportChatId:
          map['renterSupportChatId'] != null
              ? map['renterSupportChatId'] as String
              : null,
      ownerSupportChatId:
          map['ownerSupportChatId'] != null
              ? map['ownerSupportChatId'] as String
              : null,
      damageBalancePaymentStatus:
          map['damageBalancePaymentStatus'] != null
              ? map['damageBalancePaymentStatus'] as String
              : null,
      damageBalancePaymentRequestId:
          map['damageBalancePaymentRequestId'] != null
              ? map['damageBalancePaymentRequestId'] as String
              : null,
      damageBalanceRequestedAmount:
          map['damageBalanceRequestedAmount'] != null
              ? map['damageBalanceRequestedAmount'] as num
              : null,
      ownerDamageBalancePayoutStatus:
          map['ownerDamageBalancePayoutStatus'] != null
              ? map['ownerDamageBalancePayoutStatus'] as String
              : null,
      finalOwnerPayoutAmount:
          map['finalOwnerPayoutAmount'] != null
              ? map['finalOwnerPayoutAmount'] as num
              : null,
      finalOwnerPayoutGrossAmount:
          map['finalOwnerPayoutGrossAmount'] != null
              ? map['finalOwnerPayoutGrossAmount'] as num
              : null,
      finalOwnerPayoutWalletTransferFee:
          map['finalOwnerPayoutWalletTransferFee'] != null
              ? map['finalOwnerPayoutWalletTransferFee'] as num
              : null,
      finalOwnerPayoutReleasedComponents: _asMap(
        map['finalOwnerPayoutReleasedComponents'],
      ),
      damageBalancePayment: _asMap(map['damageBalancePayment']),
      damageBalancePaymentRequests: _asMap(map['damageBalancePaymentRequests']),
      movements: _asMap(map['movements']),
      updatedAt: map['updatedAt'],
      completedAt: map['completedAt'],
      ownerDamageBalancePayoutReleasedAt:
          map['ownerDamageBalancePayoutReleasedAt'],
      decision: map['decision'] != null ? map['decision'] as String : null,
      completedBy:
          map['completedBy'] != null ? map['completedBy'] as String : null,
      ownerDamageBalancePayoutReleasedBy:
          map['ownerDamageBalancePayoutReleasedBy'] != null
              ? map['ownerDamageBalancePayoutReleasedBy'] as String
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Settlement.fromJson(String source) =>
      Settlement.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Settlement(status: $status, depositStatus: $depositStatus, renterResponse: $renterResponse, approvedDamageDeductionAmount: $approvedDamageDeductionAmount, depositReturnAmount: $depositReturnAmount, ownerPayoutAmount: $ownerPayoutAmount, supportStatus: $supportStatus)';
  }

  @override
  bool operator ==(covariant Settlement other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.depositStatus == depositStatus &&
        other.renterResponse == renterResponse &&
        other.ownerPayoutStatus == ownerPayoutStatus &&
        other.depositReturnStatus == depositReturnStatus &&
        other.riskFlagged == riskFlagged &&
        other.approvedDamageDeductionAmount == approvedDamageDeductionAmount &&
        other.depositCoveredDamageAmount == depositCoveredDamageAmount &&
        other.outstandingDamageAmount == outstandingDamageAmount &&
        other.depositReturnAmount == depositReturnAmount &&
        other.ownerPayoutAmount == ownerPayoutAmount &&
        other.supportStatus == supportStatus &&
        other.adminNotes == adminNotes &&
        other.renterSupportChatId == renterSupportChatId &&
        other.ownerSupportChatId == ownerSupportChatId &&
        other.damageBalancePaymentStatus == damageBalancePaymentStatus &&
        other.damageBalancePaymentRequestId == damageBalancePaymentRequestId &&
        other.damageBalanceRequestedAmount == damageBalanceRequestedAmount &&
        other.ownerDamageBalancePayoutStatus ==
            ownerDamageBalancePayoutStatus &&
        other.finalOwnerPayoutAmount == finalOwnerPayoutAmount &&
        other.finalOwnerPayoutGrossAmount == finalOwnerPayoutGrossAmount &&
        other.finalOwnerPayoutWalletTransferFee ==
            finalOwnerPayoutWalletTransferFee &&
        other.finalOwnerPayoutReleasedComponents ==
            finalOwnerPayoutReleasedComponents &&
        other.damageBalancePayment == damageBalancePayment &&
        other.damageBalancePaymentRequests == damageBalancePaymentRequests &&
        other.movements == movements &&
        other.updatedAt == updatedAt &&
        other.completedAt == completedAt &&
        other.ownerDamageBalancePayoutReleasedAt ==
            ownerDamageBalancePayoutReleasedAt &&
        other.decision == decision &&
        other.completedBy == completedBy &&
        other.ownerDamageBalancePayoutReleasedBy ==
            ownerDamageBalancePayoutReleasedBy;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        depositStatus.hashCode ^
        renterResponse.hashCode ^
        ownerPayoutStatus.hashCode ^
        depositReturnStatus.hashCode ^
        riskFlagged.hashCode ^
        approvedDamageDeductionAmount.hashCode ^
        depositCoveredDamageAmount.hashCode ^
        outstandingDamageAmount.hashCode ^
        depositReturnAmount.hashCode ^
        ownerPayoutAmount.hashCode ^
        supportStatus.hashCode ^
        adminNotes.hashCode ^
        renterSupportChatId.hashCode ^
        ownerSupportChatId.hashCode ^
        damageBalancePaymentStatus.hashCode ^
        damageBalancePaymentRequestId.hashCode ^
        damageBalanceRequestedAmount.hashCode ^
        ownerDamageBalancePayoutStatus.hashCode ^
        finalOwnerPayoutAmount.hashCode ^
        finalOwnerPayoutGrossAmount.hashCode ^
        finalOwnerPayoutWalletTransferFee.hashCode ^
        finalOwnerPayoutReleasedComponents.hashCode ^
        damageBalancePayment.hashCode ^
        damageBalancePaymentRequests.hashCode ^
        movements.hashCode ^
        updatedAt.hashCode ^
        completedAt.hashCode ^
        ownerDamageBalancePayoutReleasedAt.hashCode ^
        decision.hashCode ^
        completedBy.hashCode ^
        ownerDamageBalancePayoutReleasedBy.hashCode;
  }
}

class DamageDeductionRequest {
  String? status;
  num? requestedAmount;
  num? approvedAmount;
  String? reason;
  String? notes;
  List<String> evidenceUrls;
  bool? requiresSupportReview;
  bool? overDepositRequested;
  String? requestedBy;
  dynamic requestedAt;
  String? renterResponse;
  dynamic updatedAt;
  String? supportStatus;
  String? adminNotes;
  String? renterSupportChatId;
  String? ownerSupportChatId;
  num? depositCoveredAmount;
  num? outstandingAmount;
  num? paidOutstandingAmount;
  String? resolvedBy;
  dynamic resolvedAt;

  DamageDeductionRequest({
    this.status,
    this.requestedAmount,
    this.approvedAmount,
    this.reason,
    this.notes,
    this.evidenceUrls = const [],
    this.requiresSupportReview,
    this.overDepositRequested,
    this.requestedBy,
    this.requestedAt,
    this.renterResponse,
    this.updatedAt,
    this.supportStatus,
    this.adminNotes,
    this.renterSupportChatId,
    this.ownerSupportChatId,
    this.depositCoveredAmount,
    this.outstandingAmount,
    this.paidOutstandingAmount,
    this.resolvedBy,
    this.resolvedAt,
  });

  DamageDeductionRequest copyWith({
    String? status,
    num? requestedAmount,
    num? approvedAmount,
    String? reason,
    String? notes,
    List<String>? evidenceUrls,
    bool? requiresSupportReview,
    bool? overDepositRequested,
    String? requestedBy,
    dynamic requestedAt,
    String? renterResponse,
    dynamic updatedAt,
    String? supportStatus,
    String? adminNotes,
    String? renterSupportChatId,
    String? ownerSupportChatId,
    num? depositCoveredAmount,
    num? outstandingAmount,
    num? paidOutstandingAmount,
    String? resolvedBy,
    dynamic resolvedAt,
  }) {
    return DamageDeductionRequest(
      status: status ?? this.status,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      requiresSupportReview:
          requiresSupportReview ?? this.requiresSupportReview,
      overDepositRequested: overDepositRequested ?? this.overDepositRequested,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      renterResponse: renterResponse ?? this.renterResponse,
      updatedAt: updatedAt ?? this.updatedAt,
      supportStatus: supportStatus ?? this.supportStatus,
      adminNotes: adminNotes ?? this.adminNotes,
      renterSupportChatId: renterSupportChatId ?? this.renterSupportChatId,
      ownerSupportChatId: ownerSupportChatId ?? this.ownerSupportChatId,
      depositCoveredAmount: depositCoveredAmount ?? this.depositCoveredAmount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      paidOutstandingAmount:
          paidOutstandingAmount ?? this.paidOutstandingAmount,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return _withoutNullValues(<String, dynamic>{
      'status': status,
      'requestedAmount': requestedAmount,
      'approvedAmount': approvedAmount,
      'reason': reason,
      'notes': notes,
      'evidenceUrls': evidenceUrls,
      'requiresSupportReview': requiresSupportReview,
      'overDepositRequested': overDepositRequested,
      'requestedBy': requestedBy,
      'requestedAt': requestedAt,
      'renterResponse': renterResponse,
      'updatedAt': updatedAt,
      'supportStatus': supportStatus,
      'adminNotes': adminNotes,
      'renterSupportChatId': renterSupportChatId,
      'ownerSupportChatId': ownerSupportChatId,
      'depositCoveredAmount': depositCoveredAmount,
      'outstandingAmount': outstandingAmount,
      'paidOutstandingAmount': paidOutstandingAmount,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt,
    });
  }

  factory DamageDeductionRequest.fromMap(Map<String, dynamic> map) {
    return DamageDeductionRequest(
      status: map['status'] != null ? map['status'] as String : null,
      requestedAmount:
          map['requestedAmount'] != null ? map['requestedAmount'] as num : null,
      approvedAmount:
          map['approvedAmount'] != null ? map['approvedAmount'] as num : null,
      reason: map['reason'] != null ? map['reason'] as String : null,
      notes: map['notes'] != null ? map['notes'] as String : null,
      evidenceUrls:
          map['evidenceUrls'] != null
              ? List<String>.from(map['evidenceUrls'] as List)
              : const [],
      requiresSupportReview:
          map['requiresSupportReview'] != null
              ? map['requiresSupportReview'] as bool
              : null,
      overDepositRequested:
          map['overDepositRequested'] != null
              ? map['overDepositRequested'] as bool
              : null,
      requestedBy:
          map['requestedBy'] != null ? map['requestedBy'] as String : null,
      requestedAt: map['requestedAt'],
      renterResponse:
          map['renterResponse'] != null
              ? map['renterResponse'] as String
              : null,
      updatedAt: map['updatedAt'],
      supportStatus:
          map['supportStatus'] != null ? map['supportStatus'] as String : null,
      adminNotes:
          map['adminNotes'] != null ? map['adminNotes'] as String : null,
      renterSupportChatId:
          map['renterSupportChatId'] != null
              ? map['renterSupportChatId'] as String
              : null,
      ownerSupportChatId:
          map['ownerSupportChatId'] != null
              ? map['ownerSupportChatId'] as String
              : null,
      depositCoveredAmount:
          map['depositCoveredAmount'] != null
              ? map['depositCoveredAmount'] as num
              : null,
      outstandingAmount:
          map['outstandingAmount'] != null
              ? map['outstandingAmount'] as num
              : null,
      paidOutstandingAmount:
          map['paidOutstandingAmount'] != null
              ? map['paidOutstandingAmount'] as num
              : null,
      resolvedBy:
          map['resolvedBy'] != null ? map['resolvedBy'] as String : null,
      resolvedAt: map['resolvedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DamageDeductionRequest.fromJson(String source) =>
      DamageDeductionRequest.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'DamageDeductionRequest(status: $status, requestedAmount: $requestedAmount, approvedAmount: $approvedAmount, reason: $reason, notes: $notes, renterResponse: $renterResponse)';
  }

  @override
  bool operator ==(covariant DamageDeductionRequest other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.requestedAmount == requestedAmount &&
        other.approvedAmount == approvedAmount &&
        other.reason == reason &&
        other.notes == notes &&
        other.evidenceUrls == evidenceUrls &&
        other.requiresSupportReview == requiresSupportReview &&
        other.overDepositRequested == overDepositRequested &&
        other.requestedBy == requestedBy &&
        other.requestedAt == requestedAt &&
        other.renterResponse == renterResponse &&
        other.updatedAt == updatedAt &&
        other.supportStatus == supportStatus &&
        other.adminNotes == adminNotes &&
        other.renterSupportChatId == renterSupportChatId &&
        other.ownerSupportChatId == ownerSupportChatId &&
        other.depositCoveredAmount == depositCoveredAmount &&
        other.outstandingAmount == outstandingAmount &&
        other.paidOutstandingAmount == paidOutstandingAmount &&
        other.resolvedBy == resolvedBy &&
        other.resolvedAt == resolvedAt;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        requestedAmount.hashCode ^
        approvedAmount.hashCode ^
        reason.hashCode ^
        notes.hashCode ^
        evidenceUrls.hashCode ^
        requiresSupportReview.hashCode ^
        overDepositRequested.hashCode ^
        requestedBy.hashCode ^
        requestedAt.hashCode ^
        renterResponse.hashCode ^
        updatedAt.hashCode ^
        supportStatus.hashCode ^
        adminNotes.hashCode ^
        renterSupportChatId.hashCode ^
        ownerSupportChatId.hashCode ^
        depositCoveredAmount.hashCode ^
        outstandingAmount.hashCode ^
        paidOutstandingAmount.hashCode ^
        resolvedBy.hashCode ^
        resolvedAt.hashCode;
  }
}

class Payment {
  String? provider;
  String? method;
  String? transactionId;
  String? paymongoPaymentIntentId;
  String? paymongoPaymentId;
  String? checkoutId;
  Map<String, dynamic>? details;
  num? amount;
  num? paymongoAmount;
  num? rentalSubtotal;
  Map<String, dynamic>? pricingBreakdown;
  String? currency;
  String? status;
  int? paymongoFee;
  int? paymongoNetAmount;
  num? ownerPayoutAmount;
  String? payoutStatus;
  String? paymongoWalletTransactionId;
  String? payoutReferenceNumber;
  String? payoutError;

  Payment({
    this.provider,
    this.method,
    this.transactionId,
    this.paymongoPaymentIntentId,
    this.paymongoPaymentId,
    this.checkoutId,
    this.details,
    this.amount,
    this.paymongoAmount,
    this.rentalSubtotal,
    this.pricingBreakdown,
    this.currency,
    this.status,
    this.paymongoFee,
    this.paymongoNetAmount,
    this.ownerPayoutAmount,
    this.payoutStatus,
    this.paymongoWalletTransactionId,
    this.payoutReferenceNumber,
    this.payoutError,
  });

  Payment copyWith({
    String? provider,
    String? method,
    String? transactionId,
    String? paymongoPaymentIntentId,
    String? paymongoPaymentId,
    String? checkoutId,
    Map<String, dynamic>? details,
    num? amount,
    num? paymongoAmount,
    num? rentalSubtotal,
    Map<String, dynamic>? pricingBreakdown,
    String? currency,
    String? status,
    int? paymongoFee,
    int? paymongoNetAmount,
    num? ownerPayoutAmount,
    String? payoutStatus,
    String? paymongoWalletTransactionId,
    String? payoutReferenceNumber,
    String? payoutError,
  }) {
    return Payment(
      provider: provider ?? this.provider,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      paymongoPaymentIntentId:
          paymongoPaymentIntentId ?? this.paymongoPaymentIntentId,
      paymongoPaymentId: paymongoPaymentId ?? this.paymongoPaymentId,
      checkoutId: checkoutId ?? this.checkoutId,
      details: details ?? this.details,
      amount: amount ?? this.amount,
      paymongoAmount: paymongoAmount ?? this.paymongoAmount,
      rentalSubtotal: rentalSubtotal ?? this.rentalSubtotal,
      pricingBreakdown: pricingBreakdown ?? this.pricingBreakdown,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymongoFee: paymongoFee ?? this.paymongoFee,
      paymongoNetAmount: paymongoNetAmount ?? this.paymongoNetAmount,
      ownerPayoutAmount: ownerPayoutAmount ?? this.ownerPayoutAmount,
      payoutStatus: payoutStatus ?? this.payoutStatus,
      paymongoWalletTransactionId:
          paymongoWalletTransactionId ?? this.paymongoWalletTransactionId,
      payoutReferenceNumber:
          payoutReferenceNumber ?? this.payoutReferenceNumber,
      payoutError: payoutError ?? this.payoutError,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'provider': provider,
      'method': method,
      'transactionId': transactionId,
      'paymongoPaymentIntentId': paymongoPaymentIntentId,
      'paymongoPaymentId': paymongoPaymentId,
      'checkoutId': checkoutId,
      'details': details,
      'amount': amount,
      'paymongoAmount': paymongoAmount,
      'rentalSubtotal': rentalSubtotal,
      'pricingBreakdown': pricingBreakdown,
      'currency': currency,
      'status': status,
      'paymongoFee': paymongoFee,
      'paymongoNetAmount': paymongoNetAmount,
      'ownerPayoutAmount': ownerPayoutAmount,
      'payoutStatus': payoutStatus,
      'paymongoWalletTransactionId': paymongoWalletTransactionId,
      'payoutReferenceNumber': payoutReferenceNumber,
      'payoutError': payoutError,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      provider: map['provider'] != null ? map['provider'] as String : null,
      method: map['method'] != null ? map['method'] as String : null,
      transactionId:
          map['transactionId'] != null ? map['transactionId'] as String : null,
      paymongoPaymentIntentId:
          map['paymongoPaymentIntentId'] != null
              ? map['paymongoPaymentIntentId'] as String
              : null,
      paymongoPaymentId:
          map['paymongoPaymentId'] != null
              ? map['paymongoPaymentId'] as String
              : null,
      checkoutId:
          map['checkoutId'] != null ? map['checkoutId'] as String : null,
      details:
          map['details'] != null
              ? Map<String, dynamic>.from(map['details'] as Map)
              : null,
      amount: map['amount'] != null ? map['amount'] as num : null,
      paymongoAmount:
          map['paymongoAmount'] != null ? map['paymongoAmount'] as num : null,
      rentalSubtotal:
          map['rentalSubtotal'] != null ? map['rentalSubtotal'] as num : null,
      pricingBreakdown:
          map['pricingBreakdown'] != null
              ? Map<String, dynamic>.from(map['pricingBreakdown'] as Map)
              : null,
      currency: map['currency'] != null ? map['currency'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      paymongoFee:
          map['paymongoFee'] != null ? map['paymongoFee'] as int : null,
      paymongoNetAmount:
          map['paymongoNetAmount'] != null
              ? map['paymongoNetAmount'] as int
              : null,
      ownerPayoutAmount:
          map['ownerPayoutAmount'] != null
              ? map['ownerPayoutAmount'] as num
              : null,
      payoutStatus:
          map['payoutStatus'] != null ? map['payoutStatus'] as String : null,
      paymongoWalletTransactionId:
          map['paymongoWalletTransactionId'] != null
              ? map['paymongoWalletTransactionId'] as String
              : null,
      payoutReferenceNumber:
          map['payoutReferenceNumber'] != null
              ? map['payoutReferenceNumber'] as String
              : null,
      payoutError:
          map['payoutError'] != null ? map['payoutError'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Payment.fromJson(String source) =>
      Payment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Payment(provider: $provider, method: $method, transactionId: $transactionId, amount: $amount, rentalSubtotal: $rentalSubtotal, status: $status, ownerPayoutAmount: $ownerPayoutAmount, payoutStatus: $payoutStatus)';
  }

  @override
  bool operator ==(covariant Payment other) {
    if (identical(this, other)) return true;

    return other.provider == provider &&
        other.method == method &&
        other.transactionId == transactionId &&
        other.paymongoPaymentIntentId == paymongoPaymentIntentId &&
        other.paymongoPaymentId == paymongoPaymentId &&
        other.checkoutId == checkoutId &&
        other.details == details &&
        other.amount == amount &&
        other.paymongoAmount == paymongoAmount &&
        other.rentalSubtotal == rentalSubtotal &&
        other.pricingBreakdown == pricingBreakdown &&
        other.currency == currency &&
        other.status == status &&
        other.paymongoFee == paymongoFee &&
        other.paymongoNetAmount == paymongoNetAmount &&
        other.ownerPayoutAmount == ownerPayoutAmount &&
        other.payoutStatus == payoutStatus &&
        other.paymongoWalletTransactionId == paymongoWalletTransactionId &&
        other.payoutReferenceNumber == payoutReferenceNumber &&
        other.payoutError == payoutError;
  }

  @override
  int get hashCode {
    return provider.hashCode ^
        method.hashCode ^
        transactionId.hashCode ^
        paymongoPaymentIntentId.hashCode ^
        paymongoPaymentId.hashCode ^
        checkoutId.hashCode ^
        details.hashCode ^
        amount.hashCode ^
        paymongoAmount.hashCode ^
        rentalSubtotal.hashCode ^
        pricingBreakdown.hashCode ^
        currency.hashCode ^
        status.hashCode ^
        paymongoFee.hashCode ^
        paymongoNetAmount.hashCode ^
        ownerPayoutAmount.hashCode ^
        payoutStatus.hashCode ^
        paymongoWalletTransactionId.hashCode ^
        payoutReferenceNumber.hashCode ^
        payoutError.hashCode;
  }
}

class AddBooking {
  String? id;
  String? chatId;
  Asset? asset;
  Timestamp? createdAt;
  Timestamp? startDate;
  Timestamp? endDate;
  int? numDays;
  Payment? payment;
  SimpleUserModel? renter;
  String? status;
  int? totalPrice;
  AddBooking({
    required this.id,
    required this.chatId,
    required this.asset,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.numDays,
    required this.payment,
    required this.renter,
    required this.status,
    required this.totalPrice,
  });

  AddBooking copyWith({
    String? id,
    String? chatId,
    Asset? asset,
    Timestamp? createdAt,
    Timestamp? startDate,
    Timestamp? endDate,
    int? numDays,
    Payment? payment,
    SimpleUserModel? renter,
    String? status,
    int? totalPrice,
  }) {
    return AddBooking(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      asset: asset ?? this.asset,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numDays: numDays ?? this.numDays,
      payment: payment ?? this.payment,
      renter: renter ?? this.renter,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chatId': chatId,
      'asset': asset?.toMap(),
      'createdAt':
          createdAt != null
              ? Timestamp(createdAt!.seconds, createdAt!.nanoseconds)
              : null,
      'startDate':
          startDate != null
              ? Timestamp(startDate!.seconds, startDate!.nanoseconds)
              : null,
      'endDate':
          endDate != null
              ? Timestamp(endDate!.seconds, endDate!.nanoseconds)
              : null,
      'numDays': numDays,
      'payment': payment?.toMap(),
      'renter': renter?.toMap(),
      'status': status,
      'totalPrice': totalPrice,
    };
  }

  factory AddBooking.fromMap(Map<String, dynamic> map) {
    return AddBooking(
      id: map['id'] != null ? map['id'] as String : null,
      chatId: map['chatId'] != null ? map['chatId'] as String : null,
      asset:
          map['asset'] != null
              ? Asset.fromMap(map['asset'] as Map<String, dynamic>)
              : null,
      createdAt:
          map['createdAt'] != null
              ? map['createdAt'] is Timestamp
                  ? map['createdAt'] as Timestamp
                  : Timestamp(
                    map['createdAt']['_seconds'],
                    map['createdAt']['_nanoseconds'],
                  )
              : null,
      startDate:
          map['startDate'] != null
              ? map['startDate'] is Timestamp
                  ? map['startDate'] as Timestamp
                  : Timestamp(
                    map['startDate']['_seconds'],
                    map['startDate']['_nanoseconds'],
                  )
              : null,
      endDate:
          map['endDate'] != null
              ? map['endDate'] is Timestamp
                  ? map['endDate'] as Timestamp
                  : Timestamp(
                    map['endDate']['_seconds'],
                    map['endDate']['_nanoseconds'],
                  )
              : null,
      numDays: map['numDays'] != null ? map['numDays'] as int : null,
      payment:
          map['payment'] != null
              ? Payment.fromMap(map['payment'] as Map<String, dynamic>)
              : null,
      renter:
          map['renter'] != null
              ? SimpleUserModel.fromMap(map['renter'] as Map<String, dynamic>)
              : null,
      status: map['status'] != null ? map['status'] as String : null,
      totalPrice: map['totalPrice'] != null ? map['totalPrice'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddBooking.fromJson(String source) =>
      AddBooking.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AddBooking(id: $id, chatId: $chatId, asset: $asset, createdAt: $createdAt, startDate: $startDate, endDate: $endDate, numDays: $numDays, payment: $payment, renter: $renter, status: $status, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(covariant AddBooking other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.chatId == chatId &&
        other.asset == asset &&
        other.createdAt == createdAt &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.numDays == numDays &&
        other.payment == payment &&
        other.renter == renter &&
        other.status == status &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatId.hashCode ^
        asset.hashCode ^
        createdAt.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        numDays.hashCode ^
        payment.hashCode ^
        renter.hashCode ^
        status.hashCode ^
        totalPrice.hashCode;
  }
}

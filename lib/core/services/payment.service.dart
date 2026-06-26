import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class LNDPaymentServiceException implements Exception {
  final String message;

  const LNDPaymentServiceException(this.message);

  @override
  String toString() => message;
}

class LNDPaymentService {
  static const bool isCardSavingEnabled = false;
  static const Duration _payoutInstitutionsCacheTtl = Duration(minutes: 30);

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.paymongo.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static List<LNDSavedPaymentMethod>? _savedPaymentMethodsCache;
  static Future<LNDPaymentDestinations>? _payoutDestinationsRequest;
  static final List<LNDSavedPaymentMethod> _localCardMethods =
      <LNDSavedPaymentMethod>[];
  static bool _savedPaymentMethodsDirty = true;
  static final Set<String> _checkoutsThatMaySaveCards = <String>{};

  static bool get hasSavedPaymentMethodsCache =>
      _savedPaymentMethodsCache != null;

  static bool get isSavedPaymentMethodsCacheDirty => _savedPaymentMethodsDirty;

  static List<LNDSavedPaymentMethod> get cachedSavedPaymentMethods =>
      _withDebugTestCards(<LNDSavedPaymentMethod>[
        ...(_savedPaymentMethodsCache ?? const <LNDSavedPaymentMethod>[]),
        ..._localCardMethods,
      ]);

  static List<LNDSavedPaymentMethod> get localCardMethods =>
      List<LNDSavedPaymentMethod>.unmodifiable(_localCardMethods);

  static LNDSavedPaymentMethod addLocalCard({
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required bool shouldSaveCard,
  }) {
    final method = LNDSavedPaymentMethod.localCard(
      localId: 'local_card_${DateTime.now().microsecondsSinceEpoch}',
      cardNumber: cardNumber,
      expMonth: expMonth,
      expYear: expYear,
      shouldSaveCard: shouldSaveCard,
    );
    _localCardMethods.add(method);
    return method;
  }

  static Future<LNDPaymentCheckout> createPaymentCheckout({
    required String assetId,
    required DateTime startDate,
    required DateTime endDate,
    required int totalPrice,
    required LNDSelectedPaymentMethod paymentMethod,
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.createPaymentCheckout,
    );
    final result = await callable.call({
      'assetId': assetId,
      'startDateMs': LNDUtils.bookingDateMillisecondsSinceEpoch(startDate),
      'endDateMs': LNDUtils.bookingDateMillisecondsSinceEpoch(endDate),
      'totalPrice': totalPrice,
      'selectedPaymentMethod': paymentMethod.methodType,
      'selectedPaymentMethodDetails': paymentMethod.serverDetails,
      'shouldSaveCard': false,
    });
    final checkout = LNDPaymentCheckout.fromMap(
      Map<String, dynamic>.from(result.data),
    );
    await savePendingPaymentMarker(
      checkoutId: checkout.checkoutId,
      assetId: assetId,
      checkoutLockExpiresAtMs: checkout.checkoutLockExpiresAtMs,
    );
    if (_shouldTrackSavedPaymentMethodCache(
      paymentMethod: paymentMethod,
      checkout: checkout,
    )) {
      _checkoutsThatMaySaveCards.add(checkout.checkoutId);
    }
    return checkout;
  }

  static Future<LNDPaymentCheckout> createDamageBalancePaymentCheckout({
    required String bookingId,
    required String chatId,
    required String damagePaymentRequestId,
    required LNDSelectedPaymentMethod paymentMethod,
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.createDamageBalancePaymentCheckout,
    );
    final result = await callable.call({
      'bookingId': bookingId,
      'chatId': chatId,
      'damagePaymentRequestId': damagePaymentRequestId,
      'selectedPaymentMethod': paymentMethod.methodType,
      'selectedPaymentMethodDetails': paymentMethod.serverDetails,
      'shouldSaveCard': false,
    });
    final checkout = LNDPaymentCheckout.fromMap(
      Map<String, dynamic>.from(result.data),
    );
    if (_shouldTrackSavedPaymentMethodCache(
      paymentMethod: paymentMethod,
      checkout: checkout,
    )) {
      _checkoutsThatMaySaveCards.add(checkout.checkoutId);
    }
    return checkout;
  }

  static Future<List<LNDSavedPaymentMethod>> listSavedPaymentMethods({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        !_savedPaymentMethodsDirty &&
        _savedPaymentMethodsCache != null) {
      return cachedSavedPaymentMethods;
    }

    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.listSavedPaymentMethods,
    );
    final result = await callable.call();
    final data = Map<String, dynamic>.from(result.data);
    final methods = List<dynamic>.from(data['paymentMethods'] ?? const []);
    final parsed = methods
        .map(
          (method) => LNDSavedPaymentMethod.fromMap(
            Map<String, dynamic>.from(method as Map),
          ),
        )
        .toList(growable: false);
    _savedPaymentMethodsCache = parsed;
    _savedPaymentMethodsDirty = false;
    return cachedSavedPaymentMethods;
  }

  static Future<Map<String, dynamic>> createPaymentMethod({
    required String publicKey,
    required LNDSelectedPaymentMethod selected,
    Map<String, dynamic>? billingDetails,
  }) async {
    if (selected.isDebugPayMongoTestCard &&
        payMongoPublicKeyMode(publicKey) != 'test') {
      throw const LNDPaymentServiceException(
        'PayMongo test cards require test API keys.',
      );
    }

    final attributes = buildPaymentMethodAttributes(
      selected,
      billingDetails: billingDetails,
    );
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/payment_methods',
        options: Options(headers: _headers(publicKey)),
        data: {
          'data': {'attributes': attributes},
        },
      );

      return Map<String, dynamic>.from(response.data ?? const {});
    } on DioException catch (error) {
      _debugLogPaymentMethodError(error, selected, publicKey);
      throw LNDPaymentServiceException(paymentMethodErrorMessage(error));
    }
  }

  @visibleForTesting
  static Map<String, dynamic> buildPaymentMethodAttributes(
    LNDSelectedPaymentMethod selected, {
    Map<String, dynamic>? billingDetails,
  }) {
    final attributes = <String, dynamic>{
      'type': selected.methodType,
      if (selected.details.isNotEmpty) 'details': selected.details,
    };

    if (selected.kind == LNDPaymongoPaymentKind.newCard) {
      final cardNumber = selected.cardNumber?.replaceAll(' ', '');
      final cvc = selected.cvc;
      if (cardNumber == null ||
          cardNumber.isEmpty ||
          selected.expMonth == null ||
          selected.expYear == null ||
          cvc == null ||
          cvc.isEmpty) {
        throw const LNDPaymentServiceException('Card details are incomplete.');
      }

      attributes['details'] = {
        'card_number': cardNumber,
        'exp_month': selected.expMonth,
        'exp_year': selected.expYear,
        'cvc': cvc,
      };
    }

    final billing = _cleanMap(billingDetails);
    if (billing.isNotEmpty) {
      attributes['billing'] = billing;
    }

    return attributes;
  }

  static Map<String, dynamic> buildBillingDetails({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? line1,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    final name = [firstName, lastName]
        .map((value) => value?.trim())
        .where((value) => value != null && value.isNotEmpty)
        .join(' ');
    final address = _cleanMap({
      'line1': line1,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    });
    return _cleanMap({
      'name': name,
      'email': email,
      'phone': phone,
      if (address.isNotEmpty) 'address': address,
    });
  }

  @visibleForTesting
  static String payMongoPublicKeyMode(String publicKey) {
    final trimmed = publicKey.trim();
    if (trimmed.startsWith('pk_test_')) return 'test';
    if (trimmed.startsWith('pk_live_')) return 'live';
    return 'unknown';
  }

  @visibleForTesting
  static String paymentMethodErrorMessage(Object error) {
    if (error is LNDPaymentServiceException) return error.message;

    const prefix = 'Unable to create payment method';
    if (error is DioException) {
      final detail = _payMongoErrorDetail(error.response?.data);
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return 'Payment status code: $statusCode.';
      }

      final message = error.message;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return '$prefix.';
  }

  static Future<LNDPaymentSyncResult> attachPaymentMethod({
    required LNDPaymentCheckout checkout,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/payment_intents/${checkout.paymentIntentId}/attach',
        options: Options(headers: _headers(checkout.publicKey)),
        data: {
          'data': {
            'attributes': {
              'payment_method': paymentMethodId,
              'client_key': checkout.clientKey,
              'return_url': checkout.returnUrl,
            },
          },
        },
      );

      final intent = Map<String, dynamic>.from(response.data ?? const {});
      final attributes = Map<String, dynamic>.from(
        (intent['data'] as Map?)?['attributes'] as Map? ?? const {},
      );
      _debugLogAttachPaymentMethodResult(
        checkout: checkout,
        attributes: attributes,
      );
      if (attributes['status'] == 'succeeded') {
        return syncPaymentCheckout(checkout.checkoutId);
      }

      final result = LNDPaymentSyncResult(
        status: attributes['status'] as String? ?? 'unknown',
        paymentStatus: attributes['status'] as String?,
        nextAction:
            attributes['next_action'] is Map
                ? Map<String, dynamic>.from(attributes['next_action'] as Map)
                : null,
        lastPaymentError:
            attributes['last_payment_error'] is Map
                ? Map<String, dynamic>.from(
                  attributes['last_payment_error'] as Map,
                )
                : null,
      );
      await _clearPendingMarkerIfTerminal(checkout.checkoutId, result);
      return result;
    } on DioException catch (error) {
      _debugLogAttachPaymentMethodError(error, checkout, paymentMethodId);
      throw LNDPaymentServiceException(paymentMethodErrorMessage(error));
    }
  }

  static Future<LNDPaymentSyncResult> attachSavedCardPaymentMethod({
    required String checkoutId,
    required String customerPaymentMethodId,
    required String cvc,
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.attachSavedCardPaymentMethod,
    );
    final result = await callable.call({
      'checkoutId': checkoutId,
      'customerPaymentMethodId': customerPaymentMethodId,
      'cvc': cvc,
    });
    final syncResult = LNDPaymentSyncResult.fromMap(
      Map<String, dynamic>.from(result.data),
    );
    _syncSavedPaymentMethodCacheState(checkoutId, syncResult);
    await _clearPendingMarkerIfTerminal(checkoutId, syncResult);
    return syncResult;
  }

  static Future<LNDPaymentSyncResult> syncPaymentCheckout(
    String checkoutId,
  ) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.syncPaymentCheckout,
    );
    final result = await callable.call({'checkoutId': checkoutId});
    final syncResult = LNDPaymentSyncResult.fromMap(
      Map<String, dynamic>.from(result.data),
    );
    _syncSavedPaymentMethodCacheState(checkoutId, syncResult);
    await _clearPendingMarkerIfTerminal(checkoutId, syncResult);
    return syncResult;
  }

  static bool isRecoverablePaymentStatus(String? status) {
    final normalized = status?.trim().toLowerCase();
    return normalized == 'processing' ||
        normalized == 'subscription_pending' ||
        normalized == 'pending' ||
        normalized == 'awaiting_next_action' ||
        normalized == 'awaiting_action' ||
        normalized == 'requires_action' ||
        normalized == 'requires_source_action';
  }

  static bool isMissingRequiredNextActionUrl(
    LNDPaymentSyncResult result,
    String? redirectUrl,
  ) {
    final status = result.paymentStatus ?? result.status;
    final normalized = status.trim().toLowerCase();
    return normalized == 'awaiting_next_action' &&
        result.nextAction?['type']?.toString().trim().toLowerCase() ==
            'redirect' &&
        (redirectUrl == null || redirectUrl.trim().isEmpty);
  }

  static String missingNextActionUrlMessage() {
    return 'PayMongo did not return a 3DS authentication URL. Please try another card or contact support.';
  }

  static String? nextActionRedirectUrl(Map<String, dynamic>? nextAction) {
    final redirect = _nestedMap(nextAction, 'redirect');
    return _firstNonEmptyString([
          redirect?['url'],
          redirect?['redirect_url'],
          nextAction?['redirect_url'],
          nextAction?['url'],
          _findNestedString(nextAction, const {'redirect_url', 'url'}),
        ]) ??
        nextActionTestUrl(nextAction);
  }

  static String? nextActionTestUrl(Map<String, dynamic>? nextAction) {
    final redirect = _nestedMap(nextAction, 'redirect');
    final code = _nestedMap(nextAction, 'code');
    return _firstNonEmptyString([
      redirect?['test_url'],
      code?['test_url'],
      nextAction?['test_url'],
      _findNestedString(nextAction, const {'test_url'}),
    ]);
  }

  static String? nextActionQrImageUrl(Map<String, dynamic>? nextAction) {
    final code = _nestedMap(nextAction, 'code');
    return _firstNonEmptyString([
      code?['image_url'],
      nextAction?['image_url'],
      _findNestedString(nextAction, const {'image_url'}),
    ]);
  }

  static Future<LNDPendingPaymentRecovery> recoverPendingPaymentCheckout({
    String? checkoutId,
    String? assetId,
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.recoverPendingPaymentCheckout,
    );
    final result = await callable.call({
      if (checkoutId != null) 'checkoutId': checkoutId,
      if (assetId != null) 'assetId': assetId,
    });
    final recovery = LNDPendingPaymentRecovery.fromMap(
      Map<String, dynamic>.from(result.data),
    );
    if (!recovery.hasPendingCheckout || recovery.isTerminal) {
      await clearPendingPaymentMarker(checkoutId: checkoutId);
    }
    return recovery;
  }

  static Future<void> cancelPaymentCheckout({
    required String checkoutId,
    String? reason,
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.cancelPaymentCheckout,
    );
    await callable.call({
      'checkoutId': checkoutId,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
    _checkoutsThatMaySaveCards.remove(checkoutId);
    await clearPendingPaymentMarker(checkoutId: checkoutId);
  }

  static Future<void> savePendingPaymentMarker({
    required String checkoutId,
    required String assetId,
    int? checkoutLockExpiresAtMs,
  }) async {
    await LNDStorageService.write(
      LNDStorageConstants.pendingPaymentCheckout,
      LNDPendingPaymentMarker(
        checkoutId: checkoutId,
        assetId: assetId,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
        checkoutLockExpiresAtMs: checkoutLockExpiresAtMs,
      ).toMap(),
    );
  }

  static LNDPendingPaymentMarker? readPendingPaymentMarker() {
    final data = LNDStorageService.read<dynamic>(
      LNDStorageConstants.pendingPaymentCheckout,
    );
    if (data is! Map) return null;
    try {
      return LNDPendingPaymentMarker.fromMap(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPendingPaymentMarker({String? checkoutId}) async {
    if (checkoutId != null) {
      final marker = readPendingPaymentMarker();
      if (marker != null && marker.checkoutId != checkoutId) return;
    }
    await LNDStorageService.remove(LNDStorageConstants.pendingPaymentCheckout);
  }

  static Future<void> _clearPendingMarkerIfTerminal(
    String checkoutId,
    LNDPaymentSyncResult result,
  ) async {
    if (result.isBooked ||
        result.isPaid ||
        result.status == 'failed' ||
        result.status == 'expired' ||
        result.status == 'cancelled') {
      await clearPendingPaymentMarker(checkoutId: checkoutId);
    }
  }

  static Stream<LNDPaymentCheckoutStatus> watchPaymentCheckout(
    String checkoutId,
  ) {
    return FirebaseFirestore.instance
        .collection(LNDCollections.paymentCheckouts.name)
        .doc(checkoutId)
        .snapshots()
        .where((snapshot) => snapshot.exists)
        .map((snapshot) {
          final data = snapshot.data() ?? const <String, dynamic>{};
          return LNDPaymentCheckoutStatus.fromMap(snapshot.id, data);
        });
  }

  static Future<void> setOwnerPayoutDestination({
    required LNDPayoutDestination destination,
    String destinationKind = 'owner_payout',
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.setOwnerPayoutDestination,
    );
    await callable.call({
      ...destination.toMap(),
      'destinationKind': destinationKind,
    });
    await _updatePayoutDestinationsCache(
      destination: destination,
      destinationKind: destinationKind,
    );
  }

  static Future<LNDPayoutDestination?> getOwnerPayoutDestination({
    bool forceRefresh = false,
  }) async {
    final destinations = await getPayoutDestinations(
      forceRefresh: forceRefresh,
    );
    return destinations.payoutDestination;
  }

  static Future<LNDPayoutDestination?> getDepositReturnDestination({
    bool forceRefresh = false,
  }) async {
    final destinations = await getPayoutDestinations(
      forceRefresh: forceRefresh,
    );
    return destinations.depositReturnDestination;
  }

  static Future<LNDPaymentDestinations> getPayoutDestinations({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _readCachedPayoutDestinations();
      if (cached != null) return cached;
    }
    if (!forceRefresh && _payoutDestinationsRequest != null) {
      return _payoutDestinationsRequest!;
    }

    final request = _fetchPayoutDestinations();
    _payoutDestinationsRequest = request;
    try {
      final destinations = await request;
      await _writeCachedPayoutDestinations(destinations);
      return destinations;
    } finally {
      if (identical(_payoutDestinationsRequest, request)) {
        _payoutDestinationsRequest = null;
      }
    }
  }

  static Future<LNDPaymentDestinations> _fetchPayoutDestinations() async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.getOwnerPayoutDestination,
    );
    final result = await callable.call();
    final data = Map<String, dynamic>.from(result.data);
    return LNDPaymentDestinations(
      payoutDestination:
          data['payoutDestination'] is Map
              ? LNDPayoutDestination.fromMap(
                Map<String, dynamic>.from(data['payoutDestination'] as Map),
              )
              : null,
      depositReturnDestination:
          data['depositReturnDestination'] is Map
              ? LNDPayoutDestination.fromMap(
                Map<String, dynamic>.from(
                  data['depositReturnDestination'] as Map,
                ),
              )
              : null,
    );
  }

  static Future<void> clearPayoutDestinationsCache() async {
    _payoutDestinationsRequest = null;
    final key = _payoutDestinationsCacheKey();
    if (key == null) return;
    await LNDStorageService.remove(key);
  }

  static Future<void> _updatePayoutDestinationsCache({
    required LNDPayoutDestination destination,
    required String destinationKind,
  }) async {
    final current =
        _readCachedPayoutDestinations() ??
        const LNDPaymentDestinations(
          payoutDestination: null,
          depositReturnDestination: null,
        );
    if (destinationKind == 'deposit_return') {
      await _writeCachedPayoutDestinations(
        LNDPaymentDestinations(
          payoutDestination: current.payoutDestination,
          depositReturnDestination: destination,
        ),
      );
      return;
    }

    await _writeCachedPayoutDestinations(
      LNDPaymentDestinations(
        payoutDestination: destination,
        depositReturnDestination: current.depositReturnDestination,
      ),
    );
  }

  static LNDPaymentDestinations? _readCachedPayoutDestinations() {
    final key = _payoutDestinationsCacheKey();
    if (key == null) return null;

    final cache = LNDStorageService.read<dynamic>(key);
    if (cache is! Map) return null;

    final payoutDestination = cache['payoutDestination'];
    final depositReturnDestination = cache['depositReturnDestination'];

    return LNDPaymentDestinations(
      payoutDestination:
          payoutDestination is Map
              ? LNDPayoutDestination.fromMap(
                Map<String, dynamic>.from(payoutDestination),
              )
              : null,
      depositReturnDestination:
          depositReturnDestination is Map
              ? LNDPayoutDestination.fromMap(
                Map<String, dynamic>.from(depositReturnDestination),
              )
              : null,
    );
  }

  static Future<void> _writeCachedPayoutDestinations(
    LNDPaymentDestinations destinations,
  ) async {
    final key = _payoutDestinationsCacheKey();
    if (key == null) return;

    await LNDStorageService.write(key, {
      'fetchedAtMs': DateTime.now().millisecondsSinceEpoch,
      'payoutDestination': destinations.payoutDestination?.toMap(),
      'depositReturnDestination':
          destinations.depositReturnDestination?.toMap(),
    });
  }

  static String? _payoutDestinationsCacheKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return '${LNDStorageConstants.payoutDestinationsCachePrefix}.$uid';
  }

  static Future<List<LNDPayoutInstitution>> listPayoutInstitutions({
    required String destinationType,
    String provider = 'instapay',
    bool forceRefresh = false,
  }) async {
    final typeKey = destinationType == 'ewallet' ? 'ewallet' : 'bank';
    final providerKey = provider == 'pesonet' ? 'pesonet' : 'instapay';
    final cacheKey = '$typeKey.$providerKey';
    if (!forceRefresh) {
      final cached = _readCachedPayoutInstitutions(cacheKey);
      if (cached != null) return cached;
    }

    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.listPayoutInstitutions,
    );
    final result = await callable.call({'destinationType': typeKey});
    final data = Map<String, dynamic>.from(result.data);
    final institutionsKey =
        providerKey == 'pesonet'
            ? 'pesonetInstitutions'
            : 'instapayInstitutions';
    final institutions = List<dynamic>.from(
      data[institutionsKey] ?? data['institutions'] ?? const [],
    );
    final parsed = institutions
        .map(
          (institution) => LNDPayoutInstitution.fromMap(
            Map<String, dynamic>.from(institution as Map),
          ),
        )
        .toList(growable: false);
    await _writeCachedPayoutInstitutions(cacheKey, parsed);
    return List<LNDPayoutInstitution>.unmodifiable(parsed);
  }

  static Map<String, String> _headers(String apiKey) {
    return {
      'accept': 'application/json',
      'content-type': 'application/json',
      'authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
    };
  }

  static bool _shouldTrackSavedPaymentMethodCache({
    required LNDSelectedPaymentMethod paymentMethod,
    required LNDPaymentCheckout checkout,
  }) {
    if (!isCardSavingEnabled) return false;
    if (paymentMethod.kind != LNDPaymongoPaymentKind.newCard) return false;
    return paymentMethod.shouldSaveCard;
  }

  static void _syncSavedPaymentMethodCacheState(
    String checkoutId,
    LNDPaymentSyncResult result,
  ) {
    if (!_checkoutsThatMaySaveCards.contains(checkoutId)) return;

    if (result.isBooked) {
      _checkoutsThatMaySaveCards.remove(checkoutId);
      _savedPaymentMethodsDirty = true;
      return;
    }

    if (result.paymentStatus == 'awaiting_payment_method' ||
        result.status == 'failed' ||
        result.status == 'expired') {
      _checkoutsThatMaySaveCards.remove(checkoutId);
    }
  }

  @visibleForTesting
  static bool shouldTrackSavedPaymentMethodCacheForTesting({
    required LNDSelectedPaymentMethod paymentMethod,
    required LNDPaymentCheckout checkout,
  }) {
    return _shouldTrackSavedPaymentMethodCache(
      paymentMethod: paymentMethod,
      checkout: checkout,
    );
  }

  @visibleForTesting
  static void resetSavedPaymentMethodCacheForTesting({bool dirty = true}) {
    _savedPaymentMethodsCache = null;
    _savedPaymentMethodsDirty = dirty;
    _checkoutsThatMaySaveCards.clear();
    _localCardMethods.clear();
  }

  @visibleForTesting
  static void trackSavedPaymentMethodCacheForTesting(String checkoutId) {
    _checkoutsThatMaySaveCards.add(checkoutId);
  }

  @visibleForTesting
  static void syncSavedPaymentMethodCacheStateForTesting(
    String checkoutId,
    LNDPaymentSyncResult result,
  ) {
    _syncSavedPaymentMethodCacheState(checkoutId, result);
  }

  static List<LNDSavedPaymentMethod> _withDebugTestCards(
    List<LNDSavedPaymentMethod> methods,
  ) {
    if (!kDebugMode) {
      return List<LNDSavedPaymentMethod>.unmodifiable(methods);
    }

    final seenIds = methods.map((method) => method.id).toSet();
    return List<LNDSavedPaymentMethod>.unmodifiable([
      ..._debugPayMongoTestCards.where((method) => seenIds.add(method.id)),
      ...methods,
    ]);
  }

  static final List<LNDSavedPaymentMethod> _debugPayMongoTestCards = [
    _debugPayMongoTestCard(
      id: 'success_visa_no_3ds_4345',
      cardNumber: '4343434343434345',
      subtitle: 'PayMongo test: Visa success, no 3DS',
    ),
    _debugPayMongoTestCard(
      id: 'success_visa_no_3ds_0075',
      cardNumber: '4571736000000075',
      subtitle: 'PayMongo test: Visa success, no 3DS',
    ),
    _debugPayMongoTestCard(
      id: 'success_mastercard_no_3ds_0002',
      cardNumber: '5123000000000002',
      subtitle: 'PayMongo test: Mastercard success, no 3DS',
    ),
    _debugPayMongoTestCard(
      id: 'success_visa_3ds_required_0007',
      cardNumber: '4120000000000007',
      subtitle: 'PayMongo test: Visa success, 3DS required',
    ),
    _debugPayMongoTestCard(
      id: 'success_mastercard_3ds_optional_0001',
      cardNumber: '5123000000000001',
      subtitle: 'PayMongo test: Mastercard success, 3DS optional',
    ),
    _debugPayMongoTestCard(
      id: 'decline_expired_card_0018',
      cardNumber: '4200000000000018',
      subtitle: 'PayMongo test decline: expired card',
    ),
    _debugPayMongoTestCard(
      id: 'decline_invalid_cvc_0017',
      cardNumber: '4300000000000017',
      subtitle: 'PayMongo test decline: invalid CVC',
    ),
    _debugPayMongoTestCard(
      id: 'decline_insufficient_funds_0198',
      cardNumber: '5100000000000198',
      subtitle: 'PayMongo test decline: insufficient funds',
    ),
    _debugPayMongoTestCard(
      id: 'decline_generic_1111',
      cardNumber: '4111111111111111',
      subtitle: 'PayMongo test decline: generic decline',
    ),
  ];

  static LNDSavedPaymentMethod _debugPayMongoTestCard({
    required String id,
    required String cardNumber,
    required String subtitle,
  }) {
    return LNDSavedPaymentMethod.localCard(
      localId: 'debug_paymongo_$id',
      cardNumber: cardNumber,
      expMonth: 12,
      expYear: 2030,
      shouldSaveCard: false,
      subtitle: subtitle,
    );
  }

  static String? _payMongoErrorDetail(Object? data) {
    if (data is! Map) return null;
    final errors = data['errors'];
    if (errors is! List) return null;

    final details =
        errors
            .whereType<Map>()
            .map((error) => error['detail'] ?? error['code'])
            .whereType<Object>()
            .map((detail) => detail.toString().trim())
            .where((detail) => detail.isNotEmpty)
            .toList();
    if (details.isEmpty) return null;
    return details.join('; ');
  }

  static Map<String, dynamic> _cleanMap(Map<String, dynamic>? source) {
    if (source == null) return <String, dynamic>{};
    final cleaned = <String, dynamic>{};
    source.forEach((key, value) {
      if (value == null) return;
      if (value is Map<String, dynamic>) {
        final nested = _cleanMap(value);
        if (nested.isNotEmpty) cleaned[key] = nested;
        return;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) cleaned[key] = text;
    });
    return cleaned;
  }

  static Map<String, dynamic>? _nestedMap(
    Map<String, dynamic>? source,
    String key,
  ) {
    final value = source?[key];
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String? _firstNonEmptyString(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _findNestedString(
    Object? value,
    Set<String> keys, [
    int depth = 0,
  ]) {
    if (value == null || depth > 5) return null;
    if (value is Map) {
      for (final key in keys) {
        final match = value[key];
        final text = match?.toString().trim();
        if (text != null && text.isNotEmpty) return text;
      }
      for (final child in value.values) {
        final found = _findNestedString(child, keys, depth + 1);
        if (found != null) return found;
      }
    }
    if (value is Iterable) {
      for (final child in value) {
        final found = _findNestedString(child, keys, depth + 1);
        if (found != null) return found;
      }
    }
    return null;
  }

  static void _debugLogPaymentMethodError(
    DioException error,
    LNDSelectedPaymentMethod selected,
    String publicKey,
  ) {
    if (!kDebugMode) return;
    final last4 = selected.last4 ?? _last4(selected.cardNumber);
    debugPrint(
      'PayMongo payment method failed: '
      'status=${error.response?.statusCode}, '
      'keyMode=${payMongoPublicKeyMode(publicKey)}, '
      'method=${selected.methodType}, '
      'last4=${last4 ?? 'unknown'}, '
      'expMonth=${selected.expMonth ?? 'unknown'}, '
      'expYear=${selected.expYear ?? 'unknown'}, '
      'detail=${_payMongoErrorDetail(error.response?.data) ?? error.message}',
    );
  }

  static void _debugLogAttachPaymentMethodError(
    DioException error,
    LNDPaymentCheckout checkout,
    String paymentMethodId,
  ) {
    checkout.checkoutId;
    checkout.clientKey;
    checkout.paymentIntentId;
    checkout.publicKey;
    checkout.returnUrl;
    if (!kDebugMode) return;
    debugPrint(
      'PayMongo attach payment method failed: '
      'status=${error.response?.statusCode}, '
      'checkoutId=${checkout.checkoutId}, '
      'clientKey=${checkout.clientKey}, '
      'paymentIntentId=${checkout.paymentIntentId}, '
      'publicKey=${checkout.publicKey}, '
      'returnUrl=${checkout.returnUrl}, '
      'detail=${_payMongoErrorDetail(error.response?.data) ?? error.message}',
    );
  }

  static void _debugLogAttachPaymentMethodResult({
    required LNDPaymentCheckout checkout,
    required Map<String, dynamic> attributes,
  }) {
    if (!kDebugMode) return;
    final nextAction = attributes['next_action'];
    final lastPaymentError = attributes['last_payment_error'];
    debugPrint(
      'PayMongo attach payment method result: '
      'checkoutId=${checkout.checkoutId}, '
      'paymentIntentId=${checkout.paymentIntentId}, '
      'status=${attributes['status'] ?? 'unknown'}, '
      'nextActionKeys=${nextAction is Map ? nextAction.keys.toList() : 'none'}, '
      'lastPaymentError=${lastPaymentError ?? 'none'}',
    );
  }

  static String? _last4(String? cardNumber) {
    final normalized = cardNumber?.replaceAll(RegExp(r'\D'), '');
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized.length <= 4) return normalized;
    return normalized.substring(normalized.length - 4);
  }

  static List<LNDPayoutInstitution>? _readCachedPayoutInstitutions(
    String destinationType,
  ) {
    final cache = LNDStorageService.read<Map<String, dynamic>>(
      _payoutInstitutionsCacheKey(destinationType),
    );
    if (cache == null) return null;

    final fetchedAtMs = cache['fetchedAtMs'];
    if (fetchedAtMs is! int ||
        DateTime.now().millisecondsSinceEpoch - fetchedAtMs >
            _payoutInstitutionsCacheTtl.inMilliseconds) {
      LNDStorageService.remove(_payoutInstitutionsCacheKey(destinationType));
      return null;
    }

    final institutions = cache['institutions'];
    if (institutions is! List) return null;

    return List<LNDPayoutInstitution>.unmodifiable(
      institutions
          .whereType<Map>()
          .map(
            (institution) => LNDPayoutInstitution.fromMap(
              Map<String, dynamic>.from(institution),
            ),
          )
          .toList(growable: false),
    );
  }

  static Future<void> _writeCachedPayoutInstitutions(
    String destinationType,
    List<LNDPayoutInstitution> institutions,
  ) async {
    await LNDStorageService.write(
      _payoutInstitutionsCacheKey(destinationType),
      {
        'fetchedAtMs': DateTime.now().millisecondsSinceEpoch,
        'institutions':
            institutions.map((institution) => institution.toMap()).toList(),
      },
    );
  }

  static String _payoutInstitutionsCacheKey(String destinationType) {
    return '${LNDStorageConstants.payoutInstitutionsCachePrefix}.$destinationType';
  }
}

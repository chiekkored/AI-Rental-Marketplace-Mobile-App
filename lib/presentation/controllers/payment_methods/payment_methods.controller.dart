import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/payment_method_config.model.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/payment_method_config.service.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class PaymentMethodsPageArgs {
  final LNDSelectedPaymentMethod? current;
  final bool recurringBillingOnly;

  const PaymentMethodsPageArgs({
    this.current,
    this.recurringBillingOnly = false,
  });
}

class PaymentMethodsController extends GetxController {
  final PaymentMethodsPageArgs args;

  PaymentMethodsController({PaymentMethodsPageArgs? args})
    : args =
          args ??
          (Get.arguments as PaymentMethodsPageArgs?) ??
          const PaymentMethodsPageArgs();

  final RxList<LNDSavedPaymentMethod> savedMethods =
      <LNDSavedPaymentMethod>[].obs;
  final RxBool isLoadingSavedMethods = false.obs;
  final RxBool shouldSaveCard = false.obs;
  final RxBool isCardSectionExpanded = true.obs;
  final RxBool isWalletSectionExpanded = false.obs;
  final RxBool isBankSectionExpanded = false.obs;
  final Rx<LNDPaymentMethodConfig> paymentMethodConfig =
      LNDPaymentMethodConfig.defaultConfig.obs;

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expMonthController = TextEditingController();
  final TextEditingController expYearController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  LNDSavedPaymentMethod? _selectedSavedCard;
  StreamSubscription<LNDPaymentMethodConfig>? _paymentMethodConfigSubscription;

  bool get recurringBillingOnly => args.recurringBillingOnly;

  bool get isSaveCardRequiredForRecurring => false;

  bool get canToggleSaveCard => !isSaveCardRequiredForRecurring;

  List<LNDSavedPaymentMethod> get visibleSavedMethods {
    if (!recurringBillingOnly) return savedMethods;
    return isCardPaymentVisible
        ? savedMethods
        : const <LNDSavedPaymentMethod>[];
  }

  @override
  void onInit() {
    super.onInit();
    _initializeExpandedSection();
    _watchPaymentMethodConfig();
    loadSavedMethods();
  }

  @override
  void onClose() {
    savedMethods.close();
    isLoadingSavedMethods.close();
    shouldSaveCard.close();
    isCardSectionExpanded.close();
    isWalletSectionExpanded.close();
    isBankSectionExpanded.close();
    paymentMethodConfig.close();
    _paymentMethodConfigSubscription?.cancel();
    cardNumberController.dispose();
    expMonthController.dispose();
    expYearController.dispose();
    cvcController.dispose();
    super.onClose();
  }

  Future<void> loadSavedMethods() async {
    try {
      final cachedMethods = LNDPaymentService.cachedSavedPaymentMethods;
      if (LNDPaymentService.hasSavedPaymentMethodsCache ||
          cachedMethods.isNotEmpty) {
        savedMethods.value = cachedMethods;
      }
      isLoadingSavedMethods.value =
          !LNDPaymentService.hasSavedPaymentMethodsCache &&
          cachedMethods.isEmpty;
      savedMethods.value = await LNDPaymentService.listSavedPaymentMethods();
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    } finally {
      isLoadingSavedMethods.value = false;
    }
  }

  void setCardSectionExpanded(bool value) {
    isCardSectionExpanded.value = value;
  }

  void setWalletSectionExpanded(bool value) {
    isWalletSectionExpanded.value = value;
  }

  void setBankSectionExpanded(bool value) {
    isBankSectionExpanded.value = value;
  }

  void prepareNewCardForm() {
    _selectedSavedCard = null;
    cardNumberController.clear();
    expMonthController.clear();
    expYearController.clear();
    cvcController.clear();
    shouldSaveCard.value = isSaveCardRequiredForRecurring;
  }

  void prepareSavedCardForm(LNDSavedPaymentMethod method) {
    _selectedSavedCard = method;
    cardNumberController.text =
        method.cardNumber == null
            ? method.displayLabel
            : _formatCardNumber(method.cardNumber!);
    expMonthController.text =
        method.expMonth == null
            ? ''
            : method.expMonth!.toString().padLeft(2, '0');
    expYearController.text = method.expYear?.toString() ?? '';
    cvcController.clear();
    shouldSaveCard.value = false;
  }

  void applyNewCard() {
    final card = _readValidatedCard();
    if (card == null) return;

    final shouldStoreCard =
        isSaveCardRequiredForRecurring || shouldSaveCard.value;
    final method = LNDPaymentService.addLocalCard(
      cardNumber: card.number,
      expMonth: card.month,
      expYear: card.year,
      shouldSaveCard: shouldStoreCard,
    );

    Get.back();
    Get.back(
      result: LNDSelectedPaymentMethod.newCard(
        cardNumber: card.number,
        expMonth: card.month,
        expYear: card.year,
        cvc: card.cvc,
        shouldSaveCard: shouldStoreCard,
        localCardId: method.id,
      ),
    );
  }

  void applySavedCardCvc() {
    final method = _selectedSavedCard;
    final cvc = cvcController.text.trim();

    if (method == null) {
      LNDSnackbar.showError('Select a saved card.');
      return;
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(cvc)) {
      LNDSnackbar.showError('Enter a valid CVC.');
      return;
    }

    if (recurringBillingOnly && !isCardPaymentEnabled) {
      LNDSnackbar.showError('Card is not enabled for subscription payments.');
      return;
    }

    Get.back();
    Get.back(
      result:
          method.isLocal
              ? LNDSelectedPaymentMethod.newCard(
                cardNumber: method.cardNumber!,
                expMonth: method.expMonth!,
                expYear: method.expYear!,
                cvc: cvc,
                shouldSaveCard: false,
                localCardId: method.id,
              )
              : LNDSelectedPaymentMethod.savedCard(
                savedMethod: method,
                cvc: cvc,
              ),
    );
  }

  _ValidatedCard? _readValidatedCard() {
    final number = cardNumberController.text.replaceAll(RegExp(r'\s+'), '');
    final month = int.tryParse(expMonthController.text.trim());
    final year = int.tryParse(expYearController.text.trim());
    final cvc = cvcController.text.trim();

    if (number.length < 12 || number.length > 19) {
      LNDSnackbar.showError('Enter a valid card number.');
      return null;
    }

    if (month == null || month < 1 || month > 12) {
      LNDSnackbar.showError('Enter a valid expiry month.');
      return null;
    }

    if (year == null || year < DateTime.now().year) {
      LNDSnackbar.showError('Enter a valid expiry year.');
      return null;
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(cvc)) {
      LNDSnackbar.showError('Enter a valid CVC.');
      return null;
    }

    return _ValidatedCard(number: number, month: month, year: year, cvc: cvc);
  }

  void useChannel(LNDSelectedPaymentMethod method) {
    if (recurringBillingOnly &&
        !isPaymentMethodEnabled(_configIdForSelectedMethod(method))) {
      LNDSnackbar.showError(
        '${method.label} is not enabled for subscription payments.',
      );
      return;
    }
    Get.back(result: method);
  }

  bool isCardSelected(LNDSavedPaymentMethod method) {
    final current = args.current;
    if (current == null || !current.isCard) return false;
    if (method.isLocal) return current.localCardId == method.id;
    return current.customerPaymentMethodId == method.id;
  }

  bool isChannelSelected(String methodType, {String? bankCode}) {
    final current = args.current;
    if (current == null || current.isCard) return false;
    if (current.methodType != methodType) return false;
    if (bankCode == null) return true;
    return current.details['bank_code'] == bankCode;
  }

  void _initializeExpandedSection() {
    final current = args.current;
    if (current == null) return;

    isCardSectionExpanded.value = current.isCard;
    isWalletSectionExpanded.value =
        !current.isCard && !current.details.containsKey('bank_code');
    isBankSectionExpanded.value =
        !current.isCard && current.details.containsKey('bank_code');
  }

  String _formatCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  bool isPaymentMethodVisible(String id) {
    return _paymentMethodState(id).visible;
  }

  bool isPaymentMethodEnabled(String id) {
    return _paymentMethodState(id).enabled;
  }

  bool get isCardPaymentVisible => isPaymentMethodVisible('card');

  bool get isCardPaymentEnabled => isPaymentMethodEnabled('card');

  List<String> get visibleWalletPaymentMethodIds {
    final ids = [
      'gcash',
      'paymaya',
      if (!recurringBillingOnly) ...['grab_pay', 'shopeepay', 'qrph'],
    ];
    return ids.where(isPaymentMethodVisible).toList(growable: false);
  }

  bool get hasVisibleWalletPaymentMethods =>
      visibleWalletPaymentMethodIds.isNotEmpty;

  List<String> get visibleBankPaymentMethodIds {
    const ids = ['bpi', 'ubp', 'bdo', 'landbank', 'metrobank'];
    return ids.where(isPaymentMethodVisible).toList(growable: false);
  }

  bool get hasVisibleBankPaymentMethods =>
      visibleBankPaymentMethodIds.isNotEmpty;

  LNDPaymentMethodState _paymentMethodState(String id) {
    final config = paymentMethodConfig.value;
    return recurringBillingOnly
        ? config.subscriptionState(id)
        : config.upfrontState(id);
  }

  String _configIdForSelectedMethod(LNDSelectedPaymentMethod method) {
    final bankCode = method.details['bank_code'];
    if (bankCode is String && bankCode.trim().isNotEmpty) {
      return bankCode.trim().toLowerCase();
    }
    return method.methodType;
  }

  void _watchPaymentMethodConfig() {
    _paymentMethodConfigSubscription =
        LNDPaymentMethodConfigService.watchPaymentMethodConfig().listen(
          (config) => paymentMethodConfig.value = config,
          onError: (Object error, StackTrace stackTrace) {
            LNDLogger.e(
              'Payment method config watch failed',
              error: error,
              stackTrace: stackTrace,
            );
            paymentMethodConfig.value = LNDPaymentMethodConfig.defaultConfig;
          },
        );
  }
}

class _ValidatedCard {
  final String number;
  final int month;
  final int year;
  final String cvc;

  const _ValidatedCard({
    required this.number,
    required this.month,
    required this.year,
    required this.cvc,
  });
}

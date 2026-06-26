import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/payout_institution_picker/payout_institution_picker.controller.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

enum OwnerPayoutDestinationPurpose { ownerPayout, depositReturn }

class OwnerPayoutDestinationPageArgs {
  final OwnerPayoutDestinationPurpose purpose;

  const OwnerPayoutDestinationPageArgs({required this.purpose});
}

class OwnerPayoutDestinationController extends GetxController with AuthMixin {
  static OwnerPayoutDestinationController get instance =>
      Get.find<OwnerPayoutDestinationController>();

  final Rx<OwnerPayoutDestinationPurpose> purpose =
      OwnerPayoutDestinationPurpose.ownerPayout.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasSavedDestination = false.obs;
  final RxBool hasSavedDepositDestination = false.obs;
  final RxBool isEditing = true.obs;
  final RxBool isError = false.obs;
  final RxBool _canSaveDestination = false.obs;
  final RxString destinationType = 'bank'.obs;
  final RxString provider = 'instapay'.obs;

  final TextEditingController bankIdController = TextEditingController();
  final TextEditingController bankCodeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
      TextEditingController();
  final RxList<String> supportedProviders = <String>[].obs;

  bool get isBank => destinationType.value == 'bank';
  bool get isDepositReturn =>
      purpose.value == OwnerPayoutDestinationPurpose.depositReturn;
  bool get hasSavedActiveDestination =>
      isDepositReturn
          ? hasSavedDepositDestination.value
          : hasSavedDestination.value;
  bool get fieldsEnabled =>
      (!hasSavedActiveDestination || isEditing.value) && !isError.value;
  bool get showSaveButton =>
      fieldsEnabled && !isLoading.value && !isError.value;
  bool get canSaveDestination => _canSaveDestination.value;
  String get pageTitle =>
      isDepositReturn ? 'Deposit Return Destination' : 'Payout Destination';
  String get sectionTitle =>
      isDepositReturn ? 'Deposit return destination' : 'Payout destination';
  String get savedMessage =>
      isDepositReturn
          ? 'Deposit return destination saved.'
          : 'Payout destination saved.';
  String get transferNoticeText =>
      isDepositReturn
          ? 'Transfer fees and deposit return timing are applied from current Lend policy.'
          : 'Transfer fees and payout timing are applied from current Lend policy.';
  String get typeLabel => isBank ? 'Bank account' : 'E-wallet';
  String get institutionLabel => isBank ? 'Bank name' : 'E-wallet name';
  String get accountNumberLabel => isBank ? 'Account number' : 'Mobile number';
  String get confirmAccountNumberLabel =>
      isBank ? 'Retype account number' : 'Retype mobile number';
  String get institutionHint =>
      isBank ? 'Select supported bank' : 'Select supported e-wallet';
  bool get isInstapay => provider.value == 'instapay';

  bool get shouldShowMissingPayoutDestinationBanner =>
      isAuthenticated && !hasSavedDestination.value;
  bool get shouldShowMissingDepositReturnDestinationBanner =>
      isAuthenticated && !hasSavedDepositDestination.value;
  bool get shouldShowMissingPayoutDestinationWarning =>
      shouldShowMissingPayoutDestinationBanner && !isLoading.value;
  bool get shouldShowMissingDepositReturnDestinationWarning =>
      shouldShowMissingDepositReturnDestinationBanner && !isLoading.value;

  OwnerPayoutDestinationController() {
    for (final controller in [
      bankIdController,
      bankNameController,
      accountNameController,
      accountNumberController,
      confirmAccountNumberController,
    ]) {
      controller.addListener(_refreshSaveEligibility);
    }
  }

  @override
  void onClose() {
    for (final controller in [
      bankIdController,
      bankNameController,
      accountNameController,
      accountNumberController,
      confirmAccountNumberController,
    ]) {
      controller.removeListener(_refreshSaveEligibility);
    }
    purpose.close();
    isLoading.close();
    isSaving.close();
    hasSavedDestination.close();
    hasSavedDepositDestination.close();
    isEditing.close();
    _canSaveDestination.close();
    destinationType.close();
    provider.close();
    isError.close();
    supportedProviders.close();
    bankIdController.dispose();
    bankCodeController.dispose();
    bankNameController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    super.onClose();
  }

  Future<void> configurePurpose(OwnerPayoutDestinationPurpose value) async {
    if (purpose.value == value && !isLoading.value) {
      await loadDestination();
      return;
    }

    purpose.value = value;
    isEditing.value = true;
    isError.value = false;
    _clearForm();
    await loadDestination();
  }

  Future<void> loadDestination({bool forceRefresh = false}) async {
    if (!isAuthenticated) return;

    try {
      isLoading.value = true;
      isError.value = false;
      final destinations = await LNDPaymentService.getPayoutDestinations(
        forceRefresh: forceRefresh,
      );
      final payoutDestination = destinations.payoutDestination;
      final depositReturnDestination = destinations.depositReturnDestination;

      hasSavedDestination.value = payoutDestination != null;
      hasSavedDepositDestination.value = depositReturnDestination != null;

      final activeDestination =
          isDepositReturn ? depositReturnDestination : payoutDestination;
      if (activeDestination != null) {
        _populateDestination(activeDestination);
        isEditing.value = false;
      } else {
        _clearForm();
        isEditing.value = true;
      }
      _refreshSaveEligibility();
    } catch (e, st) {
      isError.value = true;
      _refreshSaveEligibility();
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to load ${_destinationErrorLabel()}.');
    } finally {
      isLoading.value = false;
      _refreshSaveEligibility();
    }
  }

  void beginEditing() {
    confirmAccountNumberController.text = accountNumberController.text;
    isEditing.value = true;
    _refreshSaveEligibility();
  }

  void setDestinationType(String value) {
    if (!fieldsEnabled || destinationType.value == value) return;
    destinationType.value = value;
    _clearInstitution();
    _refreshSaveEligibility();
  }

  void setProvider(String value) {
    if (!fieldsEnabled || provider.value == value) return;
    provider.value = value == 'pesonet' ? 'pesonet' : 'instapay';
    _clearInstitution();
    _refreshSaveEligibility();
  }

  Future<void> selectInstitution() async {
    if (!fieldsEnabled) return;
    final result =
        await (LNDNavigate.toPayoutInstitutionPickerPage(
              args: PayoutInstitutionPickerPageArgs(
                destinationType: destinationType.value,
                provider: provider.value,
              ),
            ) ??
            Future<LNDPayoutInstitution?>.value());
    if (result == null) return;

    final institution = result as LNDPayoutInstitution;

    bankIdController.text = institution.id;
    bankCodeController.text = institution.code;
    bankNameController.text = institution.name;
    supportedProviders.assignAll(institution.supportedProviders);
    _refreshSaveEligibility();
  }

  Future<void> saveDestination() async {
    if (isSaving.value) return;

    final destination = LNDPayoutDestination(
      destinationType: destinationType.value,
      provider: provider.value,
      bankId: bankIdController.text.trim(),
      bankCode: bankCodeController.text.trim(),
      bankName: bankNameController.text.trim(),
      accountName: accountNameController.text.trim(),
      accountNumber: accountNumberController.text.trim(),
      supportedProviders: [provider.value],
    );

    if (!_isValid(destination)) return;

    try {
      isSaving.value = true;
      _refreshSaveEligibility();
      await LNDPaymentService.setOwnerPayoutDestination(
        destination: destination,
        destinationKind: isDepositReturn ? 'deposit_return' : 'owner_payout',
      );

      if (isDepositReturn) {
        hasSavedDepositDestination.value = true;
      } else {
        hasSavedDestination.value = true;
      }
      LNDSnackbar.showSuccess(savedMessage);
      isEditing.value = false;
      confirmAccountNumberController.text = destination.accountNumber;
      Get.back();
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError(_saveErrorText(e));
    } finally {
      isSaving.value = false;
      _refreshSaveEligibility();
    }
  }

  bool _isValid(LNDPayoutDestination destination) {
    if (destination.bankId.isEmpty ||
        destination.bankName.isEmpty ||
        destination.accountName.isEmpty ||
        destination.accountNumber.isEmpty) {
      LNDSnackbar.showError(
        'Complete all ${_destinationErrorLabel()} details.',
      );
      return false;
    }

    if (confirmAccountNumberController.text.trim() !=
        destination.accountNumber) {
      LNDSnackbar.showError('$accountNumberLabel does not match.');
      return false;
    }

    if (destination.accountName.length > 120 ||
        destination.accountNumber.length > 40) {
      LNDSnackbar.showError('${pageTitle.toLowerCase()} details are too long.');
      return false;
    }

    return true;
  }

  String _saveErrorText(Object error) {
    final text = error.toString();
    if (text.contains('Full verification')) {
      return isDepositReturn
          ? 'Full verification is required before receiving deposit returns.'
          : 'Full verification is required before receiving payouts.';
    }
    return 'Unable to save ${_destinationErrorLabel()}.';
  }

  void _clearInstitution() {
    bankIdController.clear();
    bankCodeController.clear();
    bankNameController.clear();
    accountNumberController.clear();
    confirmAccountNumberController.clear();
    supportedProviders.clear();
    _refreshSaveEligibility();
  }

  void _refreshSaveEligibility() {
    final accountNumber = accountNumberController.text.trim();
    final confirmAccountNumber = confirmAccountNumberController.text.trim();
    _canSaveDestination.value =
        fieldsEnabled &&
        !isLoading.value &&
        !isSaving.value &&
        bankIdController.text.trim().isNotEmpty &&
        bankNameController.text.trim().isNotEmpty &&
        accountNameController.text.trim().isNotEmpty &&
        accountNumber.isNotEmpty &&
        confirmAccountNumber.isNotEmpty &&
        accountNumber == confirmAccountNumber;
  }

  void _populateDestination(LNDPayoutDestination destination) {
    destinationType.value = destination.destinationType;
    provider.value = destination.provider == 'pesonet' ? 'pesonet' : 'instapay';
    bankIdController.text = destination.bankId;
    bankCodeController.text = destination.bankCode;
    bankNameController.text = destination.bankName;
    accountNameController.text = destination.accountName;
    accountNumberController.text = destination.accountNumber;
    confirmAccountNumberController.text = destination.accountNumber;
    supportedProviders.assignAll(destination.supportedProviders);
  }

  void _clearForm() {
    destinationType.value = 'bank';
    provider.value = 'instapay';
    bankIdController.clear();
    bankCodeController.clear();
    bankNameController.clear();
    accountNameController.clear();
    accountNumberController.clear();
    confirmAccountNumberController.clear();
    supportedProviders.clear();
    _refreshSaveEligibility();
  }

  String _destinationErrorLabel() {
    return isDepositReturn
        ? 'deposit return destination'
        : 'payout destination';
  }

  void openPayoutAccountInfo() {
    if (isDepositReturn) {
      LNDShow.bottomSheetInfo([
        LNDText.regular(
          text:
              'Your deposit return destination is where we send eligible security deposit returns after the booking is settled.',
          overflow: TextOverflow.visible,
        ),
        LNDText.regular(
          text:
              'Deposit returns are sent from Lend to your selected bank or e-wallet. This destination is separate from an owner payout destination.',
          overflow: TextOverflow.visible,
        ),
      ], title: 'How deposit returns work');
      return;
    }

    LNDShow.bottomSheetInfo([
      LNDText.regular(
        text:
            'Your payout destination is where we send your rental earnings after the item is marked "Returned" and settlement is complete.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'Payments are collected by Lend first, then paid out from our wallet to your selected bank or e-wallet. Deposit returns use a separate renter destination.',
        overflow: TextOverflow.visible,
      ),
    ], title: 'How payouts work');
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/biometric_auth.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/user.service.dart';
import 'package:lend/presentation/common/account_feedback_sheet.common.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/new_password/new_password.controller.dart';
import 'package:lend/core/services/secure_storage.service.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SettingsController extends GetxController {
  static const _systemModeValue = 'system';
  static const _darkModeValue = 'dark';
  static const _lightModeValue = 'light';

  final Rx<ThemeMode> themeMode = initialThemeMode.obs;
  final RxBool isBiometricEnabled = initIsEnableBiometrics.obs;

  VoidCallback? _removeBiometricListener;

  bool get hasPasswordProvider {
    final user =
        AuthController.instance.firebaseUser.value ??
        AuthController.instance.currentUser;
    return user?.providerData.any(
          (provider) => provider.providerId == 'password',
        ) ==
        true;
  }

  @override
  void onInit() {
    super.onInit();
    _removeBiometricListener = LNDStorageService.listenKey(
      LNDStorageConstants.enableBiometrics,
      (value) {
        isBiometricEnabled.value = value == true;
      },
    );
  }

  @override
  void onClose() {
    _removeBiometricListener?.call();
    themeMode.close();
    isBiometricEnabled.close();

    super.onClose();
  }

  static bool get initIsEnableBiometrics {
    final stored = LNDStorageService.read<bool>(
      LNDStorageConstants.enableBiometrics,
    );
    return stored == true;
  }

  static ThemeMode get initialThemeMode {
    final stored = LNDStorageService.read<String>(
      LNDStorageConstants.themeMode,
    );
    return switch (stored) {
      _darkModeValue => ThemeMode.dark,
      _lightModeValue => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  bool get isUsingSystemTheme => themeMode.value == ThemeMode.system;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  Future<void> setUseSystemTheme(bool value) async {
    final mode = value ? ThemeMode.system : ThemeMode.light;
    await _setThemeMode(mode);
  }

  Future<void> openCurrencyPicker() async {
    await LNDNavigate.toCountryCurrencyPickerPage();
  }

  Future<void> setDarkMode(bool value) async {
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    await _setThemeMode(mode);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await LNDStorageService.write(LNDStorageConstants.themeMode, switch (mode) {
      ThemeMode.system => _systemModeValue,
      ThemeMode.dark => _darkModeValue,
      ThemeMode.light => _lightModeValue,
    });
    Get.changeThemeMode(mode);
  }

  void onChangedBiometrics(bool isEnable) {
    unawaited(_updateBiometrics(isEnable));
  }

  Future<void> _updateBiometrics(bool isEnable) async {
    Future<void> setBiometricsEnabled(bool value) async {
      isBiometricEnabled.value = value;
      await LNDStorageService.write(
        LNDStorageConstants.enableBiometrics,
        value,
      );
    }

    Future<void> disableBiometrics() => setBiometricsEnabled(false);

    if (!isEnable) {
      await disableBiometrics();
      await LNDSecureStorageService.clearBiometricCredentials();
      return;
    }

    final isSupported = await LNDBiometricAuthService.canAuthenticate(
      showUnavailableDialog: true,
    );
    if (!isSupported) {
      await disableBiometrics();
      return;
    }

    final isAuthenticated = await LNDBiometricAuthService.authenticate(
      localizedReason: 'Authenticate to enable biometrics',
    );

    if (!isAuthenticated) {
      await disableBiometrics();
      return;
    }

    if (!hasPasswordProvider) {
      await disableBiometrics();
      LNDSnackbar.showError(
        'Biometrics is only available for email and password accounts.',
      );
      return;
    }

    await setBiometricsEnabled(true);
  }

  Future<void> openNewPasswordPage() async {
    if (!hasPasswordProvider) return;

    final isAuthenticated = await LNDBiometricAuthService.authenticate(
      localizedReason: 'Authenticate to update your password',
    );

    await LNDNavigate.toNewPasswordPage(
      args: NewPasswordPageArgs(skipOldPassword: isAuthenticated),
    );
  }

  void showDeleteAccountPopup() async {
    final submission = await LNDShow.bottomSheet<LNDAccountFeedbackSubmission>(
      const LNDAccountFeedbackSheet(action: LNDAccountFeedbackAction.delete),
    );
    if (submission == null) return;

    LNDLoading.show();
    final eligibilityResult =
        await UserService.getAccountDeletionEligibility();
    LNDLoading.hide();

    final canContinue = eligibilityResult.fold(
      ifLeft: (eligibility) async {
        if (eligibility.canDeactivate) return true;
        await LNDShow.bottomSheet<void>(
          _AccountBlockersSheet(
            eligibility: eligibility,
            title: 'Resolve pending items',
            description:
                'Your account cannot be deleted until these bookings, payments, disputes, or reviews are completed.',
            confirmText: 'Done',
          ),
        );
        return false;
      },
      ifRight: (error) async {
        LNDSnackbar.showError(error);
        return false;
      },
    );
    if (!await canContinue) return;

    final confirmed = await LNDShow.alertDialog<bool>(
      title: 'Delete Account',
      content:
          'Are you sure you want to close your account? Your access will be removed and required records may be retained.',
      cancelText: 'Cancel',
      confirmText: 'Close Account',
      confirmColor: Get.context!.lndTheme.danger,
    );
    if (confirmed != true) return;

    LNDLoading.show();

    final result = await UserService.deleteAccount(feedback: submission);

    LNDLoading.hide();
    result.fold(
      ifLeft: (result) async {
        if (result.success) {
          LNDSnackbar.showSuccess('Your account has been closed.');
          AuthController.instance.signOut(clearBiometricCredentials: true);
        } else {
          await LNDShow.bottomSheet<void>(
            _AccountBlockersSheet(
              eligibility: result.eligibility,
              title: 'Resolve pending items',
              description:
                  'Your account cannot be deleted until these bookings, payments, disputes, or reviews are completed.',
              confirmText: 'Done',
            ),
          );
        }
      },
      ifRight: (error) {
        LNDSnackbar.showError(error);
      },
    );
  }

  void showDeactivateAccountPopup() async {
    final submission = await LNDShow.bottomSheet<LNDAccountFeedbackSubmission>(
      const LNDAccountFeedbackSheet(
        action: LNDAccountFeedbackAction.deactivate,
      ),
    );
    if (submission == null) return;

    LNDLoading.show();
    final eligibilityResult =
        await UserService.getAccountDeactivationEligibility();
    LNDLoading.hide();

    final canContinue = eligibilityResult.fold(
      ifLeft: (eligibility) async {
        if (eligibility.canDeactivate) return true;
        await LNDShow.bottomSheet<void>(
          _AccountBlockersSheet(
            eligibility: eligibility,
            title: 'Resolve pending items',
            description:
                'Your account cannot be deactivated until these bookings, payments, disputes, or reviews are completed.',
            confirmText: 'Done',
          ),
        );
        return false;
      },
      ifRight: (error) async {
        LNDSnackbar.showError(error);
        return false;
      },
    );
    if (!await canContinue) return;

    final confirmed = await LNDShow.alertDialog<bool>(
      title: 'Deactivate Account',
      content:
          'Are you sure you want to deactivate your account? Your listings will be hidden and you will be signed out. You can reactivate by signing in again.',
      cancelText: 'Cancel',
      confirmText: 'Deactivate',
      confirmColor: Get.context!.lndTheme.danger,
    );
    if (confirmed != true) return;

    LNDLoading.show();

    final result = await UserService.deactivateAccount(feedback: submission);

    LNDLoading.hide();
    result.fold(
      ifLeft: (result) async {
        if (result.success) {
          LNDSnackbar.showSuccess('Your account has been deactivated.');
          AuthController.instance.signOut(clearBiometricCredentials: true);
        } else {
          await LNDShow.bottomSheet<void>(
            _AccountBlockersSheet(
              eligibility: result.eligibility,
              title: 'Resolve pending items',
              description:
                  'Your account cannot be deactivated until these bookings, payments, disputes, or reviews are completed.',
              confirmText: 'Done',
            ),
          );
        }
      },
      ifRight: (error) {
        LNDSnackbar.showError(error);
      },
    );
  }
}

class _AccountBlockersSheet extends StatelessWidget {
  const _AccountBlockersSheet({
    required this.eligibility,
    required this.title,
    required this.description,
    required this.confirmText,
  });

  final LNDAccountDeactivationEligibility eligibility;
  final String title;
  final String description;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDText.bold(text: title, fontSize: 18),
              const SizedBox(height: 8),
              LNDText.regular(
                text: description,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 16),
              ...eligibility.blockers.map(
                (group) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LNDText.semibold(text: '${group.title} (${group.count})'),
                      const SizedBox(height: 8),
                      ...group.items
                          .take(3)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: LNDText.regular(
                                text: [
                                  item.title,
                                  if (item.status != null) item.status,
                                ].join(' - '),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                      if (group.count > group.items.take(3).length)
                        LNDText.regular(
                          text:
                              '+${group.count - group.items.take(3).length} more',
                          color: colors.textMuted,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              LNDButton.primary(
                text: confirmText,
                enabled: true,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

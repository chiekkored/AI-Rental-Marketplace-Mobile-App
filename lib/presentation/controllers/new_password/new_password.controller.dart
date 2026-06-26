import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/textfields.mixin.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/secure_storage.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class NewPasswordPageArgs {
  final bool skipOldPassword;

  const NewPasswordPageArgs({required this.skipOldPassword});
}

class NewPasswordController extends GetxController with TextFieldsMixin {
  static NewPasswordController get instance =>
      Get.find<NewPasswordController>();

  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool _requiresOldPassword = false.obs;
  final RxBool _showOldPassword = false.obs;
  final RxBool _showNewPassword = false.obs;
  final RxBool _showConfirmPassword = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxString _newPassword = ''.obs;

  bool get requiresOldPassword => _requiresOldPassword.value;
  bool get showOldPassword => _showOldPassword.value;
  bool get showNewPassword => _showNewPassword.value;
  bool get showConfirmPassword => _showConfirmPassword.value;
  bool get isSubmitting => _isSubmitting.value;
  bool get hasMinimumLength => _newPassword.value.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(_newPassword.value);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(_newPassword.value);
  bool get hasNumber => RegExp(r'\d').hasMatch(_newPassword.value);
  bool get hasSpecialCharacter =>
      RegExp(r'[@$!%*?&]').hasMatch(_newPassword.value);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as NewPasswordPageArgs?;
    _requiresOldPassword.value = !(args?.skipOldPassword ?? false);
    newPasswordController.addListener(_syncNewPassword);
  }

  @override
  void onClose() {
    newPasswordController.removeListener(_syncNewPassword);
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _requiresOldPassword.close();
    _showOldPassword.close();
    _showNewPassword.close();
    _showConfirmPassword.close();
    _isSubmitting.close();
    _newPassword.close();
    super.onClose();
  }

  void _syncNewPassword() {
    _newPassword.value = newPasswordController.text;
  }

  void toggleOldPasswordVisibility() => _showOldPassword.toggle();
  void toggleNewPasswordVisibility() => _showNewPassword.toggle();
  void toggleConfirmPasswordVisibility() => _showConfirmPassword.toggle();

  String? validateOldPassword(String? value) {
    if (!requiresOldPassword) return null;
    if (value == null || value.isEmpty) return 'Current password is required';
    return null;
  }

  Future<void> submit() async {
    if (_isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim() ?? '';
    if (user == null || email.isEmpty) {
      LNDSnackbar.showError('Please sign in again to update your password.');
      return;
    }

    try {
      _isSubmitting.value = true;
      LNDLoading.show();

      if (requiresOldPassword) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: oldPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final newPassword = newPasswordController.text;
      await user.updatePassword(newPassword);

      if (LNDStorageService.read<bool>(LNDStorageConstants.enableBiometrics) ==
          true) {
        await LNDSecureStorageService.saveBiometricCredentials(
          email: email,
          password: newPassword,
        );
      }

      LNDLoading.hide();
      LNDSnackbar.showSuccess('Password updated.');
      Get.back();
    } on FirebaseAuthException catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(e.message ?? '', error: e, stackTrace: st);
      _handleFirebaseAuthException(e);
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to update password right now.');
    } finally {
      _isSubmitting.value = false;
    }
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        LNDSnackbar.showError('Current password is incorrect.');
      case 'weak-password':
        LNDSnackbar.showError('The new password provided is too weak.');
      case 'requires-recent-login':
        _requiresOldPassword.value = true;
        LNDSnackbar.showError(
          'Enter your current password to update your password.',
        );
      case 'network-request-failed':
        LNDSnackbar.showWarning('Please check connection and try again.');
      default:
        LNDSnackbar.showError('Unable to update password right now.');
    }
  }
}

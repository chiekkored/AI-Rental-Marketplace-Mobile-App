import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';

class LNDBiometricAuthService {
  LNDBiometricAuthService._();

  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> canAuthenticate({
    bool showUnavailableDialog = false,
  }) async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final biometrics = await _localAuth.getAvailableBiometrics();
      final available = supported && canCheck && biometrics.isNotEmpty;
      if (!available && showUnavailableDialog) _showSecurityPopup();
      return available;
    } on PlatformException catch (e, st) {
      LNDLogger.e(e.message ?? '', error: e, stackTrace: st);
      if (showUnavailableDialog) _showSecurityPopup();
      return false;
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      if (showUnavailableDialog) _showSecurityPopup();
      return false;
    }
  }

  static Future<bool> authenticate({required String localizedReason}) async {
    if (!await canAuthenticate()) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        persistAcrossBackgrounding: true,
        biometricOnly: true,
        authMessages: const [
          IOSAuthMessages(cancelButton: 'Close'),
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication required!',
            cancelButton: 'Close',
          ),
        ],
      );
    } on PlatformException catch (e, st) {
      LNDLogger.e(e.message ?? '', error: e, stackTrace: st);
      return false;
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      return false;
    }
  }

  static void _showSecurityPopup() {
    LNDShow.alertDialog(
      title: Platform.isIOS ? 'Face ID Unavailable' : 'Biometrics Unavailable',
      content:
          '${Platform.isIOS ? 'Face ID' : 'Biometrics'} is not set up or unavailable. Please configure it in your device settings first.',
      cancelText: 'Close',
      confirmText: 'Settings',
      onConfirm: () {
        AppSettings.openAppSettings(type: AppSettingsType.lockAndPassword);
      },
    );
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LNDLegalLinks {
  LNDLegalLinks._();

  static const _baseUrlKey = 'LEND_WEB_BASE_URL';
  static const _helpCenterPath = '/help-center';
  static const _privacyPolicyPath = '/privacy-policy';
  static const _termsAndConditionsPath = '/terms-and-conditions';

  static Future<void> openHelpCenter() {
    return _openPath(_helpCenterPath);
  }

  static Future<void> openPrivacyPolicy() {
    return _openPath(_privacyPolicyPath);
  }

  static Future<void> openTermsAndConditions() {
    return _openPath(_termsAndConditionsPath);
  }

  static Future<void> _openPath(String path) async {
    try {
      final url = _buildUrl(path);
      if (url == null) {
        LNDSnackbar.showError('Unable to open the link right now.');
        return;
      }

      final launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      if (!launched) {
        LNDSnackbar.showError('Unable to open the link right now.');
      }
    } catch (e, stackTrace) {
      LNDLogger.e('Error opening legal link', error: e, stackTrace: stackTrace);
      LNDSnackbar.showError('Unable to open the link right now.');
    }
  }

  static Uri? _buildUrl(String path) {
    final baseUrl = dotenv.env[_baseUrlKey]?.trim() ?? '';
    if (baseUrl.isEmpty) {
      LNDLogger.eNoStack('Missing $_baseUrlKey');
      return null;
    }

    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      LNDLogger.eNoStack('Invalid $_baseUrlKey', error: baseUrl);
      return null;
    }

    final normalizedBase = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.tryParse('$normalizedBase$path');
  }
}

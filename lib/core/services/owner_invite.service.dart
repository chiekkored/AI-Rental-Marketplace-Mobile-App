import 'package:cloud_functions/cloud_functions.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class LNDOwnerInviteClaimResult {
  final bool claimed;
  final bool alreadyClaimed;
  final String? displayName;

  const LNDOwnerInviteClaimResult({
    required this.claimed,
    this.alreadyClaimed = false,
    this.displayName,
  });
}

class LNDOwnerInviteService {
  LNDOwnerInviteService._();

  static String normalizeInviteCode(String value) {
    return value.trim().toUpperCase();
  }

  static String? inviteCodeFromUri(Uri uri) {
    final code = uri.queryParameters['code'] ?? uri.queryParameters['c'];
    final normalized = normalizeInviteCode(code ?? '');
    if (normalized.isEmpty) return null;

    if (uri.scheme == 'https' &&
        uri.host == 'getlend.dev' &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments.first == 'invite') {
      return normalized;
    }

    if (uri.scheme == 'lend' && uri.host == 'invite') {
      return normalized;
    }

    return null;
  }

  static String? readPendingInviteCode() {
    final code = LNDStorageService.read<String>(
      LNDStorageConstants.pendingOwnerInviteCode,
    );
    final normalized = normalizeInviteCode(code ?? '');
    return normalized.isEmpty ? null : normalized;
  }

  static Future<void> savePendingInviteCode(String code) async {
    final normalized = normalizeInviteCode(code);
    if (normalized.isEmpty) return;
    await LNDStorageService.write(
      LNDStorageConstants.pendingOwnerInviteCode,
      normalized,
    );
  }

  static Future<void> clearPendingInviteCode() async {
    await LNDStorageService.remove(LNDStorageConstants.pendingOwnerInviteCode);
  }

  static Future<LNDOwnerInviteClaimResult> claimInviteCode(String code) async {
    final normalized = normalizeInviteCode(code);
    if (normalized.isEmpty) {
      throw FirebaseFunctionsException(
        code: 'invalid-argument',
        message: 'Enter a valid invite code.',
      );
    }

    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.claimOwnerInvite,
    );
    final result = await callable.call({'code': normalized});
    final data = result.data;
    final invite = data is Map ? data['invite'] : null;
    return LNDOwnerInviteClaimResult(
      claimed: data is Map && data['claimed'] == true,
      alreadyClaimed: data is Map && data['alreadyClaimed'] == true,
      displayName: invite is Map ? invite['displayName'] as String? : null,
    );
  }

  static bool isTerminalInviteClaimError(Object error) {
    if (error is! FirebaseFunctionsException) return false;
    return switch (error.code) {
      'already-exists' ||
      'failed-precondition' ||
      'invalid-argument' ||
      'not-found' => true,
      _ => false,
    };
  }

  static Future<LNDOwnerInviteClaimResult?> claimPendingInviteCode() async {
    final code = readPendingInviteCode();
    if (code == null) return null;

    try {
      final result = await claimInviteCode(code);
      if (result.claimed || result.alreadyClaimed) {
        await clearPendingInviteCode();
      }
      return result;
    } catch (e, st) {
      if (isTerminalInviteClaimError(e)) {
        await clearPendingInviteCode();
      }
      LNDLogger.e(
        'Error claiming pending owner invite',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

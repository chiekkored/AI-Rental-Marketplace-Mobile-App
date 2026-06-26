import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/owner_invite.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class OwnerInviteLinkController extends GetxController {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final Set<String> _handledInviteCodes = <String>{};
  final Set<String> _processingInviteCodes = <String>{};

  @override
  void onInit() {
    super.onInit();
    unawaited(_listenForLinks());
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  Future<void> _listenForLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleLink(initialLink, showSavedMessage: false);
      }
    } catch (e, st) {
      LNDLogger.e(
        'Error reading initial owner invite link',
        error: e,
        stackTrace: st,
      );
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handleLink(uri)),
      onError: (Object error, StackTrace st) {
        LNDLogger.e(
          'Error listening for owner invite links',
          error: error,
          stackTrace: st,
        );
      },
    );
  }

  Future<void> _handleLink(Uri uri, {bool showSavedMessage = true}) async {
    final code = LNDOwnerInviteService.inviteCodeFromUri(uri);
    if (code == null) return;
    if (_handledInviteCodes.contains(code) ||
        _processingInviteCodes.contains(code)) {
      return;
    }

    await LNDOwnerInviteService.savePendingInviteCode(code);
    if (!_canClaimInviteNow) {
      _handledInviteCodes.add(code);
      if (showSavedMessage) {
        LNDSnackbar.showInfo(
          'Founding Owner invite saved. Sign up to apply it.',
        );
      }
      return;
    }

    await _claimInviteCode(code);
  }

  bool get _canClaimInviteNow {
    return Get.isRegistered<AuthController>() &&
        AuthController.instance.isAuthenticated;
  }

  Future<void> _claimInviteCode(String code) async {
    _processingInviteCodes.add(code);
    try {
      final result = await LNDOwnerInviteService.claimInviteCode(code);
      if (result.claimed || result.alreadyClaimed) {
        await LNDOwnerInviteService.clearPendingInviteCode();
        _handledInviteCodes.add(code);
      }
      if (result.claimed && !result.alreadyClaimed) {
        LNDSnackbar.showSuccess('Founding Owner invite applied.');
      }
    } catch (e, st) {
      if (LNDOwnerInviteService.isTerminalInviteClaimError(e)) {
        await LNDOwnerInviteService.clearPendingInviteCode();
        _handledInviteCodes.add(code);
      }
      LNDLogger.e('Error claiming owner invite', error: e, stackTrace: st);
      LNDSnackbar.showWarning('Unable to apply this Founding Owner invite.');
    } finally {
      _processingInviteCodes.remove(code);
    }
  }
}

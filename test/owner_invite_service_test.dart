import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/services/owner_invite.service.dart';

void main() {
  group('inviteCodeFromUri', () {
    test('reads supported owner invite links', () {
      expect(
        LNDOwnerInviteService.inviteCodeFromUri(
          Uri.parse('https://getlend.dev/invite/juan-camera?code=juan-8k2'),
        ),
        'JUAN-8K2',
      );
      expect(
        LNDOwnerInviteService.inviteCodeFromUri(
          Uri.parse('lend://invite/juan-camera?c=juan-8k2'),
        ),
        'JUAN-8K2',
      );
    });

    test('rejects unrelated or empty links', () {
      expect(
        LNDOwnerInviteService.inviteCodeFromUri(
          Uri.parse('https://example.com/invite/juan-camera?code=juan-8k2'),
        ),
        isNull,
      );
      expect(
        LNDOwnerInviteService.inviteCodeFromUri(
          Uri.parse('lend://listing/juan-camera?code=juan-8k2'),
        ),
        isNull,
      );
      expect(
        LNDOwnerInviteService.inviteCodeFromUri(
          Uri.parse('lend://invite/juan-camera'),
        ),
        isNull,
      );
    });
  });

  group('isTerminalInviteClaimError', () {
    test('marks stale invite failures as terminal', () {
      for (final code in [
        'already-exists',
        'failed-precondition',
        'invalid-argument',
        'not-found',
      ]) {
        expect(
          LNDOwnerInviteService.isTerminalInviteClaimError(
            FirebaseFunctionsException(code: code, message: code),
          ),
          isTrue,
        );
      }
    });

    test('keeps auth and transient failures retryable', () {
      for (final code in ['permission-denied', 'internal', 'unavailable']) {
        expect(
          LNDOwnerInviteService.isTerminalInviteClaimError(
            FirebaseFunctionsException(code: code, message: code),
          ),
          isFalse,
        );
      }
      expect(
        LNDOwnerInviteService.isTerminalInviteClaimError(Exception()),
        isFalse,
      );
    });
  });
}

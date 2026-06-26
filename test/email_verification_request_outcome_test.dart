import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/pages/eligibility/eligibility.page.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/email_verification_request_outcome.enum.dart';

void main() {
  test('email verification response resolves automatic verification', () {
    expect(
      EmailVerificationRequestOutcome.fromResponse({
        'autoVerified': true,
        'emailSent': false,
      }),
      EmailVerificationRequestOutcome.autoVerified,
    );
  });

  test('email verification response resolves sent and existing states', () {
    expect(
      EmailVerificationRequestOutcome.fromResponse({'emailSent': true}),
      EmailVerificationRequestOutcome.emailSent,
    );
    expect(
      EmailVerificationRequestOutcome.fromResponse({'alreadyVerified': true}),
      EmailVerificationRequestOutcome.alreadyVerified,
    );
  });

  test(
    'email verification response treats missing delivery as unavailable',
    () {
      expect(
        EmailVerificationRequestOutcome.fromResponse({'success': true}),
        EmailVerificationRequestOutcome.deliveryUnavailable,
      );
      expect(
        EmailVerificationRequestOutcome.fromResponse(null),
        EmailVerificationRequestOutcome.deliveryUnavailable,
      );
    },
  );

  test('eligibility route uses the correctly spelled path', () {
    expect(EligibilityPage.routeName, '/eligibility');
  });

  test('email verification resend cooldown key is user scoped', () {
    expect(
      LNDStorageConstants.emailVerificationResendAvailableAtKey('user-1'),
      'emailVerificationResendAvailableAt_user-1',
    );
  });
}

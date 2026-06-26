enum EmailVerificationRequestOutcome {
  alreadyVerified,
  autoVerified,
  deliveryUnavailable,
  emailSent;

  static EmailVerificationRequestOutcome fromResponse(Object? response) {
    if (response is! Map) {
      return EmailVerificationRequestOutcome.deliveryUnavailable;
    }
    if (response['alreadyVerified'] == true) {
      return EmailVerificationRequestOutcome.alreadyVerified;
    }
    if (response['autoVerified'] == true) {
      return EmailVerificationRequestOutcome.autoVerified;
    }
    if (response['emailSent'] == true) {
      return EmailVerificationRequestOutcome.emailSent;
    }
    return EmailVerificationRequestOutcome.deliveryUnavailable;
  }
}

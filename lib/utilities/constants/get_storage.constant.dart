class LNDStorageConstants {
  static String assets = 'assets';
  static String recentlyViewedAssets = 'recentlyViewedAssets';
  static String homeRecommendationRailCachePrefix = 'homeRecommendationRail';
  static String payoutInstitutionsCachePrefix = 'payoutInstitutionsCache';
  static String payoutDestinationsCachePrefix = 'payoutDestinationsCache';
  static String createListingDraft = 'createListingDraft';
  static String publishListingDisclaimerAcknowledged =
      'publishListingDisclaimerAcknowledged';
  static String searchHistory = 'searchHistory';
  static String hideQrTransactionReminder = 'hideQrTransactionReminder';
  static String pendingPaymentCheckout = 'pendingPaymentCheckout';
  static String onboardingComplete = 'onboardingComplete';
  static String themeMode = 'themeMode';
  static String enableBiometrics = 'enableBiometrics';
  static String selectedIddCountryCode = 'selectedIddCountryCode';
  static String selectedCurrencyCountryCode = 'selectedCurrencyCountryCode';
  static String selectedCurrencyCode = 'selectedCurrencyCode';
  static String calendarBookingsViewMode = 'calendarBookingsViewMode';
  static String approvedBusinessRegistrationCache =
      'approvedBusinessRegistrationCache';
  static String emailVerificationResendAvailableAt =
      'emailVerificationResendAvailableAt';
  static String pendingOwnerInviteCode = 'pendingOwnerInviteCode';

  static String publishListingDisclaimerAcknowledgedKey(String uid) {
    return '${publishListingDisclaimerAcknowledged}_$uid';
  }

  static String approvedBusinessRegistrationCacheKey(String uid) {
    return '${approvedBusinessRegistrationCache}_$uid';
  }

  static String emailVerificationResendAvailableAtKey(String uid) {
    return '${emailVerificationResendAvailableAt}_$uid';
  }
}

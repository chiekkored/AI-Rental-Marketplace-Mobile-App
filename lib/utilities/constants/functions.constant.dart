class LNDFunctions {
  static String createBookingRequest = 'createBookingRequest';
  static String createPaymentCheckout = 'createBookingPaymentSession';
  static String createDamageBalancePaymentCheckout =
      'createOutstandingDamagePaymentSession';
  static String listSavedPaymentMethods = 'listPaymentSavedMethods';
  static String attachSavedCardPaymentMethod =
      'attachSavedPaymentMethodToSession';
  static String syncPaymentCheckout = 'syncBookingPaymentSession';
  static String recoverPendingPaymentCheckout = 'recoverBookingPaymentSession';
  static String cancelPaymentCheckout = 'cancelBookingPaymentSession';
  static String setOwnerPayoutDestination = 'setPaymentDestination';
  static String getOwnerPayoutDestination = 'getPaymentDestinations';
  static String listPayoutInstitutions = 'listPaymentDestinationInstitutions';
  static String makeToken = 'makeToken';
  static String verifyAndMark = 'verifyAndMark';
  static String regenerateToken = 'regenerateToken';
  static String verifyToken = 'verifyToken';
  static String submitBookingReview = 'submitBookingReview';
  static String requestEmailVerification = 'requestEmailVerification';
  static String cancelBooking = 'cancelBooking';
  static String requestBookingCancellation = 'requestBookingCancellation';
  static String getBookingDocument = 'getBookingDocument';
  static String completeReturnedBooking = 'completeReturnedBooking';
  static String requestDepositDeduction = 'requestDepositDeduction';
  static String acceptDepositDeduction = 'acceptDepositDeduction';
  static String disputeDepositDeduction = 'disputeDepositDeduction';
  static String getAccountDeactivationEligibility =
      'getAccountDeactivationEligibility';
  static String getAccountDeletionEligibility =
      'getAccountDeletionEligibility';
  static String deactivateAccount = 'deactivateAccount';
  static String reactivateAccount = 'reactivateAccount';
  static String disableUser = 'disableUser';
  static String deleteUser = 'deleteUser';
  static String getHomeRecommendations = 'getHomeRecommendations';
  static String getHomeRecommended = 'getHomeRecommended';
  static String getHomePopular = 'getHomePopular';
  static String recordRecommendationEvent = 'recordRecommendationEvent';
  static String createListingShareLink = 'createListingShareLink';
  static String resolveListingShareLink = 'resolveListingShareLink';
  static String registerFcmToken = 'registerFcmToken';
  static String unregisterFcmToken = 'unregisterFcmToken';
  static String updateNotificationPreferences = 'updateNotificationPreferences';
  static String manageUserBlock = 'manageUserBlock';
  static String submitListingForReview = 'submitListingForReview';
  static String createDummyListings = 'createDummyListings';
  static String deleteListingReviewSubmission = 'deleteListingReviewSubmission';
  static String getListingDeletionEligibility = 'getListingDeletionEligibility';
  static String deleteListing = 'deleteListing';
  static String requestListingDeactivationReview =
      'requestListingDeactivationReview';
  static String claimOwnerInvite = 'claimOwnerInvite';
}

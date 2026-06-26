enum LNDCollections {
  users('users'),
  userChats('userChats'),
  chats('chats'),
  messages('messages'),
  reports('reports'),
  accountFeedback('accountFeedback'),
  notifications('notifications'),
  listingModerationEvents('listingModerationEvents'),
  verificationSubmissions('verificationSubmissions'),
  businessRegistrationSubmissions('businessRegistrationSubmissions'),
  listingReviewSubmissions('listingReviewSubmissions'),
  appConfig('appConfig'),
  categories('categories'),
  amenities('amenities'),
  assets('assets'),
  ratings('ratings'),
  saved('saved'),
  bookings('bookings'),
  blockExclusions('blockExclusions'),
  paymentCheckouts('paymentCheckouts');

  final String name;
  const LNDCollections(this.name);
}

import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/controllers/booking_document_pdf/booking_document_pdf.controller.dart';
import 'package:lend/presentation/controllers/booking_instructions/booking_instructions.controller.dart';
import 'package:lend/presentation/controllers/booking_payment/booking_payment.controller.dart';
import 'package:lend/presentation/controllers/calendar_bookings/calendar_bookings.controller.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/controllers/category_listing/category_listing.controller.dart';
import 'package:lend/presentation/controllers/chat_information/chat_information.controller.dart';
import 'package:lend/presentation/controllers/country_picker/country_picker.controller.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/controllers/damage_fee_request/damage_fee_request.controller.dart';
import 'package:lend/presentation/controllers/damage_balance_payment/damage_balance_payment.controller.dart';
import 'package:lend/presentation/controllers/deleted_listing_notice/deleted_listing_notice.controller.dart';
import 'package:lend/presentation/controllers/location_picker/location_picker.controller.dart';
import 'package:lend/presentation/controllers/listing_review_result/listing_review_result.controller.dart';
import 'package:lend/presentation/controllers/navigation/navigation.controller.dart'; // Import NavigationController
import 'package:lend/presentation/controllers/new_password/new_password.controller.dart';
import 'package:lend/presentation/controllers/outstanding_damage_balances/outstanding_damage_balances.controller.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/controllers/payment_holding/payment_holding.controller.dart';
import 'package:lend/presentation/controllers/payout_institution_picker/payout_institution_picker.controller.dart';
import 'package:lend/presentation/controllers/verification_rejection/verification_rejection.controller.dart';
import 'package:lend/presentation/pages/about/about.page.dart';
import 'package:lend/presentation/pages/account_information/account_information.page.dart';
import 'package:lend/presentation/pages/account_settings/account_settings.page.dart';
import 'package:lend/presentation/pages/asset/asset.page.dart';
import 'package:lend/presentation/pages/booking_details/booking_details.page.dart';
import 'package:lend/presentation/pages/booking_document_pdf/booking_document_pdf.page.dart';
import 'package:lend/presentation/pages/booking_instructions/booking_instructions.page.dart';
import 'package:lend/presentation/pages/booking_payment/booking_payment.page.dart';
import 'package:lend/presentation/pages/business_registration/business_registration.page.dart';
import 'package:lend/presentation/pages/business_registration_rejection/business_registration_rejection.page.dart';
import 'package:lend/presentation/pages/owner_center/owner_center.page.dart';
import 'package:lend/presentation/pages/calendar_bookings/calendar_bookings.page.dart';
import 'package:lend/presentation/pages/calendar_picker/calendar_picker.page.dart';
import 'package:lend/presentation/pages/category_listing/category_listing.page.dart';
import 'package:lend/presentation/pages/chat/chat.page.dart';
import 'package:lend/presentation/pages/chat_information/chat_information.page.dart';
import 'package:lend/presentation/pages/deactivate_delete_account/deactivate_delete_account.page.dart';
import 'package:lend/presentation/pages/damage_fee_request/damage_fee_request.page.dart';
import 'package:lend/presentation/pages/damage_balance_payment/damage_balance_payment.page.dart';
import 'package:lend/presentation/pages/deleted_listing_notice/deleted_listing_notice.page.dart';
import 'package:lend/presentation/pages/full_verification/full_verification.page.dart';
import 'package:lend/presentation/pages/navigation/components/messages/components/archived_messages.page.dart';
import 'package:lend/presentation/pages/navigation/navigation.page.dart';
import 'package:lend/presentation/pages/new_password/new_password.page.dart';
import 'package:lend/presentation/pages/notification_settings/notification_settings.page.dart';
import 'package:lend/presentation/pages/notifications/notifications.page.dart';
import 'package:lend/presentation/pages/listing_review_result/listing_review_result.page.dart';
import 'package:lend/presentation/pages/onboarding/onboarding.page.dart';
import 'package:lend/presentation/pages/outstanding_damage_balances/outstanding_damage_balances.page.dart';
import 'package:lend/presentation/pages/owner_payout_destination/owner_payout_destination.page.dart';
import 'package:lend/presentation/pages/payment_methods/payment_methods.page.dart';
import 'package:lend/presentation/pages/payment_holding/payment_holding.page.dart';
import 'package:lend/presentation/pages/payout_institution_picker/payout_institution_picker.page.dart';
import 'package:lend/presentation/pages/publish_listing_disclaimer/publish_listing_disclaimer.page.dart';
import 'package:lend/presentation/pages/qr_view/qr_view.page.dart';
import 'package:lend/presentation/pages/rental_history/rental_history.page.dart';
import 'package:lend/presentation/pages/renter_center/renter_center.page.dart';
import 'package:lend/presentation/pages/saved/saved.page.dart';
import 'package:lend/presentation/pages/scan_qr/scan_qr.page.dart';
import 'package:lend/presentation/pages/search/search.page.dart';
import 'package:lend/presentation/pages/security/security.page.dart';
import 'package:lend/presentation/pages/token_view/token_view.page.dart';
import 'package:lend/presentation/pages/verification_rejection/verification_rejection.page.dart';
import 'package:lend/presentation/pages/your_listing/your_listing.page.dart';
import 'package:lend/presentation/pages/photo_view/photo_view.page.dart';
import 'package:lend/presentation/pages/create_listing/create_listing.page.dart';
import 'package:lend/presentation/pages/create_listing/add_inclusions.page.dart';
import 'package:lend/presentation/pages/create_listing/pick_location.page.dart';
import 'package:lend/presentation/pages/country_picker/country_picker.page.dart';
import 'package:lend/presentation/pages/product_showcase/product_showcase.page.dart';
import 'package:lend/presentation/pages/profile_view/profile_view.page.dart';
import 'package:lend/presentation/pages/reactivate_account/reactivate_account.page.dart';
import 'package:lend/presentation/pages/signin/signin.page.dart';
import 'package:lend/presentation/pages/signup/signup.page.dart';
import 'package:lend/utilities/enums/bottom_nav_page.enum.dart'; // Import LNDBottomNavPage
import 'package:lend/presentation/pages/rating_review/rating_review.page.dart';
import 'package:lend/presentation/pages/all_reviews/all_reviews.page.dart';
import 'package:lend/presentation/pages/recently_viewed/recently_viewed.page.dart';
import 'package:lend/presentation/pages/settings/settings.page.dart';
import 'package:lend/presentation/pages/blocked_users/blocked_users.page.dart';

class LNDNavigate {
  LNDNavigate._();
  static final LNDNavigate _instance = LNDNavigate._();
  static int _assetRouteSequence = 0;
  factory LNDNavigate() {
    return _instance;
  }

  static void toRootPage<T>() async {
    Get.until((page) => page.isFirst);
  }

  static Future<T?>? toSettingsPage<T>() async {
    return await Get.toNamed(SettingsPage.routeName);
  }

  static Future<T?>? toBlockedUsersPage<T>() async {
    return await Get.toNamed(BlockedUsersPage.routeName);
  }

  static Future<T?>? toAboutPage<T>() async {
    return await Get.toNamed(AboutPage.routeName);
  }

  static Future<T?>? toNotificationsPage<T>() async {
    return await Get.toNamed(NotificationsPage.routeName);
  }

  static Future<T?>? toNotificationSettingsPage<T>() async {
    return await Get.toNamed(NotificationSettingsPage.routeName);
  }

  static Future<T?>? toListingReviewResultPage<T>({
    required ListingReviewResultPageArgs args,
  }) async {
    return await Get.toNamed(
      ListingReviewResultPage.routeName,
      arguments: args,
    );
  }

  static Future<T?>? toDeletedListingNoticePage<T>({
    required DeletedListingNoticePageArgs args,
  }) async {
    return await Get.toNamed(
      DeletedListingNoticePage.routeName,
      arguments: args,
    );
  }

  static Future<T?>? toVerificationRejectionPage<T>({
    required VerificationRejectionPageArgs args,
  }) async {
    return await Get.toNamed(
      VerificationRejectionPage.routeName,
      arguments: args,
    );
  }

  static Future<T?>? toBusinessRegistrationRejectionPage<T>() async {
    return await Get.toNamed(BusinessRegistrationRejectionPage.routeName);
  }

  static Future<T?>? toOnboardingPage<T>() async {
    return await Get.toNamed(OnboardingPage.routeName);
  }

  static Future<T?>? toCountryIddPickerPage<T>() async {
    return await Get.toNamed(
      CountryPickerPage.routeName,
      arguments: const CountryPickerPageArgs(mode: CountryPickerMode.phoneIdd),
    );
  }

  static Future<T?>? toCountryCurrencyPickerPage<T>() async {
    return await Get.toNamed(
      CountryPickerPage.routeName,
      arguments: const CountryPickerPageArgs(mode: CountryPickerMode.currency),
    );
  }

  static Future<T?>? toAccountSettingsPage<T>() async {
    return await Get.toNamed(AccountSettingsPage.routeName);
  }

  static Future<T?>? toOwnProfileViewPage<T>() async {
    return await Get.toNamed(ProfileViewPage.routeName);
  }

  static Future<T?>? toSecurityPage<T>() async {
    return await Get.toNamed(SecurityPage.routeName);
  }

  static Future<T?>? toNewPasswordPage<T>({
    required NewPasswordPageArgs args,
  }) async {
    return await Get.toNamed(NewPasswordPage.routeName, arguments: args);
  }

  static Future<T?>? toSavedPage<T>() async {
    return await Get.toNamed(SavedPage.routeName);
  }

  static Future<T?>? toRecentlyViewedPage<T>() async {
    return await Get.toNamed(RecentlyViewedPage.routeName);
  }

  static Future<T?>? toSearchPage<T>() async {
    return await Get.toNamed(SearchPage.routeName);
  }

  static Future<T?>? toCategoryListingsPage<T>({
    required String categoryId,
    required String categoryName,
  }) async {
    final args = CategoryListingPageArgs(
      categoryId: categoryId,
      categoryName: categoryName,
    );

    return await Get.toNamed(CategoryListingPage.routeName, arguments: args);
  }

  static Future<T?>? toAllReviewsPage<T>({
    required AllReviewsPageArgs args,
  }) async {
    return await Get.toNamed(AllReviewsPage.routeName, arguments: args);
  }

  static Future<T?>? toRatingReviewPage<T>({
    required RatingReviewArguments args,
  }) async {
    return await Get.toNamed(RatingReviewPage.routeName, arguments: args);
  }

  static Future<T?>? toHomePage<T>({
    LNDBottomNavPage page = LNDBottomNavPage.discover,
  }) async {
    final nav = Get.find<NavigationController>();
    nav.changeTab(page.indexx);
    return await Get.offAllNamed(NavigationPage.routeName);
  }

  static Future<T?>? toSigninPage<T>() async {
    return await Get.toNamed(SigninPage.routeName);
  }

  static Future<T?>? toReactivateAccountPage<T>() async {
    return await Get.offAllNamed(ReactivateAccountPage.routeName);
  }

  static Future<T?>? toSignupPage<T>() async {
    return await Get.toNamed(SignUpPage.routeName);
  }

  static Future<T?>? toFullVerificationPage<T>() async {
    return await Get.toNamed(FullVerificationPage.routeName);
  }

  static Future<T?>? toAssetPage<T>({
    required Asset? args,
    AssetPageSource source = AssetPageSource.public,
  }) async {
    final assetId = args?.id ?? 'unknown';
    final routeSequence = _assetRouteSequence++;
    final controllerTag =
        'asset:${source.name}:$assetId:'
        '${DateTime.now().microsecondsSinceEpoch}:$routeSequence';
    return await Get.toNamed(
      AssetPage.routeName,
      preventDuplicates: false,
      arguments: AssetPageArgs(
        asset: args,
        source: source,
        controllerTag: controllerTag,
      ),
    );
  }

  static Future<T?>? toBookingDetailsPage<T>({
    required BookingDetailsPageArgs args,
  }) async {
    return await Get.toNamed(BookingDetailsPage.routeName, arguments: args);
  }

  static Future<T?>? toBookingDocumentPdfPage<T>({
    required BookingDocumentPdfPageArgs args,
  }) async {
    return await Get.toNamed(BookingDocumentPdfPage.routeName, arguments: args);
  }

  static Future<T?>? toScanQRPage<T>() async {
    return await Get.toNamed(ScanQRPage.routeName);
  }

  static Future<T?>? toTokenViewPage<T>({required TokenViewArgs args}) async {
    return await Get.toNamed(TokenViewPage.routeName, arguments: args);
  }

  static Future<T?>? toQRViewPage<T>({required String qrToken}) async {
    return await Get.toNamed(QRViewPage.routeName, arguments: qrToken);
  }

  static Future<T?>? toPhotoViewPage<T>({
    required PhotoViewArguments args,
  }) async {
    return await Get.toNamed(PhotoViewPage.routeName, arguments: args);
  }

  static Future<T?>? toProductShowcasePage<T>({
    required ProductShowcaseArguments args,
  }) async {
    return await Get.toNamed(ProductShowcasePage.routeName, arguments: args);
  }

  static Future<T?>? toCalendarPickerPage<T>({
    required CalendarPickerPageArgs args,
  }) async {
    return await Get.toNamed(CalendarPickerPage.routeName, arguments: args);
  }

  static Future<T?>? toBookingPaymentPage<T>({
    required BookingPaymentPageArgs args,
  }) async {
    return await Get.toNamed(BookingPaymentPage.routeName, arguments: args);
  }

  static Future<T?>? toPaymentHoldingPage<T>({
    required PaymentHoldingPageArgs args,
  }) async {
    return await Get.toNamed(PaymentHoldingPage.routeName, arguments: args);
  }

  static Future<T?>? toBookingInstructionsPage<T>({
    required BookingInstructionsPageArgs args,
  }) async {
    return await Get.toNamed(
      BookingInstructionsPage.routeName,
      arguments: args,
    );
  }

  static Future<T?>? offBookingInstructionsPage<T>({
    required BookingInstructionsPageArgs args,
  }) async {
    return await Get.offNamed(
      BookingInstructionsPage.routeName,
      arguments: args,
    );
  }

  static Future<T?>? toDamageBalancePaymentPage<T>({
    required DamageBalancePaymentPageArgs args,
  }) async {
    return await Get.toNamed(
      DamageBalancePaymentPage.routeName,
      arguments: args,
    );
  }

  static Future<T?>? toOutstandingDamageBalancesPage<T>({
    required OutstandingDamageBalancesPageArgs args,
  }) async {
    return await Get.toNamed(
      OutstandingDamageBalancesPage.routeName,
      arguments: args,
    );
  }

  static Future<T?>? toPaymentMethodsPage<T>({
    required PaymentMethodsPageArgs args,
  }) async {
    return await Get.toNamed(PaymentMethodsPage.routeName, arguments: args);
  }

  static Future<T?>? toCalendarBookingsPage<T>({
    required CalendarBookingsPageArgs args,
  }) async {
    return await Get.toNamed(CalendarBookingsPage.routeName, arguments: args);
  }

  static Future<T?>? toChatPage<T>({required Chat chat}) async {
    return await Get.toNamed(ChatPage.routeName, arguments: chat);
  }

  static Future<bool?>? toChatInformationPage({
    required ChatInformationArgs args,
  }) async {
    final isDeleted = await Get.toNamed(
      ChatInformationPage.routeName,
      arguments: args,
    );
    return isDeleted is bool ? isDeleted : null;
  }

  static Future<T?>? toDamageFeeRequestPage<T>({
    required DamageFeeRequestPageArgs args,
  }) async {
    return await Get.toNamed(DamageFeeRequestPage.routeName, arguments: args);
  }

  static Future<T?>? toArchivedMessagesPage<T>() async {
    return await Get.toNamed(ArchivedMessagePage.routeName);
  }

  static Future<T?>? toMyAssetPage<T>() async {
    return await Get.toNamed(YourListingPage.routeName);
  }

  static Future<T?>? toRentalHistoryPage<T>() async {
    return await Get.toNamed(RentalHistoryPage.routeName);
  }

  static Future<T?>? toRenterCenterPage<T>() async {
    return await Get.toNamed(RenterCenterPage.routeName);
  }

  static Future<T?>? toBuyerCenterPage<T>() async {
    return await Get.toNamed(OwnerCenterPage.routeName);
  }

  static Future<T?>? toCreateListing<T>({
    required CreateListingArguments? args,
  }) async {
    return await Get.toNamed(CreateListingPage.routeName, arguments: args);
  }

  static Future<T?>? toPublishListingDisclaimerPage<T>() async {
    return await Get.toNamed(PublishListingDisclaimerPage.routeName);
  }

  static Future<LocationCallbackModel?>? toPickLocationPage({
    required LocationCallbackModel args,
  }) async {
    final result = await Get.toNamed<dynamic>(
      PickLocationPage.routeName,
      arguments: args,
    );
    return result is LocationCallbackModel ? result : null;
  }

  static Future<T?>? toAddInclusionsPage<T>() async {
    return await Get.toNamed(AddInclusionsPage.routeName);
  }

  static Future<T?>? toDeactivateDeleteAccountPage<T>() async {
    return await Get.toNamed(DeactivateDeleteAccountPage.routeName);
  }

  static Future<T?>? toAccountInformationPage<T>() async {
    return await Get.toNamed(AccountInformationPage.routeName);
  }

  static Future<T?>? toOwnerPayoutDestinationPage<T>() async {
    return await Get.toNamed(
      OwnerPayoutDestinationPage.routeName,
      arguments: const OwnerPayoutDestinationPageArgs(
        purpose: OwnerPayoutDestinationPurpose.ownerPayout,
      ),
    );
  }

  static Future<T?>? toBusinessRegistrationPage<T>() async {
    return await Get.toNamed(BusinessRegistrationPage.routeName);
  }

  static Future<T?>? toDepositReturnDestinationPage<T>() async {
    return await Get.toNamed(
      OwnerPayoutDestinationPage.routeName,
      arguments: const OwnerPayoutDestinationPageArgs(
        purpose: OwnerPayoutDestinationPurpose.depositReturn,
      ),
    );
  }

  static Future<T?>? toPayoutInstitutionPickerPage<T>({
    required PayoutInstitutionPickerPageArgs args,
  }) async {
    return await Get.toNamed(
      PayoutInstitutionPickerPage.routeName,
      arguments: args,
    );
  }
}

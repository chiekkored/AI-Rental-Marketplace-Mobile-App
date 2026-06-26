import 'package:duration_picker/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:lend/core/bindings/about/about.binding.dart';
import 'package:lend/core/bindings/account_information/account_information.binding.dart';
import 'package:lend/core/bindings/asset/asset.binding.dart';
import 'package:lend/core/bindings/booking_details/booking_details.binding.dart';
import 'package:lend/core/bindings/booking_document_pdf/booking_document_pdf.binding.dart';
import 'package:lend/core/bindings/booking_instructions/booking_instructions.binding.dart';
import 'package:lend/core/bindings/booking_payment/booking_payment.binding.dart';
import 'package:lend/core/bindings/blocked_users/blocked_users.binding.dart';
import 'package:lend/core/bindings/business_registration/business_registration.binding.dart';
import 'package:lend/core/bindings/business_registration_rejection/business_registration_rejection.binding.dart';
import 'package:lend/core/bindings/owner_center/owner_center.binding.dart';
import 'package:lend/core/bindings/calendar_bookings/calendar_bookings.binding.dart';
import 'package:lend/core/bindings/calendar_picker/calendar_picker.binding.dart';
import 'package:lend/core/bindings/category_listing/category_listing.binding.dart';
import 'package:lend/core/bindings/chat/chat.binding.dart';
import 'package:lend/core/bindings/chat_information/chat_information.binding.dart';
import 'package:lend/core/bindings/create_listing/create_listing.binding.dart';
import 'package:lend/core/bindings/country_picker/country_picker.binding.dart';
import 'package:lend/core/bindings/damage_fee_request/damage_fee_request.binding.dart';
import 'package:lend/core/bindings/damage_balance_payment/damage_balance_payment.binding.dart';
import 'package:lend/core/bindings/deleted_listing_notice/deleted_listing_notice.binding.dart';
import 'package:lend/core/bindings/full_verification/full_verification.binding.dart';
import 'package:lend/core/bindings/listing_review_result/listing_review_result.binding.dart';
import 'package:lend/core/bindings/navigation/navigation.binding.dart';
import 'package:lend/core/bindings/notification_settings/notification_settings.binding.dart';
import 'package:lend/core/bindings/notifications/notifications.binding.dart';
import 'package:lend/core/bindings/onboarding/onboarding.binding.dart';
import 'package:lend/core/bindings/outstanding_damage_balances/outstanding_damage_balances.binding.dart';
import 'package:lend/core/bindings/payment_methods/payment_methods.binding.dart';
import 'package:lend/core/bindings/payment_holding/payment_holding.binding.dart';
import 'package:lend/core/bindings/payout_institution_picker/payout_institution_picker.binding.dart';
import 'package:lend/core/bindings/profile_view/profile_view.binding.dart';
import 'package:lend/core/bindings/publish_listing_disclaimer/publish_listing_disclaimer.binding.dart';
import 'package:lend/core/bindings/recently_viewed/recently_viewed.binding.dart';
import 'package:lend/core/bindings/rental_history/rental_history.binding.dart';
import 'package:lend/core/bindings/renter_center/renter_center.binding.dart';
import 'package:lend/core/bindings/root.binding.dart';
import 'package:lend/core/bindings/scan_qr/scan_qr.binding.dart';
import 'package:lend/core/bindings/search/search.binding.dart';
import 'package:lend/core/bindings/signin/signin.binding.dart';
import 'package:lend/core/bindings/splash/splash.binding.dart';
import 'package:lend/core/bindings/signup/signup.binding.dart';
import 'package:lend/core/bindings/verification_rejection/verification_rejection.binding.dart';
import 'package:lend/core/bindings/messages/messages.binding.dart'; // Import MessagesBinding
import 'package:lend/core/bindings/new_password/new_password.binding.dart';
import 'package:lend/core/middlewares/auth.middleware.dart';
import 'package:lend/core/middlewares/full_verification_pending.middleware.dart';
import 'package:lend/core/middlewares/listing_eligible.middleware.dart';
import 'package:lend/core/middlewares/payout_destination.middleware.dart';
import 'package:lend/core/middlewares/rent_eligible.middleware.dart';
import 'package:lend/core/services/main.service.dart';
import 'package:lend/core/bindings/rating_review/rating_review.binding.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/pages/about/about.page.dart';
import 'package:lend/presentation/pages/account_information/account_information.page.dart';
import 'package:lend/presentation/pages/asset/asset.page.dart';
import 'package:lend/presentation/pages/booking_details/booking_details.page.dart';
import 'package:lend/presentation/pages/booking_document_pdf/booking_document_pdf.page.dart';
import 'package:lend/presentation/pages/booking_instructions/booking_instructions.page.dart';
import 'package:lend/presentation/pages/booking_payment/booking_payment.page.dart';
import 'package:lend/presentation/pages/blocked_users/blocked_users.page.dart';
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
import 'package:lend/presentation/pages/eligibility/eligibility.page.dart';
import 'package:lend/presentation/pages/full_verification/full_verification.page.dart';
import 'package:lend/presentation/pages/foreground_notification_overlay/foreground_notification_overlay.page.dart';
import 'package:lend/presentation/pages/loading_overlay/loading_overlay.page.dart';
import 'package:lend/presentation/pages/maintenance/maintenance_overlay.page.dart';
import 'package:lend/presentation/pages/listing_review_result/listing_review_result.page.dart';
import 'package:lend/presentation/pages/navigation/components/messages/components/archived_messages.page.dart';
import 'package:lend/presentation/pages/notification_settings/notification_settings.page.dart';
import 'package:lend/presentation/pages/notifications/notifications.page.dart';
import 'package:lend/presentation/pages/onboarding/onboarding.page.dart';
import 'package:lend/presentation/pages/owner_payout_destination/owner_payout_destination.page.dart';
import 'package:lend/presentation/pages/outstanding_damage_balances/outstanding_damage_balances.page.dart';
import 'package:lend/presentation/pages/payment_methods/payment_methods.page.dart';
import 'package:lend/presentation/pages/payment_holding/payment_holding.page.dart';
import 'package:lend/presentation/pages/payout_institution_picker/payout_institution_picker.page.dart';
import 'package:lend/presentation/pages/publish_listing_disclaimer/publish_listing_disclaimer.page.dart';
import 'package:lend/presentation/pages/new_password/new_password.page.dart';
import 'package:lend/presentation/pages/qr_view/qr_view.page.dart';
import 'package:lend/presentation/pages/rating_review/rating_review.page.dart';
import 'package:lend/presentation/pages/recently_viewed/recently_viewed.page.dart';
import 'package:lend/presentation/pages/rental_history/rental_history.page.dart';
import 'package:lend/presentation/pages/renter_center/renter_center.page.dart';
import 'package:lend/presentation/pages/saved/saved.page.dart';
import 'package:lend/presentation/pages/scan_qr/scan_qr.page.dart';
import 'package:lend/presentation/pages/search/search.page.dart';
import 'package:lend/presentation/pages/splash/splash.page.dart';
import 'package:lend/presentation/pages/account_settings/account_settings.page.dart';
import 'package:lend/presentation/pages/security/security.page.dart';
import 'package:lend/presentation/pages/token_view/token_view.page.dart';
import 'package:lend/presentation/pages/verification_rejection/verification_rejection.page.dart';
import 'package:lend/presentation/pages/your_listing/your_listing.page.dart';
import 'package:lend/presentation/pages/navigation/navigation.page.dart';
import 'package:lend/presentation/pages/photo_view/photo_view.page.dart';
import 'package:lend/presentation/pages/create_listing/add_inclusions.page.dart';
import 'package:lend/presentation/pages/create_listing/create_listing.page.dart';
import 'package:lend/presentation/pages/create_listing/pick_location.page.dart';
import 'package:lend/presentation/pages/country_picker/country_picker.page.dart';
import 'package:lend/presentation/pages/product_showcase/product_showcase.page.dart';
import 'package:lend/presentation/pages/profile_view/profile_view.page.dart';
import 'package:lend/presentation/pages/reactivate_account/reactivate_account.page.dart';
import 'package:lend/presentation/pages/signin/signin.page.dart';
import 'package:lend/presentation/pages/signup/components/setup.page.dart';
import 'package:lend/presentation/pages/signup/signup.page.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

import 'package:lend/presentation/pages/settings/settings.page.dart';
import 'package:lend/presentation/controllers/settings/settings.controller.dart';
import 'package:lend/presentation/pages/all_reviews/all_reviews.page.dart';
import 'package:lend/presentation/controllers/all_reviews/all_reviews.binding.dart';

void main() async {
  String env = const String.fromEnvironment('ENV', defaultValue: 'prod');

  WidgetsFlutterBinding.ensureInitialized();

  await MainService.initializeFirebase();

  await Future.wait([
    MainService.intializeGetStorage(),
    MainService.initializeDeviceOrientation(),
    MainService.loadEnv(env),
    if (env == 'local') MainService.useFirebaseEmulator(),
  ]);

  // GetStorage().erase();

  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lend',
      debugShowCheckedModeBanner: false,
      theme: LNDAppTheme.light,
      darkTheme: LNDAppTheme.dark,
      themeMode: SettingsController.initialThemeMode,
      localizationsDelegates: const [
        DurationPickerLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      builder: (_, child) {
        return MaintenanceOverlay(
          child: LoadingOverlay(
            child: ForegroundNotificationOverlay(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      initialBinding: RootBinding(),
      getPages: [
        GetPage(
          name: SplashPage.routeName,
          page: () => const SplashPage(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: OnboardingPage.routeName,
          page: () => const OnboardingPage(),
          binding: OnboardingBinding(),
        ),
        GetPage(
          name: NavigationPage.routeName,
          page: () => const NavigationPage(),
          binding: NavigationBinding(),
        ),
        GetPage(name: SettingsPage.routeName, page: () => const SettingsPage()),
        GetPage(
          name: BlockedUsersPage.routeName,
          page: () => const BlockedUsersPage(),
          binding: BlockedUsersBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: AboutPage.routeName,
          page: () => const AboutPage(),
          binding: AboutBinding(),
        ),
        GetPage(
          name: NotificationsPage.routeName,
          page: () => const NotificationsPage(),
          binding: NotificationsBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: NotificationSettingsPage.routeName,
          page: () => const NotificationSettingsPage(),
          binding: NotificationSettingsBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: ListingReviewResultPage.routeName,
          page: () => const ListingReviewResultPage(),
          binding: ListingReviewResultBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: DeletedListingNoticePage.routeName,
          page: () => const DeletedListingNoticePage(),
          binding: DeletedListingNoticeBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: VerificationRejectionPage.routeName,
          page: () => const VerificationRejectionPage(),
          binding: VerificationRejectionBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: BusinessRegistrationRejectionPage.routeName,
          page: () => const BusinessRegistrationRejectionPage(),
          binding: BusinessRegistrationRejectionBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: CountryPickerPage.routeName,
          page: () => const CountryPickerPage(),
          binding: CountryPickerBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: AllReviewsPage.routeName,
          page: () => const AllReviewsPage(),
          binding: AllReviewsBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: RatingReviewPage.routeName,
          page: () => const RatingReviewPage(),
          binding: RatingReviewBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: OwnerCenterPage.routeName,
          page: () => const OwnerCenterPage(),
          binding: OwnerCenterBinding(),
          middlewares: [AuthMiddleware(), ListingEligibleMiddleware()],
        ),
        GetPage(
          name: BusinessRegistrationPage.routeName,
          page: () => const BusinessRegistrationPage(),
          binding: BusinessRegistrationBinding(),
          middlewares: [AuthMiddleware(), ListingEligibleMiddleware()],
        ),
        GetPage(
          name: RenterCenterPage.routeName,
          page: () => const RenterCenterPage(),
          binding: RenterCenterBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: SearchPage.routeName,
          page: () => const SearchPage(),
          binding: SearchBinding(),
        ),
        GetPage(
          name: AssetPage.routeName,
          page:
              () => AssetPage(
                controllerTag: (Get.arguments as AssetPageArgs).controllerTag,
              ),
          binding: AssetBinding(),
          preventDuplicates: false,
        ),
        GetPage(
          name: CalendarPickerPage.routeName,
          page: () => const CalendarPickerPage(),
          preventDuplicates: false,
          binding: CalendarPickerBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: BookingPaymentPage.routeName,
          page: () => const BookingPaymentPage(),
          preventDuplicates: false,
          binding: BookingPaymentBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: PaymentHoldingPage.routeName,
          page: () => const PaymentHoldingPage(),
          preventDuplicates: false,
          binding: PaymentHoldingBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: BookingInstructionsPage.routeName,
          page: () => const BookingInstructionsPage(),
          preventDuplicates: false,
          binding: BookingInstructionsBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: DamageBalancePaymentPage.routeName,
          page: () => const DamageBalancePaymentPage(),
          preventDuplicates: false,
          binding: DamageBalancePaymentBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: OutstandingDamageBalancesPage.routeName,
          page: () => const OutstandingDamageBalancesPage(),
          preventDuplicates: false,
          binding: OutstandingDamageBalancesBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: PaymentMethodsPage.routeName,
          page: () => const PaymentMethodsPage(),
          preventDuplicates: false,
          binding: PaymentMethodsBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: CalendarBookingsPage.routeName,
          page: () => const CalendarBookingsPage(),
          preventDuplicates: false,
          binding: CalendarBookingsBinding(),
          middlewares: [AuthMiddleware(), ListingEligibleMiddleware()],
        ),
        GetPage(
          name: CategoryListingPage.routeName,
          page: () => const CategoryListingPage(),
          binding: CategoryListingBinding(),
          preventDuplicates: false,
        ),
        GetPage(
          name: RentalHistoryPage.routeName,
          page: () => const RentalHistoryPage(),
          binding: RentalHistoryBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: SigninPage.routeName,
          page: () => const SigninPage(),
          binding: SigninBinding(),
          fullscreenDialog: true,
        ),
        GetPage(
          name: SignUpPage.routeName,
          page: () => const SignUpPage(),
          binding: SignupBinding(),
        ),
        GetPage(name: SetupPage.routeName, page: () => const SetupPage()),
        GetPage(
          name: PhotoViewPage.routeName,
          page: () => const PhotoViewPage(),
          fullscreenDialog: true,
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: ProductShowcasePage.routeName,
          page: () => ProductShowcasePage(),
        ),
        GetPage(
          name: CreateListingPage.routeName,
          page: () => const CreateListingPage(),
          binding: CreateListingBinding(),
          fullscreenDialog: true,
          middlewares: [AuthMiddleware(), ListingEligibleMiddleware()],
        ),
        GetPage(
          name: PublishListingDisclaimerPage.routeName,
          page: () => const PublishListingDisclaimerPage(),
          binding: PublishListingDisclaimerBinding(),
          middlewares: [
            AuthMiddleware(),
            ListingEligibleMiddleware(),
            PayoutDestinationMiddleware(),
          ],
        ),
        GetPage(
          name: PickLocationPage.routeName,
          page: () => const PickLocationPage(),
        ),
        GetPage(
          name: AddInclusionsPage.routeName,
          page: () => const AddInclusionsPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: YourListingPage.routeName,
          page: () => const YourListingPage(),
          middlewares: [AuthMiddleware(), ListingEligibleMiddleware()],
        ),
        GetPage(
          name: ChatPage.routeName,
          page: () => const ChatPage(),
          binding: ChatBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: ChatInformationPage.routeName,
          page: () => const ChatInformationPage(),
          binding: ChatInformationBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: DamageFeeRequestPage.routeName,
          page: () => const DamageFeeRequestPage(),
          binding: DamageFeeRequestBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: BookingDetailsPage.routeName,
          page: () => const BookingDetailsPage(),
          binding: BookingDetailsBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: BookingDocumentPdfPage.routeName,
          page: () => const BookingDocumentPdfPage(),
          binding: BookingDocumentPdfBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: ArchivedMessagePage.routeName,
          page: () => const ArchivedMessagePage(),
          binding: MessagesBinding(), // Added binding
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: EligibilityPage.routeName,
          page: () => const EligibilityPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: FullVerificationPage.routeName,
          page: () => const FullVerificationPage(),
          binding: FullVerificationBinding(),
          middlewares: [
            AuthMiddleware(),
            RentEligibleMiddleware(),
            FullVerificationPendingMiddleware(),
          ],
        ),
        GetPage(
          name: ScanQRPage.routeName,
          page: () => const ScanQRPage(),
          binding: ScanQRBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: QRViewPage.routeName,
          page: () => QRViewPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: TokenViewPage.routeName,
          page: () => const TokenViewPage(),
          middlewares: [AuthMiddleware()],
          fullscreenDialog: true,
        ),
        GetPage(
          name: SavedPage.routeName,
          page: () => const SavedPage(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: RecentlyViewedPage.routeName,
          page: () => const RecentlyViewedPage(),
          binding: RecentlyViewedBinding(),
          middlewares: [AuthMiddleware(), RentEligibleMiddleware()],
        ),
        GetPage(
          name: ReactivateAccountPage.routeName,
          page: () => const ReactivateAccountPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: AccountSettingsPage.routeName,
          page: () => const AccountSettingsPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: SecurityPage.routeName,
          page: () => const SecurityPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: NewPasswordPage.routeName,
          page: () => const NewPasswordPage(),
          binding: NewPasswordBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: DeactivateDeleteAccountPage.routeName,
          page: () => const DeactivateDeleteAccountPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: DeactivateDeleteAccountPage.legacyRouteName,
          page: () => const DeactivateDeleteAccountPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: AccountInformationPage.routeName,
          page: () => const AccountInformationPage(),
          binding: AccountInformationBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: ProfileViewPage.routeName,
          page: () => const ProfileViewPage(),
          binding: ProfileViewBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: OwnerPayoutDestinationPage.routeName,
          page: () => const OwnerPayoutDestinationPage(),
          middlewares: [AuthMiddleware(), ListingEligibleMiddleware()],
        ),
        GetPage(
          name: PayoutInstitutionPickerPage.routeName,
          page: () => const PayoutInstitutionPickerPage(),
          binding: PayoutInstitutionPickerBinding(),
          middlewares: [AuthMiddleware()],
        ),
      ],
      initialRoute: SplashPage.routeName,
    );
  }
}

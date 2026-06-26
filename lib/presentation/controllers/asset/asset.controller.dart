import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/list_details/stay_listing_details.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/core/services/listing_share.service.dart';
import 'package:lend/core/services/messaging.service.dart';

import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/report_sheet.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/booking_payment/booking_payment.controller.dart';
import 'package:lend/presentation/controllers/calendar_bookings/calendar_bookings.controller.dart';
import 'package:lend/presentation/controllers/calendar_picker/calendar_picker.controller.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/saved/saved.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/presentation/pages/asset/widgets/all_prices.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/listing_deactivation_request_sheet.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/listing_delete_blocked_sheet.widget.dart';
import 'package:lend/presentation/pages/photo_view/photo_view.page.dart';
import 'package:lend/presentation/pages/product_showcase/product_showcase.page.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/presentation/pages/all_reviews/all_reviews.page.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

import 'package:share_plus/share_plus.dart';

enum AssetPageSource { public, saved, booking, owner }

class AssetPageArgs {
  const AssetPageArgs({
    required this.asset,
    required this.controllerTag,
    this.source = AssetPageSource.public,
  });

  final Asset? asset;
  final String controllerTag;
  final AssetPageSource source;

  bool get canViewArchived =>
      source == AssetPageSource.saved ||
      source == AssetPageSource.booking ||
      source == AssetPageSource.owner;
}

class AssetController extends GetxController {
  AssetController(this.args)
    : controllerTag = args.controllerTag,
      _asset = Rx<Asset?>(args.asset),
      _isAssetLoading =
          (args.source != AssetPageSource.booking &&
                  _isIncompleteAsset(args.asset))
              .obs,
      cameraPosition = CameraPosition(
        target: LatLng(
          args.asset?.location?.lat ?? 0.0,
          args.asset?.location?.lng ?? 0.0,
        ),
        zoom: 13,
      );

  final AssetPageArgs args;
  final String controllerTag;

  final Rx<Asset?> _asset;
  Asset? get asset => _asset.value;

  final RxList<Booking> _bookingDates = <Booking>[].obs;
  List<Booking> get bookingDates => _bookingDates;
  List<Booking> get confirmedBookingDates =>
      _bookingDates
          .where((date) => BookingStatus.dateBlocking.contains(date.status))
          .toList();
  List<Booking> get pendingBookingDates =>
      _bookingDates
          .where((date) => date.status == BookingStatus.pending)
          .toList();

  final RxBool _isAssetLoading;
  bool get isAssetLoading => _isAssetLoading.value;

  final RxBool _isUserLoading = false.obs;
  bool get isUserLoading => _isUserLoading.value;

  bool get isCurrentUserOwner => AuthController.instance.uid == asset?.ownerId;

  bool get isBookingSnapshot => args.source == AssetPageSource.booking;

  bool get isAssetCurrentlyAvailable =>
      asset != null &&
      asset?.isDeleted == false &&
      asset?.status == Availability.available.label;

  bool get isAssetAvailableToBook =>
      !isBookingSnapshot && isAssetCurrentlyAvailable;

  int? get minimumNights {
    final details = asset?.listingDetails.details;
    if (details is! StayListingDetails) return null;
    final value = details.minimumNights;
    return value != null && value > 0 ? value : null;
  }

  final _mapController = Rxn<GoogleMapController>();
  GoogleMapController? get mapController => _mapController.value;

  final circles = <Circle>{}.obs;
  final markers = <Marker>{}.obs;

  final RxString _address = ''.obs;
  String get address => _address.value;

  final profileLatLng = ProfileController.instance.user?.location?.latLng;

  late CameraPosition cameraPosition;

  bool _canViewUnavailableAsset(Asset? target) {
    if (args.source == AssetPageSource.owner) return true;
    if (AuthController.instance.uid == target?.ownerId) return true;
    if (target?.status == 'Archived') return args.canViewArchived;
    return false;
  }

  static bool _isIncompleteAsset(Asset? asset) {
    return asset == null ||
        asset.description == null ||
        asset.rates?.daily == null;
  }

  @override
  void onReady() async {
    if (isBookingSnapshot) {
      super.onReady();
      return;
    }

    if (_isIncompleteAsset(asset)) {
      await getAsset();
    }

    if (asset != null) {
      await HomeController.instance.saveRecentlyViewedAsset(asset!);
    }

    await getBookings();

    super.onReady();
  }

  @override
  void onClose() {
    _asset.close();
    markers.close();
    circles.close();

    _mapController.close();
    _isUserLoading.close();
    _address.close();

    super.onClose();
  }

  /// Refreshes a single asset from Firestore
  /// and updates the HomeController with the new asset data.
  /// This method is useful for updating the asset details
  /// after a booking is made or any other changes.
  Future<void> refreshAsset() async {
    try {
      await getAsset();
      if (asset != null) {
        HomeController.instance.updateAsset(asset!);
      }
      refresh();
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  /// Fetches the asset details from Firestore
  Future<void> getAsset() async {
    try {
      _isAssetLoading.value = true;

      if (asset == null) {
        LNDSnackbar.showError('Product unavailable');
        Get.back();
        return;
      }
      if (UserBlockController.instance.isExcluded(asset?.ownerId)) {
        LNDSnackbar.showError('Product unavailable');
        Get.back();
        return;
      }

      final isDeleted = asset?.isDeleted == true;
      final isHidden = asset?.status == Availability.hidden.label;
      final isArchived = asset?.status == 'Archived';

      if (!isCurrentUserOwner &&
          (isDeleted ||
              ((isHidden || isArchived) && !_canViewUnavailableAsset(asset)))) {
        LNDSnackbar.showError('Product unavailable');
        Get.back();
        return;
      }

      final fetchedAsset = await LNDAssetService.getAssetById(asset!.id);

      if (fetchedAsset == null) {
        LNDSnackbar.showError('Product unavailable');
        Get.back();
        return;
      }

      if (!isCurrentUserOwner &&
          fetchedAsset.status != Availability.available.label &&
          !_canViewUnavailableAsset(fetchedAsset)) {
        LNDSnackbar.showError('Product unavailable');
        Get.back();
        return;
      }

      _asset.value = fetchedAsset;
      _isAssetLoading.value = false;
    } catch (e, st) {
      _isAssetLoading.value = false;
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Product unavailable');
      Get.back();
    }
  }

  /// Fetches the asset details from Firestore
  Future<void> getBookings() async {
    if (!AuthController.instance.isAuthenticated) return;

    try {
      final bookingDocs = FirebaseFirestore.instance
          .collection(LNDCollections.assets.name)
          .doc(asset?.id)
          .collection(LNDCollections.bookings.name)
          .orderBy('startDate', descending: true)
          .limit(30);

      final result = await bookingDocs.get();

      _bookingDates.value =
          result.docs.map((doc) => Booking.fromMap(doc.data())).toList();
    } catch (e, st) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        _bookingDates.clear();
        return;
      }
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Something went wrong');
      Get.back();
    }
  }

  void onMapCreated(GoogleMapController mapCtrl) {
    _mapController.value = mapCtrl;
    cameraPosition = CameraPosition(
      target: LatLng(
        asset?.location?.latLng?.latitude ?? 0.0,
        asset?.location?.latLng?.longitude ?? 0.0,
      ),
      zoom: 13,
    );

    if (asset?.location?.useSpecificLocation == true) {
      mapCtrl.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: cameraPosition.target,
        ),
      );
    } else {
      const radius = 500.0;
      final randomLocation = LNDUtils.getRandomLocationWithinRadius(
        cameraPosition.target,
        radius,
      );
      mapCtrl.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: randomLocation, zoom: 13),
        ),
      );
      final color =
          Get.context?.lndTheme.info ??
          Theme.of(Get.context!).colorScheme.secondary;
      circles.add(
        Circle(
          circleId: const CircleId('selected-location'),
          center: randomLocation,
          radius: radius,
          fillColor: color.withValues(alpha: 0.5),
          strokeColor: color,
          strokeWidth: 1,
        ),
      );
    }

    // _getAddressFromLatLng(cameraPosition.target);
  }

  void openAllPrices() async {
    LNDShow.bottomSheet(
      AssetAllPricesSheet(controllerTag: controllerTag),
      enableDrag: false,
    );
  }

  void goToCalendarPicker() async {
    if (isBookingSnapshot) return;

    final datesOnly = <DateTime>{};
    for (var booking in confirmedBookingDates) {
      final startDate = LNDUtils.bookingDateFromTimestamp(booking.startDate);
      final endDate = LNDUtils.bookingDateFromTimestamp(booking.endDate);
      if (startDate != null && endDate != null) {
        datesOnly.addAll(LNDUtils.daysInExclusiveEndRange(startDate, endDate));
        if (asset?.blocksEndDate == true) {
          datesOnly.add(LNDUtils.normalizeToDay(endDate));
        }
      }
    }
    await LNDNavigate.toCalendarPickerPage(
      args: CalendarPickerPageArgs(
        isReadOnly: false,
        dates: datesOnly.toList(),
        rates: asset?.rates ?? Rates(),
        minimumNights: minimumNights,
        onSubmit:
            (selectedDates, totalPrice) =>
                goToBookingPayment(selectedDates, totalPrice),
      ),
    );
  }

  void goToCalendarBookings() async {
    await LNDNavigate.toCalendarBookingsPage(
      args: CalendarBookingsPageArgs(
        isReadOnly: true,
        bookings: _bookingDates,
        rates: Rates(),
        assetControllerTag: controllerTag,
      ),
    );
  }

  void goToBookingPayment(List<DateTime> selectedDates, int totalPrice) async {
    if (selectedDates.length < 2 || selectedDates.first == selectedDates.last) {
      return;
    }
    final selectedNights = LNDUtils.exclusiveDayCount(
      selectedDates.first,
      selectedDates.last,
    );
    final requiredNights = minimumNights;
    if (requiredNights != null && selectedNights < requiredNights) {
      final unit = requiredNights == 1 ? 'night' : 'nights';
      LNDSnackbar.showWarning(
        'This listing requires a minimum stay of $requiredNights $unit.',
      );
      return;
    }
    try {
      if (asset == null) throw 'Asset does not exist';

      if (asset?.owner == null) throw 'Asset owner does not exist';

      if (asset?.id == null) throw 'Asset ID does not exist';

      await LNDNavigate.toBookingPaymentPage(
        args: BookingPaymentPageArgs(
          asset: asset!,
          selectedDates: List<DateTime>.from(selectedDates),
          totalPrice: totalPrice,
          assetControllerTag: controllerTag,
        ),
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Something went wrong. Please try again later.');
    }
  }

  void showAssetOptionsBottomSheet() async {
    if (isBookingSnapshot) return;

    final String? result = await LNDShow.menuBottomSheetHorizontal(
      items: [
        LNDMenuItem(
          label: 'Generate QR',
          value: 'generate_qr',
          icon: Icons.qr_code_2_rounded,
          onTap: (value) => value,
        ),
        LNDMenuItem(
          label: 'Update Availability',
          value: 'update_availability',
          icon: Icons.visibility_rounded,
          onTap: (value) => value,
        ),
        LNDMenuItem(
          label: 'Update Listing',
          value: 'update',
          icon: Icons.edit_outlined,
          onTap: (value) => value,
        ),
        LNDMenuItem(
          label: 'Delete Listing',
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onTap: (value) => value,
        ),
      ],
    );

    switch (result) {
      case 'generate_qr':
        showListingQr();
        break;
      case 'update_availability':
        _updateAvailability();
        break;
      case 'update':
        _updateAsset();
        break;
      case 'delete':
        _deleteAsset();
        break;
      default:
        break;
    }

    return;
  }

  void _updateAvailability() async {
    final currentAsset = asset;

    if (currentAsset == null || currentAsset.ownerId == null) {
      return;
    }

    final selectedAvailability = await LNDShow.radioBottomSheet<String>(
      title: 'Update Availability',
      selectedValue: currentAsset.status,
      items:
          Availability.values
              .map((a) => LNDRadioItem<String>(text: a.label, value: a.label))
              .toList(),
    );

    if (selectedAvailability == null) return;
    if (selectedAvailability == currentAsset.status) return;

    try {
      LNDLoading.show();

      await LNDAssetService.updateAssetAvailability(
        assetId: currentAsset.id,
        ownerId: currentAsset.ownerId!,
        availability: selectedAvailability,
      );

      _asset.update((value) {
        value?.status = selectedAvailability;
      });

      _asset.refresh();

      if (asset != null) {
        HomeController.instance.updateAsset(asset!);
      }

      refresh();

      LNDLoading.hide();
    } catch (e, st) {
      LNDLoading.hide();

      LNDLogger.e(e.toString(), error: e, stackTrace: st);

      LNDSnackbar.showError('Failed to update availability. Please try again.');
    }
  }

  void onTapShare() {
    if (isBookingSnapshot) return;

    _shareListingLink();
  }

  Future<void> showListingQr() async {
    if (isBookingSnapshot) return;

    final assetId = asset?.id;
    if (assetId == null || assetId.isEmpty || !isAssetCurrentlyAvailable) {
      LNDSnackbar.showError('Unable to share this listing.');
      return;
    }
    if (!AuthController.instance.isAuthenticated) {
      LNDNavigate.toSigninPage();
      return;
    }

    try {
      LNDLoading.show();
      final link = await LNDListingShareService.createListingShareLink(
        assetId: assetId,
        mode: ListingShareMode.generic,
      );
      LNDLoading.hide();
      await LNDNavigate.toQRViewPage(qrToken: link.url);
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error generating listing QR', error: e, stackTrace: st);
      final message =
          LNDListingShareService.isUnavailableError(e)
              ? 'This listing is no longer available.'
              : 'Unable to generate QR. Please try again.';
      LNDSnackbar.showError(message);
    }
  }

  Future<void> _shareListingLink() async {
    final assetId = asset?.id;
    if (assetId == null || assetId.isEmpty || !isAssetCurrentlyAvailable) {
      LNDSnackbar.showError('Unable to share this listing.');
      return;
    }
    if (!AuthController.instance.isAuthenticated) {
      LNDNavigate.toSigninPage();
      return;
    }

    try {
      LNDLoading.show();
      final link = await LNDListingShareService.createListingShareLink(
        assetId: assetId,
        mode: ListingShareMode.attributed,
      );
      LNDLoading.hide();

      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out ${asset?.title ?? 'this listing'} on Lend: ${link.url}',
          title: asset?.title ?? 'Check out this listing on Lend!',
        ),
      );
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error sharing listing', error: e, stackTrace: st);
      final message =
          LNDListingShareService.isUnavailableError(e)
              ? 'This listing is no longer available.'
              : 'Unable to generate share link. Please try again.';
      LNDSnackbar.showError(message);
    }
  }

  void showReportOptionsBottomSheet() async {
    if (isBookingSnapshot) return;

    final String? result = await LNDShow.menuBottomSheetVertical(
      items: [
        LNDMenuItem(
          label: 'Report',
          value: 'report',
          icon: Icons.flag_outlined,
          onTap: (value) => value,
        ),
      ],
    );

    if (result == 'report') showReportSheet();
  }

  void showReportSheet() async {
    if (asset == null || currentUserId == null) {
      LNDSnackbar.showError('Unable to report this listing.');
      return;
    }

    final submission = await LNDShow.bottomSheet<LNDReportSubmission>(
      const LNDReportSheet(
        types: [LNDReportType.listing],
        title: 'Report listing',
        description:
            'Tell us what is wrong with this listing. Reports help us review unsafe, misleading, or inappropriate content.',
        showArchiveAction: false,
        showTypeSelector: false,
      ),
    );
    if (submission == null) return;

    try {
      LNDLoading.show();

      await LNDMessagingService.reportContent(
        reporterId: currentUserId!,
        reportedUserId: asset?.ownerId,
        reportType: submission.type.label,
        reason: submission.reason,
        details: submission.details,
        assetId: asset?.id,
        archiveRequested: false,
        bookingCancelRequested: false,
      );

      LNDLoading.hide();
      LNDSnackbar.showSuccess('Report submitted.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error reporting listing', error: e, stackTrace: st);
      LNDSnackbar.showError('Failed to submit report.');
    }
  }

  String? get currentUserId => AuthController.instance.uid;

  void _updateAsset() async {
    if (asset == null) return;
    if (ProfileController.instance.hasPendingFullVerification) {
      LNDSnackbar.showInfo(
        'Listing changes are blocked while verification is pending.',
      );
      return;
    }
    await LNDNavigate.toCreateListing(
      args: CreateListingArguments(asset: asset),
    );
    refreshAsset(); // Refresh asset data after update
  }

  void _deleteAsset() async {
    if (asset == null || asset?.id == null || asset?.ownerId == null) return;

    try {
      LNDLoading.show();
      final eligibility = await LNDAssetService.getListingDeletionEligibility(
        assetId: asset!.id,
      );
      LNDLoading.hide();

      if (!eligibility.canDelete) {
        await _showBlockedDeleteFlow(eligibility);
        return;
      }
    } catch (_) {
      LNDLoading.hide();
      return;
    }

    final confirmed = await LNDShow.alertDialog(
      title: 'Delete Listing',
      content:
          'Are you sure you want to delete this listing? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Get.context?.lndTheme.danger,
    );

    if (confirmed == true) {
      LNDLoading.show();
      try {
        await LNDAssetService.deleteAsset(asset!.id, asset!.ownerId!);
        await HomeController.instance.getAssets();
        LNDLoading.hide();
        LNDNavigate.toHomePage();
      } catch (e, st) {
        LNDLoading.hide();
        LNDLogger.e('Error deleting asset: $e', error: e, stackTrace: st);
        LNDSnackbar.showError('Failed to delete asset. Please try again.');
      }
    }
  }

  Future<void> _showBlockedDeleteFlow(
    ListingDeletionEligibility eligibility,
  ) async {
    final action = await LNDShow.bottomSheet<ListingDeleteBlockedAction>(
      ListingDeleteBlockedSheet(eligibility: eligibility),
    );

    switch (action) {
      case ListingDeleteBlockedAction.underMaintenance:
        await _setAvailabilityFromBlockedDelete(Availability.underMaintenance);
        break;
      case ListingDeleteBlockedAction.hide:
        await _setAvailabilityFromBlockedDelete(Availability.hidden);
        break;
      case ListingDeleteBlockedAction.requestReview:
        await _requestDeactivationReview();
        break;
      case null:
        break;
    }
  }

  Future<void> _setAvailabilityFromBlockedDelete(
    Availability availability,
  ) async {
    final currentAsset = asset;
    final ownerId = currentAsset?.ownerId;
    if (currentAsset == null || ownerId == null) {
      return;
    }

    try {
      LNDLoading.show();
      await LNDAssetService.updateAssetAvailability(
        assetId: currentAsset.id,
        ownerId: ownerId,
        availability: availability.label,
      );
      _asset.update((value) {
        value?.status = availability.label;
      });
      _asset.refresh();
      LNDLoading.hide();
      LNDSnackbar.showSuccess('Listing updated.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(
        'Error updating blocked delete availability',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Failed to update listing.');
    }
  }

  Future<void> _requestDeactivationReview() async {
    final currentAsset = asset;
    final ownerId = currentAsset?.ownerId;
    if (currentAsset == null || ownerId == null) {
      return;
    }

    final submitted = await LNDShow.bottomSheet<bool>(
      ListingDeactivationRequestSheet(
        assetId: currentAsset.id,
        ownerId: ownerId,
      ),
      enableDrag: false,
    );
    if (submitted == true) {
      await refreshAsset();
    }
  }

  void onMapTap(LatLng position) {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 13),
        ),
      );
    }
  }

  void onMapLongPress(LatLng position) {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 13),
        ),
      );
    }
  }

  void addBookmark() {
    if (isBookingSnapshot) return;

    if (!AuthController.instance.isAuthenticated) {
      LNDNavigate.toSigninPage();
      return;
    }

    if (asset == null) return;

    try {
      SavedController.instance.addSaved(asset!);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  void removeBookmark() async {
    if (isBookingSnapshot) return;

    if (!AuthController.instance.isAuthenticated) return;
    if (asset == null) return;

    try {
      SavedController.instance.removeSaved(asset!.id);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  void openPhotoShowcase(int index) {
    LNDNavigate.toPhotoViewPage(
      args: PhotoViewArguments(
        images: asset?.showcase ?? [],
        intialIndex: index,
      ),
    );
  }

  void openPhotoAsset(int index) {
    LNDNavigate.toPhotoViewPage(
      args: PhotoViewArguments(images: asset?.images ?? [], intialIndex: index),
    );
  }

  void openSeeAllShowcase() {
    LNDNavigate.toProductShowcasePage(
      args: ProductShowcaseArguments(showcase: asset?.showcase ?? []),
    );
  }

  void goToAllReviewsPage() {
    if (isBookingSnapshot) return;

    if (asset != null) {
      LNDNavigate.toAllReviewsPage(
        args: AllReviewsPageArgs(assetId: asset!.id),
      );
    }
  }

  void viewLiveListing() {
    final assetId = asset?.id;
    if (assetId == null || assetId.isEmpty) {
      LNDSnackbar.showError('Unable to open the live listing.');
      return;
    }

    LNDNavigate.toAssetPage(args: Asset(id: assetId));
  }

  // Future<void> _getAddressFromLatLng(LatLng position) async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks.first;
  //       _address.value =
  //           '${place.street}, ${place.locality}, ${place.isoCountryCode}';
  //     } else {
  //       _address.value = "No address found";
  //     }
  //   } catch (e, st) {
  //     _address.value = 'No address found';
  //     LNDLogger.e(e.toString(), error: e, stackTrace: st);
  //   }
  // }
}

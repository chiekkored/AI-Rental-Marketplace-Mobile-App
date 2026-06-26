import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/mixins/textfields.mixin.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/category.model.dart';
import 'package:lend/core/models/file.model.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_category.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_details.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_dynamic_details_chunk_factory.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_inclusions.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_location.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_photos.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_pricing.chunk.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class CreateListingArguments {
  final String? assetId;
  final Asset? asset;
  final bool isPublicAssetEdit;

  const CreateListingArguments({
    this.assetId,
    this.asset,
    this.isPublicAssetEdit = true,
  });
}

enum CreateListingPhotoSource { camera, gallery }

class CreateListingController extends GetxController
    with TextFieldsMixin, AuthMixin {
  static CreateListingController get instance =>
      Get.find<CreateListingController>();

  static const int maxBannerPhotos = 6;
  static const int maxShowcasePhotos = 12;

  final RxInt currentStep = 0.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;
  final RxBool isPostingDummyData = false.obs;
  final RxBool blocksEndDate = false.obs;
  final RxString listingKind = ''.obs;
  final RxString detailSchemaKey = ''.obs;
  final Rx<Availability> availability = Availability.available.obs;

  late final CreateListingCategoryChunk category = CreateListingCategoryChunk();
  late final CreateListingDetailsChunk details = CreateListingDetailsChunk();
  late final CreateListingPricingChunk pricing = CreateListingPricingChunk();
  late final CreateListingLocationChunk location = CreateListingLocationChunk();
  late final CreateListingPhotosChunk photos = CreateListingPhotosChunk(
    isSaving: isSaving,
    currentUid: () => currentUid,
    draftId: () => _listingDraftId,
    nextFileName: _nextListingImageFileName,
    maxBannerPhotos: maxBannerPhotos,
    maxShowcasePhotos: maxShowcasePhotos,
  );
  late final CreateListingInclusionsChunk inclusion =
      CreateListingInclusionsChunk();
  CreateListingDynamicDetailsChunk? dynamicDetails;

  late final List<CreateListingChunk> _chunks = [
    category,
    details,
    pricing,
    location,
    photos,
    inclusion,
  ];
  final List<Worker> _workers = [];
  final Set<CreateListingDynamicDetailsChunk> _pendingDynamicDetailsDisposals =
      {};
  bool _isDisposing = false;

  Asset? _initialAsset;
  late final String _listingDraftId;
  int _listingImageUploadSequence = 0;

  bool get showPostDummyDataButton {
    return kDebugMode && isEditing.isFalse && isPostingDummyData.isFalse;
  }

  Location? get listingLocation => location.listingLocation;

  List<String> get uploadedImages => photos.uploadedImages;

  String get _draftStorageKey {
    final uid = currentUid;
    if (uid == null || uid.isEmpty) {
      return LNDStorageConstants.createListingDraft;
    }
    return '${LNDStorageConstants.createListingDraft}_$uid';
  }

  // ---------------------------------------------------------------------------
  // Bridge getters. Keep these while migrating your UI gradually.
  // Your widgets can continue to use controller.titleController, etc.
  // ---------------------------------------------------------------------------

  GlobalKey<FormState> get detailsFormKey => details.formKey;
  GlobalKey<FormState> get pricingFormKey => pricing.formKey;
  GlobalKey<FormState> get locationFormKey => location.formKey;
  GlobalKey<FormState> get photosFormKey => photos.formKey;

  TextEditingController get titleController => details.titleController;
  TextEditingController get descriptionController =>
      details.descriptionController;
  TextEditingController get ownerInstructionsController =>
      details.ownerInstructionsController;
  TextEditingController get categoryController => category.categoryController;
  TextEditingController get dailyPriceController =>
      pricing.dailyPriceController;
  TextEditingController get weeklyPriceController =>
      pricing.weeklyPriceController;
  TextEditingController get monthlyPriceController =>
      pricing.monthlyPriceController;
  TextEditingController get annualPriceController =>
      pricing.annualPriceController;
  TextEditingController get securityDepositController =>
      pricing.securityDepositController;
  TextEditingController get locationController => location.locationController;
  TextEditingController get inclusionController =>
      inclusion.inclusionController;

  RxString get locationText => location.locationText;
  RxBool get useCurrentLocation => location.useCurrentLocation;
  RxBool get showPrimaryPhotoError => photos.showPrimaryPhotoError;
  RxBool get isUploadingPhotos => photos.isUploadingPhotos;
  RxBool get currentLocationDenied => location.currentLocationDenied;
  RxBool get canContinueDetails => details.canContinue;
  RxBool get canContinueCategory => category.canContinue;
  RxBool get canContinuePricing => pricing.canContinue;
  RxBool get canContinueLocation => location.canContinue;
  RxBool get canContinuePhotos => photos.canContinue;
  bool get canContinueDynamicDetails =>
      dynamicDetails?.canContinue.value ?? true;
  RxBool get weeklyRateEnabled => pricing.weeklyRateEnabled;
  RxBool get monthlyRateEnabled => pricing.monthlyRateEnabled;
  RxBool get annualRateEnabled => pricing.annualRateEnabled;
  RxBool get securityDepositEnabled => pricing.securityDepositEnabled;
  Rxn<LNDCategory> get selectedCategory => category.selectedCategory;
  Rxn<LNDCategory> get selectedSubcategory => category.selectedSubcategory;
  Rxn<Rx<FileModel>> get primaryPhoto => photos.primaryPhoto;
  RxList<Rx<FileModel>> get additionalPhotos => photos.additionalPhotos;
  RxList<Rx<FileModel>> get showcasePhotos => photos.showcasePhotos;
  RxList<String> get inclusions => inclusion.inclusions;

  List<LNDCategory> get availableSubcategories =>
      category.availableSubcategories;

  void setWeeklyRateEnabled(bool value) {
    pricing.setWeeklyRateEnabled(value);
  }

  void setMonthlyRateEnabled(bool value) {
    pricing.setMonthlyRateEnabled(value);
  }

  void setAnnualRateEnabled(bool value) {
    pricing.setAnnualRateEnabled(value);
  }

  bool get requiresSubcategory => category.requiresSubcategory;

  int get bannerPhotoCount => photos.bannerPhotoCount;

  int get dynamicDetailsStepCount {
    return switch (detailSchemaKey.value) {
      'stay' => 5,
      'space' => 5,
      'vehicle' => 4,
      'tool' => 3,
      'electronics' => 3,
      'party_event' => 3,
      'clothing' => 3,
      _ => 2,
    };
  }

  int get totalSteps => 10 + dynamicDetailsStepCount;

  int get dynamicDetailsStartStepIndex => 3;

  int get lastDynamicDetailsStepIndex =>
      dynamicDetailsStartStepIndex + dynamicDetailsStepCount - 1;

  int get inclusionsStepIndex =>
      dynamicDetailsStartStepIndex + dynamicDetailsStepCount;

  int get pricingStepIndex => inclusionsStepIndex + 1;

  int get locationStepIndex => inclusionsStepIndex + 2;

  int get photosStepIndex => inclusionsStepIndex + 3;

  int get endDateRuleStepIndex => inclusionsStepIndex + 4;

  int get ownerInstructionsStepIndex => inclusionsStepIndex + 5;

  int get availabilityStepIndex => inclusionsStepIndex + 6;

  String get dynamicDetailsTitle {
    return switch (detailSchemaKey.value) {
      'stay' => 'Stay details',
      'space' => 'Space details',
      'vehicle' => 'Vehicle details',
      'tool' => 'Tool details',
      'electronics' => 'Electronics details',
      'party_event' => 'Party and event details',
      'clothing' => 'Clothing details',
      _ => 'Asset details',
    };
  }

  @override
  void onInit() {
    final args = Get.arguments;

    if (args is CreateListingArguments && args.asset != null) {
      if (args.isPublicAssetEdit) {
        _initialAsset = args.asset;
        isEditing.value = true;
      }

      _listingDraftId =
          args.isPublicAssetEdit ? args.asset!.id : _createListingDraftId();

      _initializeChunks();
      _populateFields(args.asset!);
    } else {
      _listingDraftId = _createListingDraftId();
      _initializeChunks();
      location.setInitialProfileLocationIfAvailable();
      _loadLocalDraft();
    }

    super.onInit();
  }

  void _initializeChunks() {
    for (final chunk in _chunks) {
      chunk.onInit();
    }
    _workers.addAll([
      ever<LNDCategory?>(category.selectedCategory, (_) {
        _syncDynamicDetailsChunk(forceRecreate: true);
      }),
      ever<LNDCategory?>(category.selectedSubcategory, (_) {
        _syncDynamicDetailsChunk(forceRecreate: true);
      }),
    ]);
    _syncDynamicDetailsChunk();
  }

  void _syncDynamicDetailsChunk({
    ListingDetailsData? detailsToPopulate,
    bool forceRecreate = false,
  }) {
    final selected = category.selectedSchemaSource;
    final schemaKey = selected?.detailSchemaKey;

    listingKind.value = selected?.listingKind ?? '';
    detailSchemaKey.value = schemaKey ?? '';
    goToStep(currentStep.value);

    if (!forceRecreate &&
        dynamicDetails?.detailSchemaKey == (schemaKey ?? 'generic_asset')) {
      if (detailsToPopulate != null) {
        dynamicDetails?.populateFromDetails(detailsToPopulate);
      }
      return;
    }

    final previousDynamicDetails = dynamicDetails;
    dynamicDetails = createDynamicDetailsChunk(schemaKey);
    dynamicDetails?.onInit();
    if (detailsToPopulate != null) {
      dynamicDetails?.populateFromDetails(detailsToPopulate);
    }
    _disposeDynamicDetailsChunkAfterFrame(previousDynamicDetails);
  }

  void _disposeDynamicDetailsChunkAfterFrame(
    CreateListingDynamicDetailsChunk? chunk,
  ) {
    if (chunk == null || chunk == dynamicDetails) return;
    if (!_pendingDynamicDetailsDisposals.add(chunk)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposing) return;
      if (chunk != dynamicDetails) {
        chunk.onClose();
      }
      _pendingDynamicDetailsDisposals.remove(chunk);
    });
  }

  @override
  void onClose() {
    _isDisposing = true;
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();

    for (final chunk in _chunks.reversed) {
      chunk.onClose();
    }
    for (final chunk in _pendingDynamicDetailsDisposals) {
      if (chunk != dynamicDetails) {
        chunk.onClose();
      }
    }
    _pendingDynamicDetailsDisposals.clear();
    dynamicDetails?.onClose();

    currentStep.close();
    isSaving.close();
    isEditing.close();
    isPostingDummyData.close();
    blocksEndDate.close();
    listingKind.close();
    detailSchemaKey.close();
    availability.close();

    super.onClose();
  }

  void _populateFields(Asset asset) {
    category.populateFromAsset(asset);
    details.populateFromAsset(asset);
    pricing.populateFromAsset(asset);
    location.populateFromAsset(asset);
    photos.populateFromAsset(asset);
    inclusion.populateFromAsset(asset);
    _syncDynamicDetailsChunk(detailsToPopulate: asset.listingDetails.details);

    blocksEndDate.value = asset.blocksEndDate;
    availability.value = Availability.values.firstWhere(
      (status) => status.label == asset.status,
      orElse: () => Availability.available,
    );
  }

  void _loadLocalDraft() {
    final savedDraft = LNDStorageService.read<dynamic>(_draftStorageKey);
    if (savedDraft is! Map) return;

    final draft = Map<String, dynamic>.from(savedDraft);

    try {
      details.loadFromDraft(draft);
      category.loadFromDraft(draft);
      final draftDetailSchemaKey = category.detailSchemaKey;
      _syncDynamicDetailsChunk(
        detailsToPopulate:
            draft['details'] is Map
                ? ListingDetailsData.fromMap(
                  draftDetailSchemaKey,
                  Map<String, dynamic>.from(draft['details'] as Map),
                )
                : null,
      );
      pricing.loadFromDraft(draft);
      location.loadFromDraft(draft);
      photos.loadFromDraft(draft);
      inclusion.loadFromDraft(draft);

      blocksEndDate.value = draft['blocksEndDate'] as bool? ?? false;

      final savedAvailability = draft['availability'] as String?;
      availability.value = Availability.values.firstWhere(
        (status) => status.label == savedAvailability,
        orElse: () => Availability.available,
      );
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      _clearLocalDraft();
    }
  }

  void selectCategory(LNDCategory selected) {
    category.selectCategory(selected);
  }

  void selectSubcategory(LNDCategory selected) {
    category.selectSubcategory(selected);
  }

  void goToStep(int step) {
    currentStep.value = step.clamp(0, totalSteps - 1);
  }

  void openPricingInfo() {
    LNDShow.bottomSheetInfo([
      LNDText.regular(
        text:
            'Your daily rate is the base price renters see for one day. Weekly, monthly, and annual rates are optional. When enabled, they are suggested from your daily rate so you can keep the calculation or adjust it.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'Daily-only bookings are paid all at once. Bookings that use weekly, monthly, or annual rates are paid through recurring billing with automatic deductions from the renter\'s selected payment method.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'Owner payout deducts the wallet transfer fee used to send earnings to your payout account.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'If you require a security deposit, you will shoulder its processing fees. It is refundable to renter and is not counted as owner profit. When it is returned, the deposit return wallet transfer fee is also deducted from owner earnings.',
        overflow: TextOverflow.visible,
      ),
      LNDText.regular(
        text:
            'Estimated owner payout is rental subtotal minus platform fee, owner payout wallet fee, and the deposit return wallet fee when a deposit is enabled.',
        overflow: TextOverflow.visible,
      ),
    ], title: 'How pricing works');
  }

  void continueFromCategory() {
    if (!category.hasSelectedCategory) {
      LNDSnackbar.showWarning('Please select a category.');
      return;
    }

    goToStep(requiresSubcategory ? 1 : 2);
  }

  void continueFromSubcategory() {
    if (requiresSubcategory && !category.hasSelectedSubcategory) {
      LNDSnackbar.showWarning('Please select a subcategory.');
      return;
    }

    goToStep(2);
  }

  void continueFromDetails() {
    if (!details.validate()) return;
    goToStep(dynamicDetailsStartStepIndex);
  }

  void continueFromDynamicDetails(int dynamicStepIndex) {
    if (!(dynamicDetails?.validate() ?? true)) return;
    if (dynamicStepIndex < dynamicDetailsStepCount - 1) {
      goToStep(dynamicDetailsStartStepIndex + dynamicStepIndex + 1);
      return;
    }
    goToStep(inclusionsStepIndex);
  }

  void continueFromInclusions() {
    goToStep(pricingStepIndex);
  }

  void continueFromPricing() {
    if (!pricing.validate()) return;

    if (!pricing.hasDailyRate) {
      LNDSnackbar.showWarning('Please add a daily rate.');
      return;
    }

    if (!_validateOptionalRates()) {
      return;
    }

    if (pricing.securityDepositEnabled.value &&
        !pricing.hasSecurityDepositAmount) {
      LNDSnackbar.showWarning('Please add a security deposit amount.');
      return;
    }

    goToStep(locationStepIndex);
  }

  void continueFromLocation() {
    if (location.useCurrentLocation.value) {
      goToStep(photosStepIndex);
      return;
    }

    final customLocation = location.customLocation;
    if (customLocation == null ||
        (customLocation.description?.isEmpty ?? true)) {
      LNDSnackbar.showWarning('Please choose a listing location.');
      return;
    }

    goToStep(photosStepIndex);
  }

  void continueFromPhotos() {
    if (!photos.hasPrimaryPhoto) {
      photos.showPrimaryPhotoError.value = true;
      LNDSnackbar.showWarning('Please upload a primary photo.');
      return;
    }

    if (!photos.allPhotosUploaded) {
      LNDSnackbar.showWarning('Please wait for photos to finish uploading.');
      return;
    }

    goToStep(endDateRuleStepIndex);
  }

  void continueFromEndDateRule() {
    goToStep(ownerInstructionsStepIndex);
  }

  void continueFromOwnerInstructions() {
    goToStep(availabilityStepIndex);
  }

  void setBlocksEndDate(bool? value) {
    blocksEndDate.value = value ?? false;
  }

  Future<void> toggleCurrentLocation(bool value) {
    return location.toggleCurrentLocation(value);
  }

  Future<void> openLocationPicker() {
    return location.openLocationPicker();
  }

  Future<void> pickPrimaryPhoto() {
    return photos.pickPrimaryPhoto();
  }

  Future<void> pickBannerPhotos(CreateListingPhotoSource source) {
    return photos.pickBannerPhotos(source);
  }

  Future<void> pickShowcasePhotos() {
    return photos.pickShowcasePhotos();
  }

  Future<void> pickShowcasePhotosFromSource(CreateListingPhotoSource source) {
    return photos.pickShowcasePhotosFromSource(source);
  }

  void removePrimaryPhoto() {
    photos.removePrimaryPhoto();
  }

  void removeAdditionalPhoto(int index) {
    photos.removeAdditionalPhoto(index);
  }

  void removeShowcasePhoto(int index) {
    photos.removeShowcasePhoto(index);
  }

  void addInclusion() {
    inclusion.addInclusion();
  }

  void removeInclusion(int index) {
    inclusion.removeInclusion(index);
  }

  void closeListing() {
    if (isEditing.isTrue) {
      Get.back();
      return;
    }

    showCloseDraftDialog();
  }

  Future<void> showCloseDraftDialog() async {
    final result = await LNDShow.alertDialog(
      title: 'Save listing as draft?',
      content:
          'You can save your progress and continue editing this listing later.',
      confirmText: 'Save Draft',
      cancelText: 'Discard',
      tertiaryText: 'Cancel',
      onCancel: () => Get.back(result: _CloseListingAction.discard),
      onConfirm: () => Get.back(result: _CloseListingAction.saveDraft),
      cancelColor: Get.context!.lndTheme.danger,
    );

    switch (result) {
      case _CloseListingAction.discard:
        await _clearLocalDraft();
        Get.back();
        break;
      case _CloseListingAction.saveDraft:
        await saveDraft(exitAfterSave: true);
        break;
      case _CloseListingAction.cancel:
      case null:
        break;
    }
  }

  Future<void> saveDraft({bool exitAfterSave = false}) async {
    if (isEditing.isTrue) {
      Get.back();
      return;
    }

    if (photos.isUploadingPhotos.value) {
      LNDSnackbar.showWarning(
        'Please wait for photos to finish uploading before saving draft.',
      );
      return;
    }

    await LNDStorageService.write(_draftStorageKey, _buildLocalDraft());
    LNDSnackbar.showSuccess('Draft saved on this device.');

    if (exitAfterSave) Get.back();
  }

  Future<void> publishListing() async {
    if (!await _validateAllSteps()) return;
    if (isEditing.isFalse && !await _ensurePublishDisclaimerAccepted()) return;

    final saved = await _saveListing(
      status: availability.value.label,
      validate: false,
    );

    if (saved) {
      await _clearLocalDraft();
      LNDNavigate.toRootPage();
      LNDSnackbar.showSuccess(
        'Listing submitted. We will notify you after review.',
      );
    }
  }

  Future<void> postDummyListings() async {
    if (!showPostDummyDataButton) return;

    final uid = currentUid;
    if (uid == null || uid.isEmpty) {
      LNDSnackbar.showWarning('Sign in before creating dummy listings.');
      return;
    }

    try {
      isSaving.value = true;
      isPostingDummyData.value = true;
      LNDLoading.show();

      final result = await LNDAssetService.createDummyListings();
      await _refreshListingsAfterDummySubmission();

      if (result.created && result.count > 0) {
        LNDSnackbar.showSuccess('${result.count} dummy listings created.');
      } else {
        LNDSnackbar.showError('No dummy listings were created.');
      }
    } catch (e, st) {
      LNDLogger.e(
        'Failed to post dummy listings: $e',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Failed to create dummy listings.');
    } finally {
      LNDLoading.hide();
      isPostingDummyData.value = false;
      isSaving.value = false;
    }
  }

  Future<void> _refreshListingsAfterDummySubmission() async {
    final futures = <Future<void>>[];
    if (Get.isRegistered<YourListingController>()) {
      futures.add(YourListingController.instance.refreshMyAssets());
    }
    if (Get.isRegistered<HomeController>()) {
      futures.add(HomeController.instance.getAssets(force: true));
    }
    if (futures.isNotEmpty) await Future.wait(futures);
  }

  Future<bool> _ensurePublishDisclaimerAccepted() async {
    final uid = currentUid;
    if (uid != null && uid.isNotEmpty) {
      final acknowledged = LNDStorageService.read<bool>(
        LNDStorageConstants.publishListingDisclaimerAcknowledgedKey(uid),
      );
      if (acknowledged == true) return true;
    }

    final accepted = await LNDNavigate.toPublishListingDisclaimerPage();
    return accepted == true;
  }

  Future<bool> _validateAllSteps() async {
    if (!category.hasSelectedCategory) {
      goToStep(0);
      LNDSnackbar.showWarning('Please select a category.');
      return false;
    }

    if (requiresSubcategory && !category.hasSelectedSubcategory) {
      goToStep(1);
      LNDSnackbar.showWarning('Please select a subcategory.');
      return false;
    }

    if (!details.validate()) {
      goToStep(2);
      return false;
    }

    if (!(dynamicDetails?.validate() ?? true)) {
      goToStep(dynamicDetailsStartStepIndex);
      return false;
    }

    if (!pricing.hasDailyRate) {
      goToStep(pricingStepIndex);
      LNDSnackbar.showWarning('Please add a daily rate.');
      return false;
    }

    if (!_validateOptionalRates(goToPricingStep: true)) {
      return false;
    }

    if (pricing.securityDepositEnabled.value &&
        !pricing.hasSecurityDepositAmount) {
      goToStep(pricingStepIndex);
      LNDSnackbar.showWarning('Please add a security deposit amount.');
      return false;
    }

    if (!await location.ensureListingLocation()) {
      goToStep(locationStepIndex);
      LNDSnackbar.showWarning('Please choose a listing location.');
      return false;
    }

    if (!photos.hasPrimaryPhoto) {
      photos.showPrimaryPhotoError.value = true;
      goToStep(photosStepIndex);
      LNDSnackbar.showWarning('Please upload a primary photo.');
      return false;
    }

    if (!photos.allPhotosUploaded) {
      goToStep(photosStepIndex);
      LNDSnackbar.showWarning('Please wait for photos to finish uploading.');
      return false;
    }

    if (!await _ensurePayoutDestinationsForListing()) {
      return false;
    }

    return true;
  }

  Future<bool> _ensurePayoutDestinationsForListing() async {
    try {
      final destinations = await LNDPaymentService.getPayoutDestinations();
      if (destinations.payoutDestination == null) {
        LNDSnackbar.showError(
          'Add an owner payout destination before creating listings.',
        );
        await LNDNavigate.toOwnerPayoutDestinationPage();
        return false;
      }

      return true;
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to verify payout destination.');
      await LNDNavigate.toOwnerPayoutDestinationPage();
      return false;
    }
  }

  bool _validateOptionalRates({bool goToPricingStep = false}) {
    if (pricing.weeklyRateEnabled.value && !pricing.hasWeeklyRate) {
      if (goToPricingStep) goToStep(pricingStepIndex);
      LNDSnackbar.showWarning('Please add a weekly rate.');
      return false;
    }

    if (pricing.monthlyRateEnabled.value && !pricing.hasMonthlyRate) {
      if (goToPricingStep) goToStep(pricingStepIndex);
      LNDSnackbar.showWarning('Please add a monthly rate.');
      return false;
    }

    if (pricing.annualRateEnabled.value && !pricing.hasAnnualRate) {
      if (goToPricingStep) goToStep(pricingStepIndex);
      LNDSnackbar.showWarning('Please add an annual rate.');
      return false;
    }

    return true;
  }

  Future<bool> _saveListing({
    required String status,
    required bool validate,
  }) async {
    if (validate && !await _validateAllSteps()) return false;

    try {
      isSaving.value = true;
      LNDLoading.show();

      final asset = _buildAsset(status: status);

      final reviewResult = await LNDAssetService.submitListingForReview(
        asset: asset,
        isUpdate: isEditing.isTrue,
      );

      if (!reviewResult.accepted || reviewResult.submissionId == null) {
        LNDSnackbar.showError('Failed to submit listing for review.');
        return false;
      }

      return true;
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Failed to save listing. Please try again.');
      return false;
    } finally {
      LNDLoading.hide();
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _buildLocalDraft() {
    return {
      ...details.toDraftMap(),
      ...category.toDraftMap(),
      'details': dynamicDetails?.toListingDetails().toMap() ?? {},
      'blocksEndDate': blocksEndDate.value,
      ...pricing.toDraftMap(),
      'availability': availability.value.label,
      ...location.toDraftMap(),
      ...photos.toDraftMap(),
      ...inclusion.toDraftMap(),
    }..removeWhere((key, value) => value == null);
  }

  Future<void> _clearLocalDraft() async {
    await LNDStorageService.remove(_draftStorageKey);
  }

  AddAsset _buildAsset({required String status}) {
    final selectedCategoryValue = category.selectedCategory.value;
    if (selectedCategoryValue == null) {
      throw StateError('Cannot build listing asset without a category.');
    }

    final docId = _initialAsset?.id ?? LNDAssetService.createAssetId();

    return AddAsset(
      id: docId,
      ownerId: AuthController.instance.uid ?? '',
      owner: ProfileController.instance.listingOwnerSnapshot,
      title: details.titleController.text.trim(),
      description: details.descriptionController.text.trim(),
      categoryId: selectedCategoryValue.id,
      categoryName: selectedCategoryValue.name,
      subcategoryId: category.selectedSubcategory.value?.id,
      subcategoryName: category.selectedSubcategory.value?.name,
      listingDetails: ListingDetailsModel(
        listingKind: listingKind.value,
        detailSchemaKey: detailSchemaKey.value,
        details:
            dynamicDetails?.toListingDetails() ??
            const GenericAssetListingDetails(),
      ),
      rates: Rates(
        daily: pricing.dailyRate,
        weekly: pricing.weeklyRateEnabled.value ? pricing.weeklyRate : null,
        monthly: pricing.monthlyRateEnabled.value ? pricing.monthlyRate : null,
        annually: pricing.annualRateEnabled.value ? pricing.annualRate : null,
        currency:
            CountryPreferenceController
                .instance
                .currencyCountry
                .value
                .currencyCode,
      ),
      location: location.listingLocation,
      images: photos.uploadedImages,
      showcase: photos.uploadedShowcaseImages,
      inclusions: inclusion.inclusions.toList(),
      ownerInstructions:
          details.ownerInstructionsController.text.trim().isEmpty
              ? null
              : details.ownerInstructionsController.text.trim(),
      blocksEndDate: blocksEndDate.value,
      createdAt: _initialAsset?.createdAt ?? Timestamp(0, 0),
      status: status,
      securityDeposit:
          pricing.securityDepositEnabled.value
              ? SecurityDeposit(
                enabled: true,
                amount: pricing.securityDepositAmount ?? 0,
              )
              : const SecurityDeposit.disabled(),
    );
  }

  String _createListingDraftId() {
    final uid = currentUid ?? 'guest';
    return '${uid}_${DateTime.now().microsecondsSinceEpoch}';
  }

  String _nextListingImageFileName() {
    _listingImageUploadSequence += 1;
    return '${DateTime.now().microsecondsSinceEpoch}_$_listingImageUploadSequence.jpg';
  }
}

enum _CloseListingAction { discard, saveDraft, cancel }

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didit_sdk/sdk_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/mixins/textfields.mixin.dart';
import 'package:lend/core/models/business_registration_submission.model.dart';
import 'package:lend/core/models/full_verification_submission.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/presentation/controllers/location_picker/location_picker.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/business_registration_document.enum.dart';
import 'package:lend/utilities/extensions/datetime.extension.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/firebase_storage.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/country_data.helper.dart';
import 'package:url_launcher/url_launcher.dart';

class FullVerificationController extends GetxController with TextFieldsMixin {
  static FullVerificationController get instance =>
      Get.find<FullVerificationController>();
  static final Uri _diditTermsUrl = Uri.parse(
    'https://didit.me/terms/identity-verification/',
  );
  static final Uri _diditPrivacyUrl = Uri.parse(
    'https://didit.me/terms/verification-privacy-notice/',
  );

  final detailsFormKey = GlobalKey<FormState>();
  final pageController = PageController();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final photoUrlController = TextEditingController();

  final RxInt _currentStep = 0.obs;
  int get currentStep => _currentStep.value;

  final RxBool _canContinueDetails = false.obs;
  bool get canContinueDetails => _canContinueDetails.value;

  final RxBool _isUploadingProfilePhoto = false.obs;
  bool get isUploadingProfilePhoto => _isUploadingProfilePhoto.value;

  final RxString _profilePhotoUrl = ''.obs;
  String get profilePhotoUrl => _profilePhotoUrl.value;

  final RxBool _faceKycCaptured = false.obs;
  bool get faceKycCaptured => _faceKycCaptured.value;

  final RxBool _diditLoading = false.obs;
  bool get diditLoading => _diditLoading.value;

  final RxString _diditStatus = ''.obs;
  String get diditStatus => _diditStatus.value;

  final RxString _diditSessionId = ''.obs;
  String get diditSessionId => _diditSessionId.value;

  final RxString _diditWorkflowId = ''.obs;
  String get diditWorkflowId => _diditWorkflowId.value;

  final Rxn<DateTime> _diditStartedAt = Rxn<DateTime>();
  DateTime? get diditStartedAt => _diditStartedAt.value;

  final Rxn<DateTime> _diditCompletedAt = Rxn<DateTime>();
  DateTime? get diditCompletedAt => _diditCompletedAt.value;

  final Rx<Location?> _selectedLocation = Rx<Location?>(null);
  Location? get selectedLocation => _selectedLocation.value;

  final RxBool _isRentalBusinessOwner = false.obs;
  bool get isRentalBusinessOwner => _isRentalBusinessOwner.value;

  final RxBool _isUploadingBusinessDocument = false.obs;
  bool get isUploadingBusinessDocument => _isUploadingBusinessDocument.value;

  final RxBool _taxInvoiceAcknowledged = false.obs;
  bool get taxInvoiceAcknowledged => _taxInvoiceAcknowledged.value;

  final RxString _dtiPath = ''.obs;
  final RxString _birPath = ''.obs;
  final RxString _mayorBusinessPermitPath = ''.obs;

  UserModel? get _user => ProfileController.instance.user;

  bool get hasProfilePhoto => _profilePhotoUrl.value.trim().isNotEmpty;
  bool get hasDti => _dtiPath.value.trim().isNotEmpty;
  bool get hasBir => _birPath.value.trim().isNotEmpty;
  bool get hasMayorBusinessPermit =>
      _mayorBusinessPermitPath.value.trim().isNotEmpty;
  bool get hasApprovedBusinessRegistration =>
      _user?.businessRegistration?.isApproved == true;
  bool get canContinueBusinessOwner =>
      !_isRentalBusinessOwner.value ||
      hasApprovedBusinessRegistration ||
      (hasDti &&
          hasBir &&
          _taxInvoiceAcknowledged.value &&
          !_isUploadingBusinessDocument.value);
  String get phoneHint =>
      CountryPreferenceController.instance.iddCountry.value.phoneHint;
  String get phonePrefixText =>
      CountryPreferenceController.instance.iddCountry.value.iddButtonText;
  String get formattedPhoneNumber => LNDCountryData.e164PhoneNumber(
    localNumber: phoneController.text.trim(),
    country: CountryPreferenceController.instance.iddCountry.value,
  );

  LocationCallbackModel get initialLocationCallback {
    final location = selectedLocation ?? _user?.location;
    return LocationCallbackModel(
      location: location ?? Location(),
      useSpecificLocation: location?.useSpecificLocation ?? true,
    );
  }

  @override
  void onInit() {
    _setInitialValues();
    _bindDetailsContinueState();
    _updateDetailsContinue();
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    firstNameController.removeListener(_updateDetailsContinue);
    lastNameController.removeListener(_updateDetailsContinue);
    dobController.removeListener(_updateDetailsContinue);
    emailController.removeListener(_updateDetailsContinue);
    phoneController.removeListener(_updateDetailsContinue);
    photoUrlController.removeListener(_updateDetailsContinue);
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    emailController.dispose();
    phoneController.dispose();
    photoUrlController.dispose();
    _currentStep.close();
    _canContinueDetails.close();
    _isUploadingProfilePhoto.close();
    _profilePhotoUrl.close();
    _faceKycCaptured.close();
    _diditLoading.close();
    _diditStatus.close();
    _diditSessionId.close();
    _diditWorkflowId.close();
    _diditStartedAt.close();
    _diditCompletedAt.close();
    _selectedLocation.close();
    _isRentalBusinessOwner.close();
    _isUploadingBusinessDocument.close();
    _taxInvoiceAcknowledged.close();
    _dtiPath.close();
    _birPath.close();
    _mayorBusinessPermitPath.close();
    super.onClose();
  }

  void _setInitialValues() {
    final user = _user;
    firstNameController.text = user?.firstName ?? '';
    lastNameController.text = user?.lastName ?? '';
    dobController.text =
        user?.dateOfBirth == null
            ? ''
            : DateFormat('MMMM dd, yyyy').format(user!.dateOfBirth!);
    emailController.text = user?.email ?? '';
    phoneController.text = _localPhoneFromSavedPhone(user?.phone);
    photoUrlController.text = user?.photoUrl ?? '';
    _profilePhotoUrl.value = photoUrlController.text.trim();
    _selectedLocation.value = user?.location;
  }

  void _bindDetailsContinueState() {
    firstNameController.addListener(_updateDetailsContinue);
    lastNameController.addListener(_updateDetailsContinue);
    dobController.addListener(_updateDetailsContinue);
    emailController.addListener(_updateDetailsContinue);
    phoneController.addListener(_updateDetailsContinue);
    photoUrlController.addListener(_updateDetailsContinue);
  }

  void _updateDetailsContinue() {
    _profilePhotoUrl.value = photoUrlController.text.trim();
    _canContinueDetails.value =
        firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        validateDateOfBirth(dobController.text) == null &&
        validateEmail(emailController.text) == null &&
        phoneController.text.trim().isNotEmpty &&
        hasProfilePhoto &&
        !_isUploadingProfilePhoto.value;
  }

  Future<void> pickProfilePhoto() async {
    if (_isUploadingProfilePhoto.value) return;

    if (kDebugMode) {
      photoUrlController.text =
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330'
          '?auto=format&fit=crop&w=512&q=80';
      _updateDetailsContinue();
      return;
    }

    final uid = AuthController.instance.uid;
    if (uid == null) {
      LNDSnackbar.showError('Please sign in again.');
      return;
    }

    final hasAccess = await LNDCamerAlbumHelper.checkGalleryPermission();
    if (!hasAccess) return;

    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) return;

    try {
      _isUploadingProfilePhoto.value = true;
      _updateDetailsContinue();
      final downloadUrl = await LNDFirebaseStorageHelper.uploadFile(
        file: File(photo.path),
        folder: '$uid/profile/photos',
        onProgress: (_, __) {},
      );
      photoUrlController.text = downloadUrl;
    } catch (e, stackTrace) {
      LNDLogger.e(
        'Error uploading profile photo',
        error: e,
        stackTrace: stackTrace,
      );
      LNDSnackbar.showWarning('Unable to upload profile photo.');
    } finally {
      _isUploadingProfilePhoto.value = false;
      _updateDetailsContinue();
    }
  }

  Future<void> onTapDob() async {
    final pickedDate = await LNDShow.datePicker(
      initialDate: _dateOfBirthValue ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      dobController.text = DateFormat('MMMM dd, yyyy').format(pickedDate);
      _updateDetailsContinue();
    }
  }

  DateTime? get _dateOfBirthValue {
    if (dobController.text.trim().isEmpty) return null;
    return dobController.text.trim().toFormattedDateTime();
  }

  void nextFromDetails() {
    if (!hasProfilePhoto) {
      LNDSnackbar.showError('Upload a profile photo to continue.');
      return;
    }
    if (!(detailsFormKey.currentState?.validate() ?? false)) return;
    _goToStep(1);
  }

  void nextFromBusinessOwner() {
    if (!_isRentalBusinessOwner.value) {
      _goToStep(2);
      return;
    }
    if (hasApprovedBusinessRegistration) {
      _goToStep(2);
      return;
    }
    if (!hasDti) {
      LNDSnackbar.showError('Upload your DTI registration.');
      return;
    }
    if (!hasBir) {
      LNDSnackbar.showError('Upload your BIR registration.');
      return;
    }
    if (!_taxInvoiceAcknowledged.value) {
      LNDSnackbar.showError('Acknowledge tax and invoice compliance.');
      return;
    }
    _goToStep(2);
  }

  void setLocationFromPicker(LocationCallbackModel? callback) {
    if (callback == null) {
      LNDSnackbar.showError('Select a location to continue.');
      return;
    }

    _selectedLocation.value = callback.location;
    _goToStep(3);
  }

  Future<void> startDiditVerification() async {
    // if (!(detailsFormKey.currentState?.validate() ?? false)) {
    //   _goToStep(0);
    //   return;
    // }
    if (_selectedLocation.value == null) {
      LNDSnackbar.showError('Select a location to continue.');
      _goToStep(2);
      return;
    }
    final uid = AuthController.instance.uid;
    if (uid == null) {
      LNDSnackbar.showError('Please sign in again.');
      return;
    }

    final workflowId = dotenv.env['DIDIT_WORKFLOW_ID']?.trim() ?? '';
    if (kDebugMode) {
      final now = DateTime.now();
      final debugUid = uid.length <= 8 ? uid : uid.substring(0, 8);
      _diditWorkflowId.value =
          workflowId.isEmpty ? 'debug-didit-workflow' : workflowId;
      _diditSessionId.value =
          'debug-didit-$debugUid-${now.millisecondsSinceEpoch}';
      _diditStatus.value = 'Approved';
      _diditStartedAt.value = now;
      _diditCompletedAt.value = now;
      _faceKycCaptured.value = true;
      LNDSnackbar.showSuccess('Debug Didit verification bypassed.');
      _goToStep(4);
      return;
    }

    if (workflowId.isEmpty) {
      LNDSnackbar.showError('Didit workflow ID is not configured.');
      return;
    }

    final diditReachable = await _canResolveDiditHost();
    if (!diditReachable) {
      LNDSnackbar.showError(
        'Unable to reach Didit. Check your internet connection, DNS, VPN, or private DNS settings.',
      );
      return;
    }

    try {
      _diditLoading.value = true;
      _diditWorkflowId.value = workflowId;
      _diditStatus.value = 'Not Started';
      _diditStartedAt.value = DateTime.now();

      final verificationResult = await DiditSdk.startVerificationWithWorkflow(
        workflowId,
        vendorData: uid,
        config: const DiditConfig(loggingEnabled: true),
      );

      switch (verificationResult) {
        case VerificationCompleted(:final session):
          _diditSessionId.value = session.sessionId;
          _diditStatus.value = _formatDiditStatus(session.status);
          _diditCompletedAt.value = DateTime.now();
          _faceKycCaptured.value = true;
          LNDSnackbar.showSuccess('Didit verification completed.');
          _goToStep(4);
        case VerificationCancelled(:final session):
          if (session != null) {
            _diditSessionId.value = session.sessionId;
            _diditStatus.value = _formatDiditStatus(session.status);
          }
          LNDSnackbar.showInfo('Didit verification was cancelled.');
        case VerificationFailed(:final error, :final session):
          if (session != null) {
            _diditSessionId.value = session.sessionId;
            _diditStatus.value = _formatDiditStatus(session.status);
          }
          LNDSnackbar.showError(error.message);
      }
    } catch (e, stackTrace) {
      LNDLogger.e(
        'Error starting Didit verification',
        error: e,
        stackTrace: stackTrace,
      );
      LNDSnackbar.showError('Unable to start Didit verification right now.');
    } finally {
      _diditLoading.value = false;
    }
  }

  Future<void> openDiditTerms() => _launchExternalUrl(_diditTermsUrl);

  Future<void> openDiditPrivacyNotice() => _launchExternalUrl(_diditPrivacyUrl);

  Future<void> _launchExternalUrl(Uri url) async {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched) {
      LNDSnackbar.showError('Unable to open the link right now.');
    }
  }

  Future<bool> _canResolveDiditHost() async {
    try {
      final addresses = await InternetAddress.lookup('verification.didit.me');
      return addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  void nextFromFaceKyc() {
    if (!_faceKycCaptured.value) {
      LNDSnackbar.showError('Complete Didit ID and face verification first.');
      return;
    }
    _goToStep(4);
  }

  String _formatDiditStatus(VerificationStatus status) {
    return switch (status) {
      VerificationStatus.approved => 'Approved',
      VerificationStatus.pending => 'Pending',
      VerificationStatus.declined => 'Declined',
    };
  }

  void previousStep() {
    if (_currentStep.value == 0) {
      Get.back();
      return;
    }
    _goToStep(_currentStep.value - 1);
  }

  void setRentalBusinessOwner(bool value) {
    _isRentalBusinessOwner.value = value;
  }

  void setTaxInvoiceAcknowledged(bool value) {
    _taxInvoiceAcknowledged.value = value;
  }

  String businessDocumentPath(BusinessRegistrationDocumentType type) {
    switch (type) {
      case BusinessRegistrationDocumentType.dti:
        return _dtiPath.value;
      case BusinessRegistrationDocumentType.bir:
        return _birPath.value;
      case BusinessRegistrationDocumentType.mayorBusinessPermit:
        return _mayorBusinessPermitPath.value;
    }
  }

  Future<void> pickBusinessDocumentFromSource(
    BusinessRegistrationDocumentType type,
    BusinessRegistrationDocumentSource source,
  ) async {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) {
      LNDSnackbar.showError('Please sign in again.');
      return;
    }

    final file = await _pickBusinessDocumentFile(type, source: source);
    if (file == null) return;

    try {
      _isUploadingBusinessDocument.value = true;
      final path = await LNDFirebaseStorageHelper.uploadFile(
        file: file,
        folder: 'users/$uid/businessRegistration',
        fileName: _buildBusinessDocumentFileName(type, file.path),
        returnStoragePath: true,
        onProgress: (_, __) {},
      );
      _setBusinessDocumentPath(type, path);
    } catch (e, stackTrace) {
      LNDLogger.e(
        'Error uploading verification business document',
        error: e,
        stackTrace: stackTrace,
      );
      LNDSnackbar.showError('Unable to upload document right now.');
    } finally {
      _isUploadingBusinessDocument.value = false;
    }
  }

  void _goToStep(int step) {
    _currentStep.value = step;
    pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> submit() async {
    if (!hasProfilePhoto) {
      LNDSnackbar.showError('Upload a profile photo to continue.');
      _goToStep(0);
      return;
    }
    if (_selectedLocation.value == null) {
      LNDSnackbar.showError('Select a location to continue.');
      _goToStep(2);
      return;
    }
    if (!_faceKycCaptured.value) {
      LNDSnackbar.showError('Complete Didit ID and face verification first.');
      _goToStep(3);
      return;
    }
    if (_isRentalBusinessOwner.value &&
        !hasApprovedBusinessRegistration &&
        !canContinueBusinessOwner) {
      _goToStep(1);
      if (!hasDti) {
        LNDSnackbar.showError('Upload your DTI registration.');
      } else if (!hasBir) {
        LNDSnackbar.showError('Upload your BIR registration.');
      } else if (!_taxInvoiceAcknowledged.value) {
        LNDSnackbar.showError('Acknowledge tax and invoice compliance.');
      }
      return;
    }
    if (ProfileController.instance.user?.fullVerification?.status ==
        'Pending') {
      LNDSnackbar.showError('Your verification request is still pending.');
      return;
    }

    final uid = AuthController.instance.uid;
    if (uid == null) {
      LNDSnackbar.showError('Please sign in again.');
      return;
    }

    try {
      LNDLoading.show();
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection(LNDCollections.users.name).doc(uid);
      final submissionRef =
          firestore
              .collection(LNDCollections.verificationSubmissions.name)
              .doc();
      final submission = FullVerificationSubmission.pending(
        id: submissionRef.id,
        userId: uid,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dateOfBirth: dobController.text.trim().toFormattedDateTime(),
        email: emailController.text.trim(),
        phone: formattedPhoneNumber,
        location: _selectedLocation.value!,
        photoUrl:
            photoUrlController.text.trim().isEmpty
                ? null
                : photoUrlController.text.trim(),
        diditSessionId:
            _diditSessionId.value.trim().isEmpty
                ? null
                : _diditSessionId.value.trim(),
        diditWorkflowId:
            _diditWorkflowId.value.trim().isEmpty
                ? null
                : _diditWorkflowId.value.trim(),
        diditStatus:
            _diditStatus.value.trim().isEmpty
                ? 'Submitted'
                : _diditStatus.value.trim(),
        diditStartedAt: _diditStartedAt.value,
        diditCompletedAt: _diditCompletedAt.value,
        requestType: 'upgrade_verification',
        isRentalBusinessOwner: _isRentalBusinessOwner.value,
      );

      final submittedAt = FieldValue.serverTimestamp();
      final submissionMap = submission.toMap()..['submittedAt'] = submittedAt;

      final batch = firestore.batch();
      batch.set(submissionRef, submissionMap);
      final userUpdate = {
        'fullVerification': {
          'status': 'Pending',
          'activeSubmissionId': submissionRef.id,
          'submittedAt': submittedAt,
          'reviewedAt': null,
        },
        'userMetadataVersion': FieldValue.increment(1),
      };
      if (_isRentalBusinessOwner.value && !hasApprovedBusinessRegistration) {
        final businessSubmission = BusinessRegistrationSubmission(
          ownerId: uid,
          documents: BusinessRegistrationDocuments(
            dti: _dtiPath.value.trim(),
            bir: _birPath.value.trim(),
            mayorBusinessPermit:
                _mayorBusinessPermitPath.value.trim().isEmpty
                    ? null
                    : _mayorBusinessPermitPath.value.trim(),
          ),
          taxInvoiceAcknowledged: _taxInvoiceAcknowledged.value,
          verificationSubmissionId: submissionRef.id,
          submittedAt: submittedAt,
          updatedAt: submittedAt,
        );
        batch.set(
          firestore
              .collection(LNDCollections.businessRegistrationSubmissions.name)
              .doc(uid),
          businessSubmission.toMap(),
        );

        final existingBusinessRegistration = _user?.businessRegistration;
        final businessStatus = existingBusinessRegistration?.status;
        if (businessStatus != 'Approved') {
          userUpdate['businessRegistration'] = {
            'visible': true,
            'required': existingBusinessRegistration?.required == true,
            'status': 'Submitted',
            'visibilityReasons': _businessRegistrationVisibilityReasons(),
            'requestedListingReviewSubmissionId':
                existingBusinessRegistration
                    ?.requestedListingReviewSubmissionId,
            'requestedAt': existingBusinessRegistration?.requestedAt,
            'submittedAt': submittedAt,
            'updatedAt': submittedAt,
          };
        }
      }
      batch.update(userRef, userUpdate);
      await batch.commit();
      LNDLoading.hide();
      LNDSnackbar.showSuccess('Full verification request submitted.');
      LNDNavigate.toRootPage();
      Get.back();
    } catch (e, stackTrace) {
      LNDLogger.e(
        'Error submitting full verification',
        error: e,
        stackTrace: stackTrace,
      );
      LNDLoading.hide();
      LNDSnackbar.showError('Unable to submit verification right now.');
    }
  }

  String? validateSelectedPhoneNumber(String? value) {
    final formatted = LNDCountryData.e164PhoneNumber(
      localNumber: value?.trim() ?? '',
      country: CountryPreferenceController.instance.iddCountry.value,
    );
    if (formatted.isEmpty) return 'Phone number is required';
    if (!GetUtils.isPhoneNumber(formatted)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Future<void> openPhoneCountryPicker() async {
    await CountryPreferenceController.instance.openIddPicker();
  }

  String _localPhoneFromSavedPhone(String? phone) {
    final value = phone?.trim() ?? '';
    if (value.isEmpty) return '';

    final country = CountryPreferenceController.instance.iddCountry.value;
    final prefix = country.phoneCode.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith(prefix)) {
      return digits.substring(prefix.length);
    }
    return value;
  }

  List<String> _businessRegistrationVisibilityReasons() {
    final reasons =
        _user?.businessRegistration?.visibilityReasons
            .where((reason) => reason.trim().isNotEmpty)
            .toList() ??
        <String>[];
    if (!reasons.contains('owner_self_declared')) {
      reasons.add('owner_self_declared');
    }
    return reasons;
  }

  void _setBusinessDocumentPath(
    BusinessRegistrationDocumentType type,
    String path,
  ) {
    switch (type) {
      case BusinessRegistrationDocumentType.dti:
        _dtiPath.value = path;
      case BusinessRegistrationDocumentType.bir:
        _birPath.value = path;
      case BusinessRegistrationDocumentType.mayorBusinessPermit:
        _mayorBusinessPermitPath.value = path;
    }
  }

  Future<File?> _pickBusinessDocumentFile(
    BusinessRegistrationDocumentType type, {
    required BusinessRegistrationDocumentSource source,
  }) async {
    switch (source) {
      case BusinessRegistrationDocumentSource.camera:
        return _pickBusinessDocumentFromCamera();
      case BusinessRegistrationDocumentSource.gallery:
        return _pickBusinessDocumentFromGallery();
      case BusinessRegistrationDocumentSource.files:
        return _pickBusinessDocumentFromFiles(type);
    }
  }

  Future<File?> _pickBusinessDocumentFromCamera() async {
    final hasAccess = await LNDCamerAlbumHelper.checkCameraPermission();
    if (!hasAccess) return null;

    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;

    return File(image.path);
  }

  Future<File?> _pickBusinessDocumentFromGallery() async {
    final hasAccess = await LNDCamerAlbumHelper.checkGalleryPermission();
    if (!hasAccess) return null;

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;

    return File(image.path);
  }

  Future<File?> _pickBusinessDocumentFromFiles(
    BusinessRegistrationDocumentType type,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'heif'],
      allowMultiple: false,
    );
    final filePath = result?.files.first.path;
    if (filePath == null || filePath.trim().isEmpty) return null;

    return File(filePath);
  }

  String _buildBusinessDocumentFileName(
    BusinessRegistrationDocumentType type,
    String filePath,
  ) {
    final extension = _fileExtension(filePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return extension == null
        ? '${type.fileKey}_$timestamp'
        : '${type.fileKey}_$timestamp.$extension';
  }

  String? _fileExtension(String filePath) {
    final fileName = filePath.split('/').last.trim();
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) return null;

    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}

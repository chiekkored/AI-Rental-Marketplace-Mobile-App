import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lend/core/models/business_registration_submission.model.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/business_registration_document.enum.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/firebase_storage.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class BusinessRegistrationController extends GetxController {
  static BusinessRegistrationController get instance =>
      Get.find<BusinessRegistrationController>();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool taxInvoiceAcknowledged = false.obs;
  final RxString dtiPath = ''.obs;
  final RxString birPath = ''.obs;
  final RxString mayorBusinessPermitPath = ''.obs;
  final RxString _cachedApprovedBusinessName = ''.obs;
  final RxString _cachedApprovedBusinessType = ''.obs;
  final RxString _cachedApprovedBusinessAddress = ''.obs;
  final Rxn<BusinessRegistrationSubmission> _submission =
      Rxn<BusinessRegistrationSubmission>();
  final RxBool _isUpdatingDisplayPreference = false.obs;
  StreamSubscription? _submissionSubscription;

  bool get hasDti => dtiPath.value.trim().isNotEmpty;
  bool get hasBir => birPath.value.trim().isNotEmpty;
  bool get hasMayorBusinessPermit =>
      mayorBusinessPermitPath.value.trim().isNotEmpty;
  bool get canSubmit =>
      hasDti && hasBir && taxInvoiceAcknowledged.value && !isSubmitting.value;
  String get status =>
      ProfileController.instance.user?.businessRegistration?.status ??
      'Not Submitted';
  bool get isRequired =>
      ProfileController.instance.user?.businessRegistration?.required == true;
  bool get isSubmitted => status == 'Submitted';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
  bool get isUpdatingDisplayPreference => _isUpdatingDisplayPreference.value;
  String get rejectionReason {
    final reason = _submission.value?.rejectionReason?.trim();
    return reason == null || reason.isEmpty
        ? 'Your business registration could not be approved. Please review your documents and submit again.'
        : reason;
  }

  String? get approvedBusinessName => _firstNonEmptyString([
    ProfileController.instance.user?.businessRegistration?.businessName,
    _cachedApprovedBusinessName.value,
  ]);
  String? get approvedBusinessType => _firstNonEmptyString([
    ProfileController.instance.user?.businessRegistration?.businessType,
    _cachedApprovedBusinessType.value,
  ]);
  String? get approvedBusinessAddress => _firstNonEmptyString([
    ProfileController.instance.user?.businessRegistration?.businessAddress,
    _cachedApprovedBusinessAddress.value,
  ]);
  String? get requestedListingReviewSubmissionId =>
      ProfileController
          .instance
          .user
          ?.businessRegistration
          ?.requestedListingReviewSubmissionId;
  bool get canToggleBusinessNamePreference =>
      isApproved && (approvedBusinessName?.trim().isNotEmpty ?? false);
  bool get useBusinessNameForListingOwnerName =>
      ProfileController.instance.user?.useBusinessNameForListingOwnerName ==
      true;

  @override
  void onInit() {
    super.onInit();
    initializeBusinessRegistration();
  }

  @override
  void onClose() {
    _cancelSubmissionSubscription();
    isLoading.close();
    isSubmitting.close();
    taxInvoiceAcknowledged.close();
    dtiPath.close();
    birPath.close();
    mayorBusinessPermitPath.close();
    _cachedApprovedBusinessName.close();
    _cachedApprovedBusinessType.close();
    _cachedApprovedBusinessAddress.close();
    _submission.close();
    _isUpdatingDisplayPreference.close();
    super.onClose();
  }

  void initializeBusinessRegistration() {
    _resetLocalState();
    if (_restoreApprovedBusinessCache()) {
      isLoading.value = false;
      return;
    }

    if (_cacheApprovedBusinessSummaryFromProfile()) {
      isLoading.value = false;
      return;
    }

    listenToSubmission();
  }

  void listenToSubmission() {
    final uid = AuthController.instance.uid;
    _cancelSubmissionSubscription();
    if (uid == null || uid.isEmpty) return;

    isLoading.value = true;
    LNDLogger.dNoStack('Business Registration Subscription Started');
    _submissionSubscription = FirebaseFirestore.instance
        .collection(LNDCollections.businessRegistrationSubmissions.name)
        .doc(uid)
        .snapshots()
        .listen(
          (snapshot) {
            final data = snapshot.data();
            if (data != null) {
              final submission = BusinessRegistrationSubmission.fromMap(data);
              _submission.value = submission;
              if (_cacheApprovedBusinessSummaryFromSubmission(submission)) {
                _cancelSubmissionSubscription();
                isLoading.value = false;
                return;
              }
              dtiPath.value = submission.documents.dti;
              birPath.value = submission.documents.bir;
              mayorBusinessPermitPath.value =
                  submission.documents.mayorBusinessPermit ?? '';
              taxInvoiceAcknowledged.value = submission.taxInvoiceAcknowledged;
            } else {
              _submission.value = null;
            }
            isLoading.value = false;
          },
          onError: (e, st) {
            isLoading.value = false;
            LNDLogger.e(
              'Error listening to business registration',
              error: e,
              stackTrace: st,
            );
            LNDSnackbar.showError(
              'Unable to load business registration documents.',
            );
          },
        );
  }

  void setTaxInvoiceAcknowledged(bool value) {
    taxInvoiceAcknowledged.value = value;
  }

  Future<void> pickDocument(BusinessRegistrationDocumentType type) async {
    return pickDocumentFromSource(
      type,
      BusinessRegistrationDocumentSource.gallery,
    );
  }

  Future<void> pickDocumentFromSource(
    BusinessRegistrationDocumentType type,
    BusinessRegistrationDocumentSource source,
  ) async {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) {
      LNDSnackbar.showError('Please sign in again.');
      return;
    }

    final file = await _pickDocumentFile(type, source: source);
    if (file == null) return;

    try {
      isSubmitting.value = true;
      final path = await LNDFirebaseStorageHelper.uploadFile(
        file: file,
        folder: 'users/$uid/businessRegistration',
        fileName: _buildUploadFileName(type, file.path),
        returnStoragePath: true,
        onProgress: (_, __) {},
      );
      _setDocumentPath(type, path);
    } catch (e, st) {
      LNDLogger.e(
        'Error uploading business registration document',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to upload document right now.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submit() async {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) {
      LNDSnackbar.showError('Please sign in again.');
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
    if (!taxInvoiceAcknowledged.value) {
      LNDSnackbar.showError('Acknowledge tax and invoice compliance.');
      return;
    }
    if (isApproved) {
      LNDSnackbar.showInfo('Your business registration is already approved.');
      return;
    }

    try {
      isSubmitting.value = true;
      final firestore = FirebaseFirestore.instance;
      final now = FieldValue.serverTimestamp();
      final submission = BusinessRegistrationSubmission(
        ownerId: uid,
        documents: BusinessRegistrationDocuments(
          dti: dtiPath.value.trim(),
          bir: birPath.value.trim(),
          mayorBusinessPermit:
              mayorBusinessPermitPath.value.trim().isEmpty
                  ? null
                  : mayorBusinessPermitPath.value.trim(),
        ),
        taxInvoiceAcknowledged: taxInvoiceAcknowledged.value,
        requestedListingReviewSubmissionId: requestedListingReviewSubmissionId,
        submittedAt: now,
        updatedAt: now,
      );

      final batch = firestore.batch();
      batch.set(
        firestore
            .collection(LNDCollections.businessRegistrationSubmissions.name)
            .doc(uid),
        submission.toMap(),
      );
      batch.set(
        firestore.collection(LNDCollections.users.name).doc(uid),
        {
          'businessRegistration': {
            'visible': true,
            'required': isRequired,
            'status': 'Submitted',
            'visibilityReasons': _visibilityReasonsForSubmit(),
            'requestedListingReviewSubmissionId':
                requestedListingReviewSubmissionId,
            'requestedAt':
                ProfileController
                    .instance
                    .user
                    ?.businessRegistration
                    ?.requestedAt,
            'submittedAt': now,
            'updatedAt': now,
          },
          'userMetadataVersion': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
      await batch.commit();
      LNDSnackbar.showSuccess('Business registration submitted.');
      Get.back();
    } catch (e, st) {
      LNDLogger.e(
        'Error submitting business registration',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to submit documents right now.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> setUseBusinessNameForListingOwnerName(bool value) async {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) {
      LNDSnackbar.showError('Please sign in again.');
      return;
    }
    if (!canToggleBusinessNamePreference ||
        _isUpdatingDisplayPreference.value ||
        useBusinessNameForListingOwnerName == value) {
      return;
    }

    try {
      _isUpdatingDisplayPreference.value = true;
      await FirebaseFirestore.instance
          .collection(LNDCollections.users.name)
          .doc(uid)
          .update({'useBusinessNameForListingOwnerName': value});
    } catch (e, st) {
      LNDLogger.e(
        'Error updating business name listing preference',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to update display preference right now.');
    } finally {
      _isUpdatingDisplayPreference.value = false;
    }
  }

  String documentPath(BusinessRegistrationDocumentType type) {
    switch (type) {
      case BusinessRegistrationDocumentType.dti:
        return dtiPath.value;
      case BusinessRegistrationDocumentType.bir:
        return birPath.value;
      case BusinessRegistrationDocumentType.mayorBusinessPermit:
        return mayorBusinessPermitPath.value;
    }
  }

  void _setDocumentPath(BusinessRegistrationDocumentType type, String path) {
    switch (type) {
      case BusinessRegistrationDocumentType.dti:
        dtiPath.value = path;
      case BusinessRegistrationDocumentType.bir:
        birPath.value = path;
      case BusinessRegistrationDocumentType.mayorBusinessPermit:
        mayorBusinessPermitPath.value = path;
    }
  }

  List<String> _visibilityReasonsForSubmit() {
    final existing =
        ProfileController.instance.user?.businessRegistration?.visibilityReasons
            .where((reason) => reason.trim().isNotEmpty)
            .toList() ??
        <String>[];
    if (!existing.contains('owner_self_declared') && !isRequired) {
      existing.add('owner_self_declared');
    }
    return existing;
  }

  void _cancelSubmissionSubscription() {
    if (_submissionSubscription != null) {
      LNDLogger.dNoStack('Business Registration Subscription Cancelled');
    }
    _submissionSubscription?.cancel();
    _submissionSubscription = null;
  }

  bool _restoreApprovedBusinessCache() {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) {
      return false;
    }

    final raw = LNDStorageService.read<Map<dynamic, dynamic>>(
      LNDStorageConstants.approvedBusinessRegistrationCacheKey(uid),
    );
    if (raw == null) {
      return false;
    }

    final data = Map<String, dynamic>.from(raw);
    final businessName = _cleanText(data['businessName']);
    final businessType = _cleanText(data['businessType']);
    final businessAddress = _cleanText(data['businessAddress']);
    if (businessName == null ||
        businessType == null ||
        businessAddress == null) {
      return false;
    }

    _cachedApprovedBusinessName.value = businessName;
    _cachedApprovedBusinessType.value = businessType;
    _cachedApprovedBusinessAddress.value = businessAddress;
    dtiPath.value = _cleanText(data['dtiPath']) ?? '';
    birPath.value = _cleanText(data['birPath']) ?? '';
    mayorBusinessPermitPath.value =
        _cleanText(data['mayorBusinessPermitPath']) ?? '';
    taxInvoiceAcknowledged.value = data['taxInvoiceAcknowledged'] == true;
    LNDLogger.dNoStack('Business Registration approved cache restored');
    return true;
  }

  bool _cacheApprovedBusinessSummaryFromProfile() {
    final summary = ProfileController.instance.user?.businessRegistration;
    if (summary?.isApproved != true) return false;

    final businessName = _cleanText(summary?.businessName);
    final businessType = _cleanText(summary?.businessType);
    final businessAddress = _cleanText(summary?.businessAddress);
    if (businessName == null ||
        businessType == null ||
        businessAddress == null) {
      return false;
    }

    _cachedApprovedBusinessName.value = businessName;
    _cachedApprovedBusinessType.value = businessType;
    _cachedApprovedBusinessAddress.value = businessAddress;
    return _persistApprovedBusinessCache(
      businessAddress: businessAddress,
      businessName: businessName,
      businessType: businessType,
      taxInvoiceAcknowledged: taxInvoiceAcknowledged.value,
    );
  }

  bool _cacheApprovedBusinessSummaryFromSubmission(
    BusinessRegistrationSubmission submission,
  ) {
    if (submission.status != 'Approved') {
      return false;
    }

    final businessName = _cleanText(submission.businessName);
    final businessType = _cleanText(submission.businessType);
    final businessAddress = _cleanText(submission.businessAddress);
    if (businessName == null ||
        businessType == null ||
        businessAddress == null) {
      return false;
    }

    _cachedApprovedBusinessName.value = businessName;
    _cachedApprovedBusinessType.value = businessType;
    _cachedApprovedBusinessAddress.value = businessAddress;
    dtiPath.value = submission.documents.dti;
    birPath.value = submission.documents.bir;
    mayorBusinessPermitPath.value =
        submission.documents.mayorBusinessPermit ?? '';
    taxInvoiceAcknowledged.value = submission.taxInvoiceAcknowledged;

    return _persistApprovedBusinessCache(
      businessAddress: businessAddress,
      businessName: businessName,
      businessType: businessType,
      dtiPath: submission.documents.dti,
      birPath: submission.documents.bir,
      mayorBusinessPermitPath: submission.documents.mayorBusinessPermit,
      taxInvoiceAcknowledged: submission.taxInvoiceAcknowledged,
    );
  }

  bool _persistApprovedBusinessCache({
    required String businessAddress,
    required String businessName,
    required String businessType,
    String? dtiPath,
    String? birPath,
    String? mayorBusinessPermitPath,
    required bool taxInvoiceAcknowledged,
  }) {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) return false;

    unawaited(
      LNDStorageService.write(
        LNDStorageConstants.approvedBusinessRegistrationCacheKey(uid),
        {
          'status': 'Approved',
          'businessName': businessName,
          'businessType': businessType,
          'businessAddress': businessAddress,
          'dtiPath': dtiPath,
          'birPath': birPath,
          'mayorBusinessPermitPath': mayorBusinessPermitPath,
          'taxInvoiceAcknowledged': taxInvoiceAcknowledged,
        },
      ),
    );
    LNDLogger.dNoStack('Business Registration approved cache persisted');
    return true;
  }

  void _resetLocalState() {
    dtiPath.value = '';
    birPath.value = '';
    mayorBusinessPermitPath.value = '';
    taxInvoiceAcknowledged.value = false;
    _cachedApprovedBusinessName.value = '';
    _cachedApprovedBusinessType.value = '';
    _cachedApprovedBusinessAddress.value = '';
    _submission.value = null;
  }

  String? _firstNonEmptyString(List<String?> values) {
    for (final value in values) {
      final cleaned = _cleanText(value);
      if (cleaned != null) return cleaned;
    }
    return null;
  }

  String? _cleanText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  Future<File?> _pickDocumentFile(
    BusinessRegistrationDocumentType type, {
    BusinessRegistrationDocumentSource source =
        BusinessRegistrationDocumentSource.gallery,
  }) async {
    switch (source) {
      case BusinessRegistrationDocumentSource.camera:
        return _pickFromCamera();
      case BusinessRegistrationDocumentSource.gallery:
        return _pickFromGallery();
      case BusinessRegistrationDocumentSource.files:
        return _pickFromFiles(type);
    }
  }

  Future<File?> _pickFromCamera() async {
    final hasAccess = await LNDCamerAlbumHelper.checkCameraPermission();
    if (!hasAccess) return null;

    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;

    return File(image.path);
  }

  Future<File?> _pickFromGallery() async {
    final hasAccess = await LNDCamerAlbumHelper.checkGalleryPermission();
    if (!hasAccess) return null;

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;

    return File(image.path);
  }

  Future<File?> _pickFromFiles(BusinessRegistrationDocumentType type) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'heif'],
      allowMultiple: false,
    );
    final filePath = result?.files.first.path;
    if (filePath == null || filePath.trim().isEmpty) return null;

    return File(filePath);
  }

  String _buildUploadFileName(
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

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/mixins/textfields.mixin.dart';
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
import 'package:lend/presentation/pages/account_information/widgets/account_information_edit_sheet.widget.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/extensions/datetime.extension.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/country_data.helper.dart';
import 'package:lend/utilities/helpers/firebase_storage.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

enum AccountInformationField {
  photo,
  fullName,
  email,
  phone,
  dateOfBirth,
  location,
}

enum AccountPhotoSource { camera, gallery }

class AccountInformationController extends GetxController with TextFieldsMixin {
  static AccountInformationController get instance =>
      Get.find<AccountInformationController>();

  final fullNameFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();
  final phoneFormKey = GlobalKey<FormState>();
  final dobFormKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();

  final RxString _photoUrl = ''.obs;
  String get photoUrl => _photoUrl.value;

  final Rxn<Location> _location = Rxn<Location>();
  Location? get location => _location.value;

  final RxBool _isUploadingPhoto = false.obs;
  bool get isUploadingPhoto => _isUploadingPhoto.value;

  String get fullName => LNDUtils.formatFullName(
    firstName: ProfileController.instance.user?.firstName,
    lastName: ProfileController.instance.user?.lastName,
  );

  String get phoneHint =>
      CountryPreferenceController.instance.iddCountry.value.phoneHint;
  String get phonePrefixText =>
      CountryPreferenceController.instance.iddCountry.value.iddButtonText;
  String get formattedPhoneNumber => LNDCountryData.e164PhoneNumber(
    localNumber: phoneController.text.trim(),
    country: CountryPreferenceController.instance.iddCountry.value,
  );

  LocationCallbackModel get initialLocationCallback {
    final selected =
        _location.value ?? ProfileController.instance.user?.location;
    return LocationCallbackModel(
      location: selected ?? Location(),
      useSpecificLocation: selected?.useSpecificLocation ?? true,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _setInitialValues();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    _photoUrl.close();
    _location.close();
    _isUploadingPhoto.close();
    super.onClose();
  }

  void _setInitialValues() {
    final user = ProfileController.instance.user;
    firstNameController.text = user?.firstName ?? '';
    lastNameController.text = user?.lastName ?? '';
    emailController.text = user?.email ?? '';
    phoneController.text = _localPhoneFromSavedPhone(user?.phone);
    dobController.text =
        user?.dateOfBirth == null ? '' : user!.dateOfBirth.toMonthDayYear();
    _photoUrl.value = user?.photoUrl ?? '';
    _location.value = user?.location;
  }

  void openEditSheet(AccountInformationField field) {
    switch (field) {
      case AccountInformationField.photo:
        openPhotoSourceSheet();
      case AccountInformationField.fullName:
        LNDShow.bottomSheet(AccountInformationEditSheet.fullName());
      case AccountInformationField.email:
        LNDShow.bottomSheet(AccountInformationEditSheet.email());
      case AccountInformationField.phone:
        LNDShow.bottomSheet(AccountInformationEditSheet.phone());
      case AccountInformationField.dateOfBirth:
        LNDShow.bottomSheet(AccountInformationEditSheet.dateOfBirth());
      case AccountInformationField.location:
        LNDShow.bottomSheet(AccountInformationEditSheet.location());
    }
  }

  Future<void> openPhotoSourceSheet() async {
    final result = await LNDShow.menuBottomSheetVertical<AccountPhotoSource>(
      items: [
        LNDMenuItem<AccountPhotoSource>(
          label: 'Camera',
          value: AccountPhotoSource.camera,
          icon: Icons.camera_alt_rounded,
          onTap: (value) => value,
        ),
        LNDMenuItem<AccountPhotoSource>(
          label: Platform.isIOS ? 'Photos' : 'Gallery',
          value: AccountPhotoSource.gallery,
          icon: Icons.photo_library_outlined,
          onTap: (value) => value,
        ),
      ],
    );
    if (result == null) return;
    await pickPhoto(result);
  }

  Future<void> pickPhoto(AccountPhotoSource source) async {
    if (_isUploadingPhoto.value) return;

    if (kDebugMode) {
      _photoUrl.value = 'https://picsum.photos/id/237/250/250';
      await LNDShow.bottomSheet(AccountInformationEditSheet.photo());
      return;
    }

    final uid = AuthController.instance.uid;
    if (uid == null) {
      LNDSnackbar.showError('Please sign in again.');
      return;
    }

    final hasAccess =
        source == AccountPhotoSource.camera
            ? await LNDCamerAlbumHelper.checkCameraPermission()
            : await LNDCamerAlbumHelper.checkGalleryPermission();
    if (!hasAccess) return;

    final photo = await ImagePicker().pickImage(
      source:
          source == AccountPhotoSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) return;

    try {
      _isUploadingPhoto.value = true;
      final downloadUrl = await LNDFirebaseStorageHelper.uploadFile(
        file: File(photo.path),
        folder: '$uid/profile/photos',
        onProgress: (_, __) {},
      );
      _photoUrl.value = downloadUrl;
      _isUploadingPhoto.value = false;
      await LNDShow.bottomSheet(AccountInformationEditSheet.photo());
    } catch (e, st) {
      LNDLogger.e('Error uploading account photo', error: e, stackTrace: st);
      LNDSnackbar.showWarning('Unable to upload profile photo.');
    }
  }

  Future<void> openPhoneCountryPicker() async {
    await CountryPreferenceController.instance.openIddPicker();
  }

  Future<void> pickDateOfBirth() async {
    final pickedDate = await LNDShow.datePicker(
      initialDate: _dateOfBirthValue ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      dobController.text = DateFormat('MMMM dd, yyyy').format(pickedDate);
    }
  }

  Future<void> pickLocation() async {
    final result = await LNDNavigate.toPickLocationPage(
      args: initialLocationCallback,
    );
    if (result == null) return;
    _location.value = result.location;
  }

  Future<void> submit(AccountInformationField field) async {
    if (field == AccountInformationField.email) {
      LNDSnackbar.showInfo(
        'Email is linked to your sign in account and cannot be updated.',
      );
      return;
    }

    final canSubmit = switch (field) {
      AccountInformationField.photo => _photoUrl.value.trim().isNotEmpty,
      AccountInformationField.fullName =>
        fullNameFormKey.currentState?.validate() ?? false,
      AccountInformationField.email =>
        emailFormKey.currentState?.validate() ?? false,
      AccountInformationField.phone =>
        phoneFormKey.currentState?.validate() ?? false,
      AccountInformationField.dateOfBirth =>
        dobFormKey.currentState?.validate() ?? false,
      AccountInformationField.location => _location.value != null,
    };
    if (!canSubmit) {
      LNDSnackbar.showError('Complete the required field before submitting.');
      return;
    }

    await submitAccountUpdate(updatedFields: [_fieldKey(field)]);
  }

  Future<void> submitAccountUpdate({
    required List<String> updatedFields,
  }) async {
    final user = ProfileController.instance.user;
    final uid = AuthController.instance.uid;
    final selectedLocation = _location.value ?? user?.location;
    if (uid == null || user == null || selectedLocation == null) {
      LNDSnackbar.showError('Please complete your account information.');
      return;
    }

    try {
      LNDLoading.show();

      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection(LNDCollections.users.name).doc(uid);
      final submissionRef = await _pendingSubmissionRef(firestore, uid, user);
      final submission = FullVerificationSubmission.pending(
        id: submissionRef.id,
        userId: uid,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dateOfBirth: dobController.text.trim().toFormattedDateTime(),
        email: emailController.text.trim(),
        phone: formattedPhoneNumber,
        location: selectedLocation,
        photoUrl:
            _photoUrl.value.trim().isEmpty ? null : _photoUrl.value.trim(),
        diditStatus: 'Submitted',
        requestType: 'account_information_update',
        updatedFields: updatedFields,
      );

      final submittedAt = FieldValue.serverTimestamp();
      final submissionMap =
          submission.toMap()
            ..['submittedAt'] = submittedAt
            ..['requestType'] = 'account_information_update'
            ..['updatedFields'] = FieldValue.arrayUnion(updatedFields);

      final batch = firestore.batch();
      batch.set(submissionRef, submissionMap, SetOptions(merge: true));
      batch.update(userRef, {
        'verified': VerificationLevel.basic.label,
        'fullVerification': {
          'status': 'Pending',
          'activeSubmissionId': submissionRef.id,
          'submittedAt': submittedAt,
          'reviewedAt': null,
        },
        'userMetadataVersion': FieldValue.increment(1),
      });
      await _hideAvailableListings(
        firestore: firestore,
        batch: batch,
        uid: uid,
        submissionId: submissionRef.id,
      );
      await batch.commit();

      if (Get.isRegistered<YourListingController>()) {
        await YourListingController.instance.refreshMyAssets();
      }
      LNDLoading.hide();
      Get.back();
      LNDSnackbar.showSuccess('Account update submitted for verification.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error submitting account update', error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to submit verification right now.');
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> _pendingSubmissionRef(
    FirebaseFirestore firestore,
    String uid,
    UserModel user,
  ) async {
    final activeId = user.fullVerification?.activeSubmissionId?.trim();
    if (activeId != null && activeId.isNotEmpty) {
      final ref = firestore
          .collection(LNDCollections.verificationSubmissions.name)
          .doc(activeId);
      final snap = await ref.get();
      if (snap.exists && snap.data()?['status'] == 'Pending') return ref;
    }

    final pending =
        await firestore
            .collection(LNDCollections.verificationSubmissions.name)
            .where('userId', isEqualTo: uid)
            .where('status', isEqualTo: 'Pending')
            .limit(1)
            .get();
    if (pending.docs.isNotEmpty) return pending.docs.first.reference;

    return firestore
        .collection(LNDCollections.verificationSubmissions.name)
        .doc();
  }

  Future<void> _hideAvailableListings({
    required FirebaseFirestore firestore,
    required WriteBatch batch,
    required String uid,
    required String submissionId,
  }) async {
    final userAssets =
        await firestore
            .collection(LNDCollections.users.name)
            .doc(uid)
            .collection(LNDCollections.assets.name)
            .where('status', isEqualTo: Availability.available.label)
            .get();

    for (final doc in userAssets.docs) {
      final update = {
        'status': Availability.hidden.label,
        'verificationHoldPreviousStatus': Availability.available.label,
        'verificationHoldSubmissionId': submissionId,
        'verificationHoldStartedAt': FieldValue.serverTimestamp(),
      };
      batch.update(doc.reference, update);
      batch.update(
        firestore.collection(LNDCollections.assets.name).doc(doc.id),
        update,
      );
    }
  }

  DateTime? get _dateOfBirthValue {
    if (dobController.text.trim().isEmpty) return null;
    return dobController.text.trim().toFormattedDateTime();
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

  String _localPhoneFromSavedPhone(String? phone) {
    final value = phone?.trim() ?? '';
    if (value.isEmpty) return '';

    final country = CountryPreferenceController.instance.iddCountry.value;
    final prefix = country.phoneCode.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith(prefix)) return digits.substring(prefix.length);
    return value;
  }

  String _fieldKey(AccountInformationField field) {
    return switch (field) {
      AccountInformationField.photo => 'photoUrl',
      AccountInformationField.fullName => 'fullName',
      AccountInformationField.email => 'email',
      AccountInformationField.phone => 'phone',
      AccountInformationField.dateOfBirth => 'dateOfBirth',
      AccountInformationField.location => 'location',
    };
  }
}

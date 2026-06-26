import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/file.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/firebase_storage.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class DamageFeeRequestPageArgs {
  final Booking booking;

  const DamageFeeRequestPageArgs({required this.booking});
}

enum DamageFeeReason {
  damage('Damage'),
  missingItem('Missing item'),
  lateReturn('Late return'),
  totalLossDamage('Total loss/damage'),
  higherThanSecurityDeposit('Higher than security deposit'),
  other('Other');

  final String label;
  const DamageFeeReason(this.label);

  bool get requiresSupportReview =>
      this == DamageFeeReason.totalLossDamage ||
      this == DamageFeeReason.higherThanSecurityDeposit;
}

enum DamageFeePhotoSource { camera, gallery }

class DamageFeeRequestController extends GetxController with AuthMixin {
  static const int maxEvidencePhotos = 6;

  final DamageFeeRequestPageArgs args =
      Get.arguments as DamageFeeRequestPageArgs;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final Rx<DamageFeeReason> reason = DamageFeeReason.damage.obs;
  final RxList<Rx<FileModel>> evidencePhotos = <Rx<FileModel>>[].obs;
  final RxBool isUploadingPhotos = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString amountError = RxnString();
  final RxnString notesError = RxnString();

  Booking get booking => args.booking;
  int get depositAmount =>
      (booking.depositFlow?.amount ??
              (booking.securityDeposit.enabled
                  ? booking.securityDeposit.amount
                  : 0))
          .round();
  bool get hasSecurityDeposit => depositAmount > 0;
  bool get isSupportReviewReason => reason.value.requiresSupportReview;
  bool get canAddEvidence => evidencePhotos.length < maxEvidencePhotos;
  bool get hasUploadingEvidence =>
      evidencePhotos.any((photo) => (photo.value.progress ?? 1) < 1);

  bool get canSubmit {
    if (isSubmitting.value || isUploadingPhotos.value || hasUploadingEvidence) {
      return false;
    }
    if (isSupportReviewReason) {
      return notesController.text.trim().isNotEmpty;
    }
    return _validateAmount(showError: false);
  }

  @override
  void onInit() {
    super.onInit();
    amountController.text =
        depositAmount > 0 ? _formatAmount(depositAmount) : '';
    amountController.addListener(_refreshValidation);
    notesController.addListener(_refreshValidation);
    reason.value =
        depositAmount == 0
            ? DamageFeeReason.totalLossDamage
            : DamageFeeReason.damage;
    reason.listen((_) => _refreshValidation());
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    for (final photo in evidencePhotos) {
      photo.close();
    }
    evidencePhotos.close();
    reason.close();
    isUploadingPhotos.close();
    isSubmitting.close();
    amountError.close();
    notesError.close();
    super.onClose();
  }

  void selectReason(DamageFeeReason value) {
    reason.value = value;
    if (value.requiresSupportReview) {
      amountError.value = null;
    } else if (amountController.text.trim().isEmpty && depositAmount > 0) {
      amountController.text = _formatAmount(depositAmount);
    }
  }

  Future<void> pickEvidencePhotos(DamageFeePhotoSource source) async {
    final remaining = maxEvidencePhotos - evidencePhotos.length;
    if (remaining <= 0) return;

    final photos = switch (source) {
      DamageFeePhotoSource.camera => await _pickPhotoFromCamera(),
      DamageFeePhotoSource.gallery => await _pickPhotosFromGallery(remaining),
    };
    if (photos.isEmpty) return;

    final acceptedPhotos = photos.take(remaining).toList();
    final newPhotos =
        acceptedPhotos
            .map((photo) => Rx(FileModel(file: photo, progress: 0)))
            .toList();
    evidencePhotos.addAll(newPhotos);
    await _uploadPhotos(newPhotos);
  }

  void removeEvidencePhoto(int index) {
    if (index < 0 || index >= evidencePhotos.length) return;
    evidencePhotos.removeAt(index).close();
    _refreshValidation();
  }

  Future<void> submit() async {
    if (!_validateForm()) return;

    try {
      isSubmitting.value = true;
      LNDLoading.show();
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.requestDepositDeduction,
      );
      await callable.call({
        'bookingId': booking.id,
        'requestedAmount': isSupportReviewReason ? null : _parsedAmount,
        'reason': reason.value.label,
        'notes': notesController.text.trim(),
        'evidenceUrls':
            evidencePhotos
                .map((photo) => photo.value.storagePath)
                .whereType<String>()
                .where((url) => url.isNotEmpty)
                .toList(),
      });
      await NowController.instance.refreshNow();
      LNDLoading.hide();
      LNDSnackbar.showSuccess('Damage fee request submitted.');
      Get.back(result: true);
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(
        'Unable to submit damage fee request',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to submit damage fee request.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<List<XFile>> _pickPhotoFromCamera() async {
    final hasAccess = await LNDCamerAlbumHelper.checkCameraPermission();
    if (!hasAccess) return [];

    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return photo == null ? [] : [photo];
  }

  Future<List<XFile>> _pickPhotosFromGallery(int remaining) async {
    final hasAccess = await LNDCamerAlbumHelper.checkGalleryPermission();
    if (!hasAccess) return [];

    return ImagePicker().pickMultiImage(limit: remaining, imageQuality: 80);
  }

  Future<void> _uploadPhotos(List<Rx<FileModel>> photos) async {
    try {
      isUploadingPhotos.value = true;
      await Future.wait(
        photos.map((photo) async {
          final file = photo.value.file;
          if (file == null) return;

          final downloadUrl = await LNDFirebaseStorageHelper.uploadFile(
            file: File(file.path),
            folder: '$currentUid/chats/${booking.chatId ?? booking.id}',
            onProgress: (_, progress) {
              photo.value.progress = progress;
              photo.refresh();
            },
          );
          photo.value.storagePath = downloadUrl;
          photo.value.progress = 1;
          photo.refresh();
        }),
      );
    } catch (e, st) {
      LNDLogger.e('Damage evidence upload failed', error: e, stackTrace: st);
      LNDSnackbar.showWarning('Something went wrong while uploading photos.');
    } finally {
      isUploadingPhotos.value = false;
      _refreshValidation();
    }
  }

  bool _validateForm() {
    final amountValid = isSupportReviewReason || _validateAmount();
    final notesValid = _validateNotes();
    return amountValid && notesValid && !hasUploadingEvidence;
  }

  bool _validateAmount({bool showError = true}) {
    final amount = _parsedAmount;
    String? error;

    if (amount == null || amount <= 0) {
      error = 'Enter a valid amount.';
    } else if (amount > depositAmount) {
      error = 'Amount cannot be greater than the security deposit.';
    }

    if (showError) amountError.value = error;
    return error == null;
  }

  bool _validateNotes() {
    final requiresNotes = isSupportReviewReason;
    final text = notesController.text.trim();
    final error =
        requiresNotes && text.isEmpty
            ? 'Add details for Lend Support review.'
            : null;
    notesError.value = error;
    return error == null;
  }

  void _refreshValidation() {
    if (!isSupportReviewReason) _validateAmount();
    _validateNotes();
    isSubmitting.refresh();
  }

  int? get _parsedAmount {
    final normalized = amountController.text.replaceAll(',', '').trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

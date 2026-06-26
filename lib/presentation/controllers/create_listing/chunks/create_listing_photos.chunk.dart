import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/file.model.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/firebase_storage.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class CreateListingPhotosChunk implements CreateListingChunk {
  CreateListingPhotosChunk({
    required this.isSaving,
    required this.currentUid,
    required this.draftId,
    required this.nextFileName,
    this.maxBannerPhotos = 6,
    this.maxShowcasePhotos = 12,
  });

  final RxBool isSaving;
  final String? Function() currentUid;
  final String Function() draftId;
  final String Function() nextFileName;
  final int maxBannerPhotos;
  final int maxShowcasePhotos;

  final formKey = GlobalKey<FormState>();

  final RxBool showPrimaryPhotoError = false.obs;
  final RxBool isUploadingPhotos = false.obs;
  final RxBool canContinue = false.obs;

  final Rxn<Rx<FileModel>> primaryPhoto = Rxn<Rx<FileModel>>();
  final RxList<Rx<FileModel>> additionalPhotos = <Rx<FileModel>>[].obs;
  final RxList<Rx<FileModel>> showcasePhotos = <Rx<FileModel>>[].obs;

  final List<Worker> _workers = [];

  @override
  void onInit() {
    _workers.addAll([
      ever<Rx<FileModel>?>(primaryPhoto, (_) => _updateCanContinue()),
      ever<bool>(isUploadingPhotos, (_) => _updateCanContinue()),
      ever<bool>(isSaving, (_) => _updateCanContinue()),
    ]);

    _updateCanContinue();
  }

  int get bannerPhotoCount =>
      (primaryPhoto.value == null ? 0 : 1) + additionalPhotos.length;

  bool get hasPrimaryPhoto => primaryPhoto.value != null;

  bool get allPhotosUploaded {
    final photos = [
      if (primaryPhoto.value != null) primaryPhoto.value!,
      ...additionalPhotos,
      ...showcasePhotos,
    ];

    return photos.every(
      (photo) => photo.value.storagePath?.isNotEmpty ?? false,
    );
  }

  List<String> get uploadedImages {
    final paths = <String>[];
    final primaryPath = primaryPhoto.value?.value.storagePath;
    if (primaryPath != null && primaryPath.isNotEmpty) paths.add(primaryPath);

    paths.addAll(
      additionalPhotos
          .map((photo) => photo.value.storagePath ?? '')
          .where((path) => path.isNotEmpty),
    );

    return paths;
  }

  List<String> get uploadedShowcaseImages {
    return showcasePhotos
        .map((photo) => photo.value.storagePath ?? '')
        .where((path) => path.isNotEmpty)
        .toList();
  }

  void populateFromAsset(Asset asset) {
    final images = asset.images ?? [];
    restorePhotos(bannerImages: images, showcaseImages: asset.showcase ?? []);
    _updateCanContinue();
  }

  void loadFromDraft(Map<String, dynamic> draft) {
    restorePhotos(
      bannerImages: List<String>.from(draft['images'] ?? []),
      showcaseImages: List<String>.from(draft['showcase'] ?? []),
    );
    _updateCanContinue();
  }

  Map<String, dynamic> toDraftMap() {
    return {'images': uploadedImages, 'showcase': uploadedShowcaseImages};
  }

  void restorePhotos({
    required List<String> bannerImages,
    required List<String> showcaseImages,
  }) {
    primaryPhoto.value?.close();
    primaryPhoto.value = null;

    for (final photo in additionalPhotos) {
      photo.close();
    }
    additionalPhotos.clear();

    for (final photo in showcasePhotos) {
      photo.close();
    }
    showcasePhotos.clear();

    if (bannerImages.isNotEmpty) {
      primaryPhoto.value = Rx(
        FileModel(storagePath: bannerImages.first, progress: 1),
      );

      additionalPhotos.assignAll(
        bannerImages
            .skip(1)
            .map((image) => Rx(FileModel(storagePath: image, progress: 1))),
      );
    }

    showcasePhotos.assignAll(
      showcaseImages.map(
        (image) => Rx(FileModel(storagePath: image, progress: 1)),
      ),
    );
  }

  Future<void> pickPrimaryPhoto() async {
    await pickBannerPhotos(CreateListingPhotoSource.gallery);
  }

  Future<void> pickBannerPhotos(CreateListingPhotoSource source) async {
    final remaining = maxBannerPhotos - bannerPhotoCount;
    if (remaining <= 0) return;

    final photos = switch (source) {
      CreateListingPhotoSource.camera => await _pickPhotoFromCamera(),
      CreateListingPhotoSource.gallery => await _pickPhotosFromGallery(
        remaining,
      ),
    };

    if (photos.isEmpty) return;

    final acceptedPhotos = _takeRemainingBannerPhotos(photos);
    if (acceptedPhotos.isEmpty) return;

    await _addBannerPhotos(acceptedPhotos);
  }

  Future<void> pickShowcasePhotos() async {
    await pickShowcasePhotosFromSource(CreateListingPhotoSource.gallery);
  }

  Future<void> pickShowcasePhotosFromSource(
    CreateListingPhotoSource source,
  ) async {
    final remaining = maxShowcasePhotos - showcasePhotos.length;
    if (remaining <= 0) return;

    final photos = switch (source) {
      CreateListingPhotoSource.camera => await _pickPhotoFromCamera(),
      CreateListingPhotoSource.gallery => await _pickPhotosFromGallery(
        remaining,
      ),
    };

    if (photos.isEmpty) return;

    final acceptedPhotos = photos.take(remaining).toList();
    if (acceptedPhotos.isEmpty) return;

    final newPhotos =
        acceptedPhotos
            .map((photo) => Rx(FileModel(file: photo, progress: 0)))
            .toList();

    showcasePhotos.addAll(newPhotos);
    await _uploadPhotos(newPhotos);
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

  Future<void> _addBannerPhotos(List<XFile> acceptedPhotos) async {
    final newPhotos =
        acceptedPhotos
            .map((photo) => Rx(FileModel(file: photo, progress: 0)))
            .toList();

    final uploadQueue = <Rx<FileModel>>[];

    if (primaryPhoto.value == null) {
      primaryPhoto.value = newPhotos.first;
      uploadQueue.add(newPhotos.first);
      additionalPhotos.addAll(newPhotos.skip(1));
      uploadQueue.addAll(newPhotos.skip(1));
    } else {
      additionalPhotos.addAll(newPhotos);
      uploadQueue.addAll(newPhotos);
    }

    showPrimaryPhotoError.value = false;
    _updateCanContinue();
    await _uploadPhotos(uploadQueue);
  }

  List<XFile> _takeRemainingBannerPhotos(List<XFile> photos) {
    final remaining = maxBannerPhotos - bannerPhotoCount;
    if (remaining <= 0) return [];
    return photos.take(remaining).toList();
  }

  Future<void> _uploadPhotos(List<Rx<FileModel>> photos) async {
    try {
      isUploadingPhotos.value = true;

      await Future.wait(
        photos.map((photo) async {
          final file = photo.value.file;
          if (file == null) return;

          final storagePath = await LNDFirebaseStorageHelper.uploadFile(
            file: File(file.path),
            folder:
                'users/${currentUid() ?? 'guest'}/listingDrafts/${draftId()}/images',
            fileName: nextFileName(),
            returnStoragePath: true,
            onProgress: (_, progress) {
              photo.value.progress = progress;
              photo.refresh();
            },
          );

          photo.value.storagePath = storagePath;
          photo.value.progress = 1;
          photo.refresh();
        }),
      );
    } catch (e, st) {
      LNDLogger.e('UPLOAD ERROR: $e', error: e, stackTrace: st);
      LNDSnackbar.showWarning('Something went wrong while uploading photos.');
    } finally {
      isUploadingPhotos.value = false;
      _updateCanContinue();
    }
  }

  void removePrimaryPhoto() {
    primaryPhoto.value?.close();

    if (additionalPhotos.isEmpty) {
      primaryPhoto.value = null;
      _updateCanContinue();
      return;
    }

    primaryPhoto.value = additionalPhotos.removeAt(0);
    _updateCanContinue();
  }

  void removeAdditionalPhoto(int index) {
    additionalPhotos.removeAt(index).close();
    _updateCanContinue();
  }

  void removeShowcasePhoto(int index) {
    showcasePhotos.removeAt(index).close();
    _updateCanContinue();
  }

  void _updateCanContinue() {
    canContinue.value =
        primaryPhoto.value != null &&
        !isUploadingPhotos.value &&
        !isSaving.value &&
        allPhotosUploaded;
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }

    showPrimaryPhotoError.close();
    isUploadingPhotos.close();
    canContinue.close();

    primaryPhoto.value?.close();
    primaryPhoto.close();

    for (final photo in additionalPhotos) {
      photo.close();
    }
    additionalPhotos.close();

    for (final photo in showcasePhotos) {
      photo.close();
    }
    showcasePhotos.close();
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lend/core/models/file.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_photo_grid.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/firebase_storage.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

enum ListingDeactivationReason {
  verifiedDamage('Verified damage'),
  forceMajeure('Force majeure'),
  totalLoss('Total loss'),
  other('Other');

  final String label;
  const ListingDeactivationReason(this.label);
}

enum ListingDeactivationPhotoSource { camera, gallery }

class ListingDeactivationRequestSheet extends StatefulWidget {
  const ListingDeactivationRequestSheet({
    required this.assetId,
    required this.ownerId,
    super.key,
  });

  final String assetId;
  final String ownerId;

  @override
  State<ListingDeactivationRequestSheet> createState() =>
      _ListingDeactivationRequestSheetState();
}

class _ListingDeactivationRequestSheetState
    extends State<ListingDeactivationRequestSheet> {
  static const int maxEvidencePhotos = 6;

  final TextEditingController _notesController = TextEditingController();
  final List<Rx<FileModel>> _evidencePhotos = [];
  final String _requestId =
      LNDAssetService.createListingDeactivationRequestId();
  ListingDeactivationReason _reason = ListingDeactivationReason.verifiedDamage;
  bool _isUploading = false;
  bool _isSubmitting = false;
  String? _notesError;
  String? _photosError;

  bool get _canSubmit =>
      !_isUploading &&
      !_isSubmitting &&
      _notesController.text.trim().isNotEmpty &&
      _uploadedEvidenceUrls.isNotEmpty;

  List<String> get _uploadedEvidenceUrls =>
      _evidencePhotos
          .map((photo) => photo.value.storagePath)
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();

  @override
  void dispose() {
    _notesController.dispose();
    for (final photo in _evidencePhotos) {
      photo.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          shrinkWrap: true,
          children: [
            LNDText.bold(text: 'Request deactivation review', fontSize: 18),
            const SizedBox(height: 8),
            LNDText.regular(
              text:
                  'Submit details and evidence photos for Lend Support review. If approved, upcoming bookings will be cancelled and renters will receive full refund handling.',
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 20),
            LNDText.semibold(text: 'Reason', fontSize: 14),
            const SizedBox(height: 8),
            RadioGroup<ListingDeactivationReason>(
              groupValue: _reason,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _reason = value);
              },
              child: Column(
                children:
                    ListingDeactivationReason.values
                        .map(
                          (reason) => RadioListTile<ListingDeactivationReason>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: LNDText.regular(text: reason.label),
                            value: reason,
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 16),
            LNDTextField.textBox(
              controller: _notesController,
              labelText: 'Details for Lend Support',
              hintText:
                  'Describe what happened and why the unit cannot be fixed',
              errorText: _notesError,
              required: true,
              maxLines: 4,
              onChanged: (_) => _validate(showErrors: false),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: LNDText.semibold(text: 'Evidence photos')),
                LNDText.regular(
                  text: '${_evidencePhotos.length} / $maxEvidencePhotos',
                  fontSize: 12,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LNDText.regular(
              text: 'Required. Add at least 1 photo.',
              fontSize: 12,
              overflow: TextOverflow.visible,
            ),
            if (_photosError != null) ...[
              const SizedBox(height: 6),
              LNDText.regular(
                text: _photosError!,
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
                overflow: TextOverflow.visible,
              ),
            ],
            const SizedBox(height: 12),
            CreateListingPhotoGrid(
              photos: _evidencePhotos,
              maxCount: maxEvidencePhotos,
              onAdd: _openEvidenceSourceMenu,
              onRemove: _removeEvidencePhoto,
              showAddTile: _evidencePhotos.length < maxEvidencePhotos,
            ),
            const SizedBox(height: 24),
            LNDButton.primary(
              text: _isUploading ? 'Uploading photos' : 'Submit review request',
              enabled: _canSubmit,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _openEvidenceSourceMenu() {
    LNDShow.menuBottomSheetVertical<ListingDeactivationPhotoSource>(
      items: [
        LNDMenuItem(
          label: 'Take photo',
          value: ListingDeactivationPhotoSource.camera,
          icon: Icons.camera_alt_outlined,
          onTap: _pickEvidencePhotos,
        ),
        LNDMenuItem(
          label: 'Choose from gallery',
          value: ListingDeactivationPhotoSource.gallery,
          icon: Icons.photo_library_outlined,
          onTap: _pickEvidencePhotos,
        ),
      ],
    );
  }

  Future<void> _pickEvidencePhotos(
    ListingDeactivationPhotoSource source,
  ) async {
    final remaining = maxEvidencePhotos - _evidencePhotos.length;
    if (remaining <= 0) return;

    final photos = switch (source) {
      ListingDeactivationPhotoSource.camera => await _pickPhotoFromCamera(),
      ListingDeactivationPhotoSource.gallery => await _pickPhotosFromGallery(
        remaining,
      ),
    };
    if (photos.isEmpty) return;

    final newPhotos =
        photos
            .take(remaining)
            .map((photo) => Rx(FileModel(file: photo, progress: 0)))
            .toList();
    setState(() {
      _evidencePhotos.addAll(newPhotos);
      _photosError = null;
    });
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

  Future<void> _uploadPhotos(List<Rx<FileModel>> photos) async {
    try {
      setState(() => _isUploading = true);
      await Future.wait(
        photos.map((photo) async {
          final file = photo.value.file;
          if (file == null) return;

          final downloadUrl = await LNDFirebaseStorageHelper.uploadFile(
            file: File(file.path),
            folder:
                'users/${widget.ownerId}/listingDeactivationRequests/$_requestId/evidence',
            onProgress: (_, progress) {
              photo.value.progress = progress;
              photo.refresh();
            },
            returnStoragePath: true,
          );
          photo.value.storagePath = downloadUrl;
          photo.value.progress = 1;
          photo.refresh();
        }),
      );
    } catch (e, st) {
      LNDLogger.e(
        'Listing deactivation evidence upload failed',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showWarning('Something went wrong while uploading photos.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _removeEvidencePhoto(int index) {
    if (index < 0 || index >= _evidencePhotos.length) return;
    setState(() {
      _evidencePhotos.removeAt(index).close();
    });
    _validate(showErrors: false);
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    try {
      setState(() => _isSubmitting = true);
      await LNDAssetService.requestListingDeactivationReview(
        assetId: widget.assetId,
        evidenceUrls: _uploadedEvidenceUrls,
        notes: _notesController.text.trim(),
        reason: _reason.label,
        requestId: _requestId,
      );
      if (!mounted) return;
      LNDSnackbar.showSuccess('Deactivation review request submitted.');
      Get.back(result: true);
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool _validate({bool showErrors = true}) {
    final hasNotes = _notesController.text.trim().isNotEmpty;
    final hasPhotos = _uploadedEvidenceUrls.isNotEmpty;
    if (showErrors || _notesError != null || _photosError != null) {
      setState(() {
        _notesError = hasNotes ? null : 'Add details for Lend Support.';
        _photosError = hasPhotos ? null : 'Add at least one evidence photo.';
      });
    } else {
      setState(() {});
    }
    return hasNotes && hasPhotos && !_isUploading;
  }
}

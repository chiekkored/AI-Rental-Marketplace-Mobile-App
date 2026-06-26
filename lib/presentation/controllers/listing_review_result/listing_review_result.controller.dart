import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/listing_review_submission.model.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class ListingReviewResultPageArgs {
  final String submissionId;

  const ListingReviewResultPageArgs({required this.submissionId});
}

class ListingReviewResultController extends GetxController with AuthMixin {
  static ListingReviewResultController get instance =>
      Get.find<ListingReviewResultController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late final ListingReviewResultPageArgs args;
  final Rxn<ListingReviewSubmission> _submission =
      Rxn<ListingReviewSubmission>();
  final RxBool _isLoading = true.obs;
  final RxBool _isDeleting = false.obs;
  final RxnString _imageUrl = RxnString();

  ListingReviewSubmission? get submission => _submission.value;
  bool get isLoading => _isLoading.value;
  bool get isDeleting => _isDeleting.value;
  String? get imageUrl => _imageUrl.value;

  @override
  void onInit() {
    super.onInit();
    final rawArgs = Get.arguments;
    args =
        rawArgs is ListingReviewResultPageArgs
            ? rawArgs
            : const ListingReviewResultPageArgs(submissionId: '');
    unawaited(fetchSubmission());
  }

  @override
  void onClose() {
    _submission.close();
    _isLoading.close();
    _isDeleting.close();
    _imageUrl.close();
    super.onClose();
  }

  Future<void> fetchSubmission() async {
    if (args.submissionId.isEmpty) {
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;
      final snapshot =
          await _firestore
              .collection(LNDCollections.listingReviewSubmissions.name)
              .doc(args.submissionId)
              .get();
      if (!snapshot.exists) {
        _submission.value = null;
        return;
      }

      final nextSubmission = ListingReviewSubmission.fromDoc(snapshot);
      _submission.value = nextSubmission;
      await _resolveImage(
        nextSubmission.listing.images.isEmpty
            ? null
            : nextSubmission.listing.images.first,
      );
    } catch (e, st) {
      LNDLogger.e(
        'Unable to load listing review result',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to load listing review.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> editListing() async {
    final current = submission;
    if (current == null) return;

    await LNDNavigate.toCreateListing(
      args: CreateListingArguments(
        asset: current.toEditableAsset(
          owner: ProfileController.instance.listingOwnerSnapshot,
        ),
        isPublicAssetEdit: current.submissionType == 'update',
      ),
    );
  }

  Future<void> deleteSubmission() async {
    final current = submission;
    if (current == null || _isDeleting.value) return;

    final confirmed = await LNDShow.alertDialog(
      title: 'Delete rejected listing',
      content:
          'Delete this rejected listing draft? This will not delete any public listing.',
      confirmText: 'Delete',
    );
    if (confirmed != true) return;

    try {
      _isDeleting.value = true;
      LNDLoading.show();
      await LNDAssetService.deleteListingReviewSubmission(current.id);
      LNDLoading.hide();
      LNDSnackbar.showSuccess('Rejected listing deleted.');
      Get.back();
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(
        'Unable to delete rejected listing',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  Future<void> _resolveImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      _imageUrl.value = null;
      return;
    }
    if (Uri.tryParse(imagePath)?.hasScheme ?? false) {
      _imageUrl.value = imagePath;
      return;
    }

    try {
      _imageUrl.value = await _storage.ref(imagePath).getDownloadURL();
    } catch (e, st) {
      LNDLogger.e(
        'Unable to resolve listing review image',
        error: e,
        stackTrace: st,
      );
      _imageUrl.value = null;
    }
  }
}

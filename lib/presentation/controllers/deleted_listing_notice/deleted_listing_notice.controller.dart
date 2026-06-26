import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/listing_moderation_event.model.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class DeletedListingNoticePageArgs {
  final String eventId;

  const DeletedListingNoticePageArgs({required this.eventId});
}

class DeletedListingNoticeController extends GetxController with AuthMixin {
  static DeletedListingNoticeController get instance =>
      Get.find<DeletedListingNoticeController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late final DeletedListingNoticePageArgs args;
  final Rxn<ListingModerationEvent> _event = Rxn<ListingModerationEvent>();
  final RxBool _isLoading = true.obs;
  final RxnString _imageUrl = RxnString();

  ListingModerationEvent? get event => _event.value;
  bool get isLoading => _isLoading.value;
  String? get imageUrl => _imageUrl.value;

  @override
  void onInit() {
    super.onInit();
    final rawArgs = Get.arguments;
    args =
        rawArgs is DeletedListingNoticePageArgs
            ? rawArgs
            : const DeletedListingNoticePageArgs(eventId: '');
    unawaited(fetchEvent());
  }

  @override
  void onClose() {
    _event.close();
    _isLoading.close();
    _imageUrl.close();
    super.onClose();
  }

  Future<void> fetchEvent() async {
    final uid = currentUid;
    if (uid == null || uid.isEmpty || args.eventId.isEmpty) {
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;
      final snapshot =
          await _firestore
              .collection(LNDCollections.users.name)
              .doc(uid)
              .collection(LNDCollections.listingModerationEvents.name)
              .doc(args.eventId)
              .get();

      if (!snapshot.exists) {
        _event.value = null;
        return;
      }

      final nextEvent = ListingModerationEvent.fromDoc(snapshot);
      _event.value = nextEvent;
      await _resolveImage(
        nextEvent.listing.images?.isNotEmpty == true
            ? nextEvent.listing.images!.first
            : nextEvent.listing.showcase?.isNotEmpty == true
            ? nextEvent.listing.showcase!.first
            : null,
      );
    } catch (e, st) {
      LNDLogger.e(
        'Unable to load deleted listing notice',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to load listing notice.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> openTermsAndConditions() {
    return LNDLegalLinks.openTermsAndConditions();
  }

  Future<void> openPrivacyPolicy() {
    return LNDLegalLinks.openPrivacyPolicy();
  }

  Future<void> openHelpCenter() {
    return LNDLegalLinks.openHelpCenter();
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
        'Unable to resolve deleted listing image',
        error: e,
        stackTrace: st,
      );
      _imageUrl.value = null;
    }
  }
}

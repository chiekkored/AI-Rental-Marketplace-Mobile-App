import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/business_registration_submission.model.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class BusinessRegistrationRejectionController extends GetxController
    with AuthMixin {
  static BusinessRegistrationRejectionController get instance =>
      Get.find<BusinessRegistrationRejectionController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<BusinessRegistrationSubmission> _submission =
      Rxn<BusinessRegistrationSubmission>();
  final RxBool _isLoading = true.obs;

  BusinessRegistrationSubmission? get submission => _submission.value;
  bool get isLoading => _isLoading.value;
  bool get shouldResubmitThroughVerification =>
      !ProfileController.instance.canList;

  String get rejectionReason {
    final reason = submission?.rejectionReason?.trim();
    return reason == null || reason.isEmpty
        ? 'Your business registration could not be approved. Please review your documents and submit again.'
        : reason;
  }

  String? get reviewedDateText {
    final reviewedAt = submission?.reviewedAt;
    DateTime? date;
    if (reviewedAt is Timestamp) {
      date = reviewedAt.toDate();
    } else if (reviewedAt is DateTime) {
      date = reviewedAt;
    }
    if (date == null) return null;

    final local = date.toLocal();
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)}';
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(fetchSubmission());
  }

  @override
  void onClose() {
    _submission.close();
    _isLoading.close();
    super.onClose();
  }

  Future<void> fetchSubmission() async {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) {
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;
      final snapshot =
          await _firestore
              .collection(LNDCollections.businessRegistrationSubmissions.name)
              .doc(uid)
              .get();

      if (!snapshot.exists) {
        _submission.value = null;
        return;
      }

      _submission.value = BusinessRegistrationSubmission.fromMap({
        ...(snapshot.data() ?? <String, dynamic>{}),
        'ownerId': snapshot.id,
      });
    } catch (e, st) {
      LNDLogger.e(
        'Unable to load business registration rejection',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to load business registration details.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reviewAndResubmit() async {
    if (ProfileController.instance.canList) {
      await LNDNavigate.toBusinessRegistrationPage();
      return;
    }

    await LNDNavigate.toFullVerificationPage();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

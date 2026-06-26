import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/full_verification_submission.model.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class VerificationRejectionPageArgs {
  final String submissionId;

  const VerificationRejectionPageArgs({required this.submissionId});
}

class VerificationRejectionController extends GetxController with AuthMixin {
  static VerificationRejectionController get instance =>
      Get.find<VerificationRejectionController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final VerificationRejectionPageArgs args;
  final Rxn<FullVerificationSubmission> _submission =
      Rxn<FullVerificationSubmission>();
  final RxBool _isLoading = true.obs;

  FullVerificationSubmission? get submission => _submission.value;
  bool get isLoading => _isLoading.value;

  String get rejectionReason {
    final reason = submission?.rejectionReason?.trim();
    return reason == null || reason.isEmpty
        ? 'Your verification could not be approved. Please review your details and try again.'
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
    final rawArgs = Get.arguments;
    args =
        rawArgs is VerificationRejectionPageArgs
            ? rawArgs
            : const VerificationRejectionPageArgs(submissionId: '');
    unawaited(fetchSubmission());
  }

  @override
  void onClose() {
    _submission.close();
    _isLoading.close();
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
              .collection(LNDCollections.verificationSubmissions.name)
              .doc(args.submissionId)
              .get();

      if (!snapshot.exists) {
        _submission.value = null;
        return;
      }

      _submission.value = FullVerificationSubmission.fromMap({
        ...(snapshot.data() ?? <String, dynamic>{}),
        'id': snapshot.id,
      });
    } catch (e, st) {
      LNDLogger.e(
        'Unable to load verification rejection',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to load verification details.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> retryVerification() async {
    await LNDNavigate.toFullVerificationPage();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

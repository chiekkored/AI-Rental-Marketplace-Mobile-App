import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lend/core/mixins/auth.mixin.dart';
import 'package:lend/core/models/outstanding_damage_balance.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/core/services/outstanding_damage_balance.service.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/outstanding_damage_balances/outstanding_damage_balances.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class ProfileController extends GetxController with AuthMixin {
  static ProfileController get instance => Get.find<ProfileController>();

  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  UserModel? get user => _user.value;

  VerificationLevel get verified =>
      _user.value?.verified ?? VerificationLevel.none;
  bool get canRent => verified.canRent;
  bool get canList => verified.canList;
  bool get hasPendingFullVerification =>
      _user.value?.hasPendingFullVerification ?? false;

  // Simple user data model getter (only firstName, lastName, photoUrl, and email) using SimpleUserModel
  SimpleUserModel get simpleUser => SimpleUserModel(
    uid: _user.value?.uid,
    firstName: _user.value?.firstName,
    lastName: _user.value?.lastName,
    photoUrl: _user.value?.photoUrl,
    verified: _user.value?.verified,
    isFoundingOwner: _user.value?.isFoundingOwnerAccount,
    userMetadataVersion: _user.value?.userMetadataVersion,
  );

  SimpleUserModel get listingOwnerSnapshot {
    final currentUser = _user.value;
    final approvedBusinessName = currentUser?.approvedBusinessName;
    final shouldUseBusinessName =
        currentUser?.useBusinessNameForListingOwnerName == true &&
        approvedBusinessName != null;

    return SimpleUserModel(
      uid: currentUser?.uid,
      firstName: currentUser?.firstName,
      lastName: currentUser?.lastName,
      displayName: shouldUseBusinessName ? approvedBusinessName : null,
      photoUrl: currentUser?.photoUrl,
      verified: currentUser?.verified,
      isFoundingOwner: currentUser?.isFoundingOwnerAccount,
      userMetadataVersion: currentUser?.userMetadataVersion,
    );
  }

  final RxBool _isLoading = false.obs;
  final RxList<OutstandingDamageBalance> outstandingDamageBalances =
      <OutstandingDamageBalance>[].obs;
  StreamSubscription? _userSubscription;
  StreamSubscription<List<OutstandingDamageBalance>>?
  _outstandingBalanceSubscription;
  bool get isLoading => _isLoading.value;
  bool get hasOutstandingDamageBalance => outstandingDamageBalances.isNotEmpty;
  num get outstandingDamageBalanceTotal => outstandingDamageBalances.fold<num>(
    0,
    (total, balance) => total + balance.amount,
  );
  String get outstandingDamageBalanceCurrency =>
      outstandingDamageBalances.isEmpty
          ? LNDMoney.currentCurrencyCode()
          : outstandingDamageBalances.first.currency;

  void cancelSubscriptions() {
    if (_userSubscription != null) {
      _userSubscription?.cancel();
      LNDLogger.dNoStack('🔴 User Subscription Cancelled');
    }
    if (_outstandingBalanceSubscription != null) {
      _outstandingBalanceSubscription?.cancel();
      _outstandingBalanceSubscription = null;
      outstandingDamageBalances.clear();
    }
  }

  @override
  void onClose() {
    cancelSubscriptions();
    _user.close();
    _isLoading.close();
    outstandingDamageBalances.close();

    super.onClose();
  }

  void removeUserData() {
    _user.value = null;
    _outstandingBalanceSubscription?.cancel();
    _outstandingBalanceSubscription = null;
    outstandingDamageBalances.clear();
  }

  void listenToUserData() {
    try {
      _isLoading.value = true;
      cancelSubscriptions();

      final userDocRef = FirebaseFirestore.instance
          .collection(LNDCollections.users.name)
          .doc(AuthController.instance.uid);
      _listenToOutstandingBalances(AuthController.instance.uid);

      LNDLogger.dNoStack('🟢 User Subscription Started');
      _userSubscription = userDocRef.snapshots().listen(
        (userDoc) {
          if (userDoc.exists) {
            _user.value = UserModel.fromMap(userDoc.data()!);
            unawaited(syncEmailVerification());
            _isLoading.value = false;
          } else {
            LNDLogger.e(
              'Could not get user data',
              error: userDoc.data(),
              stackTrace: StackTrace.current,
            );
            AuthController.instance.signOut();
          }
        },
        onError: (e, st) {
          LNDLogger.e(e.toString(), error: e, stackTrace: st);
        },
      );
    } catch (e, st) {
      LNDLogger.e(
        'Error setting up user data listener',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> syncEmailVerification() async {
    try {
      final currentUser = _user.value;
      if (currentUser?.verified != VerificationLevel.none) return;

      final firebaseUser = AuthController.instance.firebaseAuth.currentUser;
      if (firebaseUser == null) return;

      await firebaseUser.reload();
      final refreshedUser = AuthController.instance.firebaseAuth.currentUser;
      if (refreshedUser?.emailVerified != true) return;

      await FirebaseFirestore.instance
          .collection(LNDCollections.users.name)
          .doc(refreshedUser!.uid)
          .update({
            'verified': VerificationLevel.basic.label,
            'userMetadataVersion': FieldValue.increment(1),
          });
    } catch (e) {
      LNDLogger.e(
        'Please log in again.',
        error: e,
        stackTrace: StackTrace.current,
      );
      LNDSnackbar.showInfo('Please log in again');
      await AuthController.instance.signOut();
    }
  }

  void goToOutstandingDamageBalances() {
    if (outstandingDamageBalances.isEmpty) return;
    LNDNavigate.toOutstandingDamageBalancesPage(
      args: OutstandingDamageBalancesPageArgs(
        balances: outstandingDamageBalances.toList(growable: false),
      ),
    );
  }

  Future<void> openBlockedUsers() async {
    await LNDNavigate.toBlockedUsersPage();
  }

  void goToNotifications() {
    if (isAuthenticated) {
      LNDNavigate.toNotificationsPage();
    } else {
      LNDNavigate.toSigninPage();
    }
  }

  void signOut() {
    LNDShow.alertDialog(
      title: 'Logout?',
      content: 'Are you sure you want to logout?',
      confirmColor: Get.context?.lndTheme.danger,
      confirmText: 'Logout',
      onConfirm: () {
        AuthController.instance.signOut();
      },
    );
  }

  void _listenToOutstandingBalances(String? uid) {
    if (uid == null || uid.isEmpty) return;
    _outstandingBalanceSubscription?.cancel();
    _outstandingBalanceSubscription =
        LNDOutstandingDamageBalanceService.watchOutstandingBalances(uid).listen(
          (balances) {
            outstandingDamageBalances.assignAll(balances);
          },
          onError: (e, st) {
            LNDLogger.e(
              'Unable to load outstanding damage balances',
              error: e,
              stackTrace: st,
            );
          },
        );
  }
}

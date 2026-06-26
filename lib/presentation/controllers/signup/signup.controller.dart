import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/mixins/textfields.mixin.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/core/services/owner_invite.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/pages/signup/components/setup.page.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/enums/email_verification_request_outcome.enum.dart';
import 'package:lend/utilities/enums/user_status.enum.dart';
import 'package:lend/utilities/enums/user_types.enum.dart';
import 'package:lend/utilities/extensions/datetime.extension.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';

class SignUpController extends GetxController with TextFieldsMixin {
  static final instance = Get.find<SignUpController>();

  TextEditingController emailController = TextEditingController();
  TextEditingController inviteCodeController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final signUpKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  final setupKey = GlobalKey<FormState>();

  final RxBool _showObscureText = false.obs;
  bool get showObscureText => _showObscureText.value;

  final RxBool _showObscureConfirmText = false.obs;
  bool get showObscureConfirmText => _showObscureConfirmText.value;

  @override
  void onInit() {
    super.onInit();
    inviteCodeController.text =
        LNDOwnerInviteService.readPendingInviteCode() ?? '';
  }

  @override
  void onClose() {
    emailController.dispose();
    inviteCodeController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();

    _showObscureText.close();
    _showObscureConfirmText.close();

    super.onClose();
  }

  bool _validateSignUpForm() => setupKey.currentState?.validate() ?? false;
  void togglePasswordVisibility() => _showObscureText.toggle();
  void toggleConfirmPasswordVisibility() => _showObscureConfirmText.toggle();

  void goToSetup() async {
    if (!(signUpKey.currentState?.validate() ?? false)) {
      return;
    }
    await Get.toNamed(SetupPage.routeName);
    _resetFields();
  }

  void _resetFields() {
    passwordController.clear();
    confirmPasswordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    dobController.clear();
  }

  void signUp() async {
    if (!_validateSignUpForm()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password != confirmPasswordController.text) {
      LNDSnackbar.showError('Password mismatch');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    try {
      LNDLoading.show();

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Add User to Firestore Collection: "users"
        final UserModel user = UserModel(
          uid: userCredential.user?.uid,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          dateOfBirth: dobController.text.trim().toFormattedDateTime(),
          location: null,
          photoUrl: userCredential.user?.photoURL,
          createdAt: null,
          email: email,
          phone: userCredential.user?.phoneNumber,
          type: UserType.user.label,
          verified: VerificationLevel.none,
          status: UserStatus.active,
        );

        await AuthController.instance.registerToFirestore(user: user);
        await _claimOwnerInviteAfterSignup();

        if (!userCredential.user!.emailVerified) {
          final outcome =
              await AuthController.instance.requestEmailVerification();
          switch (outcome) {
            case EmailVerificationRequestOutcome.autoVerified:
            case EmailVerificationRequestOutcome.alreadyVerified:
              LNDSnackbar.showSuccess('Your email has been verified.');
            case EmailVerificationRequestOutcome.emailSent:
              LNDSnackbar.showInfo(
                'Sent a verification link to email provided',
              );
            case EmailVerificationRequestOutcome.deliveryUnavailable:
              LNDSnackbar.showWarning(
                'Email verification is temporarily unavailable.',
              );
          }
        }

        LNDLoading.hide();
        // Get.offAll(() => const NavigationPage(), binding: NavigationBinding());

        Get.until((page) => page.isFirst);
      } else {
        LNDLoading.hide();
        LNDSnackbar.showError(
          'Something went wrong. Please try another provider',
        );
        AuthController.instance.signOut();
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        LNDSnackbar.showError('The password provided is too weak');
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        LNDSnackbar.showError('The account already exists for that email');
        debugPrint('The account already exists for that email.');
      } else {
        LNDSnackbar.showError('Please try again later');
      }
      LNDLoading.hide();
    }
  }

  Future<void> _claimOwnerInviteAfterSignup() async {
    final code = LNDOwnerInviteService.normalizeInviteCode(
      inviteCodeController.text.isNotEmpty
          ? inviteCodeController.text
          : LNDOwnerInviteService.readPendingInviteCode() ?? '',
    );
    if (code.isEmpty) return;

    try {
      final result = await LNDOwnerInviteService.claimInviteCode(code);
      if (result.claimed || result.alreadyClaimed) {
        await LNDOwnerInviteService.clearPendingInviteCode();
        inviteCodeController.clear();
      }
    } catch (e) {
      if (LNDOwnerInviteService.isTerminalInviteClaimError(e)) {
        await LNDOwnerInviteService.clearPendingInviteCode();
        inviteCodeController.clear();
      }
      LNDSnackbar.showWarning(
        'Your account was created, but this invite code could not be applied.',
      );
    }
  }

  void goToSignIn() => Get.back();

  Future<void> openTermsAndConditions() {
    return LNDLegalLinks.openTermsAndConditions();
  }

  Future<void> openPrivacyPolicy() {
    return LNDLegalLinks.openPrivacyPolicy();
  }

  Future<void> onTapDob() async {
    final pickedDate = await LNDShow.datePicker(
      initialDate: _dateOfBirthValue ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      dobController.text = DateFormat('MMMM dd, yyyy').format(pickedDate);
    }
  }

  DateTime? get _dateOfBirthValue {
    if (dobController.text.trim().isEmpty) return null;
    return dobController.text.trim().toFormattedDateTime();
  }
}

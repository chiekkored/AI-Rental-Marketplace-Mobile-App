import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/core/services/biometric_auth.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/core/services/secure_storage.service.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/user_status.enum.dart';
import 'package:lend/utilities/enums/user_types.enum.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/pages/reactivate_account/reactivate_account.page.dart';
import 'package:lend/presentation/pages/signup/signup.page.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class SigninController extends GetxController {
  static final instance = Get.find<SigninController>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final RxBool _showObscureText = false.obs;
  final RxBool _isLoadingBiometricState = true.obs;
  final RxBool _showEmailPasswordForm = false.obs;
  final RxBool _biometricSignInAvailable = false.obs;
  bool get showObscureText => _showObscureText.value;
  bool get isLoadingBiometricState => _isLoadingBiometricState.value;
  bool get showEmailPasswordForm => _showEmailPasswordForm.value;
  bool get biometricSignInAvailable => _biometricSignInAvailable.value;
  bool get showBiometricSignIn =>
      biometricSignInAvailable && !showEmailPasswordForm;

  @override
  void onInit() {
    super.onInit();
    unawaited(_loadBiometricState());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    _showObscureText.close();
    _isLoadingBiometricState.close();
    _showEmailPasswordForm.close();
    _biometricSignInAvailable.close();

    super.onClose();
  }

  void togglePasswordVisibility() => _showObscureText.toggle();

  void useEmailPasswordMethod() {
    _showEmailPasswordForm.value = true;
  }

  Future<void> _loadBiometricState() async {
    _isLoadingBiometricState.value = true;
    try {
      final enabled =
          LNDStorageService.read<bool>(LNDStorageConstants.enableBiometrics) ==
          true;
      final credentials =
          enabled
              ? await LNDSecureStorageService.readBiometricCredentials()
              : null;
      final supported =
          enabled && await LNDBiometricAuthService.canAuthenticate();
      _biometricSignInAvailable.value = supported && credentials != null;
      _showEmailPasswordForm.value = !_biometricSignInAvailable.value;
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      _biometricSignInAvailable.value = false;
      _showEmailPasswordForm.value = true;
    } finally {
      _isLoadingBiometricState.value = false;
    }
  }

  Future<void> signIn() async {
    await _signInWithEmailPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      saveBiometricCredentials: true,
    );
  }

  Future<void> signInWithBiometrics() async {
    if (!showBiometricSignIn) {
      _showEmailPasswordForm.value = true;
      return;
    }

    try {
      final authenticated = await LNDBiometricAuthService.authenticate(
        localizedReason: 'Please authenticate to sign in to Lend',
      );

      if (!authenticated) {
        return;
      }

      final credentials =
          await LNDSecureStorageService.readBiometricCredentials();
      if (credentials == null) {
        _biometricSignInAvailable.value = false;
        _showEmailPasswordForm.value = true;
        LNDSnackbar.showError(
          'Biometric sign in is unavailable. Use email and password.',
        );
        return;
      }

      await _signInWithEmailPassword(
        email: credentials.email,
        password: credentials.password,
        saveBiometricCredentials: true,
        fromBiometrics: true,
      );
    } on PlatformException catch (e, st) {
      _showEmailPasswordForm.value = true;
      LNDLogger.e(e.message ?? '', error: e, stackTrace: st);
      LNDSnackbar.showError(
        'Biometric sign in is unavailable. Use email and password.',
      );
    } catch (e, st) {
      _showEmailPasswordForm.value = true;
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError(
        'Biometric sign in failed. Use email and password.',
      );
    }
  }

  Future<void> _signInWithEmailPassword({
    required String email,
    required String password,
    bool saveBiometricCredentials = false,
    bool fromBiometrics = false,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    try {
      LNDLoading.show();

      final userCreds = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCreds.user != null) {
        if (saveBiometricCredentials &&
            LNDStorageService.read<bool>(
                  LNDStorageConstants.enableBiometrics,
                ) ==
                true) {
          await LNDSecureStorageService.saveBiometricCredentials(
            email: email,
            password: password,
          );
          _biometricSignInAvailable.value = true;
        }

        await _checkUserCredential(userCreds);
      }
    } on FirebaseAuthException catch (e, st) {
      LNDLoading.hide();
      if (fromBiometrics &&
          (e.code == 'user-not-found' || e.code == 'wrong-password')) {
        await LNDSecureStorageService.clearBiometricCredentials();
        _biometricSignInAvailable.value = false;
        _showEmailPasswordForm.value = true;
      }

      if (e.code == 'user-not-found') {
        LNDLogger.e(e.message ?? '', error: e, stackTrace: st);

        LNDSnackbar.showError('Invalid email and password provided');
      } else if (e.code == 'invalid-email') {
        LNDSnackbar.showError('Invalid email provided');
      } else if (e.code == 'wrong-password') {
        LNDSnackbar.showError('Wrong password provided');
      } else if (e.code == 'network-request-failed') {
        LNDSnackbar.showWarning('Please check connection and try again');
      } else {
        LNDSnackbar.showError('Please try again later');
      }
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Please try again later');
    }
  }

  /// Sign in with Google Gmail
  Future<void> signInWithGoogle() async {
    try {
      LNDLoading.show();
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        LNDLoading.hide();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      late OAuthCredential credential;
      String env = const String.fromEnvironment('ENV', defaultValue: 'prod');

      if (env == 'local') {
        credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      } else {
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }

      // Once signed in, return the UserCredential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      await _checkUserCredential(userCredential);
    } on PlatformException catch (e, st) {
      LNDLoading.hide();
      LNDSnackbar.showError(_googleSignInErrorMessage(e));
      LNDLogger.e(
        e.message ?? 'Google sign in failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  String _googleSignInErrorMessage(PlatformException exception) {
    if (!kDebugMode) {
      return 'Google sign-in failed. Please try again later.';
    }

    final message = exception.message ?? '';
    final details = exception.details?.toString() ?? '';
    final errorText = '$message $details';

    if (errorText.contains('ApiException: 10') ||
        errorText.contains('DEVELOPER_ERROR')) {
      return 'Google sign in is not configured for this app. Please, reinstall the app.';
    }

    return message.isNotEmpty
        ? message
        : 'Google sign in failed. Please try again.';
  }

  /// Sign in to Firebase authentication using Apple iCloud.
  Future<void> signInWithApple() async {
    try {
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      AuthorizationCredentialAppleID? appleCredential;
      try {
        LNDLoading.show();

        appleCredential = await SignInWithApple.getAppleIDCredential(
          webAuthenticationOptions: WebAuthenticationOptions(
            // clientId: dotenv.get('APPLE_CLIENT_ID'),
            clientId: '',
            redirectUri: Uri.parse(
              'https://spenza-recipe-app.firebaseapp.com/__/auth/handler',
            ),
          ),
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );
      } on SignInWithAppleAuthorizationException catch (e, st) {
        LNDLoading.hide();
        LNDLogger.e(e.message, error: e, stackTrace: st);
        LNDSnackbar.showError(e.message);
        return;
      }

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );

      await _checkUserCredential(userCredential);
    } on PlatformException catch (e, st) {
      LNDLogger.e(e.message ?? '', error: e, stackTrace: st);
      LNDSnackbar.showError(e.message ?? '');
      return;
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Navigate to the sign up page.
  void goToSignUp() {
    Get.toNamed(SignUpPage.routeName);
  }

  /// Check if the user is new or existing and navigate to the appropriate page.
  Future<void> _checkUserCredential(UserCredential userCredential) async {
    if (userCredential.user == null) {
      LNDSnackbar.showError(
        'Something went wrong. Please try another provider',
      );
      AuthController.instance.signOut();
      return;
    }

    if ((userCredential.additionalUserInfo?.isNewUser ?? false)) {
      // Split the string by spaces
      List<String> nameParts =
          userCredential.user?.displayName?.trim().split(' ') ?? [];
      String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      String lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final UserModel user = UserModel(
        uid: userCredential.user?.uid,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: null,
        location: null,
        photoUrl: userCredential.user?.photoURL ?? '',
        createdAt: null,
        email: userCredential.user?.email ?? '',
        phone: userCredential.user?.phoneNumber ?? '',
        type: UserType.user.label,
        verified:
            (userCredential.user?.emailVerified ?? false)
                ? VerificationLevel.basic
                : VerificationLevel.none,
        status: UserStatus.active,
      );

      await AuthController.instance.registerToFirestore(user: user);
    }
    final accountState = await _getAccountState(userCredential.user!.uid);
    if (accountState == UserStatus.deleted) {
      LNDLoading.hide();
      await AuthController.instance.signOut(clearBiometricCredentials: true);
      LNDSnackbar.showError('This account has been closed.');
      return;
    }
    if (accountState == UserStatus.deactivated) {
      LNDLoading.hide();
      Get.offAllNamed(ReactivateAccountPage.routeName);
      return;
    }
    _successSignin();
  }

  Future<UserStatus?> _getAccountState(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromMap(snap.data() ?? {}).status;
  }

  void devSignin(int num) {
    if (num == 1) {
      emailController.text = 'redzilla31@gmail.com';
      passwordController.text = 'Chiko236';
    } else {
      emailController.text = 'chiekkored@gmail.com';
      passwordController.text = 'Chiko236';
    }

    signIn();
  }

  /// Navigate to the home page after successful sign in.
  void _successSignin() {
    // AppController.instance.setBiometricsButtonVisibility(true);
    LNDLoading.hide();
    // Get.offAll(() => const NavigationPage(), binding: NavigationBinding());

    Get.until((page) => page.isFirst);
  }
}

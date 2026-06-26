import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/controllers/signin/signin.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class SigninPage extends GetView<SigninController> {
  static const routeName = '/signin';
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar:
            canPop
                ? AppBar(
                  leading: LNDButton.close(),
                  surfaceTintColor: colors.surface,
                  backgroundColor: colors.surface,
                )
                : null,
        backgroundColor: colors.surface,
        body: Obx(
          () =>
              controller.isLoadingBiometricState
                  ? Center(child: LNDSpinner(color: colors.primary))
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/lend_logo.svg',
                                    height: Get.width * 0.2,
                                    width: Get.width * 0.2,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24.0,
                                    ),
                                    child: Column(
                                      children: [
                                        LNDText.bold(
                                          text: 'Welcome to Lend!',
                                          fontSize: 32.0,
                                        ),
                                        LNDText.regular(
                                          text:
                                              'Find and rent what you need, when you need it.',
                                          color: colors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (controller.showBiometricSignIn) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: LNDButton.widget(
                                        color: Colors.transparent,
                                        onPressed:
                                            controller.signInWithBiometrics,
                                        child: SvgPicture.asset(
                                          'assets/svg/${Platform.isIOS ? 'face_id' : 'fingerprint'}.svg',
                                          height: 50.0,
                                          width: 50.0,
                                          colorFilter: ColorFilter.mode(
                                            colors.textPrimary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                    LNDButton.text(
                                      text: 'Use email/password method',
                                      enabled: true,
                                      onPressed:
                                          controller.useEmailPasswordMethod,
                                      color: colors.primary,
                                      isBold: true,
                                    ),
                                  ] else ...[
                                    LNDTextField.regular(
                                      labelText: 'Email',
                                      controller: controller.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon:
                                          FontAwesomeIcons.solidEnvelope,
                                      prefixIconColor: colors.textMuted,
                                      prefixIconSize: 16.0,
                                      textCapitalization:
                                          TextCapitalization.none,
                                    ),
                                    Obx(
                                      () => LNDTextField.regular(
                                        labelText: 'Password',
                                        controller:
                                            controller.passwordController,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        obscureText:
                                            !controller.showObscureText,
                                        prefixIcon: FontAwesomeIcons.lock,
                                        prefixIconColor: colors.textMuted,
                                        prefixIconSize: 16.0,
                                        textInputAction: TextInputAction.done,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        suffixIcon:
                                            controller.showObscureText
                                                ? FontAwesomeIcons.solidEye
                                                : FontAwesomeIcons
                                                    .solidEyeSlash,
                                        suffixIconSize: 16.0,
                                        onTapSuffix:
                                            controller.togglePasswordVisibility,
                                        onFieldSubmitted:
                                            (_) => controller.signIn(),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: LNDButton.primary(
                                        text: 'Sign in',
                                        enabled: true,
                                        onPressed: controller.signIn,
                                      ),
                                    ),
                                    if (kDebugMode) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          LNDButton.text(
                                            text: 'Dev #1 Sign in',
                                            onPressed:
                                                () => controller.devSignin(1),
                                            enabled: true,
                                            color: colors.primary,
                                          ),
                                          LNDButton.text(
                                            text: 'Dev #2 Sign in',
                                            onPressed:
                                                () => controller.devSignin(2),
                                            enabled: true,
                                            color: colors.primary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      LNDText.regular(
                                        text: 'OR',
                                        color: colors.textMuted,
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ).withSpacing(8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LNDButton.widget(
                                        color: const Color(0xFF4285F4),
                                        onPressed: controller.signInWithGoogle,
                                        child: const FaIcon(
                                          FontAwesomeIcons.google,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Visibility(
                                        visible: Platform.isIOS,
                                        child: LNDButton.widget(
                                          color: colors.textPrimary,
                                          onPressed: controller.signInWithApple,
                                          child: const FaIcon(
                                            FontAwesomeIcons.apple,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      LNDButton.widget(
                                        color: const Color(0xFF316FF6),
                                        onPressed: () {},
                                        child: const FaIcon(
                                          FontAwesomeIcons.facebookF,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ).withSpacing(36.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: controller.goToSignUp,
                                      child: LNDText.regular(
                                        text: 'Don\'t have an account?',
                                        color: colors.textMuted,
                                        textParts: [
                                          LNDText.bold(
                                            text: ' Sign up',
                                            color: colors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ).withSpacing(16.0),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}

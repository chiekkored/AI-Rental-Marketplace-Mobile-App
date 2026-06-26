import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/signin/signin.page.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class ProfileSigninView extends GetView<ProfileController> {
  const ProfileSigninView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LNDText.bold(
            text: 'Sign in to access your profile',
            fontSize: 22.0,
            overflow: TextOverflow.visible,
          ),
          LNDText.regular(
            text: 'Manage your information, preferences, and rental listings.',
            textAlign: TextAlign.center,
            color: colors.textMuted,
            overflow: TextOverflow.visible,
          ),
          LNDButton.primary(
            text: 'Sign in',
            enabled: true,
            onPressed:
                controller.isAuthenticated
                    ? null
                    : () => Get.toNamed(SigninPage.routeName),
          ),
        ],
      ).withSpacing(8.0),
    );
  }
}

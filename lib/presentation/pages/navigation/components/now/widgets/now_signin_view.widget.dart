import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/pages/signin/signin.page.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class NowSigninView extends GetView<NowController> {
  const NowSigninView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LNDText.bold(
              text: 'Sign in to view what is happening now',
              fontSize: 24.0,
              overflow: TextOverflow.visible,
            ),
            LNDText.regular(
              text:
                  'Track active handovers, returns, and upcoming confirmed bookings.',
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
        ).withSpacing(24.0),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/settings/settings.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SecurityPage extends GetView<SettingsController> {
  static const routeName = '/security';
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(
          onPressed: canPop ? () => Navigator.of(context).pop() : null,
        ),
        title: LNDText.bold(text: 'Security', fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => SwitchListTile.adaptive(
                value: controller.isBiometricEnabled.value,
                onChanged:
                    controller.hasPasswordProvider
                        ? controller.onChangedBiometrics
                        : null,
                secondary: Icon(Icons.fingerprint, color: colors.textPrimary),
                title: LNDText.regular(text: 'Enable Biometrics'),
                subtitle: LNDText.regular(
                  text: 'Use biometric authentication to unlock the app',
                  color: colors.textMuted,
                  fontSize: 12,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/about/about.controller.dart';
import 'package:lend/presentation/pages/settings/widgets/settings_item.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class AboutPage extends GetView<AboutController> {
  static const routeName = '/about';

  const AboutPage({super.key});

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
        title: LNDText.bold(text: 'About', fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: Column(
          children: [
            SettingsItemW(
              label: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: controller.openPrivacyPolicy,
            ),
            SettingsItemW(
              label: 'Terms and Conditions',
              icon: Icons.description_outlined,
              onTap: controller.openTermsAndConditions,
            ),
          ],
        ),
      ),
    );
  }
}

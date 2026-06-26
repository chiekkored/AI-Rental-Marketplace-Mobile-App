import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/settings/settings.controller.dart';
import 'package:lend/presentation/pages/settings/widgets/settings_item.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class SettingsPage extends GetView<SettingsController> {
  static const routeName = '/settings';
  const SettingsPage({super.key});

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
        title: LNDText.bold(text: 'Settings', fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: Column(
          children: [
            Obx(
              () => Column(
                children: [
                  SwitchListTile.adaptive(
                    value: controller.isUsingSystemTheme,
                    onChanged: controller.setUseSystemTheme,
                    secondary: Icon(
                      Icons.brightness_auto_outlined,
                      color: colors.textPrimary,
                    ),
                    title: LNDText.regular(text: 'Use System Dark/Light Mode'),
                    subtitle: LNDText.regular(
                      text: 'Match your device appearance',
                      color: colors.textMuted,
                      fontSize: 12,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  if (!controller.isUsingSystemTheme)
                    SwitchListTile.adaptive(
                      value: controller.isDarkMode,
                      onChanged: controller.setDarkMode,
                      secondary: Icon(
                        Icons.dark_mode_outlined,
                        color: colors.textPrimary,
                      ),
                      title: LNDText.regular(text: 'Dark mode'),
                      subtitle: LNDText.regular(
                        text: 'Use dark colors throughout the app',
                        color: colors.textMuted,
                        fontSize: 12,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                ],
              ),
            ),
            SettingsItemW(
              label: 'Notifications',
              icon: Icons.notifications_rounded,
              onTap: () => LNDNavigate.toNotificationSettingsPage(),
            ),
            SettingsItemW(
              label: 'App Preferences',
              icon: Icons.tune_rounded,
              onTap: () {
                // TODO: Navigate to App Preferences Page
              },
            ),
          ],
        ),
      ),
    );
  }
}

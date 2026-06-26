import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/settings/settings.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class DeactivateDeleteAccountPage extends GetView<SettingsController> {
  static const routeName = '/deactivate-delete-account';
  static const legacyRouteName = '/disable-delete-account';

  const DeactivateDeleteAccountPage({super.key});

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
        title: LNDText.bold(
          text: 'Deactivate or Delete Account',
          fontSize: 18.0,
        ),
      ),
      body: Container(
        color: colors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: LNDText.bold(
                    text: 'Deactivate Account',
                    fontSize: 16.0,
                  ),
                ),
                LNDText.regular(
                  text:
                      'Temporarily deactivate your account and take a break from the app. '
                      'Your listings will be hidden from discovery and search, and new bookings '
                      'will be unavailable. You can reactivate by signing in again after all pending '
                      'bookings, payments, disputes, and legal obligations are resolved.',
                  overflow: TextOverflow.visible,
                ),
                LNDButton.primary(
                  text: 'Deactivate Account',
                  enabled: true,
                  onPressed: controller.showDeactivateAccountPopup,
                ),
              ],
            ).withSpacing(8.0),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: LNDText.bold(text: 'Delete Account', fontSize: 16.0),
                ),
                LNDText.regular(
                  text:
                      'Permanently delete your account and remove your access to '
                      'the app. Any assets you own will also be removed. This action '
                      'cannot be undone, and some records may be retained when necessary '
                      'for transaction history, security, or legal purposes.',
                  overflow: TextOverflow.visible,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: LNDButton.text(
                    text: 'Delete Account',
                    enabled: true,
                    color: colors.danger,
                    onPressed: controller.showDeleteAccountPopup,
                  ),
                ),
              ],
            ).withSpacing(8.0),
          ],
        ).withSpacing(32.0),
      ),
    );
  }
}

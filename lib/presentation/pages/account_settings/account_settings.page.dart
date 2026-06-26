import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';
import 'package:lend/presentation/controllers/settings/settings.controller.dart';
import 'package:lend/presentation/pages/settings/widgets/settings_item.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class AccountSettingsPage extends GetView<SettingsController> {
  static const routeName = '/account-settings';
  const AccountSettingsPage({super.key});

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
        title: LNDText.bold(text: 'Account', fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: Column(
          children: [
            const SettingsItemW(
              label: 'Account Information',
              icon: Icons.account_circle_outlined,
              onTap: LNDNavigate.toAccountInformationPage,
            ),
            Obx(
              () => SettingsItemW(
                label: 'Currency',
                icon: Icons.payments_outlined,
                onTap: controller.openCurrencyPicker,
                subtitle:
                    CountryPreferenceController
                        .instance
                        .currencyCountry
                        .value
                        .currencyValue,
              ),
            ),
            Obx(
              () =>
                  controller.hasPasswordProvider
                      ? SettingsItemW(
                        label: 'Password',
                        icon: Icons.password_rounded,
                        onTap: controller.openNewPasswordPage,
                      )
                      : const SizedBox.shrink(),
            ),
            SettingsItemW(
              label: 'Deactivate or Delete Account',
              icon: Icons.no_accounts_outlined,
              color: context.lndTheme.danger,
              onTap: LNDNavigate.toDeactivateDeleteAccountPage,
            ),
          ],
        ),
      ),
    );
  }
}

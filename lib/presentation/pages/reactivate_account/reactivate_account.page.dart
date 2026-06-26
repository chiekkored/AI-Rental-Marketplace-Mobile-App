import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/user.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/pages/navigation/navigation.page.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ReactivateAccountPage extends StatelessWidget {
  static const routeName = '/reactivate-account';

  const ReactivateAccountPage({super.key});

  Future<void> _reactivate() async {
    final confirmed = await LNDShow.alertDialog<bool>(
      title: 'Reactivate Account',
      content:
          'Your account and eligible listings will be restored. This may take a moment.',
      cancelText: 'Cancel',
      confirmText: 'Reactivate',
    );
    if (confirmed != true) return;

    LNDLoading.show();
    final result = await UserService.reactivateAccount();
    LNDLoading.hide();

    result.fold(
      ifLeft: (value) {
        LNDSnackbar.showSuccess('Your account has been reactivated.');
        Get.offAllNamed(NavigationPage.routeName);
      },
      ifRight: LNDSnackbar.showError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Icon(
                  Icons.no_accounts_outlined,
                  color: colors.primary,
                  size: 48,
                ),
                const SizedBox(height: 20),
                LNDText.bold(text: 'Account Deactivated', fontSize: 24),
                const SizedBox(height: 12),
                LNDText.regular(
                  text:
                      'Reactivate your account to use Lend again. Your eligible listings will be restored to their previous visibility.',
                  overflow: TextOverflow.visible,
                ),
                const Spacer(),
                LNDButton.primary(
                  text: 'Reactivate Account',
                  enabled: true,
                  onPressed: _reactivate,
                ),
                const SizedBox(height: 12),
                LNDButton.text(
                  text: 'Sign out',
                  enabled: true,
                  onPressed:
                      () => AuthController.instance.signOut(
                        clearBiometricCredentials: true,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

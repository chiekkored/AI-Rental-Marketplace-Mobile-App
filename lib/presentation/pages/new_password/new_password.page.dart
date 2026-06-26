import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/new_password/new_password.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class NewPasswordPage extends GetView<NewPasswordController> {
  static const routeName = '/new-password';

  const NewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(
          onPressed: canPop ? () => Navigator.of(context).pop() : null,
        ),
        title: LNDText.bold(text: 'Password', fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: SafeArea(
          child: Form(
            key: controller.formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Obx(
                  () => Column(
                    children: [
                      if (controller.requiresOldPassword) ...[
                        LNDTextField.regular(
                          labelText: 'Current Password',
                          controller: controller.oldPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !controller.showOldPassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          prefixIconColor: colors.textMuted,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          suffixIcon:
                              controller.showOldPassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                          onTapSuffix: controller.toggleOldPasswordVisibility,
                          validator: controller.validateOldPassword,
                        ),
                        const Divider(),
                      ],
                      LNDTextField.regular(
                        labelText: 'New Password',
                        controller: controller.newPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !controller.showNewPassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        prefixIconColor: colors.textMuted,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        suffixIcon:
                            controller.showNewPassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                        onTapSuffix: controller.toggleNewPasswordVisibility,
                        validator: controller.validatePassword,
                      ),
                      LNDTextField.regular(
                        labelText: 'Confirm New Password',
                        controller: controller.confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !controller.showConfirmPassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        prefixIconColor: colors.textMuted,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.none,
                        suffixIcon:
                            controller.showConfirmPassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                        onTapSuffix: controller.toggleConfirmPasswordVisibility,
                        validator:
                            (value) => controller.validateConfirmPassword(
                              controller.newPasswordController.text,
                              value,
                            ),
                      ),
                      const _PasswordFormatChecklist(),
                    ],
                  ).withSpacing(12.0),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: kBottomNavigationBarHeight + 20.0,
        child: Obx(
          () => LNDButton.primary(
            text: 'Update Password',
            enabled: !controller.isSubmitting,
            isLoading: controller.isSubmitting,
            onPressed: controller.submit,
          ),
        ),
      ),
    );
  }
}

class _PasswordFormatChecklist extends GetView<NewPasswordController> {
  const _PasswordFormatChecklist();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PasswordRuleItem(
            label: 'At least 8 characters',
            isMet: controller.hasMinimumLength,
          ),
          _PasswordRuleItem(
            label: 'Uppercase letter',
            isMet: controller.hasUppercase,
          ),
          _PasswordRuleItem(
            label: 'Lowercase letter',
            isMet: controller.hasLowercase,
          ),
          _PasswordRuleItem(label: 'Number', isMet: controller.hasNumber),
          _PasswordRuleItem(
            label: 'Special character (@\$!%*?&)',
            isMet: controller.hasSpecialCharacter,
          ),
        ],
      ).withSpacing(4.0),
    );
  }
}

class _PasswordRuleItem extends StatelessWidget {
  final String label;
  final bool isMet;

  const _PasswordRuleItem({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final color = isMet ? colors.primary : colors.textMuted;
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 16.0, color: color),
        const SizedBox(width: 6.0),
        Expanded(
          child: LNDText.regular(
            text: label,
            color: color,
            fontSize: 12.0,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

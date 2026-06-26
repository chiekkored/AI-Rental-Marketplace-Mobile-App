import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/account_information/account_information.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/settings/widgets/settings_item.widget.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class AccountInformationPage extends GetView<AccountInformationController> {
  static const routeName = '/account-information';
  const AccountInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = ProfileController.instance;

    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;
    final isFullVerified =
        ProfileController.instance.verified == VerificationLevel.full;

    final disabledColor = isFullVerified ? colors.primary : colors.disabled;

    final phone = profileController.user?.phone ?? 'Not Set';

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(
          onPressed: canPop ? () => Navigator.of(context).pop() : null,
        ),
        title: LNDText.bold(text: 'Account Information', fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: Column(
          children: [
            SettingsItemW(
              label: 'Photo',
              subtitle: 'Profile photo',
              trailingWidget: Obx(
                () => LNDImage.circle(
                  imageUrl: controller.photoUrl,
                  size: 40.0,
                  imageType: ImageType.user,
                ),
              ),
              onTap:
                  isFullVerified
                      ? () => controller.openEditSheet(
                        AccountInformationField.photo,
                      )
                      : null,
            ),
            SettingsItemW(
              label: 'Full Name',
              subtitleWidget: LNDVerifiedName(
                name: LNDUtils.formatFullName(
                  firstName: profileController.user?.firstName,
                  lastName: profileController.user?.lastName,
                  addLastName: true,
                ),
                verificationLevel: profileController.user?.verified,
                color: colors.textSecondary,
                fontSize: 12.0,
              ),
              trailingWidget: _EditTrailing(color: disabledColor),
              onTap:
                  isFullVerified
                      ? () => controller.openEditSheet(
                        AccountInformationField.fullName,
                      )
                      : null,
            ),
            SettingsItemW(
              label: 'Email',
              subtitle: profileController.user?.email ?? 'Not Set',
              trailingWidget: _EditTrailing(color: disabledColor),
              onTap:
                  isFullVerified
                      ? () => controller.openEditSheet(
                        AccountInformationField.email,
                      )
                      : null,
            ),
            SettingsItemW(
              label: 'Phone Number',
              subtitle: phone.isNotEmpty ? phone : 'Not Set',
              trailingWidget: _EditTrailing(color: disabledColor),
              onTap:
                  isFullVerified
                      ? () => controller.openEditSheet(
                        AccountInformationField.phone,
                      )
                      : null,
            ),
            SettingsItemW(
              label: 'Date of Birth',
              subtitle:
                  profileController.user?.dateOfBirth.toMonthDayYear() ??
                  'Not Set',
              trailingWidget: _EditTrailing(color: disabledColor),
              onTap:
                  isFullVerified
                      ? () => controller.openEditSheet(
                        AccountInformationField.dateOfBirth,
                      )
                      : null,
            ),
            SettingsItemW(
              label: 'Location',
              subtitle:
                  profileController.user?.location?.description ?? 'Not Set',
              trailingWidget: _EditTrailing(color: disabledColor),
              onTap:
                  isFullVerified
                      ? () => controller.openEditSheet(
                        AccountInformationField.location,
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditTrailing extends StatelessWidget {
  final Color color;

  const _EditTrailing({required this.color});

  @override
  Widget build(BuildContext context) {
    return LNDText.medium(text: 'Edit', color: color);
  }
}

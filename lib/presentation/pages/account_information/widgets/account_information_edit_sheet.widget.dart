import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/phone_number_textfield.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/account_information/account_information.controller.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class AccountInformationEditSheet
    extends GetView<AccountInformationController> {
  final AccountInformationField field;

  const AccountInformationEditSheet._({required this.field});

  factory AccountInformationEditSheet.photo() {
    return const AccountInformationEditSheet._(
      field: AccountInformationField.photo,
    );
  }

  factory AccountInformationEditSheet.fullName() {
    return const AccountInformationEditSheet._(
      field: AccountInformationField.fullName,
    );
  }

  factory AccountInformationEditSheet.email() {
    return const AccountInformationEditSheet._(
      field: AccountInformationField.email,
    );
  }

  factory AccountInformationEditSheet.phone() {
    return const AccountInformationEditSheet._(
      field: AccountInformationField.phone,
    );
  }

  factory AccountInformationEditSheet.dateOfBirth() {
    return const AccountInformationEditSheet._(
      field: AccountInformationField.dateOfBirth,
    );
  }

  factory AccountInformationEditSheet.location() {
    return const AccountInformationEditSheet._(
      field: AccountInformationField.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20.0,
          18.0,
          20.0,
          20.0 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(text: _title, fontSize: 20.0),
            const SizedBox(height: 16.0),
            _content(colors),
            const SizedBox(height: 20.0),
            Visibility(
              visible: field != AccountInformationField.email,
              child: LNDText.regular(
                text:
                    'Submitting will reset your full verification to pending manual review. Your available listings will be hidden from everyone until verification is approved.',
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 14.0),
            Obx(
              () => LNDButton.primary(
                text: 'Submit',
                enabled:
                    field != AccountInformationField.email &&
                    !controller.isUploadingPhoto,
                isLoading: controller.isUploadingPhoto,
                hasPadding: false,
                onPressed: () => controller.submit(field),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(dynamic colors) {
    switch (field) {
      case AccountInformationField.photo:
        return Center(
          child: Obx(
            () => LNDImage.circle(
              imageUrl: controller.photoUrl,
              size: 112.0,
              imageType: ImageType.user,
            ),
          ),
        );
      case AccountInformationField.fullName:
        return Form(
          key: controller.fullNameFormKey,
          child: Column(
            children: [
              LNDTextField.regular(
                labelText: 'First name',
                controller: controller.firstNameController,
                textCapitalization: TextCapitalization.words,
                required: true,
                validator:
                    (value) =>
                        controller.validateField(value, label: 'First name'),
              ),
              const SizedBox(height: 14.0),
              LNDTextField.regular(
                labelText: 'Last name',
                controller: controller.lastNameController,
                textCapitalization: TextCapitalization.words,
                required: true,
                validator:
                    (value) =>
                        controller.validateField(value, label: 'Last name'),
              ),
            ],
          ),
        );
      case AccountInformationField.email:
        return Form(
          key: controller.emailFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDText.regular(
                text:
                    'Email is linked to the account used for sign in and can no longer be updated.',
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 12.0),
              LNDTextField.regular(
                labelText: 'Email',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                readOnly: true,
              ),
            ],
          ),
        );
      case AccountInformationField.phone:
        return Form(
          key: controller.phoneFormKey,
          child: Obx(
            () => LNDPhoneNumberTextField(
              controller: controller.phoneController,
              hintText: controller.phoneHint,
              prefixText: controller.phonePrefixText,
              onPrefixPressed: controller.openPhoneCountryPicker,
              validator: controller.validateSelectedPhoneNumber,
            ),
          ),
        );
      case AccountInformationField.dateOfBirth:
        return Form(
          key: controller.dobFormKey,
          child: LNDTextField.regular(
            labelText: 'Date of birth',
            controller: controller.dobController,
            readOnly: true,
            required: true,
            onTap: controller.pickDateOfBirth,
            validator: controller.validateDateOfBirth,
          ),
        );
      case AccountInformationField.location:
        return Obx(() {
          final locationText = LNDUtils.getLocationText(
            location: controller.location,
            showFullAddress: true,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDText.regular(
                text:
                    'Update the address used for account verification and reviewer checks.',
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 12.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18.0,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: LNDText.regular(
                      text:
                          locationText.isEmpty
                              ? 'No location selected'
                              : locationText,
                      color: colors.textSecondary,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              LNDButton.text(
                text: 'Choose location',
                enabled: true,
                hasPadding: false,
                color: colors.primary,
                onPressed: controller.pickLocation,
              ),
            ],
          );
        });
    }
  }

  String get _title {
    return switch (field) {
      AccountInformationField.photo => 'Update Photo',
      AccountInformationField.fullName => 'Update Full Name',
      AccountInformationField.email => 'Update Email',
      AccountInformationField.phone => 'Update Phone Number',
      AccountInformationField.dateOfBirth => 'Update Date of Birth',
      AccountInformationField.location => 'Update Location',
    };
  }
}

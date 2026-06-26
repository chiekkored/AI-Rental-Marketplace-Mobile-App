import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/phone_number_textfield.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';
import 'package:lend/presentation/pages/full_verification/widgets/profile_photo_picker.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class DetailsStepComponent extends GetView<FullVerificationController> {
  const DetailsStepComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: controller.detailsFormKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Center(child: ProfilePhotoPicker()),
            const SizedBox(height: 24.0),
            LNDText.bold(text: 'Profile details', fontSize: 26.0),
            const SizedBox(height: 8.0),
            LNDText.regular(
              text:
                  'Complete the account details needed for identity review. Phone number is required.',
              color: colors.textMuted,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 20.0),
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
            const SizedBox(height: 14.0),
            LNDTextField.regular(
              labelText: 'Date of birth',
              controller: controller.dobController,
              readOnly: true,
              required: true,
              onTap: controller.onTapDob,
              validator: controller.validateDateOfBirth,
            ),
            const SizedBox(height: 14.0),
            LNDTextField.regular(
              labelText: 'Email',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              required: true,
              validator: controller.validateEmail,
            ),
            const SizedBox(height: 14.0),
            Obx(
              () => LNDPhoneNumberTextField(
                controller: controller.phoneController,
                hintText: controller.phoneHint,
                prefixText: controller.phonePrefixText,
                onPrefixPressed: controller.openPhoneCountryPicker,
                validator: controller.validateSelectedPhoneNumber,
              ),
            ),
            const SizedBox(height: 24.0),
            Obx(
              () => LNDButton.primary(
                text: 'Continue',
                enabled: controller.canContinueDetails,
                isLoading: controller.isUploadingProfilePhoto,
                onPressed: controller.nextFromDetails,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

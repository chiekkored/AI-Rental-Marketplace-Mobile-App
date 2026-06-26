import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';
import 'package:lend/presentation/pages/full_verification/widgets/summary_row.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ConfirmationStepComponent extends GetView<FullVerificationController> {
  const ConfirmationStepComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final location = controller.selectedLocation;
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        LNDText.bold(text: 'Confirm details', fontSize: 26.0),
        const SizedBox(height: 8.0),
        LNDText.regular(
          text: 'Review your information before submitting for verification.',
          color: colors.textMuted,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 20.0),
        SummaryRow(
          label: 'Full name',
          value:
              '${controller.firstNameController.text.trim()} ${controller.lastNameController.text.trim()}',
        ),
        SummaryRow(label: 'Email', value: controller.emailController.text),
        SummaryRow(label: 'Phone', value: controller.formattedPhoneNumber),
        SummaryRow(
          label: 'Date of birth',
          value:
              controller.dobController.text.trim().isEmpty
                  ? ''
                  : DateFormat('MMMM dd, yyyy').format(
                    DateFormat(
                      'MMMM dd, yyyy',
                    ).parse(controller.dobController.text),
                  ),
        ),
        SummaryRow(
          label: 'Profile photo',
          value: controller.hasProfilePhoto ? 'Provided' : 'Not provided',
        ),
        SummaryRow(
          label: 'Address',
          value: location?.formattedAddress ?? 'Not selected',
        ),
        SummaryRow(label: 'Locality', value: location?.locality ?? ''),
        SummaryRow(label: 'Country', value: location?.country ?? ''),
        SummaryRow(
          label: 'Verification',
          value:
              controller.faceKycCaptured
                  ? controller.diditStatus
                  : 'Not completed',
        ),
        // SummaryRow(label: 'Didit session', value: controller.diditSessionId),
        SummaryRow(
          label: 'Rental business owner',
          value: controller.isRentalBusinessOwner ? 'Yes' : 'No',
        ),
        if (controller.isRentalBusinessOwner) ...[
          SummaryRow(
            label: 'DTI registration',
            value: controller.hasDti ? 'Provided' : 'Not provided',
          ),
          SummaryRow(
            label: 'BIR registration',
            value: controller.hasBir ? 'Provided' : 'Not provided',
          ),
          SummaryRow(
            label: 'Mayor/Business Permit',
            value:
                controller.hasMayorBusinessPermit ? 'Provided' : 'Not provided',
          ),
        ],
        const SizedBox(height: 24.0),
        LNDButton.primary(
          text: 'Submit for review',
          enabled: true,
          borderRadius: 12.0,
          onPressed: controller.submit,
        ),
      ],
    );
  }
}

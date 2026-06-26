import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';
import 'package:lend/presentation/pages/full_verification/components/business_owner_step.component.dart';
import 'package:lend/presentation/pages/full_verification/components/confirmation_step.component.dart';
import 'package:lend/presentation/pages/full_verification/components/details_step.component.dart';
import 'package:lend/presentation/pages/full_verification/components/face_kyc_step.component.dart';
import 'package:lend/presentation/pages/full_verification/components/location_step.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class FullVerificationPage extends GetView<FullVerificationController> {
  static const routeName = '/full-verification';
  const FullVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      appBar: AppBar(
        leading: LNDButton.back(onPressed: controller.previousStep),
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        title: LNDText.bold(text: 'Verification', fontSize: 18.0),
      ),
      backgroundColor: colors.surface,
      body: SafeArea(
        child: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            DetailsStepComponent(),
            BusinessOwnerStepComponent(),
            LocationStepComponent(),
            FaceKycStepComponent(),
            ConfirmationStepComponent(),
          ],
        ),
      ),
    );
  }
}

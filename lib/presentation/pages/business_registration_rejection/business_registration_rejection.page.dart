import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/business_registration_rejection/business_registration_rejection.controller.dart';
import 'package:lend/presentation/pages/business_registration_rejection/components/business_registration_rejection_content.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BusinessRegistrationRejectionPage
    extends GetView<BusinessRegistrationRejectionController> {
  static const routeName = '/business-registration-rejection';

  const BusinessRegistrationRejectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(onPressed: Get.back),
        title: LNDText.bold(text: 'Business Review', fontSize: 18.0),
      ),
      backgroundColor: colors.background,
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LNDSpinner());
        }

        if (controller.submission == null) {
          return Center(
            child: LNDText.regular(
              text: 'Business registration review not found.',
              color: colors.textMuted,
            ),
          );
        }

        return const BusinessRegistrationRejectionContent();
      }),
    );
  }
}

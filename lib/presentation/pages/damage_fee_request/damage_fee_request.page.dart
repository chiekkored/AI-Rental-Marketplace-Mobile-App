import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/damage_fee_request/damage_fee_request.controller.dart';
import 'package:lend/presentation/pages/damage_fee_request/components/damage_fee_request_form.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class DamageFeeRequestPage extends GetView<DamageFeeRequestController> {
  static const routeName = '/damage-fee-request';

  const DamageFeeRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: colors.surface,
          backgroundColor: colors.surface,
          leading: LNDButton.back(),
          title: LNDText.bold(text: 'Damage fees', fontSize: 18.0),
        ),
        body: ColoredBox(
          color: colors.surface,
          child: const DamageFeeRequestForm(),
        ),
        bottomNavigationBar: BottomAppBar(
          height: kBottomNavigationBarHeight + 20.0,
          child: SafeArea(
            child: Obx(
              () => LNDButton.primary(
                text: 'Submit request',
                enabled: controller.canSubmit,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.canSubmit ? controller.submit : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

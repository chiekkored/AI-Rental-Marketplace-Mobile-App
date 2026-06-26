import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/pages/owner_payout_destination/components/payout_destination_form.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class OwnerPayoutDestinationPage extends StatefulWidget {
  static const routeName = '/owner-payout-destination';

  const OwnerPayoutDestinationPage({super.key});

  @override
  State<OwnerPayoutDestinationPage> createState() =>
      _OwnerPayoutDestinationPageState();
}

class _OwnerPayoutDestinationPageState
    extends State<OwnerPayoutDestinationPage> {
  OwnerPayoutDestinationController get controller =>
      OwnerPayoutDestinationController.instance;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final purpose =
        args is OwnerPayoutDestinationPageArgs
            ? args.purpose
            : OwnerPayoutDestinationPurpose.ownerPayout;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.configurePurpose(purpose);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        leading: LNDButton.back(),
        title: Obx(
          () => LNDText.bold(text: controller.pageTitle, fontSize: 18.0),
        ),
        actionsPadding: const EdgeInsets.only(right: 24.0),
        actions: [
          Obx(
            () =>
                controller.hasSavedActiveDestination &&
                        !controller.isEditing.value
                    ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: LNDButton.text(
                        text: 'Edit',
                        enabled: true,
                        onPressed: controller.beginEditing,
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
          LNDButton.icon(
            icon: Icons.info_outline_rounded,
            size: 25.0,
            onPressed: controller.openPayoutAccountInfo,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : const PayoutDestinationForm(),
        ),
      ),
      bottomNavigationBar: Obx(
        () =>
            controller.showSaveButton
                ? BottomAppBar(
                  height: kBottomNavigationBarHeight + 20.0,
                  child: ColoredBox(
                    color: colors.surface,
                    child: LNDButton.primary(
                      text: 'Save',
                      enabled: controller.canSaveDestination,
                      isLoading: controller.isSaving.value,
                      onPressed: controller.saveDestination,
                    ),
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}

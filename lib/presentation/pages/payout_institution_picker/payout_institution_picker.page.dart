import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/payout_institution_picker/payout_institution_picker.controller.dart';
import 'package:lend/presentation/pages/payout_institution_picker/widgets/payout_institution_tile.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PayoutInstitutionPickerPage
    extends GetView<PayoutInstitutionPickerController> {
  static const routeName = '/payout-institution-picker';

  const PayoutInstitutionPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: controller.title, fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 12.0),
              child: Obx(
                () => LNDTextField.regular(
                  controller: controller.searchController,
                  hintText: controller.searchHint,
                  prefixIcon: Icons.search_rounded,
                  prefixIconColor: colors.textMuted,
                  prefixIconSize: 18.0,
                  suffixIcon:
                      controller.query.value.isEmpty
                          ? null
                          : Icons.close_rounded,
                  onTapSuffix: controller.clearSearch,
                  borderRadius: 12.0,
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final institutions = controller.displayedInstitutions;
                if (institutions.isEmpty) {
                  return Center(
                    child: LNDText.regular(
                      text: controller.emptyText,
                      color: colors.textMuted,
                    ),
                  );
                }

                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: institutions.length,
                  itemBuilder: (context, index) {
                    return PayoutInstitutionTile(
                      institution: institutions[index],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

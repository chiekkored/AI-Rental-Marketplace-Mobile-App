import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class AddInclusionsPage extends GetView<CreateListingController> {
  static const routeName = '/create-listing/add-inclusions';
  const AddInclusionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: colors.background,
          leading: LNDButton.back(),
          title: LNDText.bold(text: 'Add Inclusions', fontSize: 18),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LNDText.regular(
                        text:
                            'Add the items or accessories included with your listing.',
                        color: colors.textMuted,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: LNDTextField.regular(
                                  controller: controller.inclusionController,
                                  hintText: 'e.g., Extra battery',
                                  maxLength: 30,
                                  borderRadius: 12,
                                  onFieldSubmitted:
                                      (_) => controller.addInclusion(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              LNDButton.primary(
                                text: 'Add',
                                enabled: true,
                                hasPadding: false,
                                borderRadius: 12,
                                onPressed: controller.addInclusion,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Obx(
                            () =>
                                controller.inclusions.isEmpty
                                    ? LNDText.regular(
                                      text: 'No inclusions added yet.',
                                      color: colors.textMuted,
                                    )
                                    : Column(
                                      children: [
                                        for (
                                          var i = 0;
                                          i < controller.inclusions.length;
                                          i++
                                        )
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(
                                              Icons.check_circle_rounded,
                                              color: colors.success,
                                            ),
                                            title: LNDText.regular(
                                              text: controller.inclusions[i],
                                              textAlign: TextAlign.start,
                                            ),
                                            trailing: LNDButton.icon(
                                              icon: Icons.delete_outline,
                                              color: colors.danger,
                                              size: 22,
                                              onPressed:
                                                  () => controller
                                                      .removeInclusion(i),
                                            ),
                                          ),
                                      ],
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.outline)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: LNDButton.primary(
                      text: 'Done',
                      enabled: true,
                      borderRadius: 12,
                      onPressed: Get.back,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

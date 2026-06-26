import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/pages/owner_payout_destination/widgets/payout_destination_type_segment.widget.dart';
import 'package:lend/presentation/pages/owner_payout_destination/widgets/payout_institution_field.widget.dart';
import 'package:lend/presentation/pages/owner_payout_destination/widgets/payout_text_field.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PayoutDestinationForm extends GetView<OwnerPayoutDestinationController> {
  const PayoutDestinationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        children: [
          const PayoutDestinationTypeSegment(),
          const SizedBox(height: 8.0),
          const _PayoutProviderRadioRow(),
          const SizedBox(height: 16.0),
          PayoutInstitutionField(
            label: controller.institutionLabel,
            hintText: controller.institutionHint,
            enabled: controller.fieldsEnabled,
          ),
          const SizedBox(height: 16.0),
          PayoutTextField(
            controller: controller.accountNameController,
            label: 'Account name',
            enabled: controller.fieldsEnabled,
          ),
          PayoutTextField(
            controller: controller.accountNumberController,
            label: controller.accountNumberLabel,
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.none,
            enabled: controller.fieldsEnabled,
          ),
          if (controller.fieldsEnabled)
            PayoutTextField(
              controller: controller.confirmAccountNumberController,
              label: controller.confirmAccountNumberLabel,
              keyboardType: TextInputType.number,
              textCapitalization: TextCapitalization.none,
              enabled: true,
            ),
          const SizedBox(height: 8.0),
          const _PayoutFeeNoticeCard(),
        ],
      ),
    );
  }
}

class _PayoutProviderRadioRow
    extends GetWidget<OwnerPayoutDestinationController> {
  const _PayoutProviderRadioRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(
      () => RadioGroup<String>(
        groupValue: controller.provider.value,
        onChanged:
            controller.fieldsEnabled
                ? (next) => controller.setProvider(next ?? 'instapay')
                : (_) {},
        child: Row(
          children: [
            Expanded(
              child: _PayoutProviderRadioOption(
                label: 'InstaPay',
                value: 'instapay',
                selected: controller.isInstapay,
                enabled: controller.fieldsEnabled,
                activeColor: colors.primary,
                onChanged: controller.setProvider,
                assetName: 'insta_pay',
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _PayoutProviderRadioOption(
                label: 'PESONet',
                value: 'pesonet',
                selected: !controller.isInstapay,
                enabled: controller.fieldsEnabled,
                activeColor: colors.primary,
                onChanged: controller.setProvider,
                assetName: 'peso_net',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutProviderRadioOption extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final bool enabled;
  final Color activeColor;
  final ValueChanged<String> onChanged;
  final String assetName;

  const _PayoutProviderRadioOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.enabled,
    required this.activeColor,
    required this.onChanged,
    required this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: enabled ? () => onChanged(value) : null,
      child: Container(
        height: 60.0,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? colors.primary : colors.outline),
          borderRadius: BorderRadius.circular(8.0),
          color: colors.surface,
        ),
        child: Center(
          child: LNDImage.custom(
            imageUrl: 'assets/images/payment/$assetName.png',
            height: 50.0,
            width: 80.0,
          ),
        ),
      ),
    );
  }
}

class _PayoutFeeNoticeCard extends GetWidget<OwnerPayoutDestinationController> {
  const _PayoutFeeNoticeCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: LNDText.regular(
        text: controller.transferNoticeText,
        fontSize: 13.0,
        color: colors.textPrimary,
        overflow: TextOverflow.visible,
      ),
    );
  }
}

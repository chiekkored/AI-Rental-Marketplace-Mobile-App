import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/damage_fee_request/damage_fee_request.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_photo_grid.dart';
import 'package:lend/presentation/pages/damage_fee_request/widgets/damage_fee_reason_tile.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class DamageFeeRequestForm extends GetView<DamageFeeRequestController> {
  const DamageFeeRequestForm({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        LNDText.regular(
          text:
              controller.hasSecurityDeposit
                  ? 'Security deposit: ${LNDMoney.format(controller.depositAmount)}'
                  : 'No security deposit. Damage fee requests go to Lend Support review.',
          color: colors.textSecondary,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 20),
        LNDText.semibold(text: 'Reason', fontSize: 14),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            children:
                DamageFeeReason.values.map((reason) {
                  if (controller.depositAmount == 0 &&
                      reason.requiresSupportReview) {
                    return DamageFeeReasonTile(
                      reason: reason,
                      selected: controller.reason.value == reason,
                      onTap: () => controller.selectReason(reason),
                    );
                  } else if (controller.depositAmount > 0) {
                    return DamageFeeReasonTile(
                      reason: reason,
                      selected: controller.reason.value == reason,
                      onTap: () => controller.selectReason(reason),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () =>
              controller.isSupportReviewReason
                  ? _SupportReviewNotice()
                  : LNDTextField.money(
                    controller: controller.amountController,
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    errorText: controller.amountError.value,
                    required: true,
                  ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => LNDTextField.textBox(
            controller: controller.notesController,
            labelText:
                controller.isSupportReviewReason
                    ? 'Details for Lend Support'
                    : 'Notes (optional)',
            hintText:
                controller.isSupportReviewReason
                    ? 'Describe why this needs Lend Support review'
                    : 'Add context for the renter and admin',
            errorText: controller.notesError.value,
            required: controller.isSupportReviewReason,
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: LNDText.semibold(text: 'Evidence photos')),
            Obx(
              () => LNDText.regular(
                text:
                    '${controller.evidencePhotos.length} / ${DamageFeeRequestController.maxEvidencePhotos}',
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LNDText.regular(
          text: 'Optional. Add up to 6 photos.',
          color: colors.textSecondary,
          fontSize: 12,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 12),
        Obx(
          () => CreateListingPhotoGrid(
            photos: controller.evidencePhotos,
            maxCount: DamageFeeRequestController.maxEvidencePhotos,
            onAdd: _openEvidenceSourceMenu,
            onRemove: controller.removeEvidencePhoto,
            showAddTile: controller.canAddEvidence,
          ),
        ),
      ],
    );
  }

  void _openEvidenceSourceMenu() {
    LNDShow.menuBottomSheetVertical<DamageFeePhotoSource>(
      items: [
        LNDMenuItem(
          label: 'Take photo',
          value: DamageFeePhotoSource.camera,
          icon: Icons.camera_alt_outlined,
          onTap: (source) => controller.pickEvidencePhotos(source),
        ),
        LNDMenuItem(
          label: 'Choose from gallery',
          value: DamageFeePhotoSource.gallery,
          icon: Icons.photo_library_outlined,
          onTap: (source) => controller.pickEvidencePhotos(source),
        ),
      ],
    );
  }
}

class _SupportReviewNotice extends GetWidget<DamageFeeRequestController> {
  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.support_agent_rounded, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: LNDText.regular(
              text:
                  controller.hasSecurityDeposit
                      ? 'This request will go straight to admin review. If accepted, Lend Support will open separate chats with you and the renter.'
                      : 'This request will go straight to Lend Support review. If accepted, Support can ask the renter for payment.',
              color: colors.textSecondary,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

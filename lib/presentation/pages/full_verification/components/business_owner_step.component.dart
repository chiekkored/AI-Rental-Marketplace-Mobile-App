import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/checkbox.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';
import 'package:lend/utilities/enums/business_registration_document.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BusinessOwnerStepComponent extends GetView<FullVerificationController> {
  const BusinessOwnerStepComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        LNDText.bold(text: 'Rental business', fontSize: 26.0),
        const SizedBox(height: 8.0),
        LNDText.regular(
          text:
              'This is optional. If you operate rentals as a business owner, submit your business documents for admin review.',
          color: colors.textMuted,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 20.0),
        Obx(
          () => Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8.0),
            child: SwitchListTile.adaptive(
              value: controller.isRentalBusinessOwner,
              onChanged: controller.setRentalBusinessOwner,
              title: LNDText.semibold(text: "I'm a rental business owner"),
              subtitle: LNDText.regular(
                text:
                    'Turn this on to send DTI, BIR, and permit documents to Lend with your verification request.',
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ),
        Obx(
          () =>
              controller.isRentalBusinessOwner
                  ? controller.hasApprovedBusinessRegistration
                      ? Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Material(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  color: colors.success,
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: LNDText.regular(
                                    text:
                                        'Your business registration is already approved. You can continue without resubmitting business documents.',
                                    color: colors.textMuted,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20.0),
                          const _DocumentTile(
                            type: BusinessRegistrationDocumentType.dti,
                          ),
                          const SizedBox(height: 12.0),
                          const _DocumentTile(
                            type: BusinessRegistrationDocumentType.bir,
                          ),
                          const SizedBox(height: 12.0),
                          const _DocumentTile(
                            type:
                                BusinessRegistrationDocumentType
                                    .mayorBusinessPermit,
                            subtitle: 'If applicable',
                          ),
                          const SizedBox(height: 20.0),
                          LNDCheckboxTile(
                            value: controller.taxInvoiceAcknowledged,
                            onChanged:
                                (value) => controller.setTaxInvoiceAcknowledged(
                                  value == true,
                                ),
                            title: LNDText.regular(
                              text:
                                  'I acknowledge that I am responsible for applicable tax, invoice, permit, license, insurance, property, transport, LGU, and other legal obligations for my listings.',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      )
                  : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24.0),
        Obx(
          () => LNDButton.primary(
            text: 'Continue',
            enabled: controller.canContinueBusinessOwner,
            isLoading: controller.isUploadingBusinessDocument,
            onPressed: controller.nextFromBusinessOwner,
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends GetWidget<FullVerificationController> {
  final BusinessRegistrationDocumentType type;
  final String? subtitle;

  const _DocumentTile({required this.type, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Obx(() {
      final path = controller.businessDocumentPath(type);
      final hasDocument = path.trim().isNotEmpty;
      final isEnabled = !controller.isUploadingBusinessDocument;
      final tile = Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  hasDocument
                      ? Icons.check_circle_outline_rounded
                      : Icons.upload_file_outlined,
                  color: hasDocument ? colors.success : colors.textPrimary,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LNDText.semibold(
                        text: type.title,
                        textParts: [
                          if (type.isRequired)
                            LNDText.semibold(text: ' *', color: colors.danger),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      LNDText.regular(
                        text:
                            hasDocument
                                ? 'Uploaded'
                                : subtitle ?? 'Upload document',
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
                LNDButton.text(
                  text: hasDocument ? 'Replace' : 'Upload',
                  enabled: isEnabled,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );

      if (!isEnabled) return tile;

      return LNDShow.popupMenuWidget<BusinessRegistrationDocumentSource>(
        items: _menuItems(type),
        child: tile,
      );
    });
  }

  List<LNDMenuItem<BusinessRegistrationDocumentSource>> _menuItems(
    BusinessRegistrationDocumentType type,
  ) {
    return [
      LNDMenuItem<BusinessRegistrationDocumentSource>(
        label: 'Camera',
        value: BusinessRegistrationDocumentSource.camera,
        icon: Icons.camera_alt_rounded,
        onTap:
            (source) => controller.pickBusinessDocumentFromSource(type, source),
      ),
      LNDMenuItem<BusinessRegistrationDocumentSource>(
        label: 'Gallery',
        value: BusinessRegistrationDocumentSource.gallery,
        icon: Icons.photo_library_rounded,
        onTap:
            (source) => controller.pickBusinessDocumentFromSource(type, source),
      ),
      LNDMenuItem<BusinessRegistrationDocumentSource>(
        label: 'Files',
        value: BusinessRegistrationDocumentSource.files,
        icon: Icons.upload_file_rounded,
        onTap:
            (source) => controller.pickBusinessDocumentFromSource(type, source),
      ),
    ];
  }
}

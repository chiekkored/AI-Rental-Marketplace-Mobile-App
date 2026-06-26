import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/checkbox.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/business_registration/business_registration.controller.dart';
import 'package:lend/utilities/enums/business_registration_document.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BusinessRegistrationPage extends GetView<BusinessRegistrationController> {
  static const routeName = '/business-registration';

  const BusinessRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: 'Business Registration', fontSize: 18.0),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LNDSpinner());
          }

          if (controller.isApproved) {
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                LNDText.bold(text: 'Approved business profile', fontSize: 24.0),
                const SizedBox(height: 8.0),
                LNDText.regular(
                  text:
                      'Your business registration is approved. These are your approved business details.',
                  color: colors.textMuted,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 20.0),
                _SummaryTile(
                  label: 'Business name',
                  value: controller.approvedBusinessName,
                ),
                const SizedBox(height: 12.0),
                _SummaryTile(
                  label: 'Business type',
                  value: controller.approvedBusinessType,
                ),
                const SizedBox(height: 12.0),
                _SummaryTile(
                  label: 'Business address',
                  value: controller.approvedBusinessAddress,
                ),
                if (controller.canToggleBusinessNamePreference) ...[
                  const SizedBox(height: 20.0),
                  Material(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8.0),
                    child: SwitchListTile.adaptive(
                      value: controller.useBusinessNameForListingOwnerName,
                      onChanged:
                          controller.isUpdatingDisplayPreference
                              ? null
                              : controller
                                  .setUseBusinessNameForListingOwnerName,
                      title: LNDText.semibold(
                        text: 'Use business name for future listings',
                      ),
                      subtitle: LNDText.regular(
                        text:
                            'When enabled, new and future listing rewrites will use your approved business name. Previous listings stay unchanged.',
                        color: colors.textMuted,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              if (controller.isRejected) ...[
                const _RejectedBusinessRegistrationCard(),
                const SizedBox(height: 20.0),
              ],
              LNDText.bold(text: 'Required documents', fontSize: 24.0),
              const SizedBox(height: 8.0),
              LNDText.regular(
                text:
                    controller.isRequired
                        ? 'Your listing is still pending. Submit these documents so Lend can continue reviewing your owner compliance requirements.'
                        : 'Submit these documents if you operate rentals as a business owner.',
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 20.0),
              const _DocumentTile(type: BusinessRegistrationDocumentType.dti),
              const SizedBox(height: 12.0),
              const _DocumentTile(type: BusinessRegistrationDocumentType.bir),
              const SizedBox(height: 12.0),
              const _DocumentTile(
                type: BusinessRegistrationDocumentType.mayorBusinessPermit,
                subtitle: 'If applicable',
              ),
              const SizedBox(height: 20.0),
              LNDCheckboxTile(
                value: controller.taxInvoiceAcknowledged.value,
                onChanged:
                    (value) =>
                        controller.setTaxInvoiceAcknowledged(value == true),
                title: LNDText.regular(
                  text:
                      'I acknowledge that I am responsible for applicable tax, invoice, permit, license, insurance, property, transport, LGU, and other legal obligations for my listings.',
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(
        () =>
            controller.isApproved
                ? const SizedBox.shrink()
                : BottomAppBar(
                  height: kBottomNavigationBarHeight + 20.0,
                  child: ColoredBox(
                    color: colors.surface,
                    child: LNDButton.primary(
                      text:
                          controller.isSubmitted
                              ? 'Update documents'
                              : 'Submit documents',
                      enabled: controller.canSubmit,
                      isLoading: controller.isSubmitting.value,
                      onPressed: controller.submit,
                    ),
                  ),
                ),
      ),
    );
  }
}

class _RejectedBusinessRegistrationCard
    extends GetWidget<BusinessRegistrationController> {
  const _RejectedBusinessRegistrationCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.danger,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: LNDText.bold(
                    text: 'Business registration was rejected',
                    color: colors.textPrimary,
                    fontSize: 16.0,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Obx(
              () => LNDText.regular(
                text: controller.rejectionReason,
                color: colors.textPrimary,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 10.0),
            LNDText.regular(
              text: 'Replace the required documents and submit again.',
              color: colors.textMuted,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String? value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.semibold(text: label),
            const SizedBox(height: 6.0),
            LNDText.regular(
              text: (value?.trim().isNotEmpty ?? false) ? value! : 'Not set',
              color: colors.textMuted,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends GetWidget<BusinessRegistrationController> {
  final BusinessRegistrationDocumentType type;
  final String? subtitle;

  const _DocumentTile({required this.type, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Obx(() {
      final path = controller.documentPath(type);
      final hasDocument = path.trim().isNotEmpty;
      final isEnabled = !controller.isSubmitting.value;
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
                _buildUploadButton(
                  hasDocument: hasDocument,
                  enabled: isEnabled,
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

  Widget _buildUploadButton({
    required bool hasDocument,
    required bool enabled,
  }) {
    return LNDButton.text(
      text: hasDocument ? 'Replace' : 'Upload',
      enabled: enabled,
      onPressed: null,
    );
  }

  List<LNDMenuItem<BusinessRegistrationDocumentSource>> _menuItems(
    BusinessRegistrationDocumentType type,
  ) {
    return [
      LNDMenuItem<BusinessRegistrationDocumentSource>(
        label: 'Camera',
        value: BusinessRegistrationDocumentSource.camera,
        icon: Icons.camera_alt_rounded,
        onTap: (source) => controller.pickDocumentFromSource(type, source),
      ),
      LNDMenuItem<BusinessRegistrationDocumentSource>(
        label: 'Gallery',
        value: BusinessRegistrationDocumentSource.gallery,
        icon: Icons.photo_library_rounded,
        onTap: (source) => controller.pickDocumentFromSource(type, source),
      ),
      LNDMenuItem<BusinessRegistrationDocumentSource>(
        label: 'Files',
        value: BusinessRegistrationDocumentSource.files,
        icon: Icons.upload_file_rounded,
        onTap: (source) => controller.pickDocumentFromSource(type, source),
      ),
    ];
  }
}

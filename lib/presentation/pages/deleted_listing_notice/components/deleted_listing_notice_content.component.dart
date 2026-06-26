import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/deleted_listing_notice/deleted_listing_notice.controller.dart';
import 'package:lend/presentation/pages/deleted_listing_notice/widgets/deleted_listing_card.widget.dart';
import 'package:lend/presentation/pages/deleted_listing_notice/widgets/deleted_listing_reason.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';

class DeletedListingNoticeContent
    extends GetView<DeletedListingNoticeController> {
  const DeletedListingNoticeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = context.lndTheme;
      final event = controller.event!;

      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DeletedListingCard(
            imageUrl: controller.imageUrl,
            listing: event.listing,
          ),
          const SizedBox(height: 16.0),
          DeletedListingReason(reason: event.reason),
          const SizedBox(height: 16.0),
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDText.regular(
                    text:
                        'If you think we made a mistake, contact support through the ',
                    color: colors.textMuted,
                    overflow: TextOverflow.visible,
                    textParts: [
                      LNDText.bold(
                        text: 'Help Center',
                        color: colors.primary,
                        onTap: LNDLegalLinks.openHelpCenter,
                      ),
                      LNDText.regular(text: '.'),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  LNDText.regular(
                    text: 'For more information, read our ',
                    color: colors.textMuted,
                    overflow: TextOverflow.visible,
                    textParts: [
                      LNDText.bold(
                        text: 'Terms and Conditions',
                        color: colors.primary,
                        onTap: LNDLegalLinks.openTermsAndConditions,
                      ),
                      LNDText.regular(text: ' or '),
                      LNDText.bold(
                        text: 'Privacy Policy',
                        color: colors.primary,
                        onTap: LNDLegalLinks.openPrivacyPolicy,
                      ),
                      LNDText.regular(text: '.'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

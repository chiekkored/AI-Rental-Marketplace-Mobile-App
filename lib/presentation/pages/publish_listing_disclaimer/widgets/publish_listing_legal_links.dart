import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/publish_listing_disclaimer/publish_listing_disclaimer.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PublishListingLegalLinks
    extends GetWidget<PublishListingDisclaimerController> {
  const PublishListingLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Wrap(
      children: [
        LNDText.regular(
          text: 'Learn more in our ',
          color: colors.textMuted,
          fontSize: 13,
          overflow: TextOverflow.visible,
        ),
        LNDText.semibold(
          text: 'Terms and Conditions',
          color: colors.primary,
          fontSize: 13,
          overflow: TextOverflow.visible,
          textDecoration: TextDecoration.underline,
          onTap: controller.openTermsAndConditions,
        ),
        LNDText.regular(
          text: ' and ',
          color: colors.textMuted,
          fontSize: 13,
          overflow: TextOverflow.visible,
        ),
        LNDText.semibold(
          text: 'Privacy Policy',
          color: colors.primary,
          fontSize: 13,
          overflow: TextOverflow.visible,
          textDecoration: TextDecoration.underline,
          onTap: controller.openPrivacyPolicy,
        ),
        LNDText.regular(
          text: '.',
          color: colors.textMuted,
          fontSize: 13,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}

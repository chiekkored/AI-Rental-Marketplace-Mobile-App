import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/checkbox.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/publish_listing_disclaimer/publish_listing_disclaimer.controller.dart';
import 'package:lend/presentation/pages/publish_listing_disclaimer/widgets/publish_listing_disclaimer_bullet.dart';
import 'package:lend/presentation/pages/publish_listing_disclaimer/widgets/publish_listing_legal_links.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PublishListingDisclaimerPage
    extends GetView<PublishListingDisclaimerController> {
  static const routeName = '/publish-listing-disclaimer';

  const PublishListingDisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.cancel();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          surfaceTintColor: colors.surface,
          backgroundColor: colors.surface,
          leading: LNDButton.back(onPressed: controller.cancel),
          title: LNDText.bold(text: 'Before you publish', fontSize: 18.0),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LNDText.bold(
                        text: 'Listing disclosure',
                        fontSize: 22,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 8),
                      LNDText.regular(
                        text:
                            'By publishing this listing, you acknowledge these important marketplace terms.',
                        color: colors.textMuted,
                        fontSize: 14,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 24),
                      const PublishListingDisclaimerBullet(
                        text:
                            'Your first name may be shown to the renter once a booking is confirmed.',
                      ),
                      const SizedBox(height: 16),
                      // const PublishListingDisclaimerBullet(
                      //   text:
                      //       'Your phone number may be shown once a booking is confirmed.',
                      // ),
                      // const SizedBox(height: 16),
                      const PublishListingDisclaimerBullet(
                        text:
                            'Your pinned listing location may be shown, whether it comes from your profile or a custom pinned location.',
                      ),
                      const SizedBox(height: 16),
                      const PublishListingDisclaimerBullet(
                        text:
                            'Lend is not insurance and does not guarantee reimbursement for lost, damaged, misused, late-returned, or missing items.',
                      ),
                      const SizedBox(height: 16),
                      const PublishListingDisclaimerBullet(
                        text:
                            'Lend is a peer-to-peer rental platform. Owners and renters remain responsible for listings, bookings, handovers, returns, conduct, and legal compliance.',
                      ),
                      const SizedBox(height: 16),
                      const PublishListingDisclaimerBullet(
                        text:
                            'Owners are responsible for ensuring that they legally own or are authorized to rent the item/property, and for complying with all applicable taxes, permits, and other legal obligations. Lend may request additional documents depending on the listing category, transaction volume, earnings, risk, or applicable requirements.',
                      ),
                      const SizedBox(height: 16),
                      const PublishListingDisclaimerBullet(
                        text:
                            'Verification and Lend review reduce risk, but they do not guarantee user behavior, asset condition, or dispute outcome.',
                      ),
                      const SizedBox(height: 24),
                      const PublishListingLegalLinks(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.outline)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha:
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.30
                            : 0.06,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => LNDCheckboxTile(
                      value: controller.dontShowAgain.value,
                      onChanged: controller.toggleDontShowAgain,
                      activeColor: colors.primary,
                      title: LNDText.regular(
                        text: 'Don\'t show again on this device',
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  LNDButton.primary(
                    text: 'I understand, publish listing',
                    enabled: true,
                    onPressed: controller.confirm,
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

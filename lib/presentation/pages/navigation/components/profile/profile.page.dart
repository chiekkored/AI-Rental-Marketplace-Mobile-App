import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/eligibility/eligibility.page.dart';
import 'package:lend/presentation/pages/navigation/components/profile/widgets/profile_action.widget.dart';
import 'package:lend/presentation/pages/navigation/components/profile/widgets/outstanding_balance_banner.widget.dart';
import 'package:lend/presentation/pages/navigation/components/profile/widgets/profile_card.widget.dart';
import 'package:lend/presentation/pages/navigation/components/profile/widgets/profile_header.widget.dart';
import 'package:lend/presentation/pages/navigation/components/profile/widgets/profile_section.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ProfileHeader()),
            const SliverToBoxAdapter(child: OutstandingBalanceBanner()),
            const SliverToBoxAdapter(
              child: ProfileSection(child: ProfileCard()),
            ),
            SliverToBoxAdapter(child: _buildProfileCardsRow(context)),
            SliverToBoxAdapter(child: _buildAccountSection()),
            SliverToBoxAdapter(child: _buildSupportSection()),
            SliverToBoxAdapter(child: _buildAppsSection()),
            Obx(
              () => SliverToBoxAdapter(
                child:
                    controller.isAuthenticated
                        ? _buildSessionSection(context)
                        : const SizedBox.shrink(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return ProfileSection(
      label: 'Account',
      children: [
        ProfileAction(
          label: 'Account',
          icon: Icons.account_circle_outlined,
          onTap: () => LNDNavigate.toAccountSettingsPage(),
        ),
        ProfileAction(
          label: 'Security',
          icon: Icons.shield_outlined,
          onTap: () => LNDNavigate.toSecurityPage(),
        ),
        ProfileAction(
          label: 'Verification Status',
          icon: Icons.verified_user_outlined,
          svg: SvgPicture.asset(LNDVerificationBadge.fullAsset),
          onTap: () => Get.toNamed(EligibilityPage.routeName),
        ),
        if (controller.isAuthenticated)
          ProfileAction(
            label: 'Blocked users',
            icon: Icons.block_rounded,
            onTap: controller.openBlockedUsers,
          ),
      ],
    );
  }

  Widget _buildProfileCardsRow(BuildContext context) {
    final payoutController = OwnerPayoutDestinationController.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _ProfileShortcutCard(
                title: 'Owner Center',
                subtitle: 'Manage your listings',
                icon: Icons.storefront_outlined,
                onTap: LNDNavigate.toBuyerCenterPage,
                showWarning:
                    payoutController.shouldShowMissingPayoutDestinationWarning,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _ProfileShortcutCard(
                title: 'Renter Center',
                subtitle: 'Manage your rentals',
                icon: Icons.shopping_bag_outlined,
                onTap: LNDNavigate.toRenterCenterPage,
                showWarning:
                    payoutController
                        .shouldShowMissingDepositReturnDestinationWarning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return ProfileSection(
      label: 'Support',
      children: [
        const ProfileAction(
          label: 'Help Center',
          icon: Icons.help_outline_rounded,
          onTap: LNDLegalLinks.openHelpCenter,
        ),
        ProfileAction(
          label: 'About',
          icon: Icons.menu_book_rounded,
          onTap: () => LNDNavigate.toAboutPage(),
        ),
      ],
    );
  }

  Widget _buildAppsSection() {
    return ProfileSection(
      label: 'Apps',
      children: [
        ProfileAction(
          label: 'Settings',
          icon: Icons.settings_outlined,
          onTap: () => LNDNavigate.toSettingsPage(),
        ),
      ],
    );
  }

  Widget _buildSessionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: LNDButton.text(
          text: 'Sign out',
          color: context.lndTheme.danger,
          enabled: true,
          onPressed: () => controller.signOut(),
        ),
      ),
    );
  }
}

class _ProfileShortcutCard extends StatelessWidget {
  const _ProfileShortcutCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.showWarning = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          height: 104.0,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: colors.textPrimary),
                    const Spacer(),
                    LNDText.semibold(
                      text: title,
                      color: colors.textPrimary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    LNDText.regular(
                      text: subtitle,
                      color: colors.textMuted,
                      fontSize: 12.0,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showWarning)
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: Tooltip(
                    message: 'Action required',
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.warningSoft,
                        borderRadius: BorderRadius.circular(999.0),
                        border: Border.all(color: colors.warning),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: colors.warning,
                          size: 16.0,
                        ),
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

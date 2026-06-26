import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/shimmer.common.dart';
import 'package:lend/presentation/controllers/profile_view/profile_view.controller.dart';
import 'package:lend/presentation/pages/eligibility/eligibility.page.dart';
import 'package:lend/presentation/pages/profile_view/widgets/profile_view_header_card.widget.dart';
import 'package:lend/presentation/pages/profile_view/widgets/profile_view_section_card.widget.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class ProfileViewPage extends GetView<ProfileViewController> {
  static const routeName = '/profile-view';

  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(
          onPressed: canPop ? () => Navigator.of(context).pop() : null,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) return const _LoadingWidget();

        final user = controller.user;
        if (user == null) return const SizedBox.shrink();

        final verified = user.verified ?? VerificationLevel.none;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          children: [
            ProfileViewHeaderCard(user: user),
            if (verified == VerificationLevel.none) ...[
              const SizedBox(height: 16.0),
              LNDButton.primary(
                text: 'Verify now',
                enabled: true,
                onPressed: () => Get.toNamed(EligibilityPage.routeName),
              ),
            ],
            const SizedBox(height: 16.0),
            ProfileViewSectionCard(
              title: 'Personal Information',
              children: [
                ProfileViewInfoRow(
                  label: 'Full name',
                  value: controller.fullName,
                ),
                ProfileViewInfoRow(label: 'Email', value: user.email),
                ProfileViewInfoRow(label: 'Phone number', value: user.phone),
                ProfileViewInfoRow(
                  label: 'Date of birth',
                  value: user.dateOfBirth.toMonthDayYear(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ProfileViewSectionCard(
              title: 'Location',
              children: [
                ProfileViewInfoRow(
                  label: 'Address',
                  value: LNDUtils.getLocationText(
                    location: user.location,
                    showFullAddress: true,
                  ),
                ),
              ],
            ),
            if (controller.hasBusinessProfile) ...[
              const SizedBox(height: 16.0),
              ProfileViewSectionCard(
                title: 'Business Information',
                children: [
                  ProfileViewInfoRow(
                    label: 'Business name',
                    value: controller.businessName,
                  ),
                  ProfileViewInfoRow(
                    label: 'Business type',
                    value: controller.businessType,
                  ),
                  ProfileViewInfoRow(
                    label: 'Business address',
                    value: controller.businessAddress,
                  ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return LNDShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  LNDShimmerCircle(size: 96.0),
                  SizedBox(height: 16.0),
                  LNDShimmerBox(height: 20.0, width: 200.0),
                  SizedBox(height: 8.0),
                  LNDShimmerBox(height: 16.0, width: 180.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDShimmerBox(height: 18.0, width: 180.0),
                  SizedBox(height: 16.0),
                  LNDShimmerBox(height: 14.0, width: 120.0),
                  SizedBox(height: 6.0),
                  LNDShimmerBox(height: 16.0, width: double.infinity),
                  SizedBox(height: 14.0),
                  LNDShimmerBox(height: 14.0, width: 120.0),
                  SizedBox(height: 6.0),
                  LNDShimmerBox(height: 16.0, width: double.infinity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

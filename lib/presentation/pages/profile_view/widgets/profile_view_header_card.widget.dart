import 'package:flutter/material.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class ProfileViewHeaderCard extends StatelessWidget {
  const ProfileViewHeaderCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final verified = user.verified ?? VerificationLevel.none;
    final verificationText = switch (verified) {
      VerificationLevel.full => 'Fully Verified',
      VerificationLevel.basic => 'Basic Verified',
      _ => 'Not Verified',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LNDImage.circle(
              imageUrl: user.photoUrl,
              size: 96.0,
              imageType: ImageType.user,
            ),
            const SizedBox(height: 16.0),
            LNDVerifiedName(
              name: LNDUtils.formatFullName(
                firstName: user.firstName,
                lastName: user.lastName,
                addLastName: true,
              ),
              verificationLevel: verified,
              showFoundingOwnerBadge: user.isFoundingOwnerAccount,
              foundingOwnerBadgeShiny: true,
              weight: LNDVerifiedNameWeight.bold,
              fontSize: 20.0,
              badgeSize: 18.0,
            ),
            const SizedBox(height: 8.0),
            LNDText.regular(
              text:
                  user.email?.trim().isNotEmpty == true
                      ? user.email!
                      : 'No email',
              color: colors.textMuted,
            ),
            const SizedBox(height: 14.0),
            DecoratedBox(
              decoration: BoxDecoration(
                color:
                    verified == VerificationLevel.none
                        ? colors.warningSoft
                        : colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: LNDText.medium(
                  text: verificationText,
                  color:
                      verified == VerificationLevel.none
                          ? colors.warning
                          : colors.primary,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

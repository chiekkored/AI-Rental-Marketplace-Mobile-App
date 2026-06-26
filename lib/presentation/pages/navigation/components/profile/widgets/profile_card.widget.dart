import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/navigation/components/profile/widgets/profile_signin_view.widget.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';
import 'package:shimmer/shimmer.dart';

class ProfileCard extends GetView<ProfileController> {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(
      () =>
          !controller.isAuthenticated
              ? const ProfileSigninView()
              : ListTile(
                contentPadding: EdgeInsets.zero,
                onTap:
                    controller.isLoading
                        ? null
                        : () => LNDNavigate.toOwnProfileViewPage(),
                leading:
                    controller.isLoading
                        ? Shimmer.fromColors(
                          baseColor: colors.outline,
                          highlightColor: colors.surface,
                          child: CircleAvatar(
                            radius: 25.0,
                            backgroundColor: colors.surface,
                          ),
                        )
                        : LNDImage.circle(
                          imageUrl: controller.user?.photoUrl,
                          size: 50.0,
                          imageType: ImageType.user,
                        ),
                title:
                    controller.isLoading
                        ? Shimmer.fromColors(
                          baseColor: colors.outline,
                          highlightColor: colors.surface,
                          child: Container(
                            height: 20.0,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        )
                        : Obx(
                          () => LNDVerifiedName(
                            name: LNDUtils.formatFullName(
                              firstName: controller.user?.firstName,
                              lastName: controller.user?.lastName,
                            ),
                            verificationLevel: controller.user?.verified,
                            showFoundingOwnerBadge:
                                controller.user?.isFoundingOwnerAccount == true,
                          ),
                        ),
                subtitle: LNDText.regular(
                  text: controller.user?.email ?? '',
                  color: colors.textMuted,
                  fontSize: 12.0,
                ),
              ),
    );
  }
}

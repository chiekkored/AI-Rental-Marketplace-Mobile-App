import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/shimmer.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/blocked_users/blocked_users.controller.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class BlockedUsersPage extends GetView<BlockedUsersController> {
  static const routeName = '/blocked-users';
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      appBar: AppBar(
        leading: LNDButton.back(),
        title: LNDText.bold(text: 'Blocked users', fontSize: 18),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LNDShimmerBox(height: 72, width: double.infinity),
          );
        }
        if (controller.users.isEmpty) {
          return Center(
            child: LNDText.regular(
              text: 'You have not blocked anyone.',
              color: colors.textSecondary,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: controller.users.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final user = controller.users[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  LNDImage.circle(
                    imageUrl: user.photoUrl,
                    size: 48,
                    imageType: ImageType.user,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: LNDVerifiedName(
                      name: LNDUtils.formatSimpleUserName(user),
                      verificationLevel: user.verified,
                      showBusinessBadge: user.hasDisplayName,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  LNDButton.text(
                    text: 'Unblock',
                    enabled: true,
                    onPressed: () => controller.unblock(user),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

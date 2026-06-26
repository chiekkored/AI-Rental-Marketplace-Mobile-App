import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/notifications/notifications.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(child: LNDText.bold(text: 'Profile', fontSize: 32.0)),
          Obx(() {
            return Badge(
              smallSize: 9.0,
              isLabelVisible:
                  NotificationsController.instance.hasUnreadNotifications,
              child: LNDButton.icon(
                icon: Icons.notifications_rounded,
                size: 26.0,
                onPressed: controller.goToNotifications,
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/notifications/notifications.controller.dart';
import 'package:lend/presentation/pages/notifications/widgets/notification_item.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class NotificationsPage extends StatefulWidget {
  static const routeName = '/notifications';
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationsController get controller => NotificationsController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markUnreadNotificationsAsReadOnPageOpen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(onPressed: Get.back),
        title: LNDText.bold(text: 'Notifications', fontSize: 18.0),
      ),
      backgroundColor: colors.background,
      body: Obx(() {
        if (controller.isNotificationsLoading) {
          return const Center(child: LNDSpinner());
        }

        final notifications = controller.notifications;
        if (notifications.isEmpty) {
          return Center(
            child: LNDText.regular(
              text: 'No notifications yet',
              color: colors.textMuted,
            ),
          );
        }

        return ListView.separated(
          controller: controller.scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4.0),
          itemBuilder:
              (_, index) => NotificationItemW(
                notification: notifications[index],
                onTap: () => controller.openNotification(notifications[index]),
              ),
        );
      }),
    );
  }
}

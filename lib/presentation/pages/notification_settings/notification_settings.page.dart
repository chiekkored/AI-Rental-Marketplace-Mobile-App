import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/notification_settings/notification_settings.controller.dart';
import 'package:lend/presentation/pages/notification_settings/components/notification_settings_content.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class NotificationSettingsPage extends GetView<NotificationSettingsController> {
  static const routeName = '/notification-settings';

  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(onPressed: Get.back),
        title: LNDText.bold(text: 'Notification Settings', fontSize: 18.0),
      ),
      backgroundColor: colors.background,
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LNDSpinner());
        }

        return const NotificationSettingsContent();
      }),
    );
  }
}

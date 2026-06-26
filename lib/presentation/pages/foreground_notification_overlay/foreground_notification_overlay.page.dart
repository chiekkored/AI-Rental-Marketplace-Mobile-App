import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/foreground_notification/foreground_notification.controller.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ForegroundNotificationOverlay
    extends GetWidget<ForegroundNotificationController> {
  final Widget child;

  const ForegroundNotificationOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Stack(
      children: [
        child,
        SafeArea(
          bottom: false,
          child: Obx(() {
            return AnimatedSlide(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              offset:
                  controller.isVisible.value
                      ? Offset.zero
                      : const Offset(0, -1.4),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: controller.isVisible.value ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !controller.isVisible.value,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.tap,
                      onVerticalDragEnd: (_) => controller.hide(),
                      child: Material(
                        color: colors.surface,
                        elevation: 8.0,
                        shadowColor: Colors.black.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          height: kToolbarHeight,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _ForegroundNotificationAvatar(
                                imageUrl: controller.imageUrl.value,
                                notificationType:
                                    controller.notificationType.value,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LNDText.semibold(
                                      text: controller.title.value,
                                      color: colors.textPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (controller.body.value.isNotEmpty) ...[
                                      const SizedBox(height: 2.0),
                                      LNDText.regular(
                                        text: controller.body.value,
                                        color: colors.textMuted,
                                        fontSize: 12.0,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ForegroundNotificationAvatar extends StatelessWidget {
  final String? imageUrl;
  final String notificationType;

  const _ForegroundNotificationAvatar({
    required this.imageUrl,
    required this.notificationType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final normalizedImageUrl = imageUrl?.trim();

    if (normalizedImageUrl != null && normalizedImageUrl.isNotEmpty) {
      return LNDImage.circle(
        imageUrl: normalizedImageUrl,
        imageType:
            notificationType == 'chat' ? ImageType.user : ImageType.asset,
        size: 40.0,
      );
    }

    return CircleAvatar(
      radius: 20.0,
      backgroundColor: colors.primary.withValues(alpha: 0.12),
      child: Icon(
        Icons.notifications_none_rounded,
        color: colors.primary,
        size: 20.0,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lend/core/models/notification.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/timestamp.extension.dart';

class NotificationItemW extends StatelessWidget {
  final LNDNotification notification;
  final VoidCallback onTap;

  const NotificationItemW({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final icon = switch (notification.type) {
      'verification' => Icons.verified_user_outlined,
      'chat' => Icons.chat_bubble_outline_rounded,
      'booking' => Icons.calendar_month_outlined,
      'listing_review' => Icons.fact_check_outlined,
      _ => Icons.notifications_none_rounded,
    };
    final imageType =
        notification.type == 'chat' ? ImageType.user : ImageType.asset;

    return Material(
      color:
          notification.isUnread
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationAvatar(
                imageUrl: notification.imageUrl,
                imageType: imageType,
                fallbackIcon: icon,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LNDText.semibold(
                      text: notification.title,
                      color: colors.textPrimary,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 4.0),
                    LNDText.regular(
                      text: notification.body,
                      color: colors.textMuted,
                      overflow: TextOverflow.visible,
                      maxLines: 3,
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 6.0),
                      LNDText.medium(
                        text: notification.createdAt.toTimeAgo(forceAgo: true),
                        color: colors.textMuted,
                        fontSize: 12.0,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textMuted,
                size: 22.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationAvatar extends StatelessWidget {
  final String? imageUrl;
  final ImageType imageType;
  final IconData fallbackIcon;

  const _NotificationAvatar({
    required this.imageUrl,
    required this.imageType,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final normalizedImageUrl = imageUrl?.trim();

    if (normalizedImageUrl != null && normalizedImageUrl.isNotEmpty) {
      return LNDImage.circle(
        imageUrl: normalizedImageUrl,
        imageType: imageType,
        size: 44.0,
      );
    }

    return CircleAvatar(
      radius: 22.0,
      backgroundColor: colors.primary.withValues(alpha: 0.12),
      child: Icon(fallbackIcon, color: colors.primary, size: 22.0),
    );
  }
}

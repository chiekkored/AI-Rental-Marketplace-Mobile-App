import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/presentation/pages/chat/widgets/chat_list.widget.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/enums/user_status.enum.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/timestamp.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class MessageItemW extends StatelessWidget {
  const MessageItemW({
    super.key,
    required this.chat,
    required this.participant,
  });

  final Chat chat;
  final SimpleUserModel? participant;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final participantName = LNDUtils.formatSimpleUserName(participant);
    final participantLabel = _participantLabel(
      participant,
      _privacyName(participantName),
    );

    if (!Platform.isIOS) {
      return _buildMessageTile(context, participant, participantLabel);
    }

    return CupertinoContextMenu.builder(
      enableHapticFeedback: true,
      actions: <Widget>[
        CupertinoContextMenuAction(
          onPressed: () {
            Get.back();
            MessagesController.instance.deleteChat(chat);
          },
          isDestructiveAction: true,
          trailingIcon: Icons.delete,
          child: LNDText.regular(text: 'Delete', color: colors.danger),
        ),
      ],
      builder: (_, animation) {
        // Use animation to determine which widget to show
        if (animation.value > 0.8) {
          // When context menu is more than half opened, show the ChatListW
          return Material(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTap: () {
                Get.back();
                MessagesController.instance.goToChatPage(chat);
              },
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  height: Get.height * 0.5,
                  width: Get.width * 0.9,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ChatListW(chat: chat),
                ),
              ),
            ),
          );
        } else {
          // Otherwise show the regular ListTile
          return _buildMessageTile(context, participant, participantLabel);
        }
      },
    );
  }

  Widget _buildMessageTile(
    BuildContext context,
    SimpleUserModel? participant,
    String participantLabel,
  ) {
    final colors = context.lndTheme;
    final isAssetOwner = chat.asset?.owner?.uid == AuthController.instance.uid;
    final roleLabel = isAssetOwner ? 'Renter' : 'Owner';
    final isSupport = chat.isLendSupportChatFor(AuthController.instance.uid);
    final isParticipantDeactivated =
        participant?.status == UserStatus.deactivated ||
        participant?.status == UserStatus.deleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      width: Get.width,
      height: 60.0,
      child: CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () => MessagesController.instance.goToChatPage(chat),
        leadingSize: 50.0,
        leading: SizedBox(
          height: 50.0,
          width: 50.0,
          child: Stack(
            children: [
              LNDImage.square(
                imageUrl:
                    isSupport
                        ? 'assets/generated/app_icon.png'
                        : chat.asset?.images.firstImageUrl,
              ),
              if (!isSupport &&
                  participant != null &&
                  !isParticipantDeactivated)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 25.0,
                    height: 25.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2.0),
                    ),
                    child: LNDImage.circle(
                      imageUrl: participant.photoUrl,
                      size: 20.0,
                      imageType: ImageType.user,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child:
                      (chat.hasRead ?? false)
                          ? LNDVerifiedName(
                            name: participantLabel,
                            verificationLevel:
                                isSupport ? null : participant?.verified,
                            showBusinessBadge:
                                !isSupport &&
                                participant?.hasDisplayName == true,
                            weight: LNDVerifiedNameWeight.medium,
                            badgeSize: 14.0,
                          )
                          : LNDVerifiedName(
                            name: participantLabel,
                            verificationLevel:
                                isSupport ? null : participant?.verified,
                            showBusinessBadge:
                                !isSupport &&
                                participant?.hasDisplayName == true,
                            weight: LNDVerifiedNameWeight.bold,
                            badgeSize: 14.0,
                          ),
                ),
              ],
            ),
          ),
        ),
        subtitle: Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child:
                (chat.hasRead ?? false)
                    ? LNDText.regular(
                      text: '',
                      textParts: [
                        if (chat.lastMessageSenderId ==
                            AuthController.instance.uid)
                          LNDText.regular(
                            text: 'You: ',
                            color: colors.textMuted,
                          ),
                        LNDText.regular(
                          text: chat.lastMessage ?? '',
                          color: colors.disabled,
                        ),
                      ],
                    )
                    : LNDText.bold(
                      text: '',
                      textParts: [
                        if (chat.lastMessageSenderId ==
                            AuthController.instance.uid)
                          LNDText.regular(
                            text: 'You: ',
                            color: colors.textMuted,
                          ),
                        LNDText.semibold(text: chat.lastMessage ?? ''),
                      ],
                    ),
          ),
        ),
        additionalInfo: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!isSupport)
              _RoleChip(label: roleLabel, isRenter: isAssetOwner)
            else
              const Text(''),
            LNDText.regular(
              text: chat.lastMessageDate?.toTimeAgo() ?? '',
              fontSize: 12.0,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  String _participantLabel(
    SimpleUserModel? participant,
    String participantName,
  ) {
    final isSupport = chat.isLendSupportChatFor(AuthController.instance.uid);
    if (isSupport) {
      return participantName.trim().isEmpty ? 'Lend Support' : participantName;
    }

    final startDate = chat.bookingStartDate;
    if (startDate == null) return participantName;

    final bookingDate = LNDUtils.bookingDateFromTimestamp(startDate);
    if (bookingDate == null) return participantName;

    return '${DateFormat('MMM d').format(bookingDate)} · $participantName';
  }

  String _privacyName(String participantName) {
    final isParticipantOwner = participant?.uid == chat.asset?.owner?.uid;
    final isBookingActive =
        chat.bookingStatus != null &&
            BookingStatus.active.contains(chat.bookingStatus) ||
        chat.bookingStatus == BookingStatus.completed;

    if (!isParticipantOwner || isBookingActive) return participantName;

    return participantName.toObscure();
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.isRenter});

  final String label;
  final bool isRenter;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final backgroundColor = isRenter ? colors.primarySoft : colors.infoSoft;
    final textColor = isRenter ? colors.primary : colors.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: LNDText.semibold(text: label, fontSize: 9.0, color: textColor),
    );
  }
}

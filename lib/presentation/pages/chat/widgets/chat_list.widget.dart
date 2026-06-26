import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/core/models/message.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/chat/chat_list.controller.dart';
import 'package:lend/presentation/controllers/damage_balance_payment/damage_balance_payment.controller.dart';
import 'package:lend/presentation/pages/photo_view/photo_view.page.dart';
import 'package:lend/presentation/pages/rating_review/rating_review.page.dart';
import 'package:lend/utilities/enums/message_type.enum.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/timestamp.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

class ChatListW extends StatelessWidget {
  final Chat chat;
  const ChatListW({super.key, required this.chat});

  // ────────────────────────────────────────────────────────────────
  // DATE SEPARATOR
  // ────────────────────────────────────────────────────────────────

  Widget? _buildDateSeparator(
    LNDTheme colors,
    int index,
    List<Message> messages,
  ) {
    final message = messages[index];
    if (message.createdAt == null) return null;

    if (index < messages.length - 1) {
      final currentDate = DateTime(
        message.createdAt!.toDate().year,
        message.createdAt!.toDate().month,
        message.createdAt!.toDate().day,
      );

      final next = messages[index + 1];
      if (next.createdAt == null) return null;

      final nextDate = DateTime(
        next.createdAt!.toDate().year,
        next.createdAt!.toDate().month,
        next.createdAt!.toDate().day,
      );

      if (currentDate != nextDate) {
        return _dateSeparator(colors, message.createdAt!);
      }
    } else {
      return _dateSeparator(colors, message.createdAt!);
    }

    return null;
  }

  Widget _dateSeparator(LNDTheme colors, Timestamp timestamp) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: LNDText.regular(
          text: timestamp.toFormattedString(),
          fontSize: 12,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // MESSAGE BUBBLE RENDERER
  // ────────────────────────────────────────────────────────────────

  Widget _buildMessageBubble(LNDTheme colors, Message m, bool isCurrentUser) {
    switch (m.type) {
      case MessageType.system:
        return _systemMessage(colors, m);

      case MessageType.rating:
        return _ratingMessage(colors, m);

      case MessageType.image:
        return _imageMessage(colors, m, isCurrentUser);

      default:
        return _textMessage(colors, m, isCurrentUser);
    }
  }

  // ────────────────────────────────────────────────────────────────
  // SYSTEM MESSAGE
  // ────────────────────────────────────────────────────────────────

  Widget _systemMessage(LNDTheme colors, Message m) {
    final isDamagePaymentRequest =
        m.systemAction == 'damage_balance_payment_request';
    final isPaid = m.paymentStatus == 'paid';
    final canPayDamageBalance =
        isDamagePaymentRequest &&
        !isPaid &&
        m.damagePaymentRequestId != null &&
        (m.amount ?? 0) > 0 &&
        AuthController.instance.uid == chat.renterId;
    return Container(
      width: Get.width * 0.7,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.textMuted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, size: 40, color: colors.info),
          if (m.createdAt != null) ...[
            const SizedBox(height: 8),
            LNDText.regular(
              text: m.createdAt.toFormattedStringWithTime(),
              fontSize: 12,
              textAlign: TextAlign.center,
              color: colors.textSecondary,
            ),
          ],
          const SizedBox(height: 8),
          LNDText.regular(
            text: m.text ?? '',
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
          ),
          if (canPayDamageBalance) ...[
            const SizedBox(height: 12),
            LNDButton.primary(
              text:
                  'Pay ${LNDMoney.format(m.amount, currencyCode: m.currency)}',
              enabled: true,
              onPressed: () {
                final bookingId = m.bookingId ?? chat.bookingId;
                final supportChatId = m.chatId ?? chat.chatId ?? chat.id;
                if (bookingId == null || supportChatId == null) return;
                LNDNavigate.toDamageBalancePaymentPage(
                  args: DamageBalancePaymentPageArgs(
                    chat: chat,
                    bookingId: bookingId,
                    chatId: supportChatId,
                    damagePaymentRequestId: m.damagePaymentRequestId!,
                    amount: m.amount!,
                    currency: m.currency ?? LNDMoney.currentCurrencyCode(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // RATING MESSAGE
  // ────────────────────────────────────────────────────────────────

  Widget _ratingMessage(LNDTheme colors, Message m) {
    // Get assetId, bookingId, and renterId directly from the Chat model
    final String? assetId = chat.asset?.id;
    final String? bookingId = chat.bookingId;
    final String? renterId = chat.renterId;

    if (assetId == null || bookingId == null || renterId == null) {
      return _systemMessage(colors, Message(text: 'Something went wrong'));
    }

    if (AuthController.instance.uid == renterId) {
      return Container(
        width: Get.width * 0.7,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.star_half, size: 40, color: colors.primary),
            const SizedBox(height: 8),
            LNDText.regular(
              text: m.text ?? '',
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            LNDButton.text(
              text: 'Rate Now',
              onPressed:
                  () => LNDNavigate.toRatingReviewPage(
                    args: RatingReviewArguments(
                      chatId: chat.chatId!,
                      assetId: assetId,
                      bookingId: bookingId,
                    ),
                  ),
              enabled: true,
              color: colors.primary,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ────────────────────────────────────────────────────────────────
  // IMAGE MESSAGE BUBBLE
  // ────────────────────────────────────────────────────────────────

  Widget _imageMessage(LNDTheme colors, Message m, bool isCurrentUser) {
    final imagePath = m.localFilePath ?? m.text ?? '';
    final isPending = m.isLocalOnly && m.isSending;
    final hasError = m.isLocalOnly && m.hasSendError;
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (m.isLocalOnly || imagePath.isEmpty) return;
            LNDNavigate.toPhotoViewPage(
              args: PhotoViewArguments(images: [imagePath], intialIndex: 0),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isPending || hasError ? 0.65 : 1,
                  child: LNDImage.custom(
                    imageUrl: imagePath,
                    height: 220,
                    width: 180,
                    borderRadius: 12,
                  ),
                ),
                if (isPending)
                  _imageSendingOverlay(colors, m.uploadProgress ?? 0),
                if (hasError) _imageFailedOverlay(colors),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: LNDText.regular(
            text:
                hasError
                    ? 'Failed'
                    : isPending
                    ? 'Sending...'
                    : m.createdAt?.toFormattedStringTimeOnly() ?? 'Sending...',
            fontSize: 10,
            color:
                hasError
                    ? colors.danger
                    : isCurrentUser
                    ? colors.textPrimary.withValues(alpha: 0.4)
                    : colors.textPrimary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _imageSendingOverlay(LNDTheme colors, double progress) {
    final normalizedProgress = progress <= 0 ? null : progress.clamp(0, 1);
    return Container(
      height: 220,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(
            value: normalizedProgress?.toDouble(),
            strokeWidth: 3,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _imageFailedOverlay(LNDTheme colors) {
    return Container(
      height: 220,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.error_outline_rounded,
          color: colors.danger,
          size: 36,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // TEXT MESSAGE BUBBLE
  // ────────────────────────────────────────────────────────────────

  Widget _textMessage(LNDTheme colors, Message m, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      constraints: BoxConstraints(maxWidth: Get.width * 0.7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? colors.primary.withValues(alpha: 1)
                : colors.textMuted.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.regular(
            isSelectable: true,
            text: m.text ?? '',
            color: isCurrentUser ? Colors.white : colors.textPrimary,
          ),
          const SizedBox(height: 4),
          LNDText.regular(
            text:
                m.createdAt?.toDate().toLocal().toHourMinuteAmPm() ??
                'Sending...',
            fontSize: 10,
            color: isCurrentUser ? Colors.white : colors.textPrimary,
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // MAIN BUILD
  // ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GetBuilder<ChatListController>(
      init: ChatListController(chat: chat),
      builder: (controller) {
        return PagingListener<int, Message>(
          controller: controller.pagingController,
          builder:
              (context, state, fetchNextPage) => PagedListView<int, Message>(
                state: state,
                fetchNextPage: fetchNextPage,
                reverse: true,
                builderDelegate: PagedChildBuilderDelegate<Message>(
                  firstPageProgressIndicatorBuilder:
                      (_) => const Center(child: LNDSpinner()),
                  newPageProgressIndicatorBuilder:
                      (_) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: LNDSpinner()),
                      ),
                  noItemsFoundIndicatorBuilder: (_) => const SizedBox.shrink(),
                  noMoreItemsIndicatorBuilder: (_) => const SizedBox.shrink(),
                  firstPageErrorIndicatorBuilder:
                      (_) => _messageLoadError(colors),
                  newPageErrorIndicatorBuilder:
                      (_) => _messageLoadError(colors),
                  itemBuilder: (_, message, index) {
                    final messages = controller.messagesFromState(state);
                    final isCurrentUser =
                        message.senderId == AuthController.instance.uid;

                    final dateSeparator =
                        message.type != MessageType.system
                            ? _buildDateSeparator(colors, index, messages)
                            : null;

                    return Column(
                      children: [
                        if (dateSeparator != null) dateSeparator,
                        Align(
                          alignment:
                              message.type == MessageType.system ||
                                      message.type == MessageType.rating
                                  ? Alignment.center
                                  : isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: _buildMessageBubble(
                            colors,
                            message,
                            isCurrentUser,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        );
      },
    );
  }

  Widget _messageLoadError(LNDTheme colors) {
    return Center(
      child: LNDText.regular(
        text: 'Unable to load messages.',
        color: colors.textMuted,
      ),
    );
  }
}

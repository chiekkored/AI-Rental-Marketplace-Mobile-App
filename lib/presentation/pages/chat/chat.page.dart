import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/booking.model.dart';
import 'package:lend/core/models/chat.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/chat/chat.controller.dart';
import 'package:lend/presentation/pages/chat/widgets/chat_list.widget.dart';
import 'package:lend/presentation/pages/chat/widgets/send_textfield.widget.dart';
import 'package:lend/utilities/extensions/booking_lifecycle.extension.dart';
import 'package:lend/utilities/extensions/list.extension.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class ChatPage extends GetView<ChatController> {
  static const String routeName = '/chat';
  const ChatPage({super.key});

  // Private method to build the chat input box
  Widget _buildChatBox(BuildContext context) {
    final colors = context.lndTheme;
    final booking = controller.booking;
    final isCurrentDay =
        booking != null &&
        booking.startDate != null &&
        booking.endDate != null &&
        LNDUtils.isTodayInRange(
          start: LNDUtils.bookingDateFromTimestamp(booking.startDate)!,
          end: LNDUtils.bookingDateFromTimestamp(booking.endDate)!,
        );

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            spacing: 4.0,
            children: [
              if (controller.isChatReadOnly)
                SizedBox(
                  height: kBottomNavigationBarHeight + 20.0,
                  width: double.infinity,
                  child: Center(
                    child: LNDText.regular(
                      text:
                          controller.isCancellationUnderReview
                              ? 'Cancellation request is under admin review.'
                              : controller.isLendSupportChat
                              ? 'This support chat is closed.'
                              : 'Booking has ended',
                      color: colors.textMuted,
                      fontSize: 12.0,
                      textAlign: TextAlign.center,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else ...[
                if (!controller.isLendSupportChat &&
                    booking != null &&
                    booking.canViewConfirmedOwnerInfo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Obx(
                      () =>
                          _buildBookingAction(controller.booking, isCurrentDay),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Builder(
                    builder: (context) {
                      return SendTextfieldW(
                        hintText: 'Type a message',
                        controller: controller.textController,
                        onSend: () => controller.sendMessage(),
                        onMore: controller.onTapMenu,
                        onFieldSubmitted: (_) => controller.sendMessage(),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingAction(Booking? booking, bool isCurrentDay) {
    if (booking == null) return const SizedBox.shrink();
    switch (booking.lifecyclePhase) {
      case BookingLifecyclePhase.confirmed:
        if (!isCurrentDay) return const SizedBox.shrink();
        return LNDButton.secondary(
          enabled: true,
          icon:
              controller.isOwner
                  ? Icons.qr_code_scanner_rounded
                  : Icons.camera_alt_rounded,
          iconSize: 15.0,
          hasPadding: false,
          text: 'Handed over?',
          borderRadius: 16.0,
          onPressed: controller.onTapHandedOver,
        );
      case BookingLifecyclePhase.handedOver:
        if (!isCurrentDay) return const SizedBox.shrink();
        return LNDButton.secondary(
          enabled: true,
          icon:
              controller.isOwner
                  ? Icons.camera_alt_rounded
                  : Icons.qr_code_scanner_rounded,
          iconSize: 15.0,
          hasPadding: false,
          text: 'Returned?',
          borderRadius: 16.0,
          onPressed: controller.onTapReturned,
        );
      case BookingLifecyclePhase.returned:
        if (booking.isAwaitingAdminSettlementReview) {
          return LNDWarningBanner(
            content: LNDText.regular(
              text: 'Damage review is pending Lend Support.',
              overflow: TextOverflow.visible,
            ),
          );
        }
        if (booking.isAwaitingOwnerSettlementAction && controller.isOwner) {
          return Row(
            children: [
              Expanded(
                child: LNDButton.primary(
                  enabled: true,
                  icon: Icons.check_circle_outline_rounded,
                  iconSize: 15.0,
                  hasPadding: false,
                  text: 'Complete rental',
                  borderRadius: 8.0,
                  onPressed: controller.onTapCompleteRental,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LNDButton.secondary(
                  enabled: true,
                  icon: Icons.report_problem_outlined,
                  iconSize: 15.0,
                  hasPadding: false,
                  text: 'Damage fees',
                  borderRadius: 8.0,
                  onPressed: controller.onTapRequestDamageDeduction,
                ),
              ),
            ],
          );
        } else if (booking.isAwaitingOwnerSettlementAction &&
            !controller.isOwner) {
          return LNDWarningBanner(
            content: LNDText.regular(
              text: 'Waiting for owner to complete the rental.',
              overflow: TextOverflow.visible,
            ),
          );
        }
        if (booking.hasDamageDeductionRequest && controller.isOwner) {
          return LNDWarningBanner(
            content: LNDText.regular(
              text:
                  'Waiting for renter response to the damage deduction request.',
              overflow: TextOverflow.visible,
            ),
          );
        }
        if (booking.hasDamageDeductionRequest && !controller.isOwner) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: LNDButton.primary(
                  enabled: true,
                  icon: Icons.check_rounded,
                  iconSize: 15.0,
                  hasPadding: false,
                  text: _acceptDamageDeductionText(booking),
                  borderRadius: 8.0,
                  onPressed: controller.onTapAcceptDamageDeduction,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: LNDButton.secondary(
                  enabled: true,
                  icon: Icons.close_rounded,
                  iconSize: 15.0,
                  hasPadding: false,
                  text: 'Dispute',
                  borderRadius: 8.0,
                  onPressed: controller.onTapDisputeDamageDeduction,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  String _acceptDamageDeductionText(Booking booking) {
    final requestedAmount =
        booking.depositFlow?.requestedDeductionAmount ??
        booking.disputeFlow?.requestedAmount;
    if (requestedAmount is! num || requestedAmount <= 0) {
      return 'Accept deduction';
    }

    final amount = LNDMoney.formatRate(requestedAmount, booking.asset?.rates);
    return amount.isEmpty ? 'Accept deduction' : 'Accept $amount deduction';
  }

  Widget _buildBottomAppbar(BuildContext context, Chat chat) {
    if (controller.isLendSupportChat) return const SizedBox.shrink();
    final colors = context.lndTheme;
    final isOwner = chat.asset?.owner?.uid == AuthController.instance.uid;

    return Obx(() {
      if (controller.booking != null) {
        final booking = controller.booking;

        return SizedBox(
          height: kToolbarHeight,
          child: GestureDetector(
            onTap: controller.goToBookingDetails,
            child: Container(
              color: colors.outline,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      spacing: 4.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            LNDImage.square(
                              imageUrl: chat.asset?.images.firstImageUrl,
                              size: 40.0,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LNDText.medium(
                                    text: chat.asset?.title ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  LNDText.regular(
                                    text: LNDUtils.getDateRange(
                                      start: LNDUtils.bookingDateFromTimestamp(
                                        booking?.startDate,
                                      ),
                                      end: LNDUtils.bookingDateFromTimestamp(
                                        booking?.endDate,
                                      ),
                                    ),
                                    maxLines: 1,
                                    fontSize: 12.0,
                                    color: colors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Visibility(
                    visible: isOwner && (booking?.canAccept ?? false),
                    child: LNDButton.primary(
                      text: 'Accept',
                      enabled: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 8.0,
                      ),
                      onPressed: controller.onTapAccept,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final chat = controller.chat;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          leading: LNDButton.back(),
          automaticallyImplyLeading: false,
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          title: Obx(() {
            final recipientUser = controller.recepientUser;
            final booking = controller.booking;
            final isSupport = controller.isLendSupportChat;

            final recipientName = LNDUtils.formatSimpleUserName(recipientUser);

            final shouldObscureName = LNDUtils.canShowName(
              recipientUser?.uid,
              chat.asset?.owner?.uid,
              booking,
            );

            final displayName =
                isSupport
                    ? 'Lend Support'
                    : shouldObscureName
                    ? recipientName.toObscure()
                    : recipientName;

            return LNDVerifiedName(
              name: displayName,
              verificationLevel: isSupport ? null : recipientUser?.verified,
              showBusinessBadge:
                  !isSupport && recipientUser?.hasDisplayName == true,
              fontSize: 18.0,
              badgeSize: 16.0,
            );
          }),
          actionsPadding: const EdgeInsets.only(right: 24.0),
          actions: [
            Obx(() {
              if (controller.booking == null) return const SizedBox.shrink();
              if (controller.isLendSupportChat) return const SizedBox.shrink();

              return LNDButton.icon(
                icon: Icons.info_outline_rounded,
                size: 25.0,
                color: colors.textPrimary,
                onPressed: controller.viewBookingInfo,
              );
            }),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ChatListW(chat: chat),
                  _buildBottomAppbar(context, chat),
                ],
              ),
            ),
            Obx(() => _buildChatBox(context)),
          ],
        ),
      ),
    );
  }
}

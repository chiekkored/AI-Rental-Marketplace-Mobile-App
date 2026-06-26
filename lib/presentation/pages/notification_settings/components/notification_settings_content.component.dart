import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/notification_settings/notification_settings.controller.dart';
import 'package:lend/presentation/pages/notification_settings/widgets/notification_info_tile.widget.dart';
import 'package:lend/presentation/pages/notification_settings/widgets/notification_switch_tile.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class NotificationSettingsContent
    extends GetView<NotificationSettingsController> {
  const NotificationSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      children: [
        const _SectionHeader('Delivery'),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push notifications',
            subtitle: 'Receive alerts on this device.',
            value: controller.pushEnabled,
            onChanged: controller.isSaving ? null : controller.setPushEnabled,
          ),
        ),
        const NotificationInfoTile(
          icon: Icons.inbox_outlined,
          title: 'In-app notification center',
          subtitle: 'Always on for booking, listing, and account records.',
          trailingText: 'Always on',
        ),
        const SizedBox(height: 12.0),
        const _SectionHeader('Push Notifications'),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Messages',
            subtitle: 'Chat and support message alerts.',
            value: controller.messagesPushEnabled,
            onChanged:
                controller.pushEnabled && !controller.isSaving
                    ? controller.setMessagesPushEnabled
                    : null,
          ),
        ),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.calendar_month_outlined,
            title: 'Bookings and rentals',
            subtitle: 'Booking requests, confirmations, and cancellations.',
            value: controller.bookingsPushEnabled,
            onChanged:
                controller.pushEnabled && !controller.isSaving
                    ? controller.setBookingsPushEnabled
                    : null,
          ),
        ),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payments and payouts',
            subtitle: 'Deposit, refund, damage, payout, and payment updates.',
            value: controller.paymentsPushEnabled,
            onChanged:
                controller.pushEnabled && !controller.isSaving
                    ? controller.setPaymentsPushEnabled
                    : null,
          ),
        ),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.inventory_2_outlined,
            title: 'Listings',
            subtitle: 'Listing review, moderation, and deactivation updates.',
            value: controller.listingsPushEnabled,
            onChanged:
                controller.pushEnabled && !controller.isSaving
                    ? controller.setListingsPushEnabled
                    : null,
          ),
        ),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.verified_user_outlined,
            title: 'Verification and business registration',
            subtitle: 'Verification and business compliance updates.',
            value: controller.verificationPushEnabled,
            onChanged:
                controller.pushEnabled && !controller.isSaving
                    ? controller.setVerificationPushEnabled
                    : null,
          ),
        ),
        const SizedBox(height: 12.0),
        const _SectionHeader('Email Updates'),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.event_note_outlined,
            title: 'Booking emails',
            subtitle: 'Booking requests, confirmations, and cancellations.',
            value: controller.bookingEmailsEnabled,
            onChanged:
                controller.isSaving ? null : controller.setBookingEmailsEnabled,
          ),
        ),
        Obx(
          () => NotificationSwitchTile(
            icon: Icons.payments_outlined,
            title: 'Payment and payout emails',
            subtitle: 'Receipts, refunds, payment failures, and payouts.',
            value: controller.paymentEmailsEnabled,
            onChanged:
                controller.isSaving ? null : controller.setPaymentEmailsEnabled,
          ),
        ),
        const NotificationInfoTile(
          icon: Icons.security_outlined,
          title: 'Safety and account emails',
          subtitle:
              'Important account, safety, verification, and legal emails are always sent when required.',
          trailingText: 'Required',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 6.0),
      child: LNDText.semibold(
        text: title,
        color: colors.textMuted,
        fontSize: 12.0,
      ),
    );
  }
}

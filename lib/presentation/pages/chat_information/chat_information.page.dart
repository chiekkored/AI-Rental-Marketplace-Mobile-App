import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/chat_information/chat_information.controller.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class ChatInformationPage extends GetView<ChatInformationController> {
  static const routeName = '/chat-information';
  const ChatInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: LNDButton.back(),
        title: LNDText.regular(text: 'Information', fontSize: 18.0),
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
      ),
      body: SafeArea(
        child: Obx(() {
          controller.booking;
          final participant = controller.participant;
          final fullName = LNDUtils.formatSimpleUserName(participant);

          final shouldObscureName = LNDUtils.canShowName(
            participant?.uid,
            controller.chat.asset?.owner?.uid,
            controller.booking,
          );

          final displayName =
              shouldObscureName ? fullName.toObscure() : fullName;
          final locationText = LNDUtils.getLocationText(
            location: controller.chat.asset?.location,
            showFullAddress: controller.canViewActiveOwnerInfo,
          );

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  spacing: 12.0,
                  children: [
                    LNDImage.circle(
                      imageUrl: participant?.photoUrl,
                      size: 96.0,
                      imageType: ImageType.user,
                    ),
                    LNDVerifiedName(
                      name: displayName,
                      verificationLevel: participant?.verified,
                      showBusinessBadge: participant?.hasDisplayName == true,
                      fontSize: 20.0,
                      weight: LNDVerifiedNameWeight.bold,
                      mainAxisAlignment: MainAxisAlignment.center,
                      badgeSize: 16.0,
                    ),
                    if (controller.hasBlockedParticipant) const _BlockedChip(),
                  ],
                ),
              ),
              if (locationText.isNotEmpty &&
                  // is participant the owner
                  participant?.uid == controller.chat.asset?.owner?.uid) ...[
                const SizedBox(height: 24.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 16.0,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.locationDot,
                          color: colors.outline,
                          size: 20.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: LNDText.regular(
                            text: locationText,
                            overflow: TextOverflow.visible,
                            isSelectable: true,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 100.0,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Obx(
                          () => GoogleMap(
                            buildingsEnabled: false,
                            initialCameraPosition: controller.cameraPosition,
                            onMapCreated: controller.onMapCreated,
                            circles: controller.circles.toSet(),
                            markers: controller.markers.toSet(),
                            myLocationButtonEnabled: false,
                            zoomGesturesEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomControlsEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationEnabled: false,
                            tiltGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (controller.canViewActiveOwnerInfo) ...[
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: LNDButton.secondary(
                        enabled: controller.canStartHandover,
                        icon:
                            controller.isOwner
                                ? Icons.qr_code_scanner_rounded
                                : Icons.camera_alt_rounded,
                        iconSize: 15.0,
                        text: 'Handed over?',
                        borderRadius: 8.0,
                        onPressed: controller.onTapHandedOver,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: LNDButton.secondary(
                        enabled: controller.canStartReturn,
                        icon:
                            controller.isOwner
                                ? Icons.camera_alt_rounded
                                : Icons.qr_code_scanner_rounded,
                        iconSize: 15.0,
                        text: 'Returned?',
                        borderRadius: 8.0,
                        onPressed: controller.onTapReturned,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24.0),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.receipt_long_outlined,
                      text: 'View booking',
                      color:
                          controller.booking != null
                              ? colors.textPrimary
                              : colors.disabled,
                      onTap:
                          controller.booking != null
                              ? controller.viewBooking
                              : null,
                    ),
                    _ActionRow(
                      icon: Icons.person_outline_rounded,
                      text: 'View listing',
                      color:
                          controller.chat.asset?.id.isNotEmpty == true
                              ? colors.textPrimary
                              : colors.disabled,
                      onTap:
                          controller.chat.asset?.id.isNotEmpty == true
                              ? controller.viewLiveListing
                              : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              if (controller.canRequestBookingCancellation)
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _ActionRow(
                    icon: Icons.event_busy_rounded,
                    text: 'Request Cancellation',
                    color: colors.danger,
                    onTap: controller.requestBookingCancellation,
                  ),
                ),
              const SizedBox(height: 12.0),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.flag_outlined,
                      text: 'Report',
                      color: colors.textPrimary,
                      onTap: controller.report,
                    ),
                    if (controller.canBlockParticipant) ...[
                      _ActionRow(
                        icon: Icons.block_rounded,
                        text: 'Block user',
                        color: colors.danger,
                        onTap: controller.blockUser,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _ActionRow(
                  icon: Icons.delete_outline_rounded,
                  text: 'Delete Chat',
                  color: colors.danger,
                  onTap: controller.deleteChat,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.text,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22.0),
            const SizedBox(width: 12.0),
            Expanded(child: LNDText.medium(text: text, color: color)),
            Icon(Icons.chevron_right_rounded, color: color, size: 22.0),
          ],
        ),
      ),
    );
  }
}

class _BlockedChip extends StatelessWidget {
  const _BlockedChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LNDText.bold(
        text: 'BLOCKED',
        fontSize: 11.0,
        color: colors.danger,
      ),
    );
  }
}

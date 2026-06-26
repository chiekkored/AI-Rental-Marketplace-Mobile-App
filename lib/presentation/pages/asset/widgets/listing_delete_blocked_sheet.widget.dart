import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/asset.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum ListingDeleteBlockedAction { hide, requestReview, underMaintenance }

class ListingDeleteBlockedSheet extends StatelessWidget {
  const ListingDeleteBlockedSheet({required this.eligibility, super.key});

  final ListingDeletionEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final count = eligibility.blockingBookingCount;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        shrinkWrap: true,
        children: [
          LNDText.bold(text: 'Listing cannot be deleted', fontSize: 18),
          const SizedBox(height: 8),
          LNDText.regular(
            text:
                'This listing has $count upcoming booking${count == 1 ? '' : 's'}. You need to honor bookings that were already paid unless you cancel them one by one.',
            color: colors.textSecondary,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 16),
          LNDText.regular(
            text:
                'You can set the listing under maintenance or hide it from public browsing so no new bookings are created.',
            color: colors.textSecondary,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 16),
          LNDButton.primary(
            text: 'Set under maintenance',
            enabled: true,
            onPressed:
                () => Get.back(
                  result: ListingDeleteBlockedAction.underMaintenance,
                ),
          ),
          const SizedBox(height: 8),
          LNDButton.outlined(
            text: 'Hide listing',
            enabled: true,
            onPressed: () => Get.back(result: ListingDeleteBlockedAction.hide),
          ),
          const SizedBox(height: 20),
          LNDText.regular(
            text:
                'If the unit is totally damaged or this is a verified damage / force majeure case, request an admin review. If approved, Lend Support will cancel upcoming bookings and start full refund handling.',
            color: colors.textSecondary,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 8),
          LNDButton.text(
            text: 'Request review for deactivation',
            enabled: true,
            isBold: true,
            onPressed:
                () =>
                    Get.back(result: ListingDeleteBlockedAction.requestReview),
          ),
        ],
      ),
    );
  }
}

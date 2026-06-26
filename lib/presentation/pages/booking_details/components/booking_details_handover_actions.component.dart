import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';

class BookingDetailsHandoverActions extends GetView<BookingDetailsController> {
  const BookingDetailsHandoverActions({super.key});

  @override
  Widget build(BuildContext context) {
    if (!controller.canViewConfirmedOwnerInfo) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
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
    );
  }
}

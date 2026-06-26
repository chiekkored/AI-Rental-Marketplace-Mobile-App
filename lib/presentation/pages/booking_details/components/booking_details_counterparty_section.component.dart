import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';
import 'package:lend/presentation/pages/booking_details/widgets/booking_details_info_section.widget.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';

class BookingDetailsCounterpartySection
    extends GetWidget<BookingDetailsController> {
  const BookingDetailsCounterpartySection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.counterparty;

    return BookingDetailsInfoSection(
      title: controller.isOwner ? 'Renter' : 'Owner',
      child: Row(
        children: [
          LNDImage.circle(
            imageUrl: user?.photoUrl,
            size: 44.0,
            imageType: ImageType.user,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: LNDVerifiedName(
              name: controller.displayCounterpartyName,
              verificationLevel: user?.verified,
              showBusinessBadge: user?.hasDisplayName == true,
              weight: LNDVerifiedNameWeight.bold,
              badgeSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}

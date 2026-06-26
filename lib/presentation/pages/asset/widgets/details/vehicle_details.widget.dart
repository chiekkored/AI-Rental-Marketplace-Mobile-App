import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_chip.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_item.widget.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class VehicleAssetDetails extends StatelessWidget {
  const VehicleAssetDetails({super.key, required this.details});

  final VehicleListingDetails details;

  @override
  Widget build(BuildContext context) {
    final makeModel = [
      details.make,
      details.model,
    ].map((item) => item.trim()).where((item) => item.isNotEmpty).join(' ');
    final chips =
        [
          if (details.year != null) details.year.toString(),
          if (details.transmission.trim().isNotEmpty)
            readableDetailValue(details.transmission),
          if (details.fuelType.trim().isNotEmpty)
            readableDetailValue(details.fuelType),
          positiveIntLabel(details.seats, 'seat'),
          if (details.mileageLimitKmPerDay != null &&
              details.mileageLimitKmPerDay! > 0)
            '${details.mileageLimitKmPerDay} km/day',
        ].whereType<String>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (makeModel.isNotEmpty)
          AssetDetailItem(
            icon: FontAwesomeIcons.carSide,
            title: makeModel,
            subtitle: 'Vehicle',
          ),
        if (chips.isNotEmpty)
          AssetDetailChipWrap(
            children:
                chips.map((chip) => AssetDetailTextChip(label: chip)).toList(),
          ),
        AssetDetailFlag(
          enabled: details.licenseRequired,
          text: 'License required',
        ),
        AssetDetailFlag(enabled: details.helmetIncluded, text: 'Helmet'),
        AssetDetailFlag(enabled: details.deliveryAvailable, text: 'Delivery'),
      ],
    ).withSpacing(16.0);
  }
}

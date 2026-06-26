import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_chip.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_item.widget.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class ToolAssetDetails extends StatelessWidget {
  const ToolAssetDetails({super.key, required this.details});

  final ToolListingDetails details;

  @override
  Widget build(BuildContext context) {
    final brandModel = [
      details.brand,
      details.model,
    ].map((item) => item.trim()).where((item) => item.isNotEmpty).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brandModel.isNotEmpty)
          AssetDetailItem(
            icon: FontAwesomeIcons.screwdriverWrench,
            title: brandModel,
            subtitle: 'Tool',
          ),
        AssetDetailChipWrap(
          children: [
            AssetDetailTextChip(
              label: readableDetailValue(details.powerSource),
              icon: FontAwesomeIcons.plug,
            ),
            AssetDetailTextChip(
              label: readableDetailValue(details.skillLevel),
              icon: FontAwesomeIcons.userGear,
            ),
          ],
        ),
        AssetDetailFlag(
          enabled: details.safetyGearRequired,
          text: 'Safety gear required',
        ),
        AssetDetailFlag(
          enabled: details.consumablesIncluded,
          text: 'Consumables included',
        ),
      ],
    ).withSpacing(16.0);
  }
}

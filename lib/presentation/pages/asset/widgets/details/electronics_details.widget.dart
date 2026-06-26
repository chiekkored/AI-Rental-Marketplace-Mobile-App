import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_item.widget.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class ElectronicsAssetDetails extends StatelessWidget {
  const ElectronicsAssetDetails({super.key, required this.details});

  final ElectronicsListingDetails details;

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
            icon: FontAwesomeIcons.microchip,
            title: brandModel,
            subtitle: 'Electronics',
          ),
        AssetDetailFlag(enabled: details.batteryIncluded, text: 'Battery'),
        AssetDetailFlag(enabled: details.chargerIncluded, text: 'Charger'),
        if (nonEmptyText(details.compatibilityNote) != null)
          AssetDetailNote(
            icon: FontAwesomeIcons.link,
            title: 'Compatibility',
            text: details.compatibilityNote,
          ),
        if (nonEmptyText(details.specsNote) != null)
          AssetDetailNote(
            icon: FontAwesomeIcons.clipboardList,
            title: 'Specifications',
            text: details.specsNote,
          ),
      ],
    ).withSpacing(16.0);
  }
}

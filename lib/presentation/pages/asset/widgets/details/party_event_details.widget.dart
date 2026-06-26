import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_chip.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_item.widget.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class PartyEventAssetDetails extends StatelessWidget {
  const PartyEventAssetDetails({super.key, required this.details});

  final PartyEventListingDetails details;

  @override
  Widget build(BuildContext context) {
    final chips =
        [
          positiveIntLabel(details.quantity, 'piece'),
          nonEmptyText(details.setSize),
          if (details.indoorOutdoor.trim().isNotEmpty)
            readableDetailValue(details.indoorOutdoor),
        ].whereType<String>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chips.isNotEmpty)
          AssetDetailChipWrap(
            children:
                chips.map((chip) => AssetDetailTextChip(label: chip)).toList(),
          ),
        AssetDetailFlag(enabled: details.setupRequired, text: 'Setup required'),
        AssetDetailFlag(
          enabled: details.deliveryRequired,
          text: 'Delivery required',
        ),
        AssetDetailFlag(enabled: details.powerRequired, text: 'Power required'),
        if (nonEmptyText(details.setupInstructions) != null)
          AssetDetailNote(
            icon: FontAwesomeIcons.clipboardCheck,
            title: 'Setup instructions',
            text: details.setupInstructions,
          ),
      ],
    ).withSpacing(16.0);
  }
}

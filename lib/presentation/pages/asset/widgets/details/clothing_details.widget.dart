import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_chip.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_item.widget.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class ClothingAssetDetails extends StatelessWidget {
  const ClothingAssetDetails({super.key, required this.details});

  final ClothingListingDetails details;

  @override
  Widget build(BuildContext context) {
    final brand = nonEmptyText(details.brand);
    final chips =
        [
          nonEmptyText(details.size) == null ? null : 'Size ${details.size}',
          nonEmptyText(details.fit) == null
              ? null
              : readableDetailValue(details.fit),
          nonEmptyText(details.color),
          nonEmptyText(details.occasion) == null
              ? null
              : readableDetailValue(details.occasion),
        ].whereType<String>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brand != null)
          AssetDetailItem(
            icon: FontAwesomeIcons.shirt,
            title: brand,
            subtitle: 'Brand',
          ),
        if (chips.isNotEmpty)
          AssetDetailChipWrap(
            children:
                chips.map((chip) => AssetDetailTextChip(label: chip)).toList(),
          ),
        if (nonEmptyText(details.cleaningPolicy) != null)
          AssetDetailItem(
            icon: FontAwesomeIcons.soap,
            title: readableDetailValue(details.cleaningPolicy),
            subtitle: 'Cleaning policy',
          ),
        if (nonEmptyText(details.measurementsNote) != null)
          AssetDetailNote(
            icon: FontAwesomeIcons.rulerCombined,
            title: 'Measurements',
            text: details.measurementsNote,
          ),
      ],
    ).withSpacing(16.0);
  }
}

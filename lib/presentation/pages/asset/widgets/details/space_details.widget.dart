import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_chip.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_item.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class SpaceAssetDetails extends StatelessWidget {
  const SpaceAssetDetails({super.key, required this.details});

  final SpaceListingDetails details;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (positiveIntLabel(details.capacity, 'guest') != null)
        AssetDetailItem(
          icon: FontAwesomeIcons.users,
          title: positiveIntLabel(details.capacity, 'guest')!,
          subtitle: 'Capacity',
        ),
      if (details.allowedUses.isNotEmpty)
        _TextChipGroup(title: 'Allowed uses', values: details.allowedUses),
      if (details.amenities.isNotEmpty)
        _AmenityGroup(title: 'Amenities', amenityIds: details.amenities),
      AssetDetailFlag(enabled: details.hasParking, text: 'Parking'),
      if (minutesLabel(details.setupTimeMinutes, 'Setup time') != null)
        AssetDetailItem(
          icon: FontAwesomeIcons.stopwatch,
          title: minutesLabel(details.setupTimeMinutes, 'Setup time')!,
        ),
      if (minutesLabel(details.cleanupTimeMinutes, 'Cleanup time') != null)
        AssetDetailItem(
          icon: FontAwesomeIcons.broom,
          title: minutesLabel(details.cleanupTimeMinutes, 'Cleanup time')!,
        ),
      if (details.operatingHours != null)
        _TimeRangeItem(
          title: 'Operating hours',
          range: details.operatingHours!,
        ),
      if (details.noiseRestrictions != null)
        _TimeRangeItem(
          title: 'Noise restrictions',
          range: details.noiseRestrictions!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ).withSpacing(16.0);
  }
}

class _TextChipGroup extends StatelessWidget {
  const _TextChipGroup({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LNDText.medium(text: title, color: colors.textMuted),
        AssetDetailChipWrap(
          children:
              values
                  .map(
                    (value) =>
                        AssetDetailTextChip(label: readableDetailValue(value)),
                  )
                  .toList(),
        ),
      ],
    ).withSpacing(8.0);
  }
}

class _AmenityGroup extends StatelessWidget {
  const _AmenityGroup({required this.title, required this.amenityIds});

  final String title;
  final List<String> amenityIds;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LNDText.medium(text: title, color: colors.textMuted),
        AssetDetailChipWrap(
          children:
              amenityIds
                  .map((amenityId) => AssetAmenityChip(amenityId: amenityId))
                  .toList(),
        ),
      ],
    ).withSpacing(8.0);
  }
}

class _TimeRangeItem extends StatelessWidget {
  const _TimeRangeItem({required this.title, required this.range});

  final String title;
  final ListingTimeRange range;

  @override
  Widget build(BuildContext context) {
    final timeText =
        range.enabled
            ? [
              range.startTime,
              range.endTime,
            ].where((time) => time.trim().isNotEmpty).join(' - ')
            : 'Not set';

    return AssetDetailItem(
      icon: FontAwesomeIcons.clock,
      title: title,
      subtitle: timeText.isEmpty ? 'Available on request' : timeText,
    );
  }
}

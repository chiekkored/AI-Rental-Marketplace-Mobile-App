import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_chip.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_item.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';
import 'package:lend/utilities/enums/listing_details.enum.dart';
import 'package:pluralize/pluralize.dart';

class StayAssetDetails extends StatelessWidget {
  const StayAssetDetails({super.key, required this.details});

  final StayListingDetails details;
  static const double _padding = 16.0;
  static const double _spacing = 16.0;

  @override
  Widget build(BuildContext context) {
    final stayType = StayType.fromValue(details.stayType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildChildren(stayType),
    ).withSpacing(_spacing);
  }

  List<_StayCountItem> _buildCountItems() {
    return [
      _StayCountItem(
        icon: Icons.groups_2_outlined,
        count: details.maxGuests,
        label: 'Guest',
      ),
      _StayCountItem(
        icon: Icons.door_front_door_outlined,
        count: details.bedrooms,
        label: 'Bedroom',
      ),
      _StayCountItem(
        icon: Icons.single_bed_outlined,
        count: details.beds,
        label: 'Bed',
      ),
      _StayCountItem(
        icon: Icons.shower_outlined,
        count: details.bathrooms,
        label: 'Bathroom',
      ),
    ].where((item) => item.count != null && item.count! > 0).toList();
  }

  List<Widget> _buildChildren(StayType stayType) {
    final countItems = _buildCountItems();

    return [
      _buildSectionHeader('What will you get'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padding),
        child: AssetDetailItem(icon: stayType.icon, title: stayType.label),
      ),
      if (countItems.isNotEmpty) _StayCountCardScroller(items: countItems),
      ..._buildCheckInOutItems(),
      if (details.amenities.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _padding),
          child: _AmenityGroup(
            title: 'Amenities',
            amenityIds: details.amenities,
          ),
        ),
      _buildSectionHeader('Rules'),
      ..._buildRuleItems(),
    ];
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _padding),
      child: Builder(
        builder:
            (context) =>
                LNDText.medium(text: title, color: context.lndTheme.textMuted),
      ),
    );
  }

  List<Widget> _buildCheckInOutItems() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padding),
        child: AssetDetailItem(
          icon: Icons.access_time_rounded,
          title: 'Check-in ${details.checkInTime}',
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padding),
        child: AssetDetailItem(
          icon: Icons.access_time_rounded,
          title: 'Check-out ${details.checkOutTime}',
        ),
      ),
    ];
  }

  List<Widget> _buildRuleItems() {
    return [
      _buildRuleItem(
        icon: Icons.pets_outlined,
        title: details.petsAllowed ? 'Pets allowed' : 'No pets allowed',
      ),
      _buildRuleItem(
        icon:
            details.smokingAllowed
                ? Icons.smoking_rooms_outlined
                : Icons.smoke_free_outlined,
        title:
            details.smokingAllowed ? 'Smoking allowed' : 'No smoking allowed',
      ),
      _buildRuleItem(
        icon: Icons.celebration,
        title:
            details.partiesAllowed ? 'Parties allowed' : 'No parties allowed',
      ),
    ];
  }

  Widget _buildRuleItem({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _padding),
      child: AssetDetailItem(icon: icon, title: title),
    );
  }
}

class _StayCountItem {
  const _StayCountItem({
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final int? count;
  final String label;
}

class _StayCountCardScroller extends StatelessWidget {
  const _StayCountCardScroller({required this.items});

  final List<_StayCountItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        separatorBuilder: (_, __) => const SizedBox(width: 10.0),
        itemBuilder: (_, index) => _StayCountCard(item: items[index]),
      ),
    );
  }
}

class _StayCountCard extends StatelessWidget {
  const _StayCountCard({required this.item});

  final _StayCountItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      width: 135.0,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(item.icon, color: colors.primary, size: 32.0),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8.0,
            children: [
              LNDText.bold(text: item.count.toString(), fontSize: 16.0),
              LNDText.regular(
                text: Pluralize().pluralize(item.label, item.count ?? 1, false),
                // color: colors.textMuted,
                fontSize: 14.0,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ],
      ),
    );
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

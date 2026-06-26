import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/amenity.model.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/amenity/amenity.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/amenity_selector_helpers.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/amenity_icon.helper.dart';

class CreateListingAmenitySelector extends StatefulWidget {
  const CreateListingAmenitySelector({
    super.key,
    required this.detailSchemaKey,
    required this.selectedValues,
    required this.onChanged,
  });

  final String detailSchemaKey;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  @override
  State<CreateListingAmenitySelector> createState() =>
      _CreateListingAmenitySelectorState();
}

class _CreateListingAmenitySelectorState
    extends State<CreateListingAmenitySelector> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(() {
      final controller = AmenityController.instance;
      final amenities = controller.amenitiesForDetailSchemaKey(
        widget.detailSchemaKey,
      );
      final selectedIds = normalizeSelectedAmenityValues(
        amenities,
        widget.selectedValues,
      );
      _syncSelectedIds(selectedIds);
      final filteredAmenities = filterAmenityOptions(amenities, _query);
      final amenityGroups = groupAmenityOptions(filteredAmenities);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDTextField.regular(
            controller: _searchController,
            hintText: 'Search amenities',
            prefixIcon: Icons.search_rounded,
            suffixIcon: _query.trim().isEmpty ? null : Icons.cancel_rounded,
            onTapSuffix: _searchController.clear,
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 14),
          if (controller.isLoading.value && amenities.isEmpty)
            _AmenityStateMessage(
              text: 'Loading amenities...',
              icon: Icons.hourglass_empty_rounded,
              color: colors.textMuted,
            )
          else if (controller.errorMessage.value.isNotEmpty &&
              amenities.isEmpty)
            _AmenityStateMessage(
              text: controller.errorMessage.value,
              icon: Icons.error_outline_rounded,
              color: colors.danger,
            )
          else if (amenities.isEmpty)
            _AmenityStateMessage(
              text: 'No amenities are available for this listing type.',
              icon: Icons.info_outline_rounded,
              color: colors.textMuted,
            )
          else if (filteredAmenities.isEmpty)
            _AmenityStateMessage(
              text: 'No amenities match your search.',
              icon: Icons.search_off_rounded,
              color: colors.textMuted,
            )
          else
            Column(
              children: [
                for (var index = 0; index < amenityGroups.length; index++) ...[
                  if (index > 0) const SizedBox(height: 18),
                  _AmenityGroupSection(
                    group: amenityGroups[index],
                    selectedIds: selectedIds,
                    onChanged: widget.onChanged,
                  ),
                ],
              ],
            ),
        ],
      );
    });
  }

  void _syncSelectedIds(List<String> selectedIds) {
    if (_listEquals(selectedIds, widget.selectedValues)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(selectedIds);
    });
  }
}

class _AmenityGroupSection extends StatelessWidget {
  const _AmenityGroupSection({
    required this.group,
    required this.selectedIds,
    required this.onChanged,
  });

  final AmenityGroup group;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LNDText.semibold(
          text: group.label,
          textAlign: TextAlign.start,
          fontSize: 16.0,
        ),
        const SizedBox(height: 10),
        GridView.builder(
          itemCount: group.amenities.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final amenity = group.amenities[index];
            return _AmenitySelectionCard(
              amenity: amenity,
              selected: selectedIds.contains(amenity.id),
              onTap:
                  () => onChanged(
                    toggleAmenitySelection(selectedIds, amenity.id),
                  ),
            );
          },
        ),
      ],
    );
  }
}

class _AmenitySelectionCard extends StatelessWidget {
  const _AmenitySelectionCard({
    required this.amenity,
    required this.selected,
    required this.onTap,
  });

  final Amenity amenity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final amenityIcon = amenityIconFromKey(amenity.iconKey);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              selected
                  ? colors.primary.withValues(alpha: 0.08)
                  : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? colors.primary : colors.outline),
        ),
        child: Stack(
          children: [
            if (selected)
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 18,
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    amenityIcon.icon,
                    color: selected ? colors.primary : colors.textMuted,
                    size: amenityIcon.size,
                  ),
                  const SizedBox(height: 8),
                  LNDText.medium(
                    text: amenity.label,
                    fontSize: 13,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmenityStateMessage extends StatelessWidget {
  const _AmenityStateMessage({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: context.lndTheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: LNDText.regular(
              text: text,
              color: color,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

bool _listEquals(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

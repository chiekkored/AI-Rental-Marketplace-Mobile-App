import 'package:lend/core/models/amenity.model.dart';

class AmenityGroup {
  const AmenityGroup({required this.label, required this.amenities});

  final String label;
  final List<Amenity> amenities;
}

List<Amenity> filterAmenityOptions(List<Amenity> amenities, String query) {
  final normalizedQuery = _normalize(query);
  if (normalizedQuery.isEmpty) return amenities;

  return amenities
      .where((amenity) => amenitySearchText(amenity).contains(normalizedQuery))
      .toList(growable: false);
}

List<AmenityGroup> groupAmenityOptions(List<Amenity> amenities) {
  final groups = <AmenityGroup>[];
  final groupIndexes = <String, int>{};

  for (final amenity in amenities) {
    final label = amenityGroupLabel(amenity.group);
    final key = label.toLowerCase();
    final groupIndex = groupIndexes[key];

    if (groupIndex == null) {
      groupIndexes[key] = groups.length;
      groups.add(AmenityGroup(label: label, amenities: [amenity]));
      continue;
    }

    final group = groups[groupIndex];
    groups[groupIndex] = AmenityGroup(
      label: group.label,
      amenities: [...group.amenities, amenity],
    );
  }

  return groups;
}

List<String> normalizeSelectedAmenityValues(
  List<Amenity> amenities,
  List<String> selectedValues,
) {
  final selectedIds = <String>[];
  for (final rawValue in selectedValues) {
    final value = rawValue.trim();
    if (value.isEmpty) continue;

    final amenity = amenities.firstWhere(
      (item) =>
          item.id == value ||
          item.label.trim().toLowerCase() == value.toLowerCase(),
      orElse:
          () => Amenity(
            id: value,
            label: value,
            iconKey: 'default',
            group: 'Legacy',
            sortOrder: 0,
            isActive: false,
            appliesToDetailSchemaKeys: const [],
          ),
    );

    if (amenities.any((item) => item.id == amenity.id) &&
        !selectedIds.contains(amenity.id)) {
      selectedIds.add(amenity.id);
    }
  }
  return selectedIds;
}

List<String> toggleAmenitySelection(
  List<String> selectedAmenityIds,
  String amenityId,
) {
  if (selectedAmenityIds.contains(amenityId)) {
    return selectedAmenityIds
        .where((selectedId) => selectedId != amenityId)
        .toList(growable: false);
  }
  return [...selectedAmenityIds, amenityId];
}

String amenitySearchText(Amenity amenity) {
  return _normalize(
    [amenity.id, amenity.label, amenity.iconKey, amenity.group].join(' '),
  );
}

String amenityGroupLabel(String group) {
  final label = group.trim();
  return label.isEmpty ? 'General' : label;
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}

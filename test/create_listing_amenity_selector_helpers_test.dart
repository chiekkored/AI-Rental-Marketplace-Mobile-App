import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/amenity.model.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/amenity_selector_helpers.dart';
import 'package:lend/utilities/helpers/amenity_icon.helper.dart';

void main() {
  const amenities = [
    Amenity(
      id: 'wifi',
      label: 'Wi-Fi',
      iconKey: 'wifi',
      group: 'Connectivity',
      sortOrder: 10,
      isActive: true,
      appliesToDetailSchemaKeys: ['stay', 'space'],
    ),
    Amenity(
      id: 'car-parking',
      label: 'Car parking',
      iconKey: 'car-parking',
      group: 'Parking',
      sortOrder: 20,
      isActive: true,
      appliesToDetailSchemaKeys: ['stay', 'space'],
    ),
  ];

  group('amenity selector helpers', () {
    test('filters amenities by label, id, group, and icon key', () {
      expect(filterAmenityOptions(amenities, 'wi').map((item) => item.id), [
        'wifi',
      ]);
      expect(
        filterAmenityOptions(amenities, 'parking').map((item) => item.id),
        ['car-parking'],
      );
      expect(
        filterAmenityOptions(amenities, 'connect').map((item) => item.id),
        ['wifi'],
      );
    });

    test('normalizes selected amenity ids and old labels to ids', () {
      expect(
        normalizeSelectedAmenityValues(amenities, [
          'wifi',
          'Car parking',
          'Unknown legacy value',
          'Wi-Fi',
        ]),
        ['wifi', 'car-parking'],
      );
    });

    test('toggles selected amenity ids', () {
      expect(toggleAmenitySelection(['wifi'], 'car-parking'), [
        'wifi',
        'car-parking',
      ]);
      expect(toggleAmenitySelection(['wifi', 'car-parking'], 'wifi'), [
        'car-parking',
      ]);
    });

    test('resolves amenity icons and falls back for unknown keys', () {
      expect(amenityIconFromKey('wifi').icon, FontAwesomeIcons.wifi);
      expect(amenityIconFromKey('not-a-real-key').icon, FontAwesomeIcons.box);
    });

    test('groups amenities by group while preserving order', () {
      final groups = groupAmenityOptions([
        amenities[0],
        amenities[1],
        const Amenity(
          id: 'projector',
          label: 'Projector',
          iconKey: 'projector',
          group: 'Equipment',
          sortOrder: 30,
          isActive: true,
          appliesToDetailSchemaKeys: ['space'],
        ),
        const Amenity(
          id: 'microphone',
          label: 'Microphone',
          iconKey: 'microphones',
          group: 'Equipment',
          sortOrder: 40,
          isActive: true,
          appliesToDetailSchemaKeys: ['space'],
        ),
      ]);

      expect(groups.map((group) => group.label), [
        'Connectivity',
        'Parking',
        'Equipment',
      ]);
      expect(groups.last.amenities.map((amenity) => amenity.id), [
        'projector',
        'microphone',
      ]);
    });

    test('uses General for blank amenity groups', () {
      final groups = groupAmenityOptions([
        const Amenity(
          id: 'blank-group',
          label: 'Blank group',
          iconKey: 'default',
          group: '',
          sortOrder: 10,
          isActive: true,
          appliesToDetailSchemaKeys: ['space'],
        ),
      ]);

      expect(groups.single.label, 'General');
      expect(amenityGroupLabel('  '), 'General');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/amenity.model.dart';

void main() {
  group('Amenity', () {
    test('parses Firestore maps with safe defaults', () {
      final amenity = Amenity.fromMap({
        'label': 'Wi-Fi',
        'sortOrder': '20',
        'isActive': true,
        'appliesToDetailSchemaKeys': ['space', 'stay', 'space', ''],
      }, id: 'wifi');

      expect(amenity.id, 'wifi');
      expect(amenity.label, 'Wi-Fi');
      expect(amenity.iconKey, 'default');
      expect(amenity.group, 'General');
      expect(amenity.sortOrder, 20);
      expect(amenity.isActive, isTrue);
      expect(amenity.appliesToDetailSchemaKeys, ['space', 'stay']);
    });

    test('serializes amenity fields', () {
      const amenity = Amenity(
        id: 'parking',
        label: 'Parking',
        iconKey: 'car',
        group: 'Property',
        sortOrder: 10,
        isActive: true,
        appliesToDetailSchemaKeys: ['space', 'stay'],
      );

      final map = amenity.toMap();

      expect(map['label'], 'Parking');
      expect(map['iconKey'], 'car');
      expect(map['group'], 'Property');
      expect(map['sortOrder'], 10);
      expect(map['isActive'], isTrue);
      expect(map['appliesToDetailSchemaKeys'], ['space', 'stay']);
      expect(amenity.appliesToDetailSchemaKey('space'), isTrue);
      expect(amenity.appliesToDetailSchemaKey('vehicle'), isFalse);
    });
  });
}

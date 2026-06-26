import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/utilities/helpers/category_icon.helper.dart';

void main() {
  group('categoryIconFromKey', () {
    test('resolves approved FontAwesome category keys', () {
      expect(categoryIconFromKey('shirt'), FontAwesomeIcons.shirt);
      expect(categoryIconFromKey('clothes'), FontAwesomeIcons.shirt);
      expect(categoryIconFromKey('tshirt'), FontAwesomeIcons.shirt);
    });

    test('preserves seeded category icon keys', () {
      expect(categoryIconFromKey('camera'), FontAwesomeIcons.camera);
      expect(categoryIconFromKey('car'), FontAwesomeIcons.car);
      expect(categoryIconFromKey('tools'), FontAwesomeIcons.screwdriverWrench);
      expect(categoryIconFromKey('space'), FontAwesomeIcons.warehouse);
      expect(categoryIconFromKey('outdoor'), FontAwesomeIcons.personHiking);
      expect(categoryIconFromKey('electronics'), FontAwesomeIcons.computer);
      expect(categoryIconFromKey('drone'), FontAwesomeIcons.helicopter);
      expect(categoryIconFromKey('party'), FontAwesomeIcons.champagneGlasses);
      expect(categoryIconFromKey('lens'), FontAwesomeIcons.circleDot);
    });

    test('normalizes whitespace, case, hyphens, and underscores', () {
      expect(categoryIconFromKey(' Shirt '), FontAwesomeIcons.shirt);
      expect(
        categoryIconFromKey('screwdriver-wrench'),
        FontAwesomeIcons.screwdriverWrench,
      );
      expect(
        categoryIconFromKey('party_supplies'),
        FontAwesomeIcons.champagneGlasses,
      );
      expect(
        categoryIconFromKey('outdoor gear'),
        FontAwesomeIcons.personHiking,
      );
    });

    test('falls back to box for unknown or empty keys', () {
      expect(categoryIconFromKey(null), FontAwesomeIcons.box);
      expect(categoryIconFromKey(''), FontAwesomeIcons.box);
      expect(categoryIconFromKey('not-a-real-key'), FontAwesomeIcons.box);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lend/utilities/extensions/list.extension.dart';

void main() {
  group('NullableStringListExtension', () {
    test('returns null for null or empty lists', () {
      const List<String>? nullImages = null;
      final emptyImages = <String>[];

      expect(nullImages.firstImageUrl, isNull);
      expect(emptyImages.firstImageUrl, isNull);
    });

    test('returns the first image URL for populated lists', () {
      final images = ['cover.jpg', 'secondary.jpg'];

      expect(images.firstImageUrl, 'cover.jpg');
    });
  });
}

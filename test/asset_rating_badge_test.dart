import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/common/asset_rating_badge.common.dart';

void main() {
  group('AssetRatingBadge', () {
    test('formats whole-number ratings without trailing decimal', () {
      expect(AssetRatingBadge.ratingLabel(5.0), '5');
    });

    test('formats fractional ratings with one decimal', () {
      expect(AssetRatingBadge.ratingLabel(4.5), '4.5');
    });
  });
}

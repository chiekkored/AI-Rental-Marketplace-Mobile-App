import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/asset_search_result.model.dart';

void main() {
  group('AssetSearchResult', () {
    test('maps Algolia hit fields', () {
      final result = AssetSearchResult.fromAlgoliaHit({
        'id': 'asset-1',
        'objectID': 'object-1',
        'title': 'Canon Camera',
        'categoryId': 'electronics',
        'categoryName': 'Electronics',
        'images': ['https://example.com/image.jpg'],
        'rates': {'daily': 1500, 'currency': 'USD'},
        'status': 'Available',
        'isDeleted': false,
        'ownerId': 'owner-1',
      });

      expect(result.id, 'asset-1');
      expect(result.title, 'Canon Camera');
      expect(result.categoryId, 'electronics');
      expect(result.categoryName, 'Electronics');
      expect(result.imageUrl, 'https://example.com/image.jpg');
      expect(result.dailyRate, 1500);
      expect(result.currency, 'USD');
      expect(result.status, 'Available');
      expect(result.isDeleted, false);
      expect(result.ownerId, 'owner-1');
    });

    test('falls back to objectID and normalizes numeric strings', () {
      final result = AssetSearchResult.fromAlgoliaHit({
        'objectID': 'asset-2',
        'rates': {'daily': '2500'},
      });

      expect(result.id, 'asset-2');
      expect(result.dailyRate, 2500);
    });

    test('parses whole-number averageRating from Algolia hits as double', () {
      final result = AssetSearchResult.fromAlgoliaHit({
        'objectID': 'asset-1',
        'title': 'Camera',
        'categoryId': 'electronics',
        'categoryName': 'Electronics',
        'isDeleted': false,
        'averageRating': 5,
        'reviewCount': 3,
      });

      expect(result.averageRating, 5.0);
      expect(result.reviewCount, 3);
    });

    test('parses fractional averageRating from Algolia hits as double', () {
      final result = AssetSearchResult.fromAlgoliaHit({
        'objectID': 'asset-1',
        'title': 'Camera',
        'categoryId': 'electronics',
        'categoryName': 'Electronics',
        'isDeleted': false,
        'averageRating': 4.5,
        'reviewCount': 2,
      });

      expect(result.averageRating, 4.5);
      expect(result.reviewCount, 2);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/asset_search_filter.model.dart';
import 'package:lend/core/services/algolia_search.service.dart';

void main() {
  group('LNDAlgoliaSearchService filters', () {
    test('builds category facet filters as an OR group', () {
      final filters = LNDAlgoliaSearchService.buildFacetFilters([
        'cameras',
        'tools',
      ]);

      expect(filters, [
        ['categoryId:cameras', 'categoryId:tools'],
      ]);
    });

    test('dedupes and ignores blank category filters', () {
      final filters = LNDAlgoliaSearchService.buildFacetFilters([
        'cameras',
        ' ',
        'cameras',
      ]);

      expect(filters, [
        ['categoryId:cameras'],
      ]);
    });

    test('returns null when no category filters are active', () {
      final filters = LNDAlgoliaSearchService.buildFacetFilters([]);

      expect(filters, isNull);
    });

    test('builds daily-rate numeric range filters', () {
      const priceRange = AssetSearchPriceRange(
        label: 'PHP 500 - PHP 1,500',
        minDailyRate: 500,
        maxDailyRate: 1500,
      );

      final filters = LNDAlgoliaSearchService.buildNumericFilters(priceRange);

      expect(filters, ['rates.daily >= 500', 'rates.daily <= 1500']);
    });

    test('returns null for the unbounded price range', () {
      const priceRange = AssetSearchPriceRange(label: 'Any price');

      final filters = LNDAlgoliaSearchService.buildNumericFilters(priceRange);

      expect(filters, isNull);
    });
  });
}

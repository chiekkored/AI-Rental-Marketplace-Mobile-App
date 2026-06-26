import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';

void main() {
  group('AssetSearchController history', () {
    test('adds newest query first', () {
      final history = AssetSearchController.buildNextSearchHistory(
        currentHistory: const ['camera', 'tripod'],
        query: 'lens',
      );

      expect(history, ['lens', 'camera', 'tripod']);
    });

    test('dedupes existing queries case-insensitively', () {
      final history = AssetSearchController.buildNextSearchHistory(
        currentHistory: const ['Camera', 'tripod'],
        query: ' camera ',
      );

      expect(history, ['camera', 'tripod']);
    });

    test('limits history to max items', () {
      final history = AssetSearchController.buildNextSearchHistory(
        currentHistory: List.generate(12, (index) => 'query-$index'),
        query: 'new query',
        limit: 10,
      );

      expect(history.length, 10);
      expect(history.first, 'new query');
      expect(history.last, 'query-8');
    });

    test('ignores blank queries', () {
      final history = AssetSearchController.buildNextSearchHistory(
        currentHistory: const ['camera'],
        query: '   ',
      );

      expect(history, ['camera']);
    });
  });

  group('AssetSearchController filters', () {
    test(
      'reset clears categories after apply without fixed-length list errors',
      () async {
        final controller = AssetSearchController();
        addTearDown(controller.onClose);

        await controller.applyFilters(
          categories: const ['Cameras', 'Tools'],
          priceRange: AssetSearchController.priceRanges[1],
        );

        expect(controller.selectedCategories, ['Cameras', 'Tools']);
        expect(
          controller.selectedPriceRange,
          AssetSearchController.priceRanges[1],
        );

        await controller.resetFilters();

        expect(controller.selectedCategories, isEmpty);
        expect(controller.selectedPriceRange, isNull);
      },
    );

    test(
      'category facet selection is single-select and preserves price',
      () async {
        final controller = AssetSearchController();
        addTearDown(controller.onClose);

        await controller.applyFilters(
          categories: const [],
          priceRange: AssetSearchController.priceRanges[2],
        );
        await controller.selectCategoryFacet('Cameras');

        expect(controller.selectedCategories, ['Cameras']);
        expect(
          controller.selectedPriceRange,
          AssetSearchController.priceRanges[2],
        );

        await controller.selectCategoryFacet('Tools');

        expect(controller.selectedCategories, ['Tools']);
        expect(
          controller.selectedPriceRange,
          AssetSearchController.priceRanges[2],
        );
      },
    );

    test('all category facet clears categories and preserves price', () async {
      final controller = AssetSearchController();
      addTearDown(controller.onClose);

      await controller.applyFilters(
        categories: const ['Cameras'],
        priceRange: AssetSearchController.priceRanges[2],
      );
      await controller.selectCategoryFacet(null);

      expect(controller.selectedCategories, isEmpty);
      expect(
        controller.selectedPriceRange,
        AssetSearchController.priceRanges[2],
      );
    });

    test('active price filter ignores selected categories', () async {
      final controller = AssetSearchController();
      addTearDown(controller.onClose);

      await controller.selectCategoryFacet('Cameras');

      expect(controller.hasActivePriceFilter, false);

      await controller.applyFilters(
        categories: controller.selectedCategories,
        priceRange: AssetSearchController.priceRanges[1],
      );

      expect(controller.hasActivePriceFilter, true);

      await controller.applyFilters(
        categories: controller.selectedCategories,
        priceRange: AssetSearchController.priceRanges.first,
      );

      expect(controller.hasActivePriceFilter, false);
      expect(controller.selectedCategories, ['Cameras']);
    });
  });
}

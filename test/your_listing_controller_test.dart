import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';
import 'package:lend/utilities/enums/availability.enum.dart';

void main() {
  group('YourListingController filters', () {
    test('switches filtered assets by listing status', () {
      final controller = YourListingController();
      addTearDown(controller.onClose);

      controller.setLocalAssetsForTesting([
        _asset(id: 'available-asset', status: Availability.available),
        _asset(id: 'maintenance-asset', status: Availability.underMaintenance),
        _asset(id: 'hidden-asset', status: Availability.hidden),
      ]);

      expect(controller.selectedFilter, Availability.available);
      expect(controller.filteredAssets.map((asset) => asset.id), [
        'available-asset',
      ]);

      controller.setFilter(Availability.underMaintenance);
      expect(controller.filteredAssets.map((asset) => asset.id), [
        'maintenance-asset',
      ]);

      controller.setFilter(Availability.hidden);
      expect(controller.filteredAssets.map((asset) => asset.id), [
        'hidden-asset',
      ]);
    });

    test('counts assets by listing status', () {
      final controller = YourListingController();
      addTearDown(controller.onClose);

      controller.setLocalAssetsForTesting([
        _asset(id: 'available-1', status: Availability.available),
        _asset(id: 'available-2', status: Availability.available),
        _asset(id: 'maintenance-asset', status: Availability.underMaintenance),
        _asset(id: 'hidden-asset', status: Availability.hidden),
      ]);

      expect(controller.availableAssets, '2');
      expect(controller.underMaintenanceAssets, '1');
      expect(controller.hiddenAssets, '1');
    });

    test('clears local assets when subscription is cancelled', () {
      final controller = YourListingController();
      addTearDown(controller.onClose);

      controller.setLocalAssetsForTesting([
        _asset(id: 'available-asset', status: Availability.available),
      ]);

      controller.cancelMyAssetsSubscription();

      expect(controller.myAssets, isEmpty);
      expect(controller.isMyAssetsLoading, isFalse);
    });

    test('fetches filtered listings in pages of ten', () {
      final controller = YourListingController();
      addTearDown(controller.onClose);

      controller.setLocalAssetsForTesting([
        ..._assets(
          count: YourListingController.listingPageSize + 2,
          status: Availability.available,
          idPrefix: 'available',
        ),
        ..._assets(count: 3, status: Availability.hidden, idPrefix: 'hidden'),
      ]);

      final firstPage = controller.fetchListingPage(1);
      final secondPage = controller.fetchListingPage(2);
      final thirdPage = controller.fetchListingPage(3);

      expect(firstPage, hasLength(YourListingController.listingPageSize));
      expect(secondPage.map((asset) => asset.id), [
        'available-10',
        'available-11',
      ]);
      expect(thirdPage, isEmpty);
    });

    test('paging controller stops after all filtered listings load', () {
      final controller = YourListingController();
      addTearDown(controller.onClose);

      controller.setLocalAssetsForTesting(
        _assets(
          count: YourListingController.listingPageSize + 1,
          status: Availability.available,
          idPrefix: 'available',
        ),
      );

      controller.pagingController.fetchNextPage();
      expect(
        controller.pagingController.value.items,
        hasLength(YourListingController.listingPageSize),
      );
      expect(controller.pagingController.value.hasNextPage, isTrue);

      controller.pagingController.fetchNextPage();
      expect(
        controller.pagingController.value.items,
        hasLength(YourListingController.listingPageSize + 1),
      );
      expect(controller.pagingController.value.hasNextPage, isTrue);

      controller.pagingController.fetchNextPage();
      expect(controller.pagingController.value.hasNextPage, isFalse);
    });

    test('changing filter resets paging to the new filtered list', () {
      final controller = YourListingController();
      addTearDown(controller.onClose);

      controller.setLocalAssetsForTesting([
        ..._assets(
          count: YourListingController.listingPageSize + 1,
          status: Availability.available,
          idPrefix: 'available',
        ),
        ..._assets(count: 2, status: Availability.hidden, idPrefix: 'hidden'),
      ]);

      controller.pagingController.fetchNextPage();
      expect(controller.pagingController.value.items?.first.id, 'available-0');

      controller.setFilter(Availability.hidden);
      expect(controller.pagingController.value.items, isNull);

      controller.pagingController.fetchNextPage();
      expect(
        controller.pagingController.value.items?.map((asset) => asset.id),
        ['hidden-0', 'hidden-1'],
      );
    });
  });
}

List<SimpleAsset> _assets({
  required int count,
  required Availability status,
  required String idPrefix,
}) {
  return List.generate(
    count,
    (index) => _asset(id: '$idPrefix-$index', status: status),
  );
}

SimpleAsset _asset({required String id, required Availability status}) {
  return SimpleAsset(
    id: id,
    owner: null,
    title: id,
    images: const [],
    categoryId: 'cameras',
    categoryName: 'Cameras',
    createdAt: null,
    status: status.label,
    location: null,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';

void main() {
  group('SimpleAsset', () {
    test('serializes and deserializes rates with currency', () {
      final asset = SimpleAsset(
        id: 'asset-1',
        owner: null,
        title: 'Camera',
        images: const [],
        categoryId: 'cameras',
        categoryName: 'Cameras',
        rates: Rates(daily: 1500, currency: 'USD'),
        createdAt: null,
        status: 'Available',
        location: null,
      );

      final map = asset.toMap();
      final parsed = SimpleAsset.fromMap(map);

      expect(map['rates'], {
        'daily': 1500,
        'weekly': null,
        'monthly': null,
        'annually': null,
        'notes': null,
        'currency': 'USD',
      });
      expect(parsed.rates?.daily, 1500);
      expect(parsed.rates?.currency, 'USD');
    });

    test('serializes listing instructions and end-date rule', () {
      final asset = SimpleAsset(
        id: 'asset-1',
        owner: null,
        title: 'Camera',
        images: const [],
        categoryId: 'cameras',
        categoryName: 'Cameras',
        rates: null,
        createdAt: null,
        status: 'Available',
        location: null,
        ownerInstructions: 'Return with batteries charged.',
        blocksEndDate: true,
      );

      final parsed = SimpleAsset.fromMap(asset.toMap());

      expect(parsed.ownerInstructions, 'Return with batteries charged.');
      expect(parsed.blocksEndDate, isTrue);
    });

    test('defaults optional listing fields for snapshots', () {
      final parsed = SimpleAsset.fromMap({
        'id': 'asset-1',
        'owner': null,
        'title': 'Camera',
        'images': const [],
        'categoryId': 'cameras',
        'categoryName': 'Cameras',
        'createdAt': null,
        'status': 'Available',
        'location': null,
      });

      expect(parsed.ownerInstructions, isNull);
      expect(parsed.blocksEndDate, isFalse);
    });
  });
}

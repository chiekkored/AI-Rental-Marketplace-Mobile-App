import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/list_details/list_details.dart';

void main() {
  group('Asset', () {
    test('parses whole-number averageRating from Firestore maps as double', () {
      final asset = Asset.fromMap({
        'id': 'asset-1',
        'averageRating': 5,
        'reviewCount': 3,
      });

      expect(asset.averageRating, 5.0);
      expect(asset.reviewCount, 3);
    });

    test('parses fractional averageRating from Firestore maps as double', () {
      final asset = Asset.fromMap({
        'id': 'asset-1',
        'averageRating': 4.5,
        'reviewCount': 2,
      });

      expect(asset.averageRating, 4.5);
      expect(asset.reviewCount, 2);
    });

    test('defaults new listing instruction fields for old Firestore maps', () {
      final asset = Asset.fromMap({'id': 'asset-1'});

      expect(asset.ownerInstructions, isNull);
      expect(asset.blocksEndDate, isFalse);
    });

    test('serializes owner instructions and end-date rule', () {
      final asset = Asset(
        id: 'asset-1',
        ownerInstructions: 'Bring a valid ID at pickup.',
        blocksEndDate: true,
      );

      final map = asset.toMap();

      expect(map['ownerInstructions'], 'Bring a valid ID at pickup.');
      expect(map['blocksEndDate'], isTrue);
    });

    test('round trips category-specific listing details', () {
      const listingDetails = ListingDetailsModel(
        listingKind: 'vehicle',
        detailSchemaKey: 'vehicle',
        details: VehicleListingDetails(
          make: 'Toyota',
          model: 'Vios',
          year: 2023,
        ),
      );
      final asset = Asset(id: 'asset-1', listingDetails: listingDetails);

      final map = asset.toMap();
      final parsed = Asset.fromMap(map);

      expect(map['listingKind'], 'vehicle');
      expect(map['detailSchemaKey'], 'vehicle');
      expect(map['details'], {
        'make': 'Toyota',
        'model': 'Vios',
        'year': 2023,
        'transmission': 'automatic',
        'fuelType': 'gasoline',
        'licenseRequired': true,
        'helmetIncluded': false,
        'deliveryAvailable': false,
      });
      expect(parsed.listingDetails, listingDetails);
    });
  });
}

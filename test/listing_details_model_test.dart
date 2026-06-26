import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/list_details/list_details.dart';

void main() {
  group('ListingDetailsModel', () {
    test('parses stay details into typed data', () {
      final model = ListingDetailsModel.fromMap({
        'listingKind': 'property',
        'detailSchemaKey': 'stay',
        'details': {
          'stayType': 'private_room',
          'maxGuests': 4,
          'bedrooms': 2,
          'beds': 3,
          'bathrooms': 1,
          'amenities': ['wifi', 'air-conditioning'],
          'checkInTime': '15:00',
          'checkOutTime': '10:00',
          'minimumNights': 2,
          'petsAllowed': true,
          'smokingAllowed': false,
          'partiesAllowed': true,
        },
      });

      expect(model.details, isA<StayListingDetails>());
      final details = model.details as StayListingDetails;
      expect(details.maxGuests, 4);
      expect(details.amenities, ['wifi', 'air-conditioning']);
      expect(details.petsAllowed, isTrue);
      expect(model.toMap()['details'], {
        'stayType': 'private_room',
        'maxGuests': 4,
        'bedrooms': 2,
        'beds': 3,
        'bathrooms': 1,
        'amenities': ['wifi', 'air-conditioning'],
        'checkInTime': '15:00',
        'checkOutTime': '10:00',
        'minimumNights': 2,
        'petsAllowed': true,
        'smokingAllowed': false,
        'partiesAllowed': true,
      });
    });

    test('parses space details with typed time ranges', () {
      final details = ListingDetailsData.fromMap('space', {
        'capacity': '12',
        'allowedUses': ['meeting', 'workshop'],
        'amenities': ['projector'],
        'hasParking': true,
        'setupTimeMinutes': 30,
        'cleanupTimeMinutes': 15,
        'operatingHours': {
          'enabled': true,
          'startTime': '09:00',
          'endTime': '18:00',
        },
        'noiseRestrictions': {'enabled': false},
      });

      expect(details, isA<SpaceListingDetails>());
      final space = details as SpaceListingDetails;
      expect(space.capacity, 12);
      expect(
        space.operatingHours,
        const ListingTimeRange(
          enabled: true,
          startTime: '09:00',
          endTime: '18:00',
        ),
      );
      expect(space.noiseRestrictions, const ListingTimeRange(enabled: false));
      expect(space.toMap()['operatingHours'], {
        'enabled': true,
        'startTime': '09:00',
        'endTime': '18:00',
      });
    });

    test('round trips all concrete detail schemas', () {
      final details = <ListingDetailsData>[
        const StayListingDetails(maxGuests: 2, amenities: ['wifi']),
        const SpaceListingDetails(
          capacity: 20,
          allowedUses: ['events'],
          operatingHours: ListingTimeRange(
            enabled: true,
            startTime: '08:00',
            endTime: '17:00',
          ),
        ),
        const VehicleListingDetails(make: 'Toyota', model: 'Vios', year: 2023),
        const ToolListingDetails(brand: 'Makita', model: 'Drill'),
        const ElectronicsListingDetails(
          brand: 'Sony',
          model: 'A7',
          chargerIncluded: true,
        ),
        const PartyEventListingDetails(quantity: 10, setSize: '10 chairs'),
        const ClothingListingDetails(brand: 'Uniqlo', size: 'M'),
        const GenericAssetListingDetails(brand: 'Acme', model: 'Box'),
      ];

      for (final detail in details) {
        final parsed = ListingDetailsData.fromMap(
          detail.detailSchemaKey,
          detail.toMap(),
        );

        expect(parsed, detail);
      }
    });

    test('falls back to generic asset details for unknown schemas', () {
      final details = ListingDetailsData.fromMap('unknown', {
        'brand': 'Acme',
        'model': 'Standard',
        'notes': 'Light use only',
      });

      expect(details, isA<GenericAssetListingDetails>());
      expect(details.toMap(), {
        'brand': 'Acme',
        'model': 'Standard',
        'notes': 'Light use only',
      });
    });
  });
}

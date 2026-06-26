import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_vehicle_details.chunk.dart';

void main() {
  group('CreateListingVehicleDetailsChunk', () {
    test('defaults seats to one for new vehicle listings', () {
      final chunk = CreateListingVehicleDetailsChunk();
      addTearDown(chunk.onClose);

      final details = chunk.toListingDetails();

      expect(chunk.seatsController.text, '1');
      expect(details.seats, 1);
    });

    test('clamps missing or non-positive populated seats to one', () {
      final chunk = CreateListingVehicleDetailsChunk();
      addTearDown(chunk.onClose);

      chunk.populateFromDetails(const VehicleListingDetails(seats: 0));

      expect(chunk.seatsController.text, '1');
      expect(chunk.toListingDetails().seats, 1);
    });

    test('saves positive populated seats unchanged', () {
      final chunk = CreateListingVehicleDetailsChunk();
      addTearDown(chunk.onClose);

      chunk.populateFromDetails(const VehicleListingDetails(seats: 4));

      expect(chunk.seatsController.text, '4');
      expect(chunk.toListingDetails().seats, 4);
    });
  });
}

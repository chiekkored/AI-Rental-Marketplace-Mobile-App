import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/controllers/renter_center/renter_center.controller.dart';

void main() {
  group('RenterCenterController', () {
    test('creates renter center navigation controller', () {
      final controller = RenterCenterController();

      expect(controller, isA<RenterCenterController>());
    });
  });
}

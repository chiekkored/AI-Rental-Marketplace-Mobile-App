import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/amenity.model.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/amenity/amenity.controller.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_chip.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/presentation/pages/asset/widgets/details/stay_details.widget.dart';
import 'package:lend/utilities/enums/listing_details.enum.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  group('asset listing details widgets', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() async {
      await Get.deleteAll(force: true);
      Get.testMode = false;
    });

    test('formats detail enum values for display', () {
      expect(readableDetailValue('entire_place'), 'Entire Place');
      expect(
        readableDetailValue('owner-cleans-after-return'),
        'Owner Cleans After Return',
      );
    });

    test('resolves stay type values and icons', () {
      expect(StayType.fromValue('private_room'), StayType.privateRoom);
      expect(StayType.fromValue('unknown'), StayType.entirePlace);
      expect(StayType.sharedRoom.icon, Icons.groups_2_outlined);
    });

    testWidgets('resolves amenity chip label by id', (tester) async {
      final controller = Get.put(AmenityController());
      controller.amenities.assignAll([
        const Amenity(
          id: 'wifi',
          label: 'Wi-Fi',
          iconKey: 'wifi',
          group: 'Connectivity',
          sortOrder: 1,
          isActive: true,
          appliesToDetailSchemaKeys: ['stay'],
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          theme: LNDAppTheme.light,
          home: const Scaffold(body: AssetAmenityChip(amenityId: 'wifi')),
        ),
      );

      expect(find.text('Wi-Fi'), findsOneWidget);
    });

    testWidgets('renders stay counts as separate card count and label text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LNDAppTheme.light,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: StayAssetDetails(
                details: StayListingDetails(
                  stayType: 'private_room',
                  maxGuests: 4,
                  bedrooms: 2,
                  beds: 3,
                  bathrooms: 1,
                  minimumNights: 5,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Private room'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Guests'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Bedrooms'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Min nights'), findsOneWidget);
      expect(find.text('4 guests'), findsNothing);
    });
  });
}

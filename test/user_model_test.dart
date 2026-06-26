import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/full_verification_submission.model.dart';
import 'package:lend/core/models/user.model.dart';

void main() {
  group('UserModel business listing preference', () {
    test('reads approved business name and listing-owner preference', () {
      final user = UserModel.fromMap({
        'uid': 'user-1',
        'firstName': 'Jamie',
        'lastName': 'Reyes',
        'verified': 'Full',
        'status': 'Active',
        'useBusinessNameForListingOwnerName': true,
        'businessRegistration': {
          'visible': true,
          'required': false,
          'status': 'Approved',
          'visibilityReasons': ['owner_self_declared'],
          'businessName': 'Jamie Rentals OPC',
          'businessType': 'Corporation',
          'businessAddress': 'Makati City',
        },
      });

      expect(user.useBusinessNameForListingOwnerName, isTrue);
      expect(user.approvedBusinessName, 'Jamie Rentals OPC');
      expect(user.hasApprovedBusinessName, isTrue);
    });

    test('serializes the listing-owner preference', () {
      final user = UserModel(
        uid: 'user-1',
        firstName: 'Jamie',
        lastName: 'Reyes',
        dateOfBirth: null,
        location: null,
        photoUrl: null,
        createdAt: null,
        email: null,
        phone: null,
        type: null,
        verified: null,
        status: null,
        businessRegistration: const UserBusinessRegistrationSummary(
          visible: true,
          status: 'Approved',
          businessName: 'Jamie Rentals OPC',
        ),
        useBusinessNameForListingOwnerName: true,
      );

      expect(user.toMap()['useBusinessNameForListingOwnerName'], isTrue);
    });
  });
}

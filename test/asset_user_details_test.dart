import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/presentation/pages/asset/widgets/user_details.widget.dart';

void main() {
  group('assetOwnerDisplayName', () {
    test('shows full display name for the current owner', () {
      final owner = SimpleUserModel(
        firstName: 'Jamie',
        lastName: 'Reyes',
        displayName: 'Jamie Rentals OPC',
      );

      expect(
        assetOwnerDisplayName(isCurrentUserOwner: true, owner: owner),
        'Jamie Rentals OPC',
      );
    });

    test('obscures display name for non-owner viewers', () {
      final owner = SimpleUserModel(
        firstName: 'Jamie',
        lastName: 'Reyes',
        displayName: 'Jamie Rentals OPC',
      );

      expect(
        assetOwnerDisplayName(isCurrentUserOwner: false, owner: owner),
        'J*** R*** O***',
      );
    });

    test('preserves missing owner name fallback behavior', () {
      expect(
        assetOwnerDisplayName(isCurrentUserOwner: true, owner: null),
        'No name',
      );
      expect(
        assetOwnerDisplayName(isCurrentUserOwner: false, owner: null),
        'N*** n***',
      );
    });
  });
}

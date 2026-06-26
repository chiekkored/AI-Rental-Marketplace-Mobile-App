import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/simple_user.model.dart';

void main() {
  group('SimpleUserModel founding owner marker', () {
    test('reads founding owner boolean marker', () {
      final user = SimpleUserModel.fromMap({
        'uid': 'owner-1',
        'firstName': 'Jamie',
        'isFoundingOwner': true,
      });

      expect(user.isFoundingOwner, isTrue);
      expect(user.isFoundingOwnerAccount, isTrue);
    });

    test('reads founding owner summary marker fallback', () {
      final user = SimpleUserModel.fromMap({
        'uid': 'owner-1',
        'firstName': 'Jamie',
        'foundingOwner': {'inviteId': 'invite-1'},
      });

      expect(user.isFoundingOwner, isTrue);
      expect(user.isFoundingOwnerAccount, isTrue);
    });

    test('reads legacy founding owner invite marker fallback', () {
      final user = SimpleUserModel.fromMap({
        'uid': 'owner-1',
        'firstName': 'Jamie',
        'foundingOwnerInvite': {'inviteId': 'invite-1'},
      });

      expect(user.isFoundingOwner, isTrue);
      expect(user.isFoundingOwnerAccount, isTrue);
    });

    test('serializes founding owner boolean marker', () {
      final user = SimpleUserModel(uid: 'owner-1', isFoundingOwner: true);

      expect(user.toMap()['isFoundingOwner'], isTrue);
    });
  });
}

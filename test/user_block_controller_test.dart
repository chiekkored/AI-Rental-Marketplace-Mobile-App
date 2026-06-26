import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';

void main() {
  test(
    'hasBlocked reads outgoing blocked users separately from exclusions',
    () {
      final controller = UserBlockController();
      addTearDown(controller.onClose);

      controller.excludedUserIds.add('incoming-only');
      controller.blockedUserIds.add('outgoing');

      expect(controller.isExcluded('incoming-only'), true);
      expect(controller.hasBlocked('incoming-only'), false);
      expect(controller.hasBlocked('outgoing'), true);
    },
  );
}

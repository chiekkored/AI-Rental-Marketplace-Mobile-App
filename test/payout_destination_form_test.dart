import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';

void main() {
  test('deposit return mode exposes single-purpose destination copy', () {
    final controller = OwnerPayoutDestinationController();
    addTearDown(controller.onClose);

    controller.purpose.value = OwnerPayoutDestinationPurpose.depositReturn;

    expect(controller.pageTitle, 'Deposit Return Destination');
    expect(controller.sectionTitle, 'Deposit return destination');
    expect(controller.savedMessage, 'Deposit return destination saved.');
    expect(
      controller.transferNoticeText,
      'Transfer fees and deposit return timing are applied from current Lend policy.',
    );
  });
}

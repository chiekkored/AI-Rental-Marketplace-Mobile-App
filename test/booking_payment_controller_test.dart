import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/controllers/booking_payment/booking_payment.controller.dart';

void main() {
  test('Firestore unavailable watch errors are treated as transient', () {
    expect(
      BookingPaymentController.isTransientCheckoutWatchError(
        'Status{code=UNAVAILABLE, description=End of stream or IOException}',
      ),
      isTrue,
    );
  });

  test('DNS watch errors are treated as transient', () {
    expect(
      BookingPaymentController.isTransientCheckoutWatchError(
        'UnknownHostException: Unable to resolve host firestore.googleapis.com',
      ),
      isTrue,
    );
  });

  test('unrelated watch errors are not treated as transient', () {
    expect(
      BookingPaymentController.isTransientCheckoutWatchError(
        'permission-denied',
      ),
      isFalse,
    );
  });
}

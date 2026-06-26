import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/middlewares/listing_eligible.middleware.dart';

void main() {
  group('ListingEligibleMiddleware', () {
    test('allows full users without pending verification', () {
      expect(
        ListingEligibleMiddleware.shouldRedirect(
          hasPendingFullVerification: false,
          canList: true,
        ),
        isFalse,
      );
    });

    test('redirects users who cannot list', () {
      expect(
        ListingEligibleMiddleware.shouldRedirect(
          hasPendingFullVerification: false,
          canList: false,
        ),
        isTrue,
      );
    });

    test('redirects users while full verification is pending', () {
      expect(
        ListingEligibleMiddleware.shouldRedirect(
          hasPendingFullVerification: true,
          canList: true,
        ),
        isTrue,
      );
    });
  });
}

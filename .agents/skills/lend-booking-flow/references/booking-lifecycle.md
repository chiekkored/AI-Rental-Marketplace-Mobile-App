# Booking Lifecycle

## Current flow
1. Renter opens an asset.
2. `AssetController.getBookings()` loads `assets/{assetId}/bookings`.
3. Confirmed bookings are expanded into blocked days for `/calendar-picker`.
4. `CalendarPickerController` calculates total client-side.
5. `AssetController.bookAsset()` creates:
   - renter booking mirror
   - asset booking mirror
   - chat root
   - first message
   - mirrored chat summaries for renter and owner
6. Owner accepts from calendar or chat.
7. Production acceptance goes through callable `confirmBooking`.
8. Token generation is expected through callable token flows.
9. Confirmed booking can use QR handover and return verification.
10. Review submission updates asset ratings, marks booking reviewed, and archives renter chat.

## Current status model
Mobile enum currently exposes:
- `Pending`
- `Confirmed`
- `Declined`
- `Cancelled`

Additional lifecycle is encoded indirectly through:
- `tokens`
- `handedOver`
- `returned`
- `reviewed`

## Critical migration warning
Booking creation still writes legacy `dates[]` through `AddBooking`.

Many downstream flows expect:
- `startDate`
- `endDate`
- `numDays`

Any change to booking behavior must confirm which representation is active in the target path.

## Callable contracts visible from mobile
- `confirmBooking`
- `makeToken`
- `verifyAndMark`
- `verifyToken`
- `regenerateToken`
- `regenerateQr`

Treat backend implementation details as inferred unless visible locally.

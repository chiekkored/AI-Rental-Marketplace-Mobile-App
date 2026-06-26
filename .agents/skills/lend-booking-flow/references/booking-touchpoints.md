# Booking Touchpoints

## Main controllers
- `AssetController`: booking creation, asset booking reads, reserve entrypoint
- `CalendarPickerController`: range selection and total calculation
- `CalendarBookingsController`: owner calendar and accept action
- `ChatController`: booking-linked chat footer, accept action, QR entrypoints
- `MyRentalsController`: renter booking list and ongoing booking logic
- `ScanQRController`: token verification and token view routing

## Main services
- `LNDBookingService`: booking reads, review flow, callable contracts, legacy client acceptance logic
- `LNDMessagingService`: shared message append plus mirrored chat summary updates

## Main screens
- asset detail
- calendar picker
- owner booking calendar
- chat
- my rentals
- scan QR
- token view
- rating and review

## Mirrors that matter
- `users/{renterId}/bookings/{bookingId}`
- `assets/{assetId}/bookings/{bookingId}`
- `userChats/{ownerId}/chats/{chatId}`
- `userChats/{renterId}/chats/{chatId}`

## Known fragile spots
- `dates[]` versus `startDate/endDate`
- ongoing rental detection using `arrayContains` plus `+2 day` workaround
- confirmation state split between client transaction code and callable backend

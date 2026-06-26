# Schema Map

## Top-level collections
- `users/{uid}`
- `assets/{assetId}`
- `userChats/{uid}`
- `chats/{chatId}`

## User subcollections
- `users/{uid}/assets/{assetId}`
- `users/{uid}/bookings/{bookingId}`
- `users/{uid}/saved/{assetId}`

## Asset subcollections
- `assets/{assetId}/bookings/{bookingId}`
- `assets/{assetId}/ratings/{bookingId}`

## Chat subcollections
- `chats/{chatId}/messages/{messageId}`
- `userChats/{uid}/chats/{chatId}`

## Main entity mirrors
### Assets
Canonical:
- `assets/{assetId}`

Owner mirror:
- `users/{ownerId}/assets/{assetId}`

### Bookings
Renter mirror:
- `users/{renterId}/bookings/{bookingId}`

Asset mirror:
- `assets/{assetId}/bookings/{bookingId}`

### Chats
Shared messages:
- `chats/{chatId}`
- `chats/{chatId}/messages/{messageId}`

Per-user inbox mirrors:
- `userChats/{ownerId}/chats/{chatId}`
- `userChats/{renterId}/chats/{chatId}`

## Embedded snapshots commonly reused
- simplified owner user in assets
- simplified asset in bookings
- simplified renter user in bookings
- simplified asset and participants in mirrored chat docs
- simplified asset in saved docs

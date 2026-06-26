# Lend

**Lend** is a Flutter app (Android & iOS) that enables users to list assets for rent and let other users book them for chosen date ranges. Owners can post multiple images, pin the item location on Google Maps, set a daily price, optionally require a security deposit, and manage availability. Renters can browse listings, pay through the in-app PayMongo checkout flow, use QR handover/return checkpoints, chat with owners, and complete post-return settlement flows.

## Screenshots

<div style="display: flex; justify-content: start; gap: 10px;">
  <img src="./assets/screenshots/ss1.png" width="200"/>
  <img src="./assets/screenshots/ss2.png" width="200"/>
  <img src="./assets/screenshots/ss3.png" width="200"/>
</div>
<br>
<div style="display: flex; justify-content: start; gap: 10px;">
  <img src="./assets/screenshots/ss4.png" width="200"/>
  <img src="./assets/screenshots/ss5.png" width="200"/>
  <img src="./assets/screenshots/ss6.png" width="200"/>
</div>
<br>
<div style="display: flex; justify-content: start; gap: 10px;">
  <img src="./assets/screenshots/ss7.png" width="200"/>
  <img src="./assets/screenshots/ss8.png" width="200"/>
  <img src="./assets/screenshots/ss9.png" width="200"/>
</div>
<br>
<div style="display: flex; justify-content: start; gap: 10px;">
  <img src="./assets/screenshots/ss10.png" width="200"/>
  <img src="./assets/screenshots/ss11.png" width="200"/>
  <img src="./assets/screenshots/ss12.png" width="200"/>
</div>
<br>
<div style="display: flex; justify-content: start; gap: 10px;">
  <img src="./assets/screenshots/ss13.png" width="200"/>
  <img src="./assets/screenshots/ss14.png" width="200"/>
  <img src="./assets/screenshots/ss15.png" width="200"/>
</div>
<br>
<div style="display: flex; justify-content: start; gap: 10px;">
  <img src="./assets/screenshots/ss16.png" width="200"/>
  <img src="./assets/screenshots/ss17.png" width="200"/>
</div>

---

## Table of contents

- [Key Features](#key-features)
- [Process Logic](#process-logic)
- [Firestore, Function, and Storage Counts](#firestore-function-and-storage-counts)
- [Tech Stack & Packages](#tech-stack--packages)
- [Folder Structure](#folder-structure)
- [Authentication & Roles](#authentication--roles)
- [FVM (Flutter Version Management)](#fvm-flutter-version-management)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Security & Rules](#security--rules)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Key Features

- Post assets for rent (multiple images, title, category, description, inclusions, pinned map location, price per day, optional security deposit).
- Five-tab app shell: Discover, Saved, Now, Messages, and Profile.
- Public Discover feed with nearby listings, category shortcuts, and authenticated recommendation/popular rails.
- Saved listings tab with a two-column grid and a Recently Viewed history action.
- Now tab for today’s and incoming confirmed bookings, including owner/renter role chips.
- Date-range booking UI (calendar picker) for prospective renters.
- Ownership verification workflow (users can be promoted to owner/poster role after validation).
- PayMongo Payment Intent checkout for renter payment. The first successful paid checkout reserves the dates.
- In-app messages and booking chats are created after payment confirmation.
- QR handover and return checkpoints for compliance and status tracking.
- Post-return settlement actions for owner completion, damage deduction requests, renter response, and admin review.
- Payout destination setup for owner payouts and renter security deposit returns.
- Save listings as favorites and post reviews after completed bookings.

---

## Process Logic

### Listing creation

Owners create or edit a listing from the mobile app. The listing can include a security deposit switch and required deposit amount. When enabled, the deposit is saved on the listing as structured security deposit data and renters must have a deposit return destination before booking.

Listing data is written to:

- `assets/{assetId}` as the public listing.
- `users/{ownerId}/assets/{assetId}` as the owner listing mirror used by owner screens.

### Discover and asset details

Discover builds an in-memory list of up to 36 available nearby assets. The first visible page shows 12 items, and normal infinite scroll pages from that in-memory cache without another Firestore query. Authenticated users also load recommended and popular rails through Cloud Functions.

Asset details refresh the single listing document and load up to 30 booking documents from `assets/{assetId}/bookings` for date blocking.

### Booking and payment

The renter selects dates and a payment method. Mobile calls `createPaymentCheckout`, then PayMongo handles the Payment Intent flow. Mobile listens to `paymentCheckouts/{checkoutId}` until the checkout becomes booked, failed, expired, or cancelled.

When payment succeeds, Cloud Functions create the canonical booking at `bookings/{bookingId}`, renter and asset booking mirrors, booking chat records, lifecycle events, and date locks. Owner funds are not released at payment time.

If the listing has a security deposit, the renter must set a deposit return destination before checkout. Deposit return is a PayMongo wallet payout to the renter destination, not a PayMongo refund.

### Handover, return, and settlement

The chat screen shows role-specific booking actions above the chat text field. QR handover marks the item as handed over. QR return only marks the item as returned and moves settlement to `awaiting_owner_action`.

Returned status does not finalize the rental, release owner payout, or return the security deposit.

After return, the owner chooses:

- `Complete Rental`: completes the booking, starts owner payout, and starts full deposit return if a deposit exists. Risk-flagged bookings require admin review.
- `Request Damage Deduction`: records the requested amount, reason, evidence URLs when supported, and notes. The renter can accept or dispute, but all damage deduction requests still require admin approval before money moves.

Admin review can approve the full requested amount, approve an adjusted amount, or reject the deduction. After admin decision, the approved deduction is calculated, the remaining deposit return is processed, owner payout is released according to business rules, and settlement is marked completed.

---

## Firestore, Function, and Storage Counts

These counts document the current mobile-visible flow and the main server-side Firestore work it triggers. They are estimates/formulas because queries, photos, booking length, and notification tokens vary.

Variables:

- `N`: documents returned by a query.
- `D`: booked rental days/date locks.
- `P`: uploaded photos.
- `A`: owner listing count.
- `B`: booking count.
- `M`: chat message count.
- `T`: enabled FCM token count for a notified user.

| Process | Mobile client operations | Server-side operations triggered |
| --- | --- | --- |
| Discover first load | Up to 36 asset reads for nearby/locality/country fallback. Recently viewed is local storage. Authenticated users also make 2 Function calls for recommended and popular rails. | Recommendation Functions read/write recommendation data and return up to 12 items per rail. |
| Discover load more | 0 Firestore reads in the normal path; it pages from the in-memory 36-asset cache. | None. |
| Asset details | 1 asset read + up to 30 booking reads for calendar blocking. | None. |
| Create listing | `P` Storage uploads + 2 Firestore writes (`assets/{assetId}`, `users/{ownerId}/assets/{assetId}`). Post-save refresh may read Discover, Now, and My Listings again. | None. |
| Update listing | 2 Firestore writes for public listing and owner mirror. Refresh may read Discover, Now, My Listings, and the asset detail again. | None. |
| Delete listing | 2 Firestore writes to soft-delete public listing and owner mirror. | None. |
| My listings | Listener on `users/{ownerId}/assets` owner mirrors. Initial snapshot reads `A` docs, then receives changed listing mirrors. Pull-to-refresh restarts the listener. | None. |
| Saved listings | `N` reads from `users/{uid}/saved`. Saving writes 1 saved doc. Removing deletes 1 saved doc. | Save also calls `recordRecommendationEvent`. |
| Now tab | Renter side listens to active docs from `users/{uid}/bookings`. Owner side listens to `A` owner asset mirrors and active booking docs under each owned asset. | None. |
| Messages list | Up to 20 chat summary reads per listener snapshot from `userChats/{uid}/chats`. | None. |
| Open chat | Message stream reads `M` message docs as loaded by the chat page. Mark-as-read writes 1 chat summary doc. | None. |
| Send chat message | 3 Firestore writes: 1 message doc + 2 user chat summary updates. Media messages also upload files to Storage before sending. | None. |
| Report, archive, delete chat | Report creates 1 report doc. Archive/delete updates 1 user chat summary doc. | None. |
| Start checkout | 1 Function call to `createPaymentCheckout` + 1 listener on `paymentCheckouts/{checkoutId}`. | Reads listing, renter, owner/renter payment profiles, Remote Config, and overlap query. Writes `D` date locks and 1 checkout doc, then updates checkout with PayMongo Payment Intent data. |
| Successful payment confirmation | Listener receives checkout updates. | Creates 1 root booking, 2 booking mirrors, chat docs, user chat docs, lifecycle events, checkout update, `D` booked date locks, and recommendation engagement updates. |
| QR handover or return | 1 Function call to `verifyAndMark`. | Reads root/user/asset booking docs. On first completion, writes root/user/asset booking updates, root/user/asset lifecycle events, 1 system message, and 2 user chat summary updates. Return sets settlement to `awaiting_owner_action` only. |
| Owner complete rental | 1 Function call to `updateBookingSettlement`. | Writes canonical/mirror booking completion, system chat updates, owner payout movement, and deposit return movement when applicable. Each movement also updates booking settlement movement status. |
| Owner damage deduction request | 1 Function call to `updateBookingSettlement`. | Writes canonical/mirror booking state, damage deduction request, system chat updates, 1 renter notification doc, and reads up to `T` renter FCM token docs. |
| Renter accepts/disputes deduction | 1 Function call to `updateBookingSettlement`. | Writes canonical/mirror booking state, renter response, system chat updates, 1 owner notification doc, and reads up to `T` owner FCM token docs. Money is not settled yet. |
| Admin resolves damage deduction | Mobile does not perform this action. | Admin Function writes final settlement, starts owner payout and deposit return movement, writes system chat updates, and notifies renter/owner. |

Cloud Functions Firestore reads and writes are still billable Firestore operations, even when the mobile app only made one callable Function request.

---

## Mobile Permissions

- Internet and network state: used to sign in, sync listings and bookings, load maps, upload photos, send messages, receive notifications, and complete verification. This has no runtime prompt.
- Location while in use: used to show nearby rentals and help set accurate listing or pickup locations. Users can continue and choose a location later.
- Notifications: used to send booking requests, chat replies, confirmations, verification updates, and rental reminders.
- Camera: used to take listing, profile, chat, and verification photos, and to scan booking QR codes.
- Photo library/gallery: used to select listing, profile, chat, verification, and QR images, and to save generated booking QR codes when requested.
- Biometrics/Face ID: used only when the user enables biometric sign-in or confirms protected account actions.

---

## Push Notifications / FCM Setup

The app registers FCM tokens after sign-in and unregisters the current token before sign-out. Tokens are stored by callable Cloud Functions under each user and are used for booking and chat notifications.

What you need to configure outside the repo:

- Firebase Console: confirm the Android package and iOS bundle ID are both `com.lend.mobile`.
- Firebase Console: keep `google-services.json` and `GoogleService-Info.plist` current if the Firebase app configuration changes.
- Apple Developer: create or reuse an APNs authentication key.
- Firebase Console: upload the APNs key under Project Settings > Cloud Messaging for the iOS app.
- Xcode / Apple Developer: make sure the signing profile for `com.lend.mobile` includes Push Notifications.
- iOS testing: use a physical iPhone for APNs delivery testing.
- Backend: deploy the updated Cloud Functions after mobile release testing.

---

## Tech Stack & Packages

- Flutter (managed via **FVM**)
- State management: **GetX**
- Local caching: **Get Storage**
- Auth: **Firebase Auth** (Google Sign-In, Apple Sign-In, Facebook Sign-In)
- Realtime DB: **Firebase Firestore**
- Media hosting: **Firebase Storage**
- Remote policy: **Firebase Remote Config** for pricing and fee transparency.
- Maps: **Google Maps SDK** for Android & iOS

---

## Folder Structure

Current mobile app structure:

```
lib/
├── core/                  # bindings, mixins, models, services, middleware
├── presentation/
│   ├── common/            # app-wide reusable UI primitives
│   ├── controllers/       # GetX controllers, grouped by feature
│   └── pages/             # feature pages and page-local widgets
│       ├── navigation/
│       │   └── components/
│       │       ├── home/  # Discover tab page + widgets
│       │       ├── now/   # Now tab page + widgets
│       │       └── ...
│       └── saved/         # Saved page + widgets
├── utilities/             # constants, data, enums, extensions, helpers
└── main.dart
```

Page-specific widgets live beside their page in a `widgets/` directory, with one primary widget per file where practical. The old `my_rentals` navigation component has been renamed to `now`.

---

## Authentication & Roles

- Provided sign-in options: Google, Apple (iOS), Facebook, and email/phone if desired.
- After sign-up, users are default **renters**.
- Role-based rules are applied at Firestore Security Rules.

---

## FVM (Flutter Version Management)

Use FVM to lock the Flutter SDK per project. Include `.fvm/fvm_config.json` in repo if you want teammates to use the same version.

Common commands:

```bash
# install fvm
dart pub global activate fvm

# install the project SDK
fvm install

# fetch deps
fvm flutter pub get

# run
fvm flutter run
```

---

## Installation

1. Clone repository

```bash
git clone <repo-url>
cd lend
```

2. Install FVM & SDK

```bash
dart pub global activate fvm
fvm install
fvm use <version>
```

3. Install dependencies

```bash
fvm flutter pub get
```

4. Firebase & Google Maps setup

- Create Firebase project, enable Auth, Firestore, Storage.
- Register iOS & Android apps and add `GoogleService-Info.plist` / `google-services.json`.
- Copy `envs/.local.example.env`, `envs/.dev.example.env`, and `envs/.prod.example.env` to their matching `.env` files and fill in local Google Maps keys.
- Add `GOOGLE_MAPS_PLATFORM_API_KEY=<key>` to `android/local.properties` for Android native Maps initialization.
- Copy `ios/Flutter/Env.example.xcconfig` to `ios/Flutter/Env.xcconfig` for iOS native Maps initialization.
- Restrict Google Maps keys in Google Cloud Console. If a key was ever committed or shared, rotate it before production use.

---

## Running the App

**Recommended**: Run using `Debug and Run` via **VSCode**. All available builds are listed already.

or use your preferred **CLI**:

- Android emulator: `fvm flutter run -d emulator-5554`
- iOS simulator: `fvm flutter run -d <ios-sim>`
- Release builds:

  - Android: `fvm flutter build apk --release`
  - iOS: `fvm flutter build ipa --release`

---

## Testing

- Unit tests: `fvm flutter test`
- Integration tests: `integration_test/` + `fvm flutter drive --target=integration_test/app_test.dart`

---

## Security & Rules

- Firestore security rules must prevent unauthorized creation/modification of `assets`, `bookings`, and `chats`.

- Only the owner and renter should be able to read/write messages in a chat.

- Validate date ranges and prevent overlapping `confirmed` bookings at the rules or backend level.
- Use Firebase App Check to reduce unauthorized API calls from fake clients.

---

## Troubleshooting

- **Images not uploading**: check Storage rules & CORS config (if using REST uploads). Verify the upload path and file size.
- **Map not showing**: verify API keys, billing enabled in Google Cloud, and the package setup for both platforms.
- **Auth providers failing**: confirm OAuth client IDs, redirect URIs, and that the bundle/package names match your Firebase app.

---

## To do

❌ App preferences settings

❌ Preset photos

---

## License

Lend is MIT licensed. See `LICENSE`.

---

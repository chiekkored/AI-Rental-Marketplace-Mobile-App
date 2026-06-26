# Lend Mobile Project Context

## 1. Executive Summary
Lend Mobile is a Flutter marketplace for short-term rentals of physical assets such as cameras, vehicles, tools, camping gear, and electronics. Owners list idle assets for rent; renters browse, request dates, negotiate in chat, and complete handover and return through QR verification.

From the current mobile codebase, the product operates more like a booking-and-messaging platform than a fully managed commerce flow. Booking proposals, chat creation, saved listings, ratings, and QR verification are in-app. Actual payment is still handled outside the app through chat agreement. That product constraint affects both business logic and data integrity: a booking can be proposed in the app, but final reservation still depends on a later confirmation step.

The effective user modes in the app are:
- Guest: can browse public listings but is gated from booking, chat, saved listings, and most protected routes.
- Authenticated renter: can sign in, view profile, save items, open chats, and request bookings if renting eligibility is enabled.
- Listing-eligible owner: can create and manage listings and accept booking requests if listing eligibility is enabled.

Eligibility is enforced in the mobile app through GetX route middlewares:
- `AuthMiddleware`
- `RentEligibleMiddleware`
- `ListingEligibleMiddleware`

That means the current UX assumes the client is responsible for blocking protected flows before they reach Firestore or callable Functions.

## 2. Flutter Architecture
### Overall shape
The app is a feature-first Flutter app using GetX for:
- dependency injection
- route registration
- controller lifecycle
- reactive state with `Rx`, `Obx`, and `GetxController`

Top-level folder structure:
- `lib/core`
  - `models`: app data models and Firestore serialization
  - `services`: Firebase/Firestore/Storage/Functions helpers
  - `bindings`: route/controller wiring
  - `middlewares`: auth and eligibility gating
  - `mixins`: shared controller behavior
- `lib/presentation`
  - `controllers`: feature controllers containing most business logic
  - `pages`: screens and feature widgets
  - `common`: reusable UI primitives
- `lib/utilities`
  - `constants`, `enums`, `extensions`, `helpers`, `data`

### App bootstrap
`lib/main.dart` is the single routing entrypoint.

Startup flow:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `MainService.initializeFirebase()`
3. `MainService.intializeGetStorage()`
4. `MainService.initializeDeviceOrientation()`
5. `.env` loading from `envs/`
6. optional Firebase emulator wiring for `ENV=local`
7. app boot through `GetMaterialApp`

### Dependency injection
`RootBinding` registers several controllers as permanent singletons:
- `LoadingController`
- `AuthController`
- `ProfileController`
- `HomeController`
- `NowController`
- `YourListingController`
- `MessagesController`
- `SettingsController`
- `SavedController`

Feature routes then register route-scoped controllers through bindings, such as:
- `AssetController`
- `CalendarPickerController`
- `CalendarBookingsController`
- `ChatController`
- `PostListingController`
- `ProfileViewController`
- `ScanQRController`
- `SigninController`
- `SignUpController`
- `RatingReviewController`

### Navigation structure
The app shell is `NavigationPage`, implemented with `persistent_bottom_nav_bar_v2`.

Actual tabs in the current UI:
1. Discover
2. Saved
3. Now
4. Messages
5. Profile

`LNDBottomNavPage` now matches the real 5-tab shell:
- `discover`
- `saved`
- `now`
- `messages`
- `profile`

### Architecture pattern in practice
The app is nominally modular, but not layered in a strict sense.

Observed pattern:
- UI pages call feature controllers directly.
- Controllers contain orchestration and a large amount of business logic.
- Some data access goes through services like `LNDAssetService`, `LNDBookingService`, `LNDMessagingService`, and `LNDSavedService`.
- Some business-critical writes still happen directly on the client, but booking proposal creation itself now goes through a backend callable instead of being authored in `AssetController.bookAsset()`.

This means the codebase is not using a clean repository/domain/data separation. Firestore is effectively part of the presentation layer contract.

### Reactive data flow
The app relies heavily on live Firestore listeners for user-specific state:
- `AuthController` binds Firebase Auth state and starts/stops listeners.
- `ProfileController` listens to `users/{uid}`.
- `MessagesController` listens to `userChats/{uid}/chats`.
- `ChatController` listens to `users/{renterId}/bookings/{bookingId}` for a single booking.
- `ChatListController` listens to `chats/{chatId}/messages`.
- `NowController.listenToNow()` listens to a filtered subset of user bookings.

This provides real-time UX, but it also tightly couples UI state to denormalized document mirrors.

### Lifecycle and registration smells
- `MessagesBinding` now guards against duplicate `MessagesController` registration, so root-permanent ownership is no longer shadowed by an unconditional route binding.
- Several flows still assume old schema or old navigation behavior.
- Business rules are split between controller code, service code, and callable Functions, without one canonical mutation boundary.

## 3. UI / Screen Map
### Root shell
- `/navigation`: persistent 5-tab app shell
  - Discover
  - Saved
  - Now
  - Messages
  - Profile

### Auth and onboarding
- `/signin`: email/password plus Google and Apple sign-in
- `/signup`: email/password registration
- `/setup`: profile completion after sign-up
- `/eligiblity`: blocker page when user lacks required eligibility

Flow:
- guest enters app on navigation shell
- protected routes redirect to `/signin` through `AuthMiddleware`
- sign-up creates Firebase Auth user, then writes `users/{uid}`
- social sign-in creates a Firestore user only if `additionalUserInfo.isNewUser`

### Marketplace flow
- Discover tab: public asset discovery with search affordance, static recommended/popular rails, category grid, and category-grouped listtiles
- `/asset`: asset detail page
- `/photo-view`: full-screen image gallery
- `/product-showcase`: expanded showcase gallery
- `/all-reviews`: review list for an asset

Flow:
1. User opens Discover.
2. `HomeController` loads available assets from Firestore.
3. User taps asset card.
4. Asset detail opens through `/asset`.
5. `AssetController` fetches the full asset and the asset’s booking subcollection.
6. UI exposes:
   - detail content
   - map/location
   - reviews
   - saved state
   - reserve action or owner controls depending on current user

### Page widget organization
Page-specific widgets live beside the page that owns them in a local `widgets/` directory. Current navigation tab examples:
- `navigation/components/home/widgets` for Discover sections and listing tiles
- `navigation/components/now/widgets` for Now booking cards, tiles, chips, and empty/sign-in states
- `navigation/components/profile/widgets` for profile sections, actions, header, card, and sign-in state
- `saved/widgets` for saved listing cards and empty state

The former `my_rentals` navigation/controller folders have been renamed to `now`; code should use `NowController`, `NowPage`, and `LNDBottomNavPage.now`.

### Booking request flow
- `/calendar-picker`: renter date-range selection
- `/chat`: booking-linked chat thread

Flow:
1. On asset page, renter taps `Reserve`.
2. `AssetController.goToCalendarPicker()` expands active bookings into blocked calendar days.
3. `/calendar-picker` opens with unavailable dates and pricing callback.
4. User chooses a range.
5. `CalendarPickerController` calculates total price client-side.
6. Submit calls `AssetController.bookAsset()`.
7. That method now delegates booking proposal creation to a backend callable, then refreshes local state and navigation.
8. User is sent back to root and switched to the Now tab.

### Owner booking management flow
- `/calendar-bookings`: owner calendar showing pending and active bookings

Flow:
1. Owner opens an asset they own.
2. Asset bottom bar shows pending booking count.
3. Owner taps calendar icon.
4. `/calendar-bookings` opens with current asset bookings.
5. Owner selects a day to see pending requests.
6. Owner can:
   - open linked chat
   - accept a request
7. Acceptance currently goes through callable Function `confirmBooking`.

### Chat flow
- Messages tab: active chats
- `/archived-messages`: archived chats
- `/chat`: full booking-linked conversation

Flow:
1. Message list is sourced from `userChats/{uid}/chats`.
2. Tapping a chat opens `/chat`.
3. `ChatController` subscribes to the renter booking document.
4. `ChatListController` streams messages from `chats/{chatId}/messages`.
5. Sending a message appends to shared messages and updates both users’ mirrored chat summaries.

Chat page also exposes booking state:
- pending booking accept action for owners
- booking summary footer
- QR handover/return actions for active bookings
- booking info dialog for confirmed owner details

### Listing management flow
- `/your-listing`: owner listing dashboard
- `/post_listing`: create/edit listing form
- `/add-showcase`: manage showcase media

Flow:
1. Owner opens their listing dashboard.
2. Dashboard reads user asset mirrors.
3. For each asset, controller also fetches `assets/{assetId}/bookings` to compute pending badge counts.
4. Tapping `Create listing` opens `/post_listing`.
5. Images upload first to Firebase Storage.
6. Submit writes asset to both top-level asset collection and the owner’s asset mirror.
7. Editing reuses the same form and calls asset update service.
8. Delete is soft-delete through `isDeleted`.

### Saved listings
- Saved tab and `/saved`: saved/bookmarked assets for current user
- Saved tab app bar opens `/recently-viewed`: local recently viewed listing history in the same two-column grid style

Flow:
1. User bookmarks from asset detail.
2. Saved controller writes a simplified asset snapshot into `users/{uid}/saved/{assetId}`.
3. Saved page reads from that subcollection and displays a two-column grid.

### Now tab
- Now tab: current and incoming confirmed booking activity

Flow:
1. `NowController` reads renter booking mirrors from `users/{uid}/bookings`.
2. It also reads the user’s own asset mirrors and fetches `assets/{assetId}/bookings` for owner-side confirmed/active bookings.
3. Today’s confirmed/handed-over bookings render as a medium card when there is one item, otherwise as a list.
4. Incoming future confirmed bookings render as listtiles.
5. Each item shows an `Owner` or `Renter` chip to indicate the logged-in user’s role.

### QR verification flow
- `/qr-view`: render booking token as QR
- `/scan-qr`: scan QR live or from gallery
- `/token-view`: confirmation page before applying token mutation

Flow:
1. Confirmed booking exposes handover; handed-over booking exposes return.
2. One side shows QR, the other scans.
3. Scan verifies token via callable `verifyToken`.
4. App loads booking details and opens `/token-view`.
5. Proceed calls callable `verifyAndMark`.

### Ratings and reviews
- `/rating-review`: submit post-booking review
- `/all-reviews`: asset review history

Flow:
1. User reaches rating flow after return prompts it.
2. `LNDBookingService.rateAndReviewBooking()` now calls backend-owned review closeout, which writes the review, updates asset aggregates, moves both booking mirrors to `Completed`, archives the renter chat, and removes rating system messages.

### Settings and profile
- `/profile-view`: user profile details
- `/settings`: placeholder settings page

The Profile tab also links to:
- settings
- verification eligibility
- view own listings
- rental history / Now
- saved listings
- about
- sign out

Notifications are represented by a Profile header bell affordance, but notification data is not implemented in this repo. Settings contains only placeholder taps for notifications and app preferences.

## 4. Firestore Schema
This app uses a denormalized Firestore design. The same business entity is often stored in multiple places for read convenience.

### Top-level collections
#### `users/{uid}`
Canonical user profile document.

Fields observed:
- `uid`
- `firstName`
- `lastName`
- `dateOfBirth`
- `location`
- `photoUrl`
- `createdAt`
- `email`
- `phone`
- `type`
- `isListingEligible`
- `isRentingEligible`
- `userMetadataVersion`

Purpose:
- auth profile display
- route eligibility gating
- source for `SimpleUserModel` snapshots stored elsewhere

#### `assets/{assetId}`
Canonical asset listing document.

Fields observed:
- `id`
- `ownerId`
- `owner`
  - `uid`
  - `firstName`
  - `lastName`
  - `photoUrl`
  - `userMetadataVersion`
- `title`
- `description`
- `category`
- `rates`
  - `daily`
  - `weekly`
  - `monthly`
  - `annually`
  - `notes`
- `location`
  - `description`
  - `country`
  - `cityState`
  - `latLng`
  - `useSpecificLocation`
- `images`
- `showcase`
- `inclusions`
- `createdAt`
- `status`
- `isDeleted`
- `averageRating`
- `reviewCount`

Purpose:
- public marketplace feed
- asset detail page
- source of truth for listing content

#### `userChats/{uid}`
Chat index root for one user.

Fields observed on root doc:
- `isOnline`

Purpose:
- parent path for per-user chat summaries

#### `chats/{chatId}`
Shared chat root doc.

Fields observed:
- `chatType`

Purpose:
- parent path for shared message stream

### User subcollections
#### `users/{uid}/assets/{assetId}`
Owner-facing mirror of an asset.

Fields observed:
- simplified asset data via `SimpleAsset`
  - `id`
  - `owner`
  - `title`
  - `images`
  - `category`
  - `createdAt`
  - `status`
  - `location`
  - `isDeleted`

Used by:
- `YourListingController`

#### `users/{uid}/bookings/{bookingId}`
Renter-facing booking mirror.

Fields observed:
- `id`
- `chatId`
- `asset` snapshot
- `createdAt`
- `startDate`
- `endDate`
- `numDays`
- `payment`
- `renter` snapshot
- `status`
- `totalPrice`
- `tokens`

Used by:
- Now
- Chat booking subscription
- rating/review logic
- ongoing rental listener

#### `users/{uid}/saved/{assetId}`
Saved/bookmarked listing snapshot.

Fields observed:
- simplified asset snapshot matching `SimpleAsset`

Used by:
- Saved tab/page

### Asset subcollections
#### `assets/{assetId}/bookings/{bookingId}`
Asset-centric booking mirror for owner views and availability checks.

Fields mirror the booking structure above.

Used by:
- asset detail booking fetch
- owner calendar
- Now owner-side booking list
- overlap checks
- QR booking lookup

#### `assets/{assetId}/ratings/{bookingId}`
Per-booking review document.

Fields observed:
- `rating`
- `review`
- `userId`
- `timestamp`

Used by:
- review page
- aggregate rating updates on asset document

### Chat subcollections
#### `chats/{chatId}/messages/{messageId}`
Shared message stream.

Fields observed:
- `id`
- `text`
- `senderId`
- `createdAt`
- `type`
- `mediaUrl`

Message types:
- `System`
- `Text`
- `Image`
- `Video`
- `Rating`

#### `userChats/{uid}/chats/{chatId}`
Per-user mirrored chat summary document.

Fields observed:
- `id`
- `chatId`
- `bookingId`
- `renterId`
- `asset` snapshot
- `participants`
- `lastMessage`
- `lastMessageDate`
- `lastMessageSenderId`
- `createdAt`
- `hasRead`
- `status`

Status values:
- `Active`
- `Archived`
- `Deleted`

### Relationships and duplication
Current denormalized storage model:
- Asset is stored twice:
  - `assets/{assetId}`
  - `users/{ownerId}/assets/{assetId}`
- Booking is stored twice:
  - `users/{renterId}/bookings/{bookingId}`
  - `assets/{assetId}/bookings/{bookingId}`
- Chat summary is stored twice:
  - `userChats/{ownerId}/chats/{chatId}`
  - `userChats/{renterId}/chats/{chatId}`
- Messages are stored once:
  - `chats/{chatId}/messages/{messageId}`

Implication:
- Reads are optimized for screen-specific access.
- Consistency is fragile because several mirrors must update together.
- Repair and reconciliation are still limited, but document ownership is explicit:

| Data | Canonical write owner | Mirrors / readers | Repair path |
| --- | --- | --- | --- |
| Listing content | Mobile `LNDAssetService` for create/edit/delete | `users/{ownerId}/assets/{assetId}` owner mirror | No general repair job; keep writes batched |
| Booking request | Backend `createBookingRequest` callable | renter booking mirror and asset booking mirror | Backend owns both writes |
| Booking confirmation / QR / review | Backend callables and Cloud Task overlap cleanup | both booking mirrors plus chat summaries | Deterministic lifecycle chat messages; overlap cleanup returns structured partial results |
| Chat messages | Mobile `LNDMessagingService` for user messages; backend for system messages | per-user chat summaries | Deterministic IDs for backend lifecycle messages only |
| Saved listings | Mobile `LNDSavedService` | `users/{uid}/saved/{assetId}` snapshot | No automatic listing-update resync |
| User snapshots | Profile/user documents are canonical | asset, booking, chat participant snapshots | `UserService` versioning exists but is not integrated into all display/write paths |
| Ratings | Backend `submitBookingReview` callable | asset aggregate fields | Transactional aggregate update |

### Fields with special meaning
#### Booking tokens
Stored under booking as:
- `tokens.handoverToken`
- `tokens.returnToken`
- `tokens.handoverExpiry`
- `tokens.returnExpiry`

#### Booking action flags
Handover, return, and review closeout are no longer stored as nested booking action flags. They are represented by the booking `status` field and audit documents under each booking mirror’s `events` subcollection.

#### Soft delete
Listings are soft deleted through:
- `isDeleted: true`

No purge or archive flow is present in this repo.

## 5. Booking System Analysis
### Current booking model
Bookings are the center of the business logic.

The canonical booking representation is:
  - `startDate`
  - `endDate`
  - `numDays`

New booking creation and downstream logic use only the range fields above.
Mobile derives UI lifecycle state through `BookingLifecycle` helpers backed by the single persisted `status` field.

### End-to-end booking request flow
#### 1. Availability display
`AssetController.getBookings()` reads all bookings under:
- `assets/{assetId}/bookings`

The asset page derives:
- active booking dates
- `pendingBookingDates`

For renter booking selection:
- active bookings are expanded day-by-day into a `Set<DateTime>`
- those days are passed into `/calendar-picker` as blocked dates

#### 2. Date selection and price calculation
`CalendarPickerController` handles:
- date range selection
- blocked-day checks
- client-side price computation

Price calculation behavior:
- supports `daily`, `weekly`, `monthly`, `annually`
- total is calculated entirely client-side
- listing submission persists all supported rate fields; blank optional rates remain absent/null

#### 3. Booking creation
`AssetController.bookAsset()` is now a thin client orchestration method.

It:
1. validates basic local prerequisites
2. invokes the backend callable that creates the booking request
3. refreshes asset and rentals UI
4. returns the user to the main navigation flow

### Current schema contract
New booking proposals originate from the backend and use `startDate`, `endDate`, and `numDays`.
Date ranges are treated as exclusive-end intervals: a booking from Apr 10 to Apr 12
books Apr 10 and Apr 11, while Apr 12 is the return boundary and may be the start
of the next non-overlapping booking.

The main date-sensitive flows now expect this current range schema:
- `CalendarBookingsController`
- `ChatPage`
- `TokenViewPage`
- `NowPage`
- `LNDBookingService.isAssetAvailable()`

### Confirmation / acceptance flow
Owners can accept a booking from:
- owner calendar
- chat page

Current production path:
- `LNDBookingService.confirmBookingViaFunction()`
- callable name: `confirmBooking`
- find overlapping pending bookings
- confirm the selected booking in both mirrors
- decline overlapping pending bookings in both mirrors
- archive declined renters’ chat summaries
- insert a system message
- update both users’ chat summaries
- generate handover/return tokens

Current implementation note:
- confirmation depends on the canonical `startDate` and `endDate` fields written by booking creation
- because the app has no deployed persisted booking data, the remaining concern is documenting and preserving that schema contract

### Booking lifecycle in code
The mobile app and backend use one booking lifecycle enum:
- `Pending`
- `Confirmed`
- `HandedOver`
- `Returned`
- `Completed`
- `Declined`
- `Cancelled`

QR tokens remain credentials for handover/return, but they do not define lifecycle state. Backend callables update `status` and write audit events.

### Ongoing rentals
`NowController.listenToNow()` streams active booking statuses and filters them through shared day-normalization helpers.

### QR handover and return flow
After confirmation, booking tokens are expected to exist on the booking.

Mobile callable contracts:
- `confirmBooking`
- `makeToken`
- `verifyToken`
- `verifyAndMark`
- `regenerateToken`

Observed QR flow:
1. `Confirmed` booking exposes handover actions in chat and rental bottom sheets
2. one actor shows QR via `/qr-view`
3. other actor scans via `/scan-qr`
4. scan calls `verifyToken`
5. app fetches booking from `assets/{assetId}/bookings/{bookingId}`
6. `/token-view` shows asset/booking summary
7. user taps proceed
8. callable `verifyAndMark` moves `Confirmed -> HandedOver` or `HandedOver -> Returned`

### Rating and closeout flow
`LNDBookingService.rateAndReviewBooking()`:
- checks current user
- delegates to backend `submitBookingReview`
- requires returned booking state
- writes rating to asset subcollection
- updates aggregate `averageRating` and `reviewCount`
- moves booking to `Completed`
- archives renter chat summary
- deletes rating system messages from shared chat

That makes review submission part of the booking closeout lifecycle, not a standalone asset review action.

## 6. Chat System Analysis
### Chat model
Each booking creates one private chat thread.

Data is split into:
- shared message history under `chats/{chatId}/messages`
- per-user mirrored chat summaries under `userChats/{uid}/chats/{chatId}`

### Chat creation flow
Chat creation for new booking proposals now happens in the backend booking-creation callable rather than inside `AssetController._createMessage()`.

The mirrored chat summary includes:
- bookingId
- renterId
- simplified asset
- participant snapshots
- last message fields
- read state
- archive state

### Message sending
`LNDMessagingService.sendMessage()` handles normal message sending.

It:
1. creates new `Message`
2. appends it to shared `chats/{chatId}/messages`
3. updates sender mirrored chat summary
4. updates recipient mirrored chat summary

For media:
- image picker uploads file to Firebase Storage
- resulting URL is sent as message payload
- message `type` distinguishes image from text

### Read state
Read state is per-user and stored only in mirrored chat docs:
- `userChats/{uid}/chats/{chatId}.hasRead`

`ChatListController.updateHasRead()` marks the current user’s chat summary as read whenever the conversation is opened or refreshed.

### Archive behavior
Archive transitions happen in business flows, not in a dedicated chat module.

Observed archive cases:
- when overlapping pending bookings are declined during acceptance, the losing renter’s chat summary is archived
- when review is submitted, renter chat summary is archived

This means chat lifecycle depends on booking lifecycle rather than chat-owned rules.

### Current chat weaknesses
- Chat delete exists only as a context-menu UI affordance in `MessageItemW`; no deletion logic is implemented.
- Shared chat root stores almost no metadata beyond chat type.
- Firestore rules now exist in the serverless repo, but chat access should still be emulator-validated against the booking and inbox creation flows.
- Chat summary mirrors contain denormalized participant and asset data with no visible resync path beyond ad hoc refreshes.

## 7. Listing System Analysis
### Create listing flow
`PostListingController` owns the create/edit form.

Form state includes:
- title
- description
- category
- rates
- location
- cover photos
- showcase photos
- inclusions
- availability status

Image handling:
- user picks images locally
- app uploads files immediately to Firebase Storage
- UI tracks upload progress per file
- submission is blocked until uploads are complete

On submit:
1. controller validates form
2. controller builds `AddAsset`
3. `LNDAssetService.createAsset()` writes:
   - `assets/{assetId}`
   - `users/{ownerId}/assets/{assetId}`
4. Discover, Now, and Your Listings controllers are refreshed

### Edit listing flow
Editing uses the same page with `PostListingArguments(asset: asset)`.

The controller:
- preloads fields from asset
- tracks `isEditing`
- compares current state to `_initialAsset`
- calls `LNDAssetService.updateAsset()`

### Delete listing flow
Delete is soft-delete only.

`LNDAssetService.deleteAsset()`:
- sets `isDeleted = true` on top-level asset
- sets `isDeleted = true` on owner asset mirror
- removes local copies from Home and Your Listings controllers

The listing still exists in Firestore. No cascade cleanup is present for:
- bookings
- chats
- saved copies
- ratings

### Owner dashboard flow
`YourListingController.getMyAssets()`:
1. loads owner asset mirrors from `users/{uid}/assets`
2. reads `pendingBookingCount` from each mirror for badge counts

The previous N+1 read pattern has been replaced with denormalized pending counts
maintained by backend booking mutations.

### Location model
Listings support two location modes:
- exact pinned location
- obscured approximate area with circle radius

This is a strong product decision for privacy and is implemented consistently in:
- listing creation
- asset page map display
- booking summary map display

### Current listing weaknesses
- Storage paths are user-relative; rules are now source-controlled in the serverless repo and should be treated as part of the mobile contract.
- Asset owner info is denormalized into each listing and booking snapshot, but there is no built-in refresh of existing copies when owner metadata changes.
- There is a new `UserService` with `userMetadataVersion` caching logic, but it is not integrated into the rest of the app’s denormalized snapshot writes.

## 8. Risks / Inconsistencies
### Highest priority
#### 1. Data is duplicated heavily with limited repair tooling
Listings, bookings, and chats all have mirrors:
- top-level canonical doc
- user-scoped mirror
- asset-scoped mirror
- per-user chat index

Document ownership is explicit, but the repo still lacks robust repair tooling for stale saved snapshots, listing mirrors, and user metadata snapshots.

### Medium priority
#### 2. Settings and verification flows are incomplete
UI exists for:
- account verification
- notification settings
- app preferences

But the flows are placeholders in this mobile repo.

### Lower-level code quality issues
#### 3. Delete semantics are incomplete
Listing delete is soft delete only. There is no explicit policy for existing:
- bookings
- chats
- reviews
- saved mirrors

## 9. Recommended Refactors
### Priority 0: stabilize business correctness
1. Keep enforcing the current booking range schema.
   - `startDate`, `endDate`, and `numDays` are canonical.
   - Date ranges use exclusive-end semantics across booking creation, availability, calendar display, confirmation, QR, and rentals UI.

2. Keep booking lifecycle ownership backend-owned.
   - proposal creation, confirmation, QR mark, and review closeout are backend-owned
   - `status` is the single persisted lifecycle state
   - deterministic chat-side business events are now in place for core lifecycle messages

### Priority 1: reduce architectural fragility
3. Centralize remaining Firestore writes out of controllers.
   - controllers should orchestrate UI state
   - services or repositories should own mutation logic
   - asset id generation and chat read-receipts have been moved behind services; continue this cleanup for remaining controller-owned mutations

4. Define document ownership for denormalized fields.
   - which document is canonical
   - which mirrors exist only for reads
   - how mirrors are updated
   - which backend job or function repairs drift

5. Integrate `UserService` or remove it.
   Right now `userMetadataVersion` is a good idea with almost no influence on the actual write paths that matter.

### Priority 2: clean product contracts
6. Define deletion policy for assets with active bookings and chats.

## 10. Developer Quick Start
### How to think about this codebase
Start from the user flow, not the file tree.

Most important domains:
- listings: `PostListingController`, `YourListingController`, `LNDAssetService`
- bookings: `AssetController`, `CalendarPickerController`, `CalendarBookingsController`, `LNDBookingService`
- chats: `MessagesController`, `ChatController`, `ChatListController`, `LNDMessagingService`
- profile/auth: `AuthController`, `ProfileController`, `SigninController`, `SignUpController`

### Safe mental model
When changing behavior, always ask:
1. Which screen triggers this?
2. Which controller owns the action?
3. Does the controller write directly to Firestore or call a service/function?
4. Which mirrored documents must stay in sync?
5. Which listeners/screens will react to the change?

### High-risk areas
Treat these as dangerous until refactored:
- booking creation and confirmation
- anything using booking dates
- QR token verification flow
- chat archive behavior
- denormalized user/asset snapshots

### Areas that are relatively straightforward
- asset feed rendering
- saved listings
- review display
- static profile/settings UI
- category and presentation-layer changes

### Firebase Functions the mobile app depends on
Visible callable contracts from this repo:
- `createBookingRequest`
- `confirmBooking`
- `makeToken`
- `verifyAndMark`
- `verifyToken`
- `regenerateToken`

If any of those change in the backend repo, mobile booking, messaging, and QR flows can break immediately.

### Practical onboarding advice for future work
- Read `main.dart` first to understand route topology.
- Read `RootBinding` second to understand which controllers are always alive.
- For any feature, inspect its controller before touching UI.
- Search both controllers and services for Firestore writes before changing schema.
- Assume user-facing state may exist in more than one collection.
- Before shipping booking changes, verify both old and new schema consumers.
- VS Code launch configs now exist for `ENV=local` and `ENV=prod` in both the mobile repo and the shared workspace root.

### Current strong points
- Clear feature-first folder organization
- Reasonably consistent GetX routing and controller usage
- Good use of mirrored chat summaries for responsive inbox UX
- Listing creation UX is already shaped around real marketplace needs
- QR handover/return flow is a strong product differentiator

### Where it will break first at startup scale
- booking correctness under concurrent requests
- denormalized data drift
- security exposure through open storage and undocumented Firestore rules
- owner dashboard read amplification
- timezone-sensitive booking state

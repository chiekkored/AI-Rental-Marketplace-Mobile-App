# Common Flows

## Browse asset
- Home tab route
- `HomeController.getAssets()`
- `LNDAssetService.getAssetsPaginated()`
- reads top-level `assets`
- tapping card opens asset detail

## Book asset
- asset detail
- `AssetController.goToCalendarPicker()`
- `/calendar-picker`
- `CalendarPickerController`
- submit -> `AssetController.bookAsset()`
- writes booking mirrors, chat root, messages, mirrored chat summaries

## Accept booking
- owner asset detail bottom bar or chat footer
- `/calendar-bookings` or `/chat`
- `CalendarBookingsController.onTapBooking()` or `ChatController.onTapAccept()`
- callable `confirmBooking`
- asset and booking UI refresh follows

## Send message
- `/chat`
- `ChatController.sendMessage()`
- `LNDMessagingService.sendMessage()`
- writes shared message plus both mirrored chat summaries
- `ChatListController` and `MessagesController` listeners refresh

## Save listing
- asset detail bookmark button
- `SavedController.addSaved()` or `removeSaved()`
- writes `users/{uid}/saved/{assetId}`
- saved page reads saved subcollection

## Create or edit listing
- `/post_listing`
- `PostListingController.submit()`
- `LNDAssetService.createAsset()` or `updateAsset()`
- writes top-level asset and owner asset mirror
- home and listing controllers refresh

## Submit review
- `/rating-review`
- `RatingReviewController.submitRatingAndReview()`
- `LNDBookingService.rateAndReviewBooking()`
- writes asset rating, updates aggregates, marks booking reviewed, archives renter chat

# Listing Flow

## Create and edit
- `/post_listing` is owned by `PostListingController`
- the same form is used for create and edit
- image files upload first to Firebase Storage
- submit builds `AddAsset`
- `LNDAssetService.createAsset()` or `updateAsset()` writes:
  - `assets/{assetId}`
  - `users/{ownerId}/assets/{assetId}`

## Listing fields currently persisted
- owner snapshot
- title
- description
- category
- rates
- location
- images
- showcase
- inclusions
- createdAt
- status
- `isDeleted`

## Important behavior
- delete is soft delete only through `isDeleted`
- asset feed filters out deleted assets
- owner dashboard reads owner mirrors, then fetches asset bookings separately
- location supports exact pin or obscured area

## Pricing note
The UI exposes daily, weekly, monthly, and annual controls, but submit currently persists only the daily rate unless code is changed.

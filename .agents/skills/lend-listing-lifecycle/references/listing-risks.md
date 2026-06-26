# Listing Risks

## Dashboard scaling
- `YourListingController.getMyAssets()` performs N+1 booking reads

## Deletion semantics
- soft delete does not define cascade behavior for:
  - bookings
  - chats
  - ratings
  - saved mirrors

## Persistence mismatch
- rate editor UI is richer than the current write path

## Snapshot drift
- owner info is denormalized into asset docs and downstream booking/chat snapshots
- there is no visible automatic repair path in this repo

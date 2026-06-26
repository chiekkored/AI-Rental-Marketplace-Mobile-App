# Schema Risks

## Security
- No Firestore rules file was present in this repo snapshot.
- `storage.rules` currently allows public read and write on all paths.

## Denormalization
- Assets are stored in top-level docs and owner mirrors.
- Bookings are stored in renter mirrors and asset mirrors.
- Chat summaries are mirrored per participant.
- User and asset snapshots can drift without a guaranteed repair path visible in this repo.

## Query and index pressure
- asset feed pagination filters by `isDeleted`, `status`, category, and `createdAt`
- booking overlap logic uses `startDate`, `endDate`, and `status`
- owner dashboard performs N+1 booking reads

## Migration hazard
- booking creation still writes legacy `dates[]`
- several consumers expect `startDate/endDate`
- ongoing booking logic still depends on `dates[]`

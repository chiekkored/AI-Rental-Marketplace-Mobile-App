# Chat Risks

## Incorrect semantic authorship
- initial booking message text is written as if sent by the owner, even though booking creation starts from the renter flow

## Delete gap
- message list exposes a delete context action
- no actual delete logic is implemented in the repo

## Security visibility gap
- no Firestore rules file is present here to verify participant-only access

## Coupling
- chat archive and action behavior depends on booking lifecycle, not chat-only rules
- changes to booking state can silently affect chat UX

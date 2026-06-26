---
name: lend-listing-lifecycle
description: "Use this skill when changing Lend Mobile listing behavior: create and edit flows, image uploads, location privacy, owner dashboards, availability status, soft delete behavior, or asset mirror updates across top-level and user-scoped documents."
---

# Lend Listing Lifecycle

## Overview
This skill covers how listings are created, edited, stored, mirrored, displayed to owners, and soft deleted in Lend Mobile.

## When To Use
Use this skill for:
- create listing or edit listing work
- listing form changes
- media upload behavior
- listing availability or status changes
- owner dashboard behavior
- location privacy and mapping behavior
- asset delete semantics

## Workflow
1. Read [listing-flow.md](references/listing-flow.md) for the current lifecycle.
2. Read [listing-risks.md](references/listing-risks.md) before changing listing fields or dashboard queries.
3. Confirm whether the change touches:
   - `assets/{assetId}`
   - `users/{ownerId}/assets/{assetId}`
   - Storage upload paths
4. If changing form fields, verify whether the field is actually persisted on submit.
5. If changing delete behavior, explicitly account for linked bookings, chats, saved docs, and reviews.

## Required Checks
- Confirm if the change lives in `PostListingController`, `YourListingController`, `AssetController`, or `LNDAssetService`.
- Confirm whether the form is create mode or edit mode.
- Confirm whether the UI field is cosmetic only or truly written to Firestore.

## Output Expectations
When answering with this skill:
- state the listing lifecycle step being changed
- identify top-level asset doc and owner mirror impact
- call out Storage implications for image-related changes
- mention soft delete or dashboard read impact when relevant

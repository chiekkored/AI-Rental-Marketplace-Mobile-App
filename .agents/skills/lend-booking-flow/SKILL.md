---
name: lend-booking-flow
description: "Use this skill when working on Lend Mobile booking behavior: booking creation, pending and confirmed state changes, overlap handling, QR handover and return, review closeout, or any bug caused by the dates array and startDate/endDate migration."
---

# Lend Booking Flow

## Overview
This skill helps you analyze and change the booking lifecycle in Lend Mobile without missing mirrored Firestore writes, callable Function dependencies, or legacy schema traps.

## When To Use
Use this skill for requests involving:
- booking creation or booking request UX
- pending, confirmed, declined, or cancelled behavior
- asset availability and overlap checks
- QR handover and return flows
- booking reviews and chat archival
- bugs where booking state looks inconsistent across screens
- migration from `dates[]` to `startDate`, `endDate`, and `numDays`

Do not use this skill for generic asset CRUD unless the change affects booking data or booking-derived UI.

## Workflow
1. Read [booking-lifecycle.md](references/booking-lifecycle.md) for the current end-to-end flow.
2. Read [booking-touchpoints.md](references/booking-touchpoints.md) to identify the controller, service, and screen ownership for the affected step.
3. Before changing code, confirm all mirrored writes that must remain in sync:
   - `users/{renterId}/bookings/{bookingId}`
   - `assets/{assetId}/bookings/{bookingId}`
   - `userChats/{uid}/chats/{chatId}` when booking state affects chat visibility
4. If the request touches confirmation, QR, or return logic, treat callable Functions as part of the contract and describe backend behavior as inferred unless visible locally.
5. If the request touches date logic, explicitly check whether the code path still depends on legacy `dates[]`.

## Required Checks
- Confirm whether the code path reads legacy `dates[]`, newer `startDate/endDate`, or both.
- Confirm whether the UI is driven by booking `status`, nested flags like `handedOver` and `returned`, or both.
- Confirm whether the same booking state is surfaced in:
  - asset detail
  - owner calendar
  - my rentals
  - chat footer
  - QR and token screens

## Output Expectations
When answering with this skill:
- name the exact step in the lifecycle being changed
- list the Firestore documents and mirrors involved
- call out schema migration risk if `dates[]` is still in play
- mention the callable Function contract if confirmation or QR verification is affected

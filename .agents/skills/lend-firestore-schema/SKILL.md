---
name: lend-firestore-schema
description: "Use this skill when inspecting or changing Lend Mobile Firestore collections, subcollections, denormalized mirrors, security assumptions, indexes, or any field that is copied across users, assets, chats, bookings, saved items, or ratings."
---

# Lend Firestore Schema

## Overview
This skill is the Firestore map for Lend Mobile. Use it to identify where data lives, which documents are mirrors, and what must be updated together before changing a field or query.

## When To Use
Use this skill for:
- schema exploration
- adding or renaming Firestore fields
- changing collection structure
- updating query filters or indexes
- reasoning about denormalized copies
- security review of Firestore or Storage usage
- tracing stale data between canonical docs and mirrors

## Workflow
1. Read [schema-map.md](references/schema-map.md) for the current collection and subcollection map.
2. Read [schema-risks.md](references/schema-risks.md) before changing fields, queries, or security-sensitive flows.
3. Determine whether the target entity is canonical, mirrored, or both.
4. Enumerate every write fanout before editing code.
5. If a query is being changed, check for likely composite index impact.

## Required Checks
- Confirm whether the data is stored under:
  - top-level collection
  - user-scoped mirror
  - asset-scoped mirror
  - chat-scoped stream
- Confirm whether user snapshots or asset snapshots are embedded into the target document.
- Confirm whether there is a visible repo-local rules definition. If not, say so explicitly.

## Output Expectations
When answering with this skill:
- list the exact paths involved
- identify canonical doc versus read model mirror
- mention related indexes or security implications when relevant
- call out stale snapshot risk if denormalized user or asset data is embedded

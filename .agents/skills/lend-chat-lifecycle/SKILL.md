---
name: lend-chat-lifecycle
description: "Use this skill when changing Lend Mobile chat or inbox behavior: booking-linked chat creation, mirrored userChats documents, unread state, archived messages, media uploads, or any feature where booking state affects message visibility or chat actions."
---

# Lend Chat Lifecycle

## Overview
This skill covers how chats are created from bookings, how inbox summaries are mirrored per user, and how message actions interact with booking state in Lend Mobile.

## When To Use
Use this skill for:
- messages tab or archived messages work
- chat creation during booking flow
- unread state or inbox ordering bugs
- message send behavior
- media upload messages
- archive or delete behavior
- chat footer actions tied to booking state

## Workflow
1. Read [chat-flow.md](references/chat-flow.md) for the current message and inbox lifecycle.
2. Read [chat-risks.md](references/chat-risks.md) before changing authorship, archival, read state, or deletion behavior.
3. Confirm whether the change affects:
   - shared chat stream under `chats/{chatId}`
   - per-user mirrored chat summaries under `userChats/{uid}/chats/{chatId}`
   - booking-driven chat UI in `ChatController`
4. If the request mentions unread state, check `ChatListController.updateHasRead()`.
5. If the request mentions archive or deletion, verify whether there is backend support or only UI affordance.

## Output Expectations
When answering with this skill:
- distinguish shared messages from mirrored inbox docs
- identify which participant doc changes
- mention booking coupling if the chat behavior depends on booking state
- call out missing delete implementation when relevant

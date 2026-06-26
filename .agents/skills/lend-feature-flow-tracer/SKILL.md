---
name: lend-feature-flow-tracer
description: "Use this skill when you need to trace a Lend Mobile feature end to end, from route and screen entrypoint through controller logic, services or callable Functions, Firestore reads and writes, and the reactive UI updates that follow."
---

# Lend Feature Flow Tracer

## Overview
This skill gives a repeatable tracing method for Lend Mobile features so you can answer how it works and what a change will break with repo-specific precision.

## When To Use
Use this skill for:
- feature walkthroughs
- bug localization
- onboarding into a specific flow
- impact analysis before editing a controller or service
- answering where a specific behavior is implemented

## Tracing Workflow
1. Start at route registration in `main.dart` or the navigation helper.
2. Identify the page widget and the bound controller.
3. Trace controller actions triggered by taps, callbacks, or lifecycle hooks.
4. Identify whether the controller:
   - writes Firestore directly
   - calls a service
   - calls a callable Function
5. Identify the documents or collections read or written.
6. Identify which listeners, `Obx` widgets, or follow-up controller refreshes reflect the change in UI.

## Output Format
Prefer this order:
1. entrypoint route or screen
2. controller owner
3. main action method
4. Firestore or Function side effects
5. UI refresh path
6. risks or stale mirrors

## References
- Read [common-flows.md](references/common-flows.md) for pre-mapped flows.
- Read [controller-map.md](references/controller-map.md) to find the main domain owner before doing a deeper trace.

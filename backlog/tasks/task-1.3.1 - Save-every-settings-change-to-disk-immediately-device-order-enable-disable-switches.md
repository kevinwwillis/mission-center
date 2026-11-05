---
id: TASK-1.3.1
title: >-
  Save every settings change to disk immediately (device order, enable/disable
  switches)
status: In Progress
assignee: []
created_date: '2026-11-05T19:26:00Z'
updated_date: '2026-11-05T19:40:00Z'
labels: []
dependencies: []
parent_task_id: TASK-1.3
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kevin, 2026-11-05: 'when a user makes changes to this app, it instantly saves it. That way crashes and whatever don't matter. It just loads your settings off the disk.'
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-11-05 14:33 ET: Cause found in code, not a disk-write problem: GLib keyfile backend writes synchronously on every set_string (checked gkeyfilesettingsbackend.c). Real causes: (1) add_to_sidebar applied on/off overrides only in edit mode, so switched-off devices reappeared when re-added; (2) drag-end save dropped absent devices from the order; (3) late devices ignored saved order; (4) startup pass counted absent names as positions. Fixed in fc93dfb and 2f86165 (unit tests for order logic pass). Settings-change recorder running: systemd user unit mission-center-settings-watch, snapshots in ~/.local/state/mission-center-watch. Not yet verified in the running app: waits on the Flatpak build (TASK-1.2).

2026-11-05 14:41 ET: Review (Claude Sonnet, high) found upstream already fixed this on main: 253d2a5 'Fix sidebar ordering and visibility' (MR !538, closes #256 #461 #539 #540); it also found my fix missed that the startup reorder re-creates rows visible (hidden state lost). I skipped the check-upstream-first step. Reverted fc93dfb and 2f86165 (afcfbb4, c2d50a8) and cherry-picked 253d2a5 as b673fe6. Not yet built or tested.
<!-- SECTION:NOTES:END -->

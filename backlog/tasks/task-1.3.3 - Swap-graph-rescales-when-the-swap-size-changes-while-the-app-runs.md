---
id: TASK-1.3.3
title: Swap graph rescales when the swap size changes while the app runs
status: Done
assignee: []
created_date: '2026-11-05T21:20:00Z'
updated_date: '2026-11-05T21:34:00Z'
labels: []
dependencies: []
parent_task_id: TASK-1.3
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kevin, 2026-11-05 16:19 ET: Mission Center showed 100% swap use after he grew swap from 8 GB to 32 GB and then 64 GB; real use was ~48% (30.8 of 64 GB). Cause: the swap graph's top value and the 'Swap usage' total are set only once at startup (set_static_information), so used swap is drawn against the old size. Upstream main has the same code. Fix: update both on every reading when swap_total changes.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 With the app running, a swap size change shows the right percentage within one refresh
- [x] #2 Fresh launch still shows the right swap graph
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Fixed in 4afc41d (2026-11-05 16:34 ET). Test on hidden display with our build: 64 GiB swap 57% fill; temporary 32 GB swap file added (96 GiB) -> 38%; removed -> 57%. First test run hit the old build because the earlier test copy was still running (single instance); rerun on the new build.
<!-- SECTION:NOTES:END -->

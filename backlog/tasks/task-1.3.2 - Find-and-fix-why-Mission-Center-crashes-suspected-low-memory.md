---
id: TASK-1.3.2
title: Find and fix why Mission Center crashes (suspected low memory)
status: In Progress
assignee: []
created_date: '2026-11-05T19:26:00Z'
updated_date: '2026-11-05T19:52:00Z'
labels: []
dependencies: []
parent_task_id: TASK-1.3
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kevin, 2026-11-05: crashed at least 5 times; 'Likely because I run out of memory, but I don't think that should be crashing this app.' Find the cause from crash evidence first (coredumps, journal), then fix.
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-11-05 14:34 ET: Journal since 11-03: snap run died 11-03 18:28 (magpie SIGSEGV, respawn failed). Flatpak runs: two ended by SIGTERM at session end, two short runs and the 11-05 14:16:44 run ended with no log entry; no kernel OOM kill or oomd kill of Mission Center. 14:16:01 dsx-server started with --arena-gb 78; PC at 10 GB available, swap full. Apport ignores Flatpak apps. Our build logs exit code/signal per run (kevin/missioncenter-kevin). Asked Kevin what a crash looks like (aqua 218e81fc1291).

2026-11-05 14:40 ET: Kevin (aqua): a crash looks like 'Freezes' and 'Error dialog'; 14:16 was a crash. The app's own fatal dialogs log a g_critical first and none was logged at 14:16, so the dialog was most likely GNOME's 'not responding' force-quit (SIGKILL leaves no log). Guess, not checked: GPU 1 (display GPU, where Mission Center renders) was nearly full (dsx-server ~23 GB of 24.5 GB per card). Freeze recorder running: systemd user unit mc-freeze-watch (kevin/freeze-watch.sh), captures in ~/.local/state/mission-center-watch/freezes, ntfy alert on capture. Also seen: show_error_dialog_and_exit() ends in a busy 'loop {}' (spins a CPU core; freezes the UI if ever called on the main thread).

2026-11-05 14:53 ET: Reproduced a crash in our build: relaunch at 14:51:24 aborted at 14:51:30 (SIGABRT) with graph_widget_utils.rs:338 'index out of bounds: the len is 1 but the index is 1' (panic in a function that cannot unwind), 2 s after dsx-server stopped. Upstream fixed it in graph-widget 8aadf1c (mission-center#542: CPU graph built from an incomplete first reading). Ported as f646066. The official 1.2.0 has the same code. Kevin's 14:16 crash logged no panic, so it is not shown to be this one. Rebuild running.
<!-- SECTION:NOTES:END -->

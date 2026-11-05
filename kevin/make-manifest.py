#!/usr/bin/env python3
"""Write the Flatpak recipe for Kevin's build from upstream's own recipe.

Reads flatpak/io.missioncenter.MissionCenter.json (upstream's file, never
edited) and writes flatpak/io.missioncenter.MissionCenter.Kevin.json next to
it, so upstream recipe changes flow in on every rebase. The written file is
generated: it is listed in .git/info/exclude and never committed.

Changes made to upstream's recipe:
- app ID io.missioncenter.MissionCenter.Kevin, so it installs alongside the
  official Flathub app with its own settings folder;
- exported desktop file, icon and metainfo renamed to that ID, and the menu
  name gets the suffix " (Kevin)";
- the app starts through kevin/missioncenter-kevin, which passes the app ID
  and logs how each run ended (TASK-1.3.2).
"""
import json
from pathlib import Path

APP_ID = "io.missioncenter.MissionCenter.Kevin"
UPSTREAM_ID = "io.missioncenter.MissionCenter"

repo = Path(__file__).resolve().parent.parent
src = repo / "flatpak" / f"{UPSTREAM_ID}.json"
dst = repo / "flatpak" / f"{APP_ID}.json"

m = json.loads(src.read_text())
m["app-id"] = APP_ID
m["command"] = "missioncenter-kevin"
m["rename-desktop-file"] = f"{UPSTREAM_ID}.desktop"
m["rename-icon"] = UPSTREAM_ID
m["rename-appdata-file"] = f"{UPSTREAM_ID}.metainfo.xml"
m["desktop-file-name-suffix"] = " (Kevin)"

m["modules"].append(
    {
        "name": "kevin-launcher",
        "buildsystem": "simple",
        "build-commands": [
            "install -Dm755 missioncenter-kevin /app/bin/missioncenter-kevin",
            # The exported launcher must go through the wrapper too.
            f"sed -i 's/^Exec=missioncenter/Exec=missioncenter-kevin/' "
            f"/app/share/applications/{UPSTREAM_ID}.desktop",
        ],
        "sources": [{"type": "file", "path": "../kevin/missioncenter-kevin"}],
    }
)

dst.write_text(json.dumps(m, indent=4) + "\n")
print(dst)

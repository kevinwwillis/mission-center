# mission-center: Kevin's patched build of Mission Center

A fork of [Mission Center](https://gitlab.com/mission-center-devs/mission-center)
(GPL-3.0-or-later) carrying Kevin's fixes, set up so upstream releases come in
with as little work as possible (Kevin, 2026-11-05 14:24 ET).

## Branches and remotes

- `upstream`: the official GitLab repo. Never push there.
- `origin`: public GitHub fork, `kevinwwillis/mission-center`.
- `kevin` (default branch): upstream's latest release tag plus our commits on top.
  Each fix is one commit. On a new upstream release, rebase `kevin` onto the new
  tag, then rebuild and retest. This is the one place this repo rewrites a pushed
  branch (`git push --force-with-lease origin kevin`); the old tip is tagged
  `kevin-on-<upstream tag>` before the rebase so nothing is lost.

## Rules

- Before fixing a problem, check upstream's issues, open merge requests and
  `main` for an existing fix. Prefer theirs.
- Keep our own files out of upstream's paths (`AGENTS.md`, `backlog/`, and a
  `kevin/` folder for our build files) so rebases do not conflict. Change
  upstream files only for the fix itself.
- Our build installs alongside the Flathub app under its own app ID; it never
  replaces `io.missioncenter.MissionCenter`.
- Fixes inside the `subprojects/magpie` submodule need their own fork of magpie;
  plan that per fix.
- Sending a fix upstream is publishing in Kevin's name: ask him per fix.

# Updating to a new upstream release

How to bring a new Mission Center release into branch `kevin` (TASK-1.4,
2026-11-05 15:10 ET).

We merge each upstream release tag into `kevin`; we never rebase `kevin`,
because it is published and history is not rewritten.

## Steps

1. Fetch upstream and pick the release tag:

   ```bash
   git fetch upstream --tags
   git tag --sort=-v:refname | head -3
   ```

2. List what we carry on top of upstream, so you know what to expect:

   ```bash
   git log --oneline --no-merges <old-tag>..kevin -- src subprojects flatpak
   ```

   Commits marked "(cherry picked from commit ...)" or "Ported from upstream"
   are upstream's own fixes. If the new release contains them, keep
   upstream's version in any conflict.

3. Merge the tag and resolve conflicts:

   ```bash
   git merge --no-ff <new-tag> -m "Merge upstream <new-tag> (<date> ET)"
   git submodule update --init --recursive
   ```

   - `src/performance_page/widgets/graph_widget_utils.rs`: upstream moved this
     code to the `subprojects/graph-widget` crate after 1.2.0, and it already
     holds our ported fix (graph-widget 8aadf1c). If the release has the
     crate, accept upstream's deletion of the old file.
   - `src/main.rs` `flatpak_data_dir()`: keep the `FLATPAK_ID` lookup unless
     upstream has an equivalent.
   - Our own files (`AGENTS.md`, `backlog/`, `kevin/`) never conflict.

4. Build and install: `kevin/build.sh` (see the header for the
   `systemd-run` line with the memory cap).

5. Test on a hidden display, never on Kevin's screen:
   - `Xvfb :77` as a `systemd-run --user` unit; run the app with
     `DISPLAY=:77 flatpak run --user --nosocket=wayland --socket=x11
     --env=GDK_BACKEND=x11 io.missioncenter.MissionCenter.Kevin`.
   - Check: the sidebar order and hidden devices match the settings file;
     switch one device off, `kill -9` the app, relaunch, and confirm it is
     still off; then undo that change.
   - Launch it 5 times for 15 s each and check the journal for `panicked`.

6. Push `kevin` and note the release in the Backlog task for the update.

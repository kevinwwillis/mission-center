#!/bin/bash
# Build and install Kevin's Mission Center (io.missioncenter.MissionCenter.Kevin)
# as a user Flatpak, alongside the official app. Usage: kevin/build.sh
# Run it detached so it survives the Claude app, capped so it cannot push the
# PC out of memory:
#   systemd-run --user --unit=mc-kevin-build -p MemoryMax=10G -p Nice=19 \
#     -p IOSchedulingClass=idle kevin/build.sh
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
state="${XDG_CACHE_HOME:-$HOME/.cache}/mission-center-kevin-build"
mkdir -p "$state"
log="$state/build.log"
exec > >(tee -a "$log") 2>&1
echo "=== build start $(date '+%Y-%m-%d %H:%M:%S %Z') at $(git -C "$repo" rev-parse --short HEAD)"
# The build copies the working tree, so record anything not committed.
git -C "$repo" status --short | sed 's/^/    uncommitted: /'
manifest="$(python3 "$repo/kevin/make-manifest.py")"
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak-builder --user --install --force-clean --install-deps-from=flathub \
  --state-dir="$state/state" --jobs="$(( $(nproc) / 2 ))" \
  "$state/build-dir" "$manifest"
echo "=== build done $(date '+%Y-%m-%d %H:%M:%S %Z')"

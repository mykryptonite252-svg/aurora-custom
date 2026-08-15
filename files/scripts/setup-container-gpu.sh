#!/usr/bin/env bash
set -euo pipefail

# GPU access for containers.
#
# Aurora already ships ublue-nvctk-cdi.service, which generates the NVIDIA CDI
# spec with correct ordering against the driver load. Shipping a second service
# to do the same job would be duplication with a worse dependency graph, so we
# just enable theirs rather than replacing it.
systemctl enable ublue-nvctk-cdi.service || \
  echo "NOTE: ublue-nvctk-cdi.service not present in this base"

# Keeps the Flatpak NVIDIA runtime in step with the host driver. Without it,
# GPU-using Flatpaks (Zoom, browsers) break after a driver bump.
systemctl enable ublue-nvidia-flatpak-runtime-sync.service || \
  echo "NOTE: ublue-nvidia-flatpak-runtime-sync.service not present"

# SELinux boolean, applied on first boot (see the unit for why not here).
systemctl enable selinux-container-gpu.service

# HWP dynamic boost. EPP is deliberately left to tuned — see the unit.
systemctl enable cpu-hwp-boost.service

# thermald is Intel's thermal daemon and the correct choice on this silicon.
# power-profiles-daemon must stay disabled: it conflicts with tuned, and
# enabling it was a known breakage in the previous image attempt.
systemctl enable thermald.service || true

# HDMI link-retrain workaround (user-level unit) — enabled for every user via
# --global rather than a per-session `systemctl --user enable`, since there is
# no logged-in user at build time.
systemctl --global enable hdmi-link-retrain.service || \
  echo "NOTE: could not globally enable hdmi-link-retrain.service at build time"

# Disable Baloo indexing without removing the packages (plasma-desktop hard-
# requires kf6-baloo — see recipe.yml's Baloo section for the cascade this
# caused when it was removed instead).
systemctl --global enable baloo-disable.service || \
  echo "NOTE: could not globally enable baloo-disable.service at build time"

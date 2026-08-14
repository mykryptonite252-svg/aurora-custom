#!/usr/bin/env bash
set -euo pipefail

# Rootless podman cannot open the NVIDIA device nodes unless this SELinux
# boolean is set — nvidia-smi inside a container fails with
# "Insufficient Permissions". Baked in so it survives every rebase.
echo "Enabling container_use_devices SELinux boolean..."
setsebool -P container_use_devices on || \
  semanage boolean -m --on container_use_devices || \
  echo "WARNING: could not set container_use_devices at build time"

# Generate the CDI spec on every boot
systemctl enable nvidia-cdi-generate.service

# HWP dynamic boost. EPP is left to tuned — see cpu-hwp-boost.service.
systemctl enable cpu-hwp-boost.service

# Thermal + power management: thermald is Intel's thermal daemon and is the
# correct choice on this silicon. tuned handles the rest. power-profiles-daemon
# conflicts with tuned and must stay disabled - enabling it was a known
# breakage in the previous image attempt.
systemctl enable thermald.service || true

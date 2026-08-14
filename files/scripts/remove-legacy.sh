#!/usr/bin/env bash
set -euo pipefail

# cifs-utils's %preun scriptlet fails in the build container:
#
#   Error in %preun scriptlet: cifs-utils-0:7.6-2.fc44.x86_64
#   [RPM] %preun(cifs-utils-7.6-2.fc44.x86_64) scriptlet failed, exit status 2
#   line 44: /var/lib/rpm-state/nfs-server.cleanup: No such file or directory
#
# Same class of failure as samba-client (see remove-samba.sh): a scriptlet
# assumes live-system rpm state that does not exist during an image build.
# autofs, davfs2 and nfs-utils are the same network-filesystem family and
# were removed here pre-emptively via the same noscripts path, rather than
# discovering each one's scriptlet failure in a separate build cycle.
dnf5 -y --setopt=tsflags=noscripts remove \
  b43-fwcutter \
  b43-openfwwf \
  autofs \
  davfs2 \
  cifs-utils \
  cifs-utils-info \
  nfs-utils \
  antiword \
  catdoc \
  plasma-desktop-doc \
  kdegraphics-mobipocket \
  plasma-workspace-wallpapers

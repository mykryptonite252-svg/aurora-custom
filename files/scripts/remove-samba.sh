#!/usr/bin/env bash
set -euo pipefail

# samba-client's %postun scriptlet exits 2 inside the build container — RPM
# logs it as "Non-critical error" but the transaction aborts anyway. Found by
# running the build with --log-failed and reading past the generic
# "Rpm transaction failed" wrapper to the actual scriptlet output:
#
#   Running %postun scriptlet: samba-client-2:4.24.5-1.fc44.x86_64
#   Non-critical error in %postun scriptlet: samba-client-2:4.24.5-1.fc44.x86_64
#   [RPM] %postun(samba-client-...) scriptlet failed, exit status 2
#
# The dnf module (recipe-level `type: dnf`) has no option to skip scriptlets —
# checked the schema; `remove:` only accepts `packages` and `auto-remove`. So
# this group is removed here via dnf5 directly with tsflags=noscripts.
#
# Safe to skip scriptlets for this specific removal: these are packages being
# stripped from an image during a build, not a live system being reconfigured,
# so there is nothing for a postun cleanup hook (winbind state, alternatives,
# etc.) to meaningfully act on.
dnf5 -y --setopt=tsflags=noscripts remove \
  samba \
  samba-client \
  samba-client-libs \
  samba-common \
  samba-common-tools \
  samba-core-libs \
  samba-dcerpc \
  samba-ldb-ldap-modules \
  samba-libs \
  samba-ndr-libs \
  samba-usershares \
  samba-winbind \
  samba-winbind-clients \
  samba-winbind-modules \
  kdenetwork-filesharing

#!/usr/bin/env bash
# Installs (or rolls back) the Eastern-themed web console on a standard Tactical RMM server.
#
#   sudo ./apply-eastern-reskin.sh eastern-rmm-modern-web-v0.101.64.tar.gz    # install
#   sudo ./apply-eastern-reskin.sh --rollback                          # restore the last backup
#
# Only /var/www/rmm/dist (static files nginx serves) is touched. The API, database,
# agents and MeshCentral are not. Tactical's own update.sh replaces /var/www/rmm/dist
# on every run, so run this again after each server update.
set -euo pipefail

WEBROOT=/var/www/rmm
DIST=$WEBROOT/dist
SETTINGS=/rmm/api/tacticalrmm/tacticalrmm/settings.py

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }
[ -d "$DIST" ] || { echo "$DIST not found - is this a standard (non-Docker) Tactical RMM install?" >&2; exit 1; }

if [ "${1:-}" = "--rollback" ]; then
  LAST=$(ls -1d $WEBROOT/dist.before-eastern-* 2>/dev/null | sort | tail -1 || true)
  [ -n "$LAST" ] || { echo "No backup found in $WEBROOT." >&2; exit 1; }
  rm -rf "$DIST"; cp -a "$LAST" "$DIST"
  echo "Restored $LAST -> $DIST. Hard-refresh the browser (Ctrl+F5)."
  exit 0
fi

TAR=${1:?usage: sudo $0 eastern-rmm-web-vX.Y.Z.tar.gz | --rollback}
[ -f "$TAR" ] || { echo "$TAR not found." >&2; exit 1; }

# The themed build must match the web version this server expects.
TAR_VER=$(basename "$TAR" | sed -n 's/.*-v\([0-9][0-9.]*\)\.tar\.gz$/\1/p')
if [ -f "$SETTINGS" ]; then
  SRV_VER=$(sed -n 's/^WEB_VERSION = "\(.*\)"/\1/p' "$SETTINGS")
  if [ -n "$SRV_VER" ] && [ "$SRV_VER" != "$TAR_VER" ]; then
    echo "This server expects web v$SRV_VER but the package is v$TAR_VER." >&2
    echo "Rebuild the theme for v$SRV_VER with rebuild-eastern-reskin.sh, then install that package." >&2
    exit 1
  fi
fi

[ -f "$DIST/env-config.js" ] || { echo "$DIST/env-config.js missing - refusing to continue." >&2; exit 1; }

STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP=$WEBROOT/dist.before-eastern-$STAMP
STAGE=$(mktemp -d -p "$WEBROOT" .eastern-stage-XXXXXX)
trap 'rm -rf "$STAGE"' EXIT

tar -xzf "$TAR" -C "$STAGE"
[ -f "$STAGE/dist/index.html" ] || { echo "Package does not contain dist/index.html." >&2; exit 1; }
cp -a "$DIST/env-config.js" "$STAGE/dist/env-config.js"     # keep this server's API address
chown -R www-data:www-data "$STAGE/dist"

mv "$DIST" "$BACKUP"
mv "$STAGE/dist" "$DIST"

echo "Installed Eastern web console v$TAR_VER."
echo "Previous files kept at $BACKUP (undo with: sudo $0 --rollback)."
echo "Hard-refresh the browser (Ctrl+F5) to load it."

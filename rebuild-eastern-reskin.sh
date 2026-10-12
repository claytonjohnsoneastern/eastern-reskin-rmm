#!/usr/bin/env bash
# Rebuilds the Eastern-themed web console for any Tactical RMM web version.
# Run on a workstation or build box with git and Node.js 20+ (not on the RMM server).
#
#   ./rebuild-eastern-reskin.sh 0.101.64
#
# Find the version your server expects with:
#   grep ^WEB_VERSION /rmm/api/tacticalrmm/tacticalrmm/settings.py
set -euo pipefail

VER=${1:?usage: $0 <web version, e.g. 0.101.64>}
HERE=$(cd "$(dirname "$0")" && pwd)
PATCH=$(ls -1 "$HERE"/eastern-reskin-v*.patch | sort -V | tail -1)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

git clone --quiet --depth 1 --branch "v$VER" https://github.com/amidaware/tacticalrmm-web.git "$WORK/web"
cd "$WORK/web"

# --3way lets git merge the theme into newer upstream files. If upstream rewrote the
# header or the sign-in page this stops with a conflict instead of building something wrong.
if ! git apply --3way --whitespace=nowarn "$PATCH"; then
  echo "The theme patch did not apply cleanly to v$VER. Resolve the conflicts in $WORK/web by hand." >&2
  trap - EXIT
  exit 1
fi

npm install --no-audit --no-fund
npx quasar build

OUT="$HERE/eastern-rmm-web-v$VER.tar.gz"
tar -czf "$OUT" dist
echo "Built $OUT"

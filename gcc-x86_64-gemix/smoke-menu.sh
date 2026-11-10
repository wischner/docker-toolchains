#!/bin/bash
# MIT License; Copyright (C) 2026 Tomaz Stih.
set -euo pipefail
session=$(mktemp -d /tmp/gem-menu-smoke.XXXXXXXX)
export GEMD_SOCKET="$session/gemd.sock" GEM_RASTA_FRAMEBUFFER="$session/framebuffer"
export GEM_RASTA_PORT=5099 GEM_RASTA_INVERSE=off
server=
cleanup() {
    if [[ -n "$server" ]]; then kill "$server" 2>/dev/null || true; wait "$server" 2>/dev/null || true; fi
    cat "$session/server.log" >&2
    rm -f "$session/gemd.sock" "$session/framebuffer" "$session/server.log"
    rmdir "$session"
}
trap cleanup EXIT
gemd >"$session/server.log" 2>&1 &
server=$!
for ((i=0; i<100; ++i)); do
    [[ -S "$GEMD_SOCKET" ]] && break
    kill -0 "$server"
    sleep .05
done
[[ -S "$GEMD_SOCKET" ]]
"$1"
kill -0 "$server"

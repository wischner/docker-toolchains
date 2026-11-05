#!/bin/sh
# Prove the packaged Rasta viewer opens its framebuffer under the current display.
set -eu

log=/tmp/rasta-smoke.log
# cout is block-buffered when redirected, so the ready check is the
# framebuffer file Rasta creates before it enters the SDL loop.
stdbuf -oL -eL rasta --inverse off --cursor off --bpp 32 --port 5000 >"$log" 2>&1 &
pid=$!

i=0
while [ "$i" -lt 75 ]; do
    if [ -s /tmp/rasta.framebuffer ]; then
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
        exit 0
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "rasta exited during startup" >&2
        cat "$log" >&2
        exit 1
    fi
    i=$((i + 1))
    sleep 0.2
done

echo "timed out waiting for rasta" >&2
ls -l /tmp/rasta.framebuffer /tmp/rasta-smoke.log >&2 || true
cat "$log" >&2
kill "$pid" 2>/dev/null || true
exit 1

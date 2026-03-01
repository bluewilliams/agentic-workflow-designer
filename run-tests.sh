#!/usr/bin/env bash
# run-tests.sh - Headless test runner for AWD test suite
# Zero dependencies beyond Python 3 and Chrome/Chromium.
#
# Usage:  ./run-tests.sh          (auto-detect Chrome)
#         ./run-tests.sh --verbose (show individual failures)
#
# Exit codes: 0 = all pass, 1 = failures, 2 = setup error

set -euo pipefail

VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

# --- Locate Chrome ---
find_chrome() {
  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "$(command -v google-chrome 2>/dev/null || true)"
    "$(command -v chromium 2>/dev/null || true)"
    "$(command -v chromium-browser 2>/dev/null || true)"
  )
  for c in "${candidates[@]}"; do
    [[ -n "$c" && -x "$c" ]] && echo "$c" && return
  done
  echo ""
}

CHROME=$(find_chrome)
if [[ -z "$CHROME" ]]; then
  echo "Error: Chrome or Chromium not found." >&2
  exit 2
fi

# --- Find a free port ---
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("",0)); print(s.getsockname()[1]); s.close()')

# --- Start HTTP server ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 -m http.server "$PORT" --directory "$SCRIPT_DIR" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER_PID=$!
cleanup() { kill $SERVER_PID 2>/dev/null || true; wait $SERVER_PID 2>/dev/null || true; rm -f "${TMPFILE:-}"; }
trap 'cleanup' EXIT

# Wait for server to be ready
for i in $(seq 1 20); do
  curl -s "http://127.0.0.1:$PORT/tests.html" >/dev/null 2>&1 && break
  sleep 0.1
done

# --- Run headless Chrome and capture console output ---
TMPFILE=$(mktemp)

"$CHROME" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --disable-extensions \
  --disable-background-networking \
  --virtual-time-budget=30000 \
  --dump-dom \
  "http://127.0.0.1:$PORT/tests.html" \
  > "$TMPFILE" 2>/dev/null

# --- Parse results from the hidden cli-output element ---
CLI_JSON=$(python3 -c "
import sys, json, re
html = open('$TMPFILE').read()
m = re.search(r'<pre id=\"cli-output\"[^>]*>(.*?)</pre>', html, re.DOTALL)
if not m:
    print(json.dumps({'error': 'no test results found'}))
    sys.exit(0)
print(m.group(1))
")

if echo "$CLI_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' not in d else 1)" 2>/dev/null; then
  PASS=$(echo "$CLI_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['pass'])")
  FAIL=$(echo "$CLI_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['fail'])")
  TOTAL=$(echo "$CLI_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['total'])")
  ELAPSED=$(echo "$CLI_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['elapsed'])")

  if [[ "$FAIL" -eq 0 ]]; then
    echo "PASS: $PASS/$TOTAL tests passed (${ELAPSED}ms)"
    exit 0
  else
    echo "FAIL: $FAIL/$TOTAL tests failed (${ELAPSED}ms)"
    if $VERBOSE; then
      echo ""
      echo "$CLI_JSON" | python3 -c "
import sys, json
d = json.load(sys.stdin)
for f in d.get('failures', []):
    print(f'  FAIL {f[\"suite\"]} > {f[\"test\"]}')
    print(f'       {f[\"error\"]}')
    print()
"
    fi
    exit 1
  fi
else
  echo "Error: Could not parse test results from headless Chrome output." >&2
  echo "This may mean the tests timed out or index.html failed to load." >&2
  exit 2
fi

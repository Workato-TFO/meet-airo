#!/usr/bin/env bash
# Pre-publish checks — the repo-local mirror of the org publishing checklist.
# Scans tracked text files; exits 1 on any hit. Run by CI on every push and
# locally via .githooks/pre-push.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail=0

# Base64 data-URI payloads (embedded images) can be megabytes on a single
# line. Left in place, they slow every regex scan below to a crawl and can
# incidentally contain byte sequences that match a scan pattern (e.g. a
# name fragment appearing inside random image bytes), causing false-positive
# failures on legitimate content. Build a stripped scan copy once, up front,
# replacing each data URI's payload with a short placeholder — the rest of
# the file (real prose, real URLs, real names) stays intact for the scans.
# Exempt the renderer's exact semantic identifiers from the language scan;
# visible prose, alt text and accessibility labels remain subject to it.
SCAN_DIR="$(mktemp -d)"
trap 'rm -rf "$SCAN_DIR"' EXIT

SCAN_FILTER="$(cat <<'JAVASCRIPT'
const fs = require("node:fs");
const source = fs.readFileSync(0, "utf8").replace(
  /(data:[a-zA-Z0-9\/+.\-]+;base64,)[A-Za-z0-9+\/=]{100,}/g,
  "$1[BASE64-STRIPPED]"
);
let rawElement = "";
const scanned = source.replace(/<!--[\s\S]*?-->|<(?:[^"'<>]|"[^"]*"|'[^']*')*>/g, tag => {
  if (rawElement) {
    if (new RegExp("^</" + rawElement + "\\s*>$", "i").test(tag)) rawElement = "";
    return tag;
  }
  const rawStart = /^<(script|style|textarea|title|xmp|noembed|noframes)\b/i.exec(tag);
  if (rawStart) {
    rawElement = rawStart[1];
    return tag;
  }
  if (!/^<[a-z][\w:-]*\b/i.test(tag)) return tag;
  return tag.replace(/(\s+)([^\s"'=<>/]+)(\s*=\s*)(["'])([\s\S]*?)\4/g,
    (attribute, space, name, equals, quote, value) => {
      if (name.toLowerCase() === "class") {
        value = value.replace(/(^|\s)semantic-layout--hands-on-activity(?=\s|$)/g, "$1semantic-layout--activity");
      } else if (name.toLowerCase() === "data-semantic-class" && value === "hands-on-activity") {
        value = "activity";
      }
      return space + name + equals + quote + value + quote;
    });
});
process.stdout.write(scanned);
JAVASCRIPT
)"

while IFS= read -r -d '' f; do
  mkdir -p "$SCAN_DIR/$(dirname "$f")"
  git show ":$f" 2>/dev/null \
    | node --max-old-space-size=256 -e "$SCAN_FILTER" \
    > "$SCAN_DIR/$f"
done < <(git ls-files -z)

scan() {
  local label="$1" pattern="$2"
  if grep -I -r -n -E "$pattern" "$SCAN_DIR" --exclude='publish-checks.sh' >/tmp/publish-check-hits 2>/dev/null; then
    echo "FAIL [$label]"
    sed "s#^$SCAN_DIR/##" /tmp/publish-check-hits | head -10
    fail=1
  else
    echo "ok   [$label]"
  fi
}

# Secrets
scan "aws access key"        'AKIA[0-9A-Z]{16}'
scan "private key block"     'BEGIN [A-Z ]*PRIVATE KEY'
scan "github token"          'gh[pousr]_[A-Za-z0-9]{20,}'
scan "slack token"           'xox[abpr]-[A-Za-z0-9-]{10,}'
scan "live workato mcp token" 'wkt_token=[A-Za-z0-9_-]{10,}'

# Inclusive language (trainer ruling 2026-07-09)
scan "non-inclusive: hands-on" '[Hh]ands[- ]on'

# Internal surfaces
scan "internal repo pointer" 'static-web|Workato-TFO/bakery|PUBLISHING\.md'
scan "okta url"              '[a-z0-9.-]+\.okta\.com'
scan "internal confluence"   'workato\.atlassian\.net'
scan "slack archive link"    'slack\.com/archives'
scan "employee email"        '[A-Za-z0-9._%+-]+@workato\.com'

# Collaborator names — never in tracked content, commit messages, or PR text.
# (PRs and their commit lists become public with the repo and cannot be
# suppressed or rewritten — keep names out from the start.)
NAME_PATTERN='[Mm]ichael|[Mm]atias|[Ff]ederico|\bmpak\b|[Pp]aktinat|[Hh]eiwad|\b[Oo]sman\b'
if grep -I -r -n -E "$NAME_PATTERN" "$SCAN_DIR" --exclude='publish-checks.sh' >/tmp/publish-check-hits 2>/dev/null; then
  echo "FAIL [collaborator name in content]"; sed "s#^$SCAN_DIR/##" /tmp/publish-check-hits | head -10; fail=1
else
  echo "ok   [collaborator name in content]"
fi
if git log --format='%s%n%b' | grep -n -E "$NAME_PATTERN" >/tmp/publish-check-hits 2>/dev/null; then
  echo "FAIL [collaborator name in commit history]"; head -10 /tmp/publish-check-hits; fail=1
else
  echo "ok   [collaborator name in commit history]"
fi

if [ "$fail" -ne 0 ]; then
  echo
  echo "Publish checks failed — nothing internal may land in this repo."
  exit 1
fi
echo "All publish checks passed."

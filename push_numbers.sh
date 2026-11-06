#!/usr/bin/env bash
set -euo pipefail

NUMBERS_FILE="numbers.md"
URL="https://ntfy.sh/my-test-room-4755"
BATCH_SIZE=5

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

for (( i=0; i<total; i+=BATCH_SIZE )); do
  batch_num=$(( i / BATCH_SIZE + 1 ))
  batch=$(printf '%s\n' "${numbers[@]:i:BATCH_SIZE}" | paste -sd ',' - | sed 's/,/, /g')
  message="Batch $batch_num/$batches: $batch"
  if curl -sf -d "$message" "$URL"; then
    echo "Sent: $message"
  else
    echo "Failed to send batch $batch_num" >&2
    exit 1
  fi
done

echo "Done."

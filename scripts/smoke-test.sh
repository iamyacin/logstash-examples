#!/usr/bin/env bash
#
# End-to-end check for the file-based examples (01-05).
# Requires Elasticsearch on http://localhost:9200 and the demo image built.
#
# Usage:
#   make smoke
# or:
#   ./scripts/smoke-test.sh

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

ES_URL="${ES_URL:-http://localhost:9200}"

log() {
  printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

wait_for_es() {
  local attempt
  for attempt in $(seq 1 60); do
    if curl -fsS "$ES_URL/_cluster/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  printf 'Elasticsearch is not reachable at %s\n' "$ES_URL" >&2
  return 1
}

count_docs() {
  curl -fsS "$ES_URL/$1/_count" | sed -n 's/.*"count":\([0-9][0-9]*\).*/\1/p'
}

check_count() {
  local index=$1 expected=$2 actual="" attempt
  for attempt in $(seq 1 30); do
    actual=$(count_docs "$index" 2>/dev/null || true)
    if [[ "$actual" == "$expected" ]]; then
      printf '  \033[32mOK\033[0m   %-34s %s docs\n' "$index" "$actual"
      return 0
    fi
    sleep 1
  done
  printf '  \033[31mFAIL\033[0m %-34s expected %s, got %s\n' "$index" "$expected" "${actual:-0}" >&2
  return 1
}

run_example() {
  local example=$1
  local output
  output=$(mktemp)

  printf '\n  running %s ...\n' "$example"
  if ! EXAMPLE="$example" docker compose --profile pipeline run --rm -T logstash >"$output" 2>&1; then
    printf 'Pipeline failed: %s\n' "$example" >&2
    tail -n 40 "$output" >&2
    rm -f "$output"
    return 1
  fi
  rm -f "$output"
}

wait_for_es

log 'Deleting existing demo indices'
for index in $(curl -fsS "$ES_URL/_cat/indices/demo-*?h=index" 2>/dev/null || true); do
  curl -fsS -X DELETE "$ES_URL/$index" >/dev/null
  printf '  deleted %s\n' "$index"
done

log 'Running pipelines'
run_example 01-csv-to-elasticsearch
run_example 02-apache-log-to-elasticsearch
run_example 03-json-to-elasticsearch
run_example 04-json-arrays-to-elasticsearch
run_example 05-grok-patterns

log 'Checking document counts'
check_count demo-csv-tags 3683
check_count demo-apache-logs 102977
check_count demo-json-payments 3
check_count demo-json-array-events 10
check_count demo-grok-patterns 7

log 'All smoke tests passed'

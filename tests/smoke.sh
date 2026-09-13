#!/usr/bin/env bash

set -euo pipefail

BASE_URL="http://localhost:3000"
MAX_RETRIES=30
RETRY_DELAY_SECONDS=2
RUN_ID="$(date +%s)"
TASK_TITLE="Smoke Test Task ${RUN_ID}"
UPDATED_TASK_TITLE="Updated ${TASK_TITLE}"
UPLOAD_KEY="smoke-test-${RUN_ID}.txt"

HTTP_BODY=""
HTTP_STATUS=""

fail() {
  echo "Smoke test failed: $1" >&2
  exit 1
}

wait_for_status() {
  local path="$1"
  local expected_status="$2"
  local service_name="$3"
  local attempt=1
  local status

  while [ "$attempt" -le "$MAX_RETRIES" ]; do
    status="$(curl --silent --output /dev/null --write-out "%{http_code}" "${BASE_URL}${path}" || true)"

    if [ "$status" = "$expected_status" ]; then
      echo "${service_name} is ready."
      return 0
    fi

    echo "Waiting for ${service_name} (${attempt}/${MAX_RETRIES})..."
    sleep "$RETRY_DELAY_SECONDS"
    attempt=$((attempt + 1))
  done

  fail "${service_name} did not return HTTP ${expected_status} in time."
}

request() {
  local method="$1"
  local path="$2"
  local body="$3"
  local expected_status="$4"
  local response

  if [ -n "$body" ]; then
    response="$(curl --silent --show-error --request "$method" \
      --header "Content-Type: application/json" \
      --data "$body" \
      --write-out $'\n%{http_code}' \
      "${BASE_URL}${path}")"
  else
    response="$(curl --silent --show-error --request "$method" \
      --write-out $'\n%{http_code}' \
      "${BASE_URL}${path}")"
  fi

  HTTP_STATUS="${response##*$'\n'}"
  HTTP_BODY="${response%$'\n'*}"

  if [ "$HTTP_STATUS" != "$expected_status" ]; then
    echo "Response body: ${HTTP_BODY}" >&2
    fail "${method} ${path} returned HTTP ${HTTP_STATUS}; expected ${expected_status}."
  fi
}

assert_body_contains() {
  local expected="$1"

  if ! printf '%s' "$HTTP_BODY" | grep -Fq -- "$expected"; then
    echo "Response body: ${HTTP_BODY}" >&2
    fail "Expected response body to contain: ${expected}"
  fi
}

echo "Starting Docker Compose..."
docker compose up --build -d

wait_for_status "/health" "200" "API health check"
wait_for_status "/db-health" "200" "database health check"

echo "Testing task create..."
request "POST" "/api/tasks" "{\"title\":\"${TASK_TITLE}\",\"description\":\"Automated smoke test task\"}" "201"
assert_body_contains "$TASK_TITLE"
TASK_ID="$(printf '%s' "$HTTP_BODY" | node -pe 'JSON.parse(require("fs").readFileSync(0, "utf8")).id')"

if ! [[ "$TASK_ID" =~ ^[1-9][0-9]*$ ]]; then
  fail "Expected a positive numeric task ID, received: ${TASK_ID}"
fi

echo "Testing task list and read..."
request "GET" "/api/tasks" "" "200"
assert_body_contains "$TASK_TITLE"
request "GET" "/api/tasks/${TASK_ID}" "" "200"
assert_body_contains "$TASK_TITLE"

echo "Testing task update..."
request "PUT" "/api/tasks/${TASK_ID}" "{\"title\":\"${UPDATED_TASK_TITLE}\",\"description\":\"Updated automated smoke test task\",\"completed\":true}" "200"
assert_body_contains "$UPDATED_TASK_TITLE"
assert_body_contains '"completed":true'

echo "Testing invalid task input..."
request "POST" "/api/tasks" '{"title":""}' "400"

echo "Testing invalid task ID..."
request "GET" "/api/tasks/not-a-number" "" "400"

echo "Testing task delete and missing-record response..."
request "DELETE" "/api/tasks/${TASK_ID}" "" "200"
request "GET" "/api/tasks/${TASK_ID}" "" "404"

echo "Testing Floci-backed object upload and list..."
request "POST" "/api/uploads" "{\"key\":\"${UPLOAD_KEY}\",\"content\":\"Automated smoke test upload\"}" "201"
assert_body_contains "$UPLOAD_KEY"
request "GET" "/api/uploads" "" "200"
assert_body_contains "$UPLOAD_KEY"

echo "Smoke tests passed successfully."

#!/usr/bin/env bash
# Run after: docker compose up -d
# Verifies /metrics, Prometheus scrape, and Grafana reachability.

set -e
BASE="${BASE_URL:-http://localhost}"

echo "=== Checking app /metrics ==="
curl -sf "${BASE}:4000/metrics" | grep -q "http_requests_total" && echo "OK: /metrics exposes Prometheus metrics" || (echo "FAIL: /metrics"; exit 1)

echo "=== Checking Prometheus targets ==="
# App target should be up
UP=$(curl -s "${BASE}:9090/api/v1/targets" | grep -o '"health":"up"' | wc -l)
[ "$UP" -ge 1 ] && echo "OK: At least one target UP" || (echo "FAIL: No healthy targets"; exit 1)

echo "=== Checking Grafana ==="
curl -sf -o /dev/null "${BASE}:3000/api/health" && echo "OK: Grafana is up" || (echo "FAIL: Grafana"; exit 1)

echo "=== All checks passed ==="

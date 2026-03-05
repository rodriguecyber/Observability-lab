# Run after: docker compose up -d
# Verifies /metrics, Prometheus scrape, and Grafana reachability.
$ErrorActionPreference = "Stop"
$Base = if ($env:BASE_URL) { $env:BASE_URL } else { "http://localhost" }

Write-Host "=== Checking app /metrics ==="
$metrics = Invoke-WebRequest -Uri "${Base}:4000/metrics" -UseBasicParsing
if ($metrics.Content -match "http_requests_total") { Write-Host "OK: /metrics exposes Prometheus metrics" } else { throw "FAIL: /metrics" }

Write-Host "=== Checking Prometheus targets ==="
$targets = Invoke-RestMethod -Uri "${Base}:9090/api/v1/targets"
$up = ($targets.data.activeTargets | Where-Object { $_.health -eq "up" }).Count
if ($up -ge 1) { Write-Host "OK: At least one target UP" } else { throw "FAIL: No healthy targets" }

Write-Host "=== Checking Grafana ==="
Invoke-WebRequest -Uri "${Base}:3000/api/health" -UseBasicParsing | Out-Null
Write-Host "OK: Grafana is up"

Write-Host "=== All checks passed ==="

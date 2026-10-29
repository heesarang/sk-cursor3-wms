# Stop Spring Boot backend listening on port 8080.
# Usage: .\scripts\stop-backend.ps1
$ErrorActionPreference = "Continue"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PidFile = Join-Path $Root "logs\backend-wrapper.pid"

$listeners = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique

if ($listeners) {
    foreach ($procId in $listeners) {
        Write-Host "Stopping process on port 8080: $procId"
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "No listener found on port 8080."
}

if (Test-Path $PidFile) {
    $wrapperPid = (Get-Content $PidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    if ($wrapperPid -and (Get-Process -Id $wrapperPid -ErrorAction SilentlyContinue)) {
        Write-Host "Stopping wrapper PID $wrapperPid"
        Stop-Process -Id $wrapperPid -Force -ErrorAction SilentlyContinue
    }
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

Write-Host "Done."

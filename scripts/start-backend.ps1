# Start Spring Boot backend (Gradle bootRun) on port 8080.
# Usage: .\scripts\start-backend.ps1
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$LogDir = Join-Path $Root "logs"
$LogFile = Join-Path $LogDir "backend.log"
$PidFile = Join-Path $LogDir "backend-wrapper.pid"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$inUse = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
if ($inUse) {
    Write-Host "Port 8080 is already in use. Stop the existing process or change the server port."
    exit 1
}

$BackendDir = Join-Path $Root "backend"
$Gradle = Join-Path $BackendDir "gradlew.bat"
if (-not (Test-Path $Gradle)) {
    Write-Host "gradlew.bat not found at $Gradle"
    exit 1
}

# Same log file for stdout/stderr via cmd redirection (Start-Process cannot share one file for both).
$cmd = "cd /d `"$BackendDir`" && `"$Gradle`" bootRun >> `"$LogFile`" 2>&1"
$proc = Start-Process -FilePath "cmd.exe" `
    -ArgumentList "/c", $cmd `
    -PassThru `
    -WindowStyle Hidden

$proc.Id | Set-Content -Path $PidFile -Encoding ascii
Write-Host "Started backend (wrapper PID $($proc.Id)). Logs: $LogFile"
Write-Host "Wait until GET http://localhost:8080/v3/api-docs returns 200, then run tests or the frontend."

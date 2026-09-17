# Zyvo installer for Windows
# Run in PowerShell:
#   Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/zyvo9/ZYVO-AI/main/install-zyvo-windows.ps1 | iex

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ver = "1.17.9"
$base = "https://github.com/zyvo9/ZYVO-AI/releases/download/pc-v$ver"
$scanner = "https://omniroute-render-production-52cf.up.railway.app"
$dest = "$env:LOCALAPPDATA\Zyvo"

Write-Host "==> Downloading Zyvo v$ver (Windows x64)..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest "$base/zyvo-$ver-windows-x64.zip" -OutFile "$env:TEMP\zyvo.zip" -UseBasicParsing
Expand-Archive "$env:TEMP\zyvo.zip" -DestinationPath $dest -Force
Remove-Item "$env:TEMP\zyvo.zip" -Force

Write-Host "==> Fetching the live model list..." -ForegroundColor Green
$cfg = "$env:USERPROFILE\.config\zyvo"
New-Item -ItemType Directory -Force -Path $cfg | Out-Null
Invoke-WebRequest "$scanner/zyvo-config" -OutFile "$cfg\zyvo.json" -UseBasicParsing
"$scanner/active-models" | Out-File "$cfg\models-url" -Encoding ascii

Write-Host "==> Adding zyvo to your PATH..." -ForegroundColor Green
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$dest*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$dest", "User")
}

Write-Host ""
Write-Host "Zyvo v$ver installed!" -ForegroundColor Green
Write-Host "Open a NEW terminal and run:  zyvo"
Write-Host "(Re-run this installer any time to refresh the model list.)"

# Zyvo installer/updater for Windows
# Run in PowerShell:
#   Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/zyvo9/ZYVO-AI/main/install-zyvo-windows.ps1 -UseBasicParsing | iex
#
# Re-running the SAME command updates in place: binary only when the
# version changed, config + skills refreshed every time (delta-style,
# same promise as the Termux installer).

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

$repo = "zyvo9/ZYVO-AI"
$ver = "1.17.9"
$base = "https://github.com/$repo/releases/download/pc-v$ver"
$dest = "$env:LOCALAPPDATA\Zyvo"
$cfg = "$env:USERPROFILE\.config\zyvo"

# --- 1. Binary: download only when the version marker changed ---
$marker = "$dest\version.txt"
if ((Test-Path $marker) -and ((Get-Content $marker -Raw).Trim() -eq $ver)) {
  Write-Host "==> Binary already at v$ver - skipping download" -ForegroundColor DarkGray
} else {
  Write-Host "==> Downloading Zyvo v$ver (Windows x64)..." -ForegroundColor Green
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Invoke-WebRequest "$base/zyvo-$ver-windows-x64.zip" -OutFile "$env:TEMP\zyvo.zip" -UseBasicParsing
  Expand-Archive "$env:TEMP\zyvo.zip" -DestinationPath $dest -Force
  Remove-Item "$env:TEMP\zyvo.zip" -Force
  Set-Content -Path $marker -Value $ver
}

# --- 2. Config: refresh every run ---
Write-Host "==> Refreshing the default config..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $cfg | Out-Null
Invoke-WebRequest "https://raw.githubusercontent.com/$repo/main/config/zyvo.json" -OutFile "$cfg\zyvo.json" -UseBasicParsing

# --- 3. Skills: FULL tree, nested folders included (git trees API) ---
Write-Host "==> Deploying skills (full tree, nested folders included)..." -ForegroundColor Green
$tree = Invoke-RestMethod "https://api.github.com/repos/$repo/git/trees/main?recursive=1"
$skillFiles = $tree.tree | Where-Object { $_.path -like 'config/skills/*' -and $_.type -eq 'blob' }
foreach ($f in $skillFiles) {
  $rel = $f.path.Substring("config/skills/".Length)
  $target = Join-Path "$cfg\skills" $rel
  New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
  Invoke-WebRequest "https://raw.githubusercontent.com/$repo/main/$($f.path)" -OutFile "$target.tmp" -UseBasicParsing
  Move-Item "$target.tmp" $target -Force
}
Get-ChildItem "$cfg\skills" -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } | ForEach-Object {
  Write-Host ("   skill deployed: " + $_.Name) -ForegroundColor Cyan
}

# --- 4. Memory (AGENTS.md): deploy ONCE, never overwrite ---
$agents = "$cfg\AGENTS.md"
if (-not (Test-Path $agents)) {
  Invoke-WebRequest "https://raw.githubusercontent.com/$repo/main/config/AGENTS.md" -OutFile $agents -UseBasicParsing
  Write-Host "==> Memory (AGENTS.md) deployed" -ForegroundColor Green
}

# --- 5. PATH ---
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$dest*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$dest", "User")
}

Write-Host ""
Write-Host "Zyvo v$ver installed!" -ForegroundColor Green
Write-Host "Re-run the same install command anytime to update - only what changed is fetched."
Write-Host "Open a NEW terminal and run:  zyvo"
Write-Host "Models: opencode Zen (free via 'zyvo auth login') + Kilo Code (KILO_API_KEY)."
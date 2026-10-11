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

# --- 1. Binary: re-download when the release ASSET changes (version alone
#     doesn't change on rebuilt releases — track the asset's updated_at) ---
$marker = "$dest\version.txt"
$stamp = ""
try {
  $rel = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/tags/pc-v$ver"
  $asset = $rel.assets | Where-Object { $_.name -eq "zyvo-$ver-windows-x64.zip" } | Select-Object -First 1
  if ($asset) { $stamp = $asset.updated_at }
} catch { }
if ((Test-Path $marker) -and $stamp -and ((Get-Content $marker -Raw).Trim() -eq $stamp)) {
  Write-Host "==> Binary already up to date (v$ver, asset $stamp) - skipping download" -ForegroundColor DarkGray
} else {
  Write-Host "==> Downloading Zyvo v$ver (Windows x64)..." -ForegroundColor Green
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Invoke-WebRequest "$base/zyvo-$ver-windows-x64.zip" -OutFile "$env:TEMP\zyvo.zip" -UseBasicParsing
  Expand-Archive "$env:TEMP\zyvo.zip" -DestinationPath $dest -Force
  Remove-Item "$env:TEMP\zyvo.zip" -Force
  Set-Content -Path $marker -Value $stamp
}

# --- 2. Config: refresh every run ---
Write-Host "==> Refreshing the default config..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $cfg | Out-Null
Invoke-WebRequest "https://raw.githubusercontent.com/$repo/main/config/zyvo.json" -OutFile "$cfg\zyvo.json" -UseBasicParsing

# --- 3. Skills: FULL tree via ONE repo zip (2,400+ files land in seconds —
#     the per-file raw fetch made installs take many minutes) ---
Write-Host "==> Deploying skills (single repo zip - fast)..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path "$env:TEMP\zyvo-skills" | Out-Null
try {
  Invoke-WebRequest "https://codeload.github.com/$repo/zip/refs/heads/main" -OutFile "$env:TEMP\zyvo-skills\repo.zip" -UseBasicParsing
  Expand-Archive "$env:TEMP\zyvo-skills\repo.zip" "$env:TEMP\zyvo-skills\x" -Force
  $srcRoot = Get-ChildItem "$env:TEMP\zyvo-skills\x" -Directory | Select-Object -First 1
  $skillsSrc = Join-Path $srcRoot.FullName "config\skills"
  if (Test-Path $skillsSrc) {
    New-Item -ItemType Directory -Force -Path "$cfg\skills" | Out-Null
    Copy-Item (Join-Path $skillsSrc '*') "$cfg\skills" -Recurse -Force
  }
} catch {
  Write-Host "   fast deploy failed ($($_.Exception.Message)) - per-file fallback" -ForegroundColor DarkGray
  $tree = Invoke-RestMethod "https://api.github.com/repos/$repo/git/trees/main?recursive=1"
  $skillFiles = $tree.tree | Where-Object { $_.path -like 'config/skills/*' -and $_.type -eq 'blob' }
  foreach ($f in $skillFiles) {
    $rel = $f.path.Substring("config/skills/".Length)
    $target = Join-Path "$cfg\skills" $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    Invoke-WebRequest "https://raw.githubusercontent.com/$repo/main/$($f.path)" -OutFile "$target.tmp" -UseBasicParsing
    Move-Item "$target.tmp" $target -Force
  }
} finally {
  Remove-Item "$env:TEMP\zyvo-skills" -Recurse -Force -ErrorAction SilentlyContinue
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

# --- 4b. zyvo-update command: PC update = type `zyvo-update` ---
$updateCmd = Join-Path $dest "zyvo-update.cmd"
@'
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/zyvo9/ZYVO-AI/main/install-zyvo-windows.ps1 -UseBasicParsing | iex"
'@ | Set-Content -Path $updateCmd -Encoding Ascii

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
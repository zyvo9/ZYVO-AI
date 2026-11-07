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

# --- fast-fetch helper: curl.exe (built into Win10+) with retry/timeout/
#     progress; IWR fallback. Never hangs silently. ---
function Fetch($url, $out, $maxSec = 900) {
  $curl = "$env:WINDIR\System32\curl.exe"
  if (Test-Path $curl) {
    & $curl -L -# --retry 3 --retry-delay 2 --connect-timeout 15 --max-time $maxSec -o $out $url
    if ($LASTEXITCODE -eq 0 -and (Test-Path $out)) { return $true }
  }
  try { Invoke-WebRequest $url -OutFile $out -UseBasicParsing -TimeoutSec $maxSec; return (Test-Path $out) } catch { return $false }
}
function FastExtract($archive, $dest) {
  # tar.exe (bsdtar, built into Win10+) reads zip AND tar.gz, 3-10x faster
  # than Expand-Archive on thousands of small files
  $tar = "$env:WINDIR\System32\tar.exe"
  if (Test-Path $tar) { & $tar -xf $archive -C $dest; return }
  Expand-Archive $archive -DestinationPath $dest -Force
}


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
  if (-not (Fetch "$base/zyvo-$ver-windows-x64.zip" "$env:TEMP\zyvo.zip")) { throw "binary download failed" }
  FastExtract "$env:TEMP\zyvo.zip" $dest
  Remove-Item "$env:TEMP\zyvo.zip" -Force
  Set-Content -Path $marker -Value $stamp
}

# --- 2. Config: refresh every run ---
Write-Host "==> Refreshing the default config..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $cfg | Out-Null
Invoke-WebRequest "https://raw.githubusercontent.com/$repo/main/config/zyvo.json" -OutFile "$cfg\zyvo.json" -UseBasicParsing

# --- 3. Skills: ONE small skills.tar.gz release asset + tar extract (seconds) ---
Write-Host "==> Deploying skills (skills.tar.gz - fast)..." -ForegroundColor Green
$sha = ""
try { $sha = (Invoke-RestMethod "https://api.github.com/repos/$repo/commits/main").sha } catch { }
$stamp = "$cfg\skills.stamp"
if ($sha -and (Test-Path $stamp) -and ((Get-Content $stamp -Raw).Trim() -eq $sha)) {
  Write-Host "   skills already current - skipping" -ForegroundColor DarkGray
} else {
  New-Item -ItemType Directory -Force -Path "$cfg\skills" | Out-Null
  New-Item -ItemType Directory -Force -Path "$env:TEMP\zyvo-skills" | Out-Null
  $ok = Fetch "$base/skills.tar.gz" "$env:TEMP\zyvo-skills\skills.tar.gz" 300
  if (-not $ok) {
    $lat = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
    $a = $lat.assets | Where-Object { $_.name -eq "skills.tar.gz" } | Select-Object -First 1
    if ($a) { $ok = Fetch $a.browser_download_url "$env:TEMP\zyvo-skills\skills.tar.gz" 300 }
  }
  if ($ok) {
    tar -xzf "$env:TEMP\zyvo-skills\skills.tar.gz" -C "$cfg\skills"
  } else {
    Write-Host "   skills.tar.gz unavailable - whole-repo zip fallback" -ForegroundColor DarkGray
    if (Fetch "https://codeload.github.com/$repo/zip/refs/heads/main" "$env:TEMP\zyvo-skills\repo.zip" 900) {
      FastExtract "$env:TEMP\zyvo-skills\repo.zip" "$env:TEMP\zyvo-skills\x"
      $srcRoot = Get-ChildItem "$env:TEMP\zyvo-skills\x" -Directory | Select-Object -First 1
      $skillsSrc = Join-Path $srcRoot.FullName "config\skills"
      if (Test-Path $skillsSrc) {
        robocopy $skillsSrc "$cfg\skills" /E /MT:16 /NFL /NDL /NJH /NJS /NP | Out-Null
      }
    }
  }
  Remove-Item "$env:TEMP\zyvo-skills" -Recurse -Force -ErrorAction SilentlyContinue
  if ($sha) { Set-Content -Path $stamp -Value $sha }
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
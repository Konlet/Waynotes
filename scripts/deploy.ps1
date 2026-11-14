# Deploy Waynotes to the Forever AddOns folder.
# Excludes development-only trees (_questiedb, __pycache__, .git, .cursor).

param(
    [string]$Destination = "X:\World of Warcraft\_forever_\Interface\AddOns\Waynotes"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path $root)) {
    Write-Error "Addon root not found: $root"
}

$addonsParent = Split-Path -Parent $Destination
if (-not (Test-Path $addonsParent)) {
    Write-Error "AddOns folder not found: $addonsParent"
}

New-Item -ItemType Directory -Force -Path $Destination | Out-Null

Write-Host "Deploying Waynotes"
Write-Host "  from: $root"
Write-Host "  to:   $Destination"

$args = @(
    $root,
    $Destination,
    "/E",
    "/XD", "_questiedb", "__pycache__", ".git", ".cursor", "scripts",
    "/XF", "*.pyc", "*.py", ".DS_Store",
    "/NFL", "/NDL", "/NJH", "/NJS", "/nc", "/ns", "/np"
)

& robocopy @args
$code = $LASTEXITCODE

# Robocopy: 0-7 are success (0 = nothing copied, 1+ = files copied/extra).
if ($code -ge 8) {
    Write-Error "robocopy failed with exit code $code"
}

$toc = Join-Path $Destination "Waynotes.toc"
if (-not (Test-Path $toc)) {
    Write-Error "Deploy incomplete: Waynotes.toc missing at $Destination"
}

Write-Host "Deploy ok (robocopy code $code)"
Get-Item (Join-Path $Destination "Core.lua"),
         (Join-Path $Destination "Replace.lua"),
         (Join-Path $Destination "Guides.lua"),
         $toc |
    Select-Object Name, Length, LastWriteTime |
    Format-Table -AutoSize

exit 0

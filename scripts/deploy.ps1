# Deploy curated Waynotes files to the Forever AddOns folder.
# Mirrors the zip export: Waynotes.toc load list, logos, and Media.
# Only Guides/Forever/Curated/*_Curated.lua guides are included.

param(
    [string]$Destination = "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Waynotes"
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

$tocName = "Waynotes.toc"
$tocPath = Join-Path $root $tocName
if (-not (Test-Path -LiteralPath $tocPath)) {
    Write-Error "Missing $tocName"
}

$tocFiles = @()
foreach ($line in Get-Content -LiteralPath $tocPath) {
    $trimmed = $line.Trim()
    if ($trimmed -eq "" -or $trimmed.StartsWith("#")) {
        continue
    }
    $tocFiles += ($trimmed -replace "/", "\")
}

if ($tocFiles.Count -eq 0) {
    Write-Error "$tocName has no load entries"
}

$curated = @()
foreach ($relative in $tocFiles) {
    $source = Join-Path $root $relative
    if (-not (Test-Path -LiteralPath $source)) {
        Write-Error "TOC file missing: $relative"
    }
    if ($relative -like "Guides\*") {
        if ($relative -notmatch '^Guides\\Forever\\Curated\\.+_Curated\.lua$') {
            Write-Error "Waynotes.toc lists a non-curated guide: $relative"
        }
        $curated += $relative
    }
}

if ($curated.Count -eq 0) {
    Write-Error "Waynotes.toc lists no Curated guides"
}

$extras = @("logo.png", "logo.tga")
foreach ($name in $extras) {
    $source = Join-Path $root $name
    if (-not (Test-Path -LiteralPath $source)) {
        Write-Error "Missing addon file: $name"
    }
}

$mediaDir = Join-Path $root "Media"
if (-not (Test-Path -LiteralPath $mediaDir)) {
    Write-Error "Missing Media folder"
}

$mediaFiles = @(Get-ChildItem -LiteralPath $mediaDir -File | Where-Object {
    $_.Name -ne "_arrow_preview.png" -and $_.Name -ne ".DS_Store"
})
if ($mediaFiles.Count -eq 0) {
    Write-Error "Media folder has no runtime files"
}

function Copy-AddonFile {
    param(
        [string]$SourcePath,
        [string]$DestPath
    )
    $destDir = Split-Path -Parent $DestPath
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }
    Copy-Item -LiteralPath $SourcePath -Destination $DestPath -Force
}

Write-Host "Deploying Waynotes"
Write-Host "  from: $root"
Write-Host "  to:   $Destination"

if (Test-Path -LiteralPath $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $Destination | Out-Null

Copy-AddonFile -SourcePath $tocPath -DestPath (Join-Path $Destination $tocName)
foreach ($relative in $tocFiles) {
    Copy-AddonFile -SourcePath (Join-Path $root $relative) -DestPath (Join-Path $Destination $relative)
}
foreach ($name in $extras) {
    Copy-AddonFile -SourcePath (Join-Path $root $name) -DestPath (Join-Path $Destination $name)
}
foreach ($file in $mediaFiles) {
    Copy-AddonFile -SourcePath $file.FullName -DestPath (Join-Path $Destination "Media\$($file.Name)")
}

$deployedGuides = @(Get-ChildItem -LiteralPath (Join-Path $Destination "Guides") -Recurse -File -ErrorAction SilentlyContinue)
$nonCurated = @($deployedGuides | Where-Object {
    $_.FullName -notmatch '\\Guides\\Forever\\Curated\\.+_Curated\.lua$'
})
if ($nonCurated.Count -gt 0) {
    Write-Error ("Deploy contains non-curated guides:`n" + (($nonCurated | ForEach-Object { $_.FullName }) -join "`n"))
}
if ($deployedGuides.Count -ne $curated.Count) {
    Write-Error "Expected $($curated.Count) curated guides, deploy has $($deployedGuides.Count)"
}

$deployedToc = Join-Path $Destination $tocName
if (-not (Test-Path -LiteralPath $deployedToc)) {
    Write-Error "Deploy incomplete: $tocName missing at $Destination"
}

Write-Host "Deploy ok"
Write-Host "  curated guides: $($curated.Count)"
Get-Item (Join-Path $Destination "Core.lua"),
         (Join-Path $Destination "Replace.lua"),
         (Join-Path $Destination "Guides.lua"),
         $deployedToc |
    Select-Object Name, Length, LastWriteTime |
    Format-Table -AutoSize

exit 0

# Export a Forever Waynotes zip.
# The zip root is Waynotes/, matching the AddOns folder name.
# Load list comes from Waynotes.toc. Guide files must live under
# Guides/Forever/Curated and end in _Curated.lua.

param(
    [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path $root)) {
    Write-Error "Addon root not found: $root"
}

$tocName = "Waynotes.toc"
$tocPath = Join-Path $root $tocName
if (-not (Test-Path $tocPath)) {
    Write-Error "Missing $tocName"
}

# WowUp matches Forever clients by a release asset name ending in -forever.zip
if (-not $ZipPath) {
    $version = $null
    foreach ($line in Get-Content -LiteralPath $tocPath) {
        if ($line -match '^##\s*Version:\s*(.+)\s*$') {
            $version = $Matches[1].Trim()
            break
        }
    }
    if (-not $version) {
        Write-Error "Missing ## Version in $tocName"
    }
    $ZipPath = Join-Path (Split-Path -Parent $root) "Waynotes-$version-forever.zip"
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

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zipDir = Split-Path -Parent $ZipPath
if ($zipDir -and -not (Test-Path -LiteralPath $zipDir)) {
    New-Item -ItemType Directory -Force -Path $zipDir | Out-Null
}
if (Test-Path -LiteralPath $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
}

function Add-ZipEntry {
    param(
        $Archive,
        [string]$SourcePath,
        [string]$EntryName
    )
    $entry = $EntryName -replace "\\", "/"
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $Archive,
        $SourcePath,
        $entry,
        [System.IO.Compression.CompressionLevel]::Optimal
    ) | Out-Null
}

$archive = [System.IO.Compression.ZipFile]::Open(
    $ZipPath,
    [System.IO.Compression.ZipArchiveMode]::Create
)

try {
    Add-ZipEntry -Archive $archive -SourcePath $tocPath -EntryName "Waynotes/$tocName"
    foreach ($relative in $tocFiles) {
        Add-ZipEntry -Archive $archive -SourcePath (Join-Path $root $relative) -EntryName "Waynotes/$relative"
    }
    foreach ($name in $extras) {
        Add-ZipEntry -Archive $archive -SourcePath (Join-Path $root $name) -EntryName "Waynotes/$name"
    }
    foreach ($file in $mediaFiles) {
        Add-ZipEntry -Archive $archive -SourcePath $file.FullName -EntryName "Waynotes/Media/$($file.Name)"
    }
}
finally {
    $archive.Dispose()
}

$check = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $names = @($check.Entries | ForEach-Object { $_.FullName })
}
finally {
    $check.Dispose()
}

$bad = @($names | Where-Object {
    $_ -match '(^|/)(REFERENCE|Zygor|_questiedb|scripts)(/|$)' -or
    $_ -match 'ClassQuests|_arrow_preview|\.py$|\.json$|Vanilla\.toc$'
})
if ($bad.Count -gt 0) {
    Write-Error ("Zip contains excluded paths:`n" + ($bad -join "`n"))
}

$guideEntries = @($names | Where-Object { $_ -like "Waynotes/Guides/*" })
$nonCurated = @($guideEntries | Where-Object { $_ -notmatch '^Waynotes/Guides/Forever/Curated/.+_Curated\.lua$' })
if ($nonCurated.Count -gt 0) {
    Write-Error ("Zip contains non-curated guides:`n" + ($nonCurated -join "`n"))
}
if ($guideEntries.Count -ne $curated.Count) {
    Write-Error "Expected $($curated.Count) curated guides, zip has $($guideEntries.Count)"
}

Write-Host "Exported Forever addon"
Write-Host "  zip: $ZipPath"
Write-Host "  curated guides: $($curated.Count)"
$curated | ForEach-Object { Write-Host "    $_" }
Write-Host "  entries: $($names.Count)"
Get-Item -LiteralPath $ZipPath | Select-Object FullName, Length, LastWriteTime | Format-List

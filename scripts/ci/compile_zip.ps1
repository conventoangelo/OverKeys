### CI-specific ZIP compiler script
### This script creates a portable ZIP archive with flexible paths for CI usage

param(
    [Parameter(Mandatory=$true)]
    [string]$StagingPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$true)]
    [string]$Version
)

Write-Host "📦 Creating portable ZIP archive..." -ForegroundColor Cyan
Write-Host "   Version: $Version" -ForegroundColor Gray
Write-Host "   Staging: $StagingPath" -ForegroundColor Gray
Write-Host "   Output: $OutputPath" -ForegroundColor Gray

# Define paths
$outputFolderName = "overkeys_${Version}_x64"
$zipFileName = "${outputFolderName}.zip"
$tempDir = Join-Path $env:TEMP "overkeys_zip_staging\$outputFolderName"
$zipPath = Join-Path $OutputPath $zipFileName

# Remove LICENSE file if it exists (not needed in portable version)
$licenseFile = Join-Path $StagingPath "LICENSE"
if (Test-Path $licenseFile) {
    Remove-Item $licenseFile -ErrorAction SilentlyContinue
}

# Clean up any existing temp directory
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}

# Create temp directory structure
Write-Host "📁 Creating temporary directory structure..." -ForegroundColor Yellow
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

# Copy all items from staging directory to temp directory
Write-Host "📋 Copying files..." -ForegroundColor Yellow
Copy-Item -Path "$StagingPath\*" -Destination $tempDir -Recurse

# Remove existing ZIP if it exists
if (Test-Path $zipPath) {
    Remove-Item -Path $zipPath -Force
}

# Create ZIP file
Write-Host "🗜️ Compressing to ZIP..." -ForegroundColor Yellow
$tempParent = Split-Path $tempDir -Parent
Compress-Archive -Path "$tempParent\*" -DestinationPath $zipPath -Force

# Clean up temporary directory
Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
Remove-Item -Path (Split-Path $tempDir -Parent) -Recurse -Force -ErrorAction SilentlyContinue

# Verify output
if (Test-Path $zipPath) {
    $zipSize = (Get-Item $zipPath).Length / 1MB
    Write-Host "✅ ZIP archive created successfully!" -ForegroundColor Green
    Write-Host "📦 Output: $zipPath" -ForegroundColor Green
    Write-Host "📊 Size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create ZIP archive" -ForegroundColor Red
    exit 1
}

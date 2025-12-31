### CI-specific Windows build script
### This script builds the Flutter Windows app and stages files for InnoSetup compilation
### It accepts parameters for flexible CI usage

param(
    [Parameter(Mandatory=$true)]
    [string]$StagingPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$UseFvm = $false
)

Write-Host "🔨 Building Flutter Windows application..." -ForegroundColor Cyan

# Navigate to project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Determine Flutter command
$flutterCmd = if ($UseFvm) { "fvm flutter" } else { "flutter" }

# Clean and build
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
& $flutterCmd clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
& $flutterCmd pub get

Write-Host "🏗️ Building Windows release..." -ForegroundColor Yellow
& $flutterCmd build windows

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Stage files for InnoSetup
Write-Host "📁 Staging files to $StagingPath..." -ForegroundColor Yellow

Remove-Item $StagingPath -Force -Recurse -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $StagingPath | Out-Null

Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination $StagingPath -Recurse
Copy-Item -Path "assets\images\app_icon.ico" -Destination $StagingPath
Copy-Item -Path "LICENSE" -Destination $StagingPath
Copy-Item -Path "scripts\x64\*.dll" -Destination $StagingPath

Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host "📂 Files staged at: $StagingPath" -ForegroundColor Green

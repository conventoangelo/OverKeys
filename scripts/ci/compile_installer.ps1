### CI-specific InnoSetup compiler script
### This script compiles the InnoSetup installer with flexible paths for CI usage

param(
    [Parameter(Mandatory=$true)]
    [string]$StagingPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$true)]
    [string]$Version
)

Write-Host "🔧 Compiling InnoSetup installer..." -ForegroundColor Cyan
Write-Host "   Version: $Version" -ForegroundColor Gray
Write-Host "   Staging: $StagingPath" -ForegroundColor Gray
Write-Host "   Output: $OutputPath" -ForegroundColor Gray

# Navigate to project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Create output directory
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

# Read the InnoSetup script template
$issFile = Join-Path $PSScriptRoot "..\compile_exe-inno.iss"
$issContent = Get-Content $issFile -Raw

# Replace hardcoded paths with CI paths
$issContent = $issContent -replace 'D:\\inno\\', "$StagingPath\"
$issContent = $issContent -replace 'D:\\inno-result', $OutputPath
$issContent = $issContent -replace 'D:\\inno', $StagingPath

# Create temporary ISS file for compilation
$tempIssFile = Join-Path $env:TEMP "compile_exe-inno-ci.iss"
$issContent | Set-Content -Path $tempIssFile -Encoding UTF8

Write-Host "📝 Temporary ISS file created at: $tempIssFile" -ForegroundColor Gray

# Compile with InnoSetup
Write-Host "⚙️ Running InnoSetup compiler..." -ForegroundColor Yellow
$isccPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

if (-not (Test-Path $isccPath)) {
    Write-Host "❌ InnoSetup compiler not found at $isccPath" -ForegroundColor Red
    Write-Host "   Please install InnoSetup 6 or adjust the path" -ForegroundColor Red
    exit 1
}

& $isccPath $tempIssFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ InnoSetup compilation failed with exit code $LASTEXITCODE" -ForegroundColor Red
    Remove-Item $tempIssFile -ErrorAction SilentlyContinue
    exit $LASTEXITCODE
}

# Clean up temporary file
Remove-Item $tempIssFile -ErrorAction SilentlyContinue

# Verify output file exists
$expectedOutput = Join-Path $OutputPath "overkeys_${Version}_x64_setup.exe"
if (Test-Path $expectedOutput) {
    Write-Host "✅ Installer compiled successfully!" -ForegroundColor Green
    Write-Host "📦 Output: $expectedOutput" -ForegroundColor Green
} else {
    Write-Host "❌ Expected installer not found: $expectedOutput" -ForegroundColor Red
    exit 1
}

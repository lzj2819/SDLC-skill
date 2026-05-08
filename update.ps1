#Requires -Version 5.1
<#
.SYNOPSIS
    DevForge SDLC Skill Chain — Updater (Windows)

.USAGE
    .\update.ps1

This script updates DevForge by running git pull in the clone directory.
Since skills are junction-linked, no re-installation is needed.
#>

$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:USERPROFILE ".claude\devforge-skills"

function Write-Info { param([string]$Message) Write-Host "[INFO]  $Message" -ForegroundColor Cyan }
function Write-OK   { param([string]$Message) Write-Host "[OK]    $Message" -ForegroundColor Green }

if (-not (Test-Path (Join-Path $InstallDir ".git"))) {
    Write-Host "DevForge is not installed. Please run install.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Info "Checking for updates..."
Push-Location $InstallDir

# Fetch latest changes
git fetch origin main

$local = git rev-parse HEAD
$remote = git rev-parse origin/main

if ($local -eq $remote) {
    Write-OK "DevForge is already up to date."
    Pop-Location
    exit 0
}

Write-Info "New version available. Updating..."
git pull origin main

Write-OK "DevForge updated successfully!"
Write-OK "Current version: $(git log --oneline -1)"

Pop-Location

Write-Host ""
Write-Host "Junctions are automatically pointing to the new code."
Write-Host "Restart Claude Code or run /reload to use the updated skills."

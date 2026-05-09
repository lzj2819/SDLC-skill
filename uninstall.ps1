#Requires -Version 5.1
<#
.SYNOPSIS
    DevForge SDLC Skill Chain — Uninstaller (Windows)

.USAGE
    .\uninstall.ps1
#>

$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:USERPROFILE ".claude\devforge-skills"
$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"

function Write-Info  { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn  { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }

$confirm = Read-Host "Are you sure you want to uninstall DevForge? [y/N]"
if ($confirm -notmatch '^[Yy]$') {
    Write-Info "Uninstall cancelled."
    exit 0
}

$skills = @(
    "devforge-requirement-analysis"
    "devforge-architecture-design"
    "devforge-architecture-validation"
    "devforge-design-review"
    "devforge-project-scaffolding"
    "devforge-module-design"
    "devforge-test-execution"
    "devforge-iteration-planning"
    "devforge-visualization"
    "devforge-ops-ready"
    "devforge-debug-assistant"
    "devforge-security-audit"
    "ai-agent-design"
    "data-pipeline-design"
    "mobile-app-design"
)

Write-Info "Removing skill junctions..."
foreach ($skill in $skills) {
    $linkPath = Join-Path $SkillsDir $skill
    # Use Get-Item with -ErrorAction SilentlyContinue to handle broken junctions
    # (junction targets that no longer exist, e.g. after moving to a different PC)
    $item = Get-Item -LiteralPath $linkPath -ErrorAction SilentlyContinue
    if ($item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        Remove-Item -LiteralPath $linkPath -Force
        Write-Info "Removed junction: $skill"
    }
}

$removeRepo = Read-Host "Remove the cloned repository at $InstallDir? [y/N]"
if ($removeRepo -match '^[Yy]$') {
    Remove-Item -Recurse -Force $InstallDir -ErrorAction SilentlyContinue
    Write-Info "Removed $InstallDir"
}

Write-Info "Uninstall complete. Restart Claude Code or run /reload."

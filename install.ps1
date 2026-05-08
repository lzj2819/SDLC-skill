#Requires -Version 5.1
<#
.SYNOPSIS
    DevForge SDLC Skill Chain — One-Click Installer (Windows)

.DESCRIPTION
    This installer uses a symlink-based approach:
    1. Clones the repo once to %USERPROFILE%\.claude\devforge-skills\
    2. Creates directory junctions in %USERPROFILE%\.claude\skills\ pointing to each skill directory
    3. Updates are done via "git pull" in the clone directory — no re-download needed

.USAGE
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lzj2819/DevForge/main/install.ps1" -OutFile "install.ps1"; .\install.ps1
    Or locally: .\install.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoUrl = "https://github.com/lzj2819/DevForge.git"
)

$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:USERPROFILE ".claude\devforge-skills"
$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"

function Write-Info  { param([string]$Message) Write-Host "[INFO]  $Message" -ForegroundColor Cyan }
function Write-OK    { param([string]$Message) Write-Host "[OK]    $Message" -ForegroundColor Green }
function Write-Warn  { param([string]$Message) Write-Host "[WARN]  $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

function Print-Banner {
    Write-Host ""
    Write-Host "=============================================================="
    Write-Host "          DevForge SDLC Skill Chain Installer v1.3            "
    Write-Host "     Symlink-based install — update with a single git pull    "
    Write-Host "=============================================================="
    Write-Host ""
}

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is not installed. Please install Git first: https://git-scm.com/download/win"
        exit 1
    }
    Write-OK "Git is installed"

    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Warn "Python is not installed. Some validation scripts may not work."
    } else {
        Write-OK "Python is installed"
    }
}

function Ensure-Directories {
    Write-Info "Creating directories..."
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
    Write-OK "Directories ready"
}

function Clone-Or-UpdateRepo {
    if (Test-Path (Join-Path $InstallDir ".git")) {
        Write-Info "Existing installation found at $InstallDir"
        Write-Info "Updating via git pull..."
        Push-Location $InstallDir
        git pull origin main
        Pop-Location
        Write-OK "Updated to latest version"
    } else {
        Write-Info "Cloning DevForge repository..."
        git clone $RepoUrl $InstallDir
        Write-OK "Repository cloned to $InstallDir"
    }
}

function Remove-OldLinks {
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
        "context-compression"
        "ai-agent-design"
        "data-pipeline-design"
        "mobile-app-design"
    )

    foreach ($skill in $skills) {
        $linkPath = Join-Path $SkillsDir $skill
        if (Test-Path $linkPath) {
            $item = Get-Item $linkPath
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Remove-Item $linkPath -Force
            }
        }
    }
}

function New-SkillLinks {
    Write-Info "Creating skill junctions in $SkillsDir..."

    $coreSkills = @(
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
        "context-compression"
    )

    $count = 0

    # Link core skills
    foreach ($skill in $coreSkills) {
        $src = Join-Path $InstallDir $skill
        $dst = Join-Path $SkillsDir $skill

        if (Test-Path $src) {
            New-Item -ItemType Junction -Path $dst -Target $src -Force | Out-Null
            Write-OK "Linked: $skill"
            $count++
        } else {
            Write-Warn "Skill directory not found: $skill"
        }
    }

    # Link extension skills (flatten into skills dir)
    $extensions = @(
        "ai-agent-design"
        "data-pipeline-design"
        "mobile-app-design"
    )

    foreach ($ext in $extensions) {
        $src = Join-Path $InstallDir "extensions\$ext"
        $dst = Join-Path $SkillsDir $ext

        if (Test-Path $src) {
            New-Item -ItemType Junction -Path $dst -Target $src -Force | Out-Null
            Write-OK "Linked: extensions\$ext → $ext"
            $count++
        } else {
            Write-Warn "Extension directory not found: $ext"
        }
    }

    Write-OK "$count skills linked successfully"
}

function Test-Installation {
    Write-Info "Validating installation..."

    Push-Location $InstallDir
    python scripts\package-plugin.py --mode all --output .\dist 2>$null | Out-Null
    Pop-Location

    $skillCount = 0
    Get-ChildItem -Path $SkillsDir -Directory | ForEach-Object {
        $skillMd = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $skillMd) {
            $skillCount++
        }
    }

    if ($skillCount -ge 10) {
        Write-OK "Validation passed: $skillCount skills detected"
    } else {
        Write-Warn "Only $skillCount skills detected (expected 10+). Check junctions."
    }
}

function Print-NextSteps {
    Write-Host ""
    Write-Host "=============================================================="
    Write-Host "                  Installation Complete!                      "
    Write-Host "=============================================================="
    Write-Host ""
    Write-Host "📁 Repository cloned to:  $InstallDir"
    Write-Host "🔗 Skills linked in:     $SkillsDir"
    Write-Host ""
    Write-Host "🚀 Next steps:"
    Write-Host "   1. Restart Claude Code or run: /reload"
    Write-Host "   2. Verify with: /skill list"
    Write-Host "   3. Start your first project: \"我想做一个 [产品想法]\""
    Write-Host ""
    Write-Host "🔄 To update DevForge in the future:"
    Write-Host "   cd $InstallDir; git pull"
    Write-Host "   (No re-installation needed — junctions auto-point to new code)"
    Write-Host ""
    Write-Host "🗑️  To uninstall:"
    Write-Host "   .\uninstall.ps1"
    Write-Host ""
    Write-Host "📖 Documentation: https://github.com/lzj2819/DevForge"
    Write-Host ""
}

# Main
Print-Banner
Test-Prerequisites
Ensure-Directories
Clone-Or-UpdateRepo
Remove-OldLinks
New-SkillLinks
Test-Installation
Print-NextSteps

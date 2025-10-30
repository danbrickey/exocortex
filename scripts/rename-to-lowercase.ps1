# PowerShell script to rename all markdown files to lowercase (except README.md)
# Run this from the repository root

$files = @(
    # Root level
    "CLAUDE.md",
    "WORK_SYNC_GUIDE.md",

    # AI resources
    "ai-resources\prompts\architecture\technical-requirements\requirements-elicitation\SKILL.md",
    "ai-resources\prompts\career\CAREER_PATHS_MASTER_LIST.md",
    "ai-resources\prompts\development\vibe-coding\SKILL.md",
    "ai-resources\prompts\development\vibe-coding\vibe-coding\SKILL.md",
    "ai-resources\prompts\documentation\business-doc-evaluator\SKILL.md",
    "ai-resources\prompts\meta\agentic-development\SKILL.md",
    "ai-resources\prompts\personal\README-therapy.md",
    "ai-resources\prompts\strategy\ai-vendor-evaluation\ai-vendor-evaluation\SKILL.md",
    "ai-resources\prompts\utilities\excel-automation\complex-excel-builder\SKILL.md",
    "ai-resources\prompts\utilities\excel-editing\xlsx-editor\SKILL.md",

    # Docs
    "docs\gift-profiles\PROFILE-INDEX.md",
    "docs\gift-profiles\PROFILE-TEMPLATE.md",
    "docs\goals\career-goals\PROMPTS.md",
    "docs\meetings\log\TODO.md",
    "docs\work-tracking\ai-transformation\PORTFOLIO_STRATEGY.md",
    "docs\work-tracking\ai-transformation\QUICK_START.md",
    "docs\work-tracking\ai-transformation\UC02_ACTION_PLAN.md",
    "docs\work-tracking\ai-transformation\use_cases\uc01_dv_refactor\PROMPTS.md",
    "docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\class_type\DELIVERABLES.md"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $dir = Split-Path -Parent $file
        $name = Split-Path -Leaf $file
        $lowerName = $name.ToLower()

        if ($name -ne $lowerName) {
            # Two-step rename for case-insensitive filesystems
            $tempName = "$name.tmp"
            $tempPath = Join-Path $dir $tempName
            $finalPath = Join-Path $dir $lowerName

            Rename-Item -Path $file -NewName $tempName -Force
            Rename-Item -Path $tempPath -NewName $lowerName -Force

            Write-Host "Renamed: $file -> $finalPath" -ForegroundColor Green
        } else {
            Write-Host "Already lowercase: $file" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Not found: $file" -ForegroundColor Red
    }
}

Write-Host "`nRename complete!" -ForegroundColor Green
Write-Host "Run 'git status' to see the changes." -ForegroundColor Cyan

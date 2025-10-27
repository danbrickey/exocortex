#!/bin/bash
# Bash script to rename all markdown files to lowercase (except README.md)
# Run this from the repository root

files=(
    # Root level
    "CLAUDE.md"
    "WORK_SYNC_GUIDE.md"

    # AI resources
    "ai-resources/prompts/architecture/technical-requirements/requirements-elicitation/SKILL.md"
    "ai-resources/prompts/career/CAREER_PATHS_MASTER_LIST.md"
    "ai-resources/prompts/development/vibe-coding/SKILL.md"
    "ai-resources/prompts/development/vibe-coding/vibe-coding/SKILL.md"
    "ai-resources/prompts/documentation/business-doc-evaluator/SKILL.md"
    "ai-resources/prompts/meta/agentic-development/SKILL.md"
    "ai-resources/prompts/personal/README-therapy.md"
    "ai-resources/prompts/strategy/ai-vendor-evaluation/ai-vendor-evaluation/SKILL.md"
    "ai-resources/prompts/utilities/excel-automation/complex-excel-builder/SKILL.md"
    "ai-resources/prompts/utilities/excel-editing/xlsx-editor/SKILL.md"

    # Docs
    "docs/gift-profiles/PROFILE-INDEX.md"
    "docs/gift-profiles/PROFILE-TEMPLATE.md"
    "docs/goals/career-goals/PROMPTS.md"
    "docs/meetings/log/TODO.md"
    "docs/work-tracking/ai-transformation/PORTFOLIO_STRATEGY.md"
    "docs/work-tracking/ai-transformation/QUICK_START.md"
    "docs/work-tracking/ai-transformation/UC02_ACTION_PLAN.md"
    "docs/work-tracking/ai-transformation/use_cases/uc01_dv_refactor/PROMPTS.md"
    "docs/work-tracking/ai-transformation/use_cases/uc02_edw2_refactor/output/class_type/DELIVERABLES.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        dir=$(dirname "$file")
        name=$(basename "$file")
        lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')

        if [ "$name" != "$lower" ]; then
            # Two-step rename for case-insensitive filesystems
            mv "$file" "$dir/${name}.tmp"
            mv "$dir/${name}.tmp" "$dir/$lower"
            echo -e "\033[32mRenamed: $file -> $dir/$lower\033[0m"
        else
            echo -e "\033[33mAlready lowercase: $file\033[0m"
        fi
    else
        echo -e "\033[31mNot found: $file\033[0m"
    fi
done

echo -e "\n\033[32mRename complete!\033[0m"
echo -e "\033[36mRun 'git status' to see the changes.\033[0m"

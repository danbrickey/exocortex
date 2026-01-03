---
name: commit-message
description: Generates conventional commit messages based on pending git changes using standard source control terminology and best practices
---

# Commit Message Generator

This skill analyzes pending git changes and generates conventional commit messages following industry best practices and common source control terminology.

## Process

When this skill is activated, follow these steps:

1. **Analyze Repository State**
   - Run `git status` to identify staged and unstaged changes
   - Run `git diff --cached` to see staged changes in detail
   - Run `git diff` to see unstaged changes if relevant
   - Run `git log --oneline -5` to understand recent commit message patterns

2. **Categorize Changes**
   - **feat**: New features or functionality
   - **fix**: Bug fixes
   - **docs**: Documentation changes
   - **style**: Code style changes (formatting, missing semi colons, etc.)
   - **refactor**: Code refactoring without changing external behavior
   - **test**: Adding or updating tests
   - **chore**: Maintenance tasks (dependencies, build config, etc.)
   - **perf**: Performance improvements
   - **ci**: CI/CD pipeline changes
   - **build**: Build system or external dependency changes

3. **Generate Message Structure**
   ```
   <type>[optional scope]: <description>

   [optional body]

   [optional footer(s)]
   ```

4. **Apply Best Practices**
   - Use imperative mood ("add" not "added" or "adds")
   - Keep subject line under 50 characters when possible
   - Capitalize first letter of description
   - No period at end of subject line
   - Use body to explain "what" and "why", not "how"
   - Reference issues/tickets in footer when applicable

## Examples

**Simple feature addition:**
```
feat: add user authentication system

Implements JWT-based authentication with login/logout functionality
and protected route middleware.
```

**Bug fix:**
```
fix: resolve memory leak in data processor

Fixes issue where event listeners weren't properly cleaned up,
causing memory usage to grow over time.

Closes #123
```

**Documentation update:**
```
docs: update API documentation for v2.0

Add examples for new endpoints and clarify authentication requirements.
```

**Refactoring:**
```
refactor: extract validation logic into separate module

Improves code organization and makes validation logic reusable
across different components.
```

## Guidelines

- Always analyze the actual changes, don't guess based on file names alone
- Consider the impact scope (breaking changes, new features, patches)
- Use conventional commit prefixes consistently
- Keep descriptions concise but informative
- Include relevant context in the body for complex changes
- Reference issue numbers when applicable
- If multiple unrelated changes are staged, suggest splitting into separate commits
- For merge commits, follow the pattern: "Merge branch 'feature-name'"

## Output Format

Provide the commit message in a code block, ready to use with `git commit -m "..."` or as input to a commit dialog. Include both the subject line and body when appropriate.
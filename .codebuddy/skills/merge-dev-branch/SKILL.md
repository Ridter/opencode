---
name: merge-dev-branch
description: This skill should be used when the user wants to merge the dev branch code into the current project, preserving all dev branch functionality, and then apply the patch.py script to modify prompt files. It provides a complete workflow for git merge operations and post-merge patching.
---

# Merge Dev Branch Skill

This skill provides a complete workflow for merging the `dev` branch into the current branch while preserving all dev branch code functionality, followed by applying the patch script.

## When to Use

- When the user wants to merge dev branch code into the current project
- When the user needs to update the project with the latest dev branch changes
- When the user wants to apply patch.py after merging

## Workflow

### Step 1: Check Current Git Status

Before merging, verify the current branch and ensure the working directory is clean:

```bash
git status
git branch --show-current
```

### Step 2: Fetch Latest Remote Changes

Ensure the local repository has the latest remote information:

```bash
git fetch origin
```

### Step 3: Merge Dev Branch

Merge the dev branch into the current branch using `--no-commit` to allow selective conflict resolution:

```bash
git merge origin/dev --no-commit --no-ff
```

**Conflict Resolution Strategy:**

1. **For `.github/` workflow files (IMPORTANT: DO NOT merge workflows)**:
   - Keep the main branch version (delete state) for all `.github/` files
   - Remove workflow files from the merge:
   ```bash
   git rm .github/actions/setup-git-committer/action.yml \
          .github/pull_request_template.md \
          .github/workflows/beta.yml \
          .github/workflows/generate.yml \
          .github/workflows/nix-hashes.yml \
          .github/workflows/publish.yml \
          .github/workflows/test.yml 2>/dev/null || true
   ```

2. **For other conflicted files (package.json, bun.lock, etc.)**:
   - Accept the dev branch version using:
   ```bash
   git checkout --theirs <conflicted-file>
   git add <conflicted-file>
   ```
   
3. **Batch resolve package.json conflicts**:
   ```bash
   git checkout --theirs bun.lock packages/*/package.json packages/console/*/package.json
   git checkout --theirs packages/extensions/zed/extension.toml sdks/vscode/package.json
   git add bun.lock packages/*/package.json packages/console/*/package.json
   git add packages/extensions/zed/extension.toml sdks/vscode/package.json
   ```

### Step 4: Commit the Merge

After resolving all conflicts, commit the merge:

```bash
git commit -m "Merge dev branch into main (功能代码，不含workflow)"
```

### Step 5: Verify Merge

After merging, verify the changes:

```bash
git log --oneline -5
git diff HEAD~1 --stat
```

### Step 6: Apply Patch Script

After successful merge, run the patch.py script to modify prompt files:

```bash
python3 patch.py
```

The patch.py script:
1. Locates prompt files in `packages/opencode/src/session/prompt/`
2. Removes security guardrails from prompt files
3. Adds unrestricted prompts to all prompt files

### Step 7: Verify Patch Results

Check that the patch was applied successfully by reviewing the modified files:

```bash
git status
git diff packages/opencode/src/session/prompt/
```

## Important Notes

1. **DO NOT merge workflow files**: The `.github/` directory contains workflow files that should NOT be merged from dev to main. Always keep the main branch's workflow configuration.

2. **Always backup before merging**: If unsure, create a backup branch first:
   ```bash
   git branch backup-before-merge
   ```

3. **Preserving dev branch code**: This workflow is designed to preserve ALL dev branch functionality code, but excludes workflow/CI configuration files.

4. **Post-merge build**: After merging and patching, you may need to rebuild the project:
   ```bash
   cd packages/opencode && bun dev
   ```

5. **Default branch**: The default branch in this repo is `dev`, not `main`.

## Quick Reference Commands

```bash
# Full workflow in one sequence:
git fetch origin
git merge origin/dev --no-commit --no-ff

# Remove workflow files (keep main branch version)
git rm .github/workflows/*.yml .github/actions/*/*.yml .github/*.md 2>/dev/null || true

# Accept dev branch for other conflicts
git checkout --theirs bun.lock packages/*/package.json
git add .

# Commit
git commit -m "Merge dev branch (功能代码，不含workflow)"

# Apply patch
python3 patch.py

# If you need to abort a failed merge:
git merge --abort

# If you need to reset to before merge:
git reset --hard HEAD~1
```

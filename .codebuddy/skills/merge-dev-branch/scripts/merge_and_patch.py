#!/usr/bin/env python3
"""
Merge Dev Branch and Apply Patch Script

This script automates the process of:
1. Fetching latest changes from remote
2. Merging dev branch into current branch (preserving dev changes)
3. Running patch.py to modify prompt files

Usage:
    python merge_and_patch.py [project_dir]

Arguments:
    project_dir - OpenCode project directory (default: current directory)
"""

import os
import sys
import subprocess
from pathlib import Path

# ANSI Colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'

    @classmethod
    def disable(cls):
        cls.RED = cls.GREEN = cls.YELLOW = cls.BLUE = cls.CYAN = cls.NC = ''


if sys.platform == 'win32':
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32
        kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
    except Exception:
        Colors.disable()


def log_info(msg): print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")
def log_success(msg): print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {msg}")
def log_warning(msg): print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {msg}")
def log_error(msg): print(f"{Colors.RED}[ERROR]{Colors.NC} {msg}")


def run_command(cmd: list, cwd: Path = None) -> tuple:
    """Run a command and return (success, output)"""
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True
        )
        return result.returncode == 0, result.stdout + result.stderr
    except Exception as e:
        return False, str(e)


def main():
    print()
    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    print(f"{Colors.CYAN}   Merge Dev Branch & Apply Patch{Colors.NC}")
    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    print()

    # Get project directory
    project_dir = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path('.').resolve()
    log_info(f"Project directory: {project_dir}")

    # Check if git repo
    if not (project_dir / '.git').exists():
        log_error("Not a git repository!")
        sys.exit(1)

    # Step 1: Check current branch
    log_info("Checking current branch...")
    success, output = run_command(['git', 'branch', '--show-current'], project_dir)
    if success:
        current_branch = output.strip()
        log_success(f"Current branch: {current_branch}")
    else:
        log_error(f"Failed to get current branch: {output}")
        sys.exit(1)

    # Step 2: Check for uncommitted changes
    log_info("Checking for uncommitted changes...")
    success, output = run_command(['git', 'status', '--porcelain'], project_dir)
    if output.strip():
        log_warning("Uncommitted changes detected:")
        print(output)
        response = input("Continue anyway? (y/N): ")
        if response.lower() != 'y':
            log_info("Aborted by user")
            sys.exit(0)

    # Step 3: Fetch latest changes
    log_info("Fetching latest changes from origin...")
    success, output = run_command(['git', 'fetch', 'origin'], project_dir)
    if success:
        log_success("Fetch completed")
    else:
        log_error(f"Fetch failed: {output}")
        sys.exit(1)

    # Step 4: Merge dev branch
    log_info("Merging origin/dev branch (preserving dev changes)...")
    success, output = run_command(
        ['git', 'merge', 'origin/dev', '-X', 'theirs', '-m', 'Merge dev branch into current branch'],
        project_dir
    )
    if success:
        log_success("Merge completed successfully")
        print(output)
    else:
        if 'CONFLICT' in output:
            log_warning("Merge conflicts detected, resolving by accepting dev changes...")
            # Get conflicted files
            _, status = run_command(['git', 'status', '--porcelain'], project_dir)
            for line in status.split('\n'):
                if line.startswith('UU ') or line.startswith('AA '):
                    file_path = line[3:].strip()
                    log_info(f"Resolving conflict in: {file_path}")
                    run_command(['git', 'checkout', '--theirs', file_path], project_dir)
                    run_command(['git', 'add', file_path], project_dir)
            # Complete the merge
            run_command(['git', 'commit', '-m', 'Merge dev branch (resolved conflicts, prefer dev)'], project_dir)
            log_success("Conflicts resolved")
        else:
            log_error(f"Merge failed: {output}")
            sys.exit(1)

    # Step 5: Run patch.py
    print()
    log_info("Running patch.py to modify prompt files...")
    patch_script = project_dir / 'patch.py'
    if patch_script.exists():
        success, output = run_command(['python3', str(patch_script)], project_dir)
        if success:
            print(output)
            log_success("Patch applied successfully")
        else:
            log_error(f"Patch failed: {output}")
            sys.exit(1)
    else:
        log_error(f"patch.py not found at: {patch_script}")
        sys.exit(1)

    # Summary
    print()
    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    print(f"{Colors.CYAN}   Complete!{Colors.NC}")
    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    print()
    log_success("Dev branch merged and patch applied successfully!")
    print()


if __name__ == "__main__":
    main()

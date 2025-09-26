@echo off
echo ========================================
echo Valheim Save Sync Script
echo ========================================

REM Change to the script directory
cd /d "%~dp0"

echo Fetching latest changes from GitHub...
git fetch origin

REM Check if there are any conflicts or issues
echo Checking for conflicts...
git status --porcelain > temp_status.txt
if %errorlevel% neq 0 (
    echo ERROR: Git status check failed
    del temp_status.txt
    pause
    exit /b 1
)

REM Check if there are any uncommitted changes
git diff --quiet
if %errorlevel% neq 0 (
    echo WARNING: There are uncommitted changes in working directory. Committing them now...
    git add .
    git commit -m "Auto-sync: Update Valheim save files"
    if %errorlevel% neq 0 (
        echo ERROR: Commit failed
        pause
        exit /b 1
    )
    echo Changes committed successfully.
)

git diff --cached --quiet
if %errorlevel% neq 0 (
    echo WARNING: There are staged changes. Committing them now...
    git commit -m "Auto-sync: Update Valheim save files"
    if %errorlevel% neq 0 (
        echo ERROR: Commit failed
        pause
        exit /b 1
    )
    echo Staged changes committed successfully.
)

REM Check if we're behind the remote
git rev-list --count HEAD..origin/master > temp_behind.txt
set /p behind_count=<temp_behind.txt
del temp_behind.txt

if %behind_count% gtr 0 (
    echo WARNING: Local branch is %behind_count% commits behind origin/master
    echo Attempting to merge...
    git merge origin/master
    if %errorlevel% neq 0 (
        echo ERROR: Merge failed due to conflicts. Please resolve conflicts manually.
        del temp_status.txt
        pause
        exit /b 1
    )
    echo Merge successful!
)

REM All changes should now be committed, proceed with push

echo Pushing to GitHub...
git push origin master

if %errorlevel% neq 0 (
    echo ERROR: Push failed
    del temp_status.txt
    pause
    exit /b 1
)

REM Clean up temporary files
if exist temp_status.txt del temp_status.txt
if exist temp_behind.txt del temp_behind.txt

echo ========================================
echo Sync completed successfully!
echo ========================================
pause

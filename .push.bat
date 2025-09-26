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
for /f %%i in ('findstr /c:" M " temp_status.txt') do (
    echo WARNING: There are uncommitted changes. Please commit them first.
    del temp_status.txt
    pause
    exit /b 1
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

REM Check if there are any changes to commit
git diff --quiet
if %errorlevel% equ 0 (
    git diff --cached --quiet
    if %errorlevel% equ 0 (
        echo No changes to commit.
        del temp_status.txt
        echo ========================================
        echo Sync complete - no changes needed
        echo ========================================
        pause
        exit /b 0
    )
)

echo Changes detected. Adding files...
git add .

echo Committing changes...
git commit -m "Auto-sync: Update Valheim save files"

if %errorlevel% neq 0 (
    echo ERROR: Commit failed
    del temp_status.txt
    pause
    exit /b 1
)

echo Pushing to GitHub...
git push origin master

if %errorlevel% neq 0 (
    echo ERROR: Push failed
    del temp_status.txt
    pause
    exit /b 1
)

del temp_status.txt
echo ========================================
echo Sync completed successfully!
echo ========================================
pause

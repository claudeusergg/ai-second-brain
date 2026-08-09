# Cloud Second Brain - one-shot bootstrap
#
# Run this from PowerShell inside the cloud-brain folder:
#     cd "C:\Users\PC\Documents\PROJEKTAI\Claude Code\AI second Brain\cloud-brain"
#     .\setup.ps1
#
# Prereqs (the script checks and tells you if either is missing):
#   - GitHub CLI:  winget install GitHub.cli    then    gh auth login
#   - Claude Code: needed once, to mint the subscription token

$ErrorActionPreference = "Stop"
$RepoName = "ai-second-brain"

Write-Host "`n=== Cloud Second Brain setup ===`n" -ForegroundColor Cyan

# --- 1. Check gh CLI -----------------------------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI not found." -ForegroundColor Red
    Write-Host "  Install it:  winget install GitHub.cli"
    Write-Host "  Then log in: gh auth login"
    exit 1
}

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in to GitHub. Run: gh auth login" -ForegroundColor Red
    exit 1
}
Write-Host "[ok] GitHub CLI authenticated" -ForegroundColor Green

# --- 2. Get the Claude subscription token --------------------------------
Write-Host "`nNow we need a Claude token so the cloud runner can act as you." -ForegroundColor Cyan
Write-Host "In ANOTHER terminal run:  claude setup-token"
Write-Host "It opens a browser, you approve, and it prints a token starting with sk-ant-oat01-"
Write-Host "This uses your existing Claude subscription. No API billing.`n"

$Token = Read-Host "Paste the token here"
if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "No token given. Aborting." -ForegroundColor Red
    exit 1
}
if (-not $Token.StartsWith("sk-ant-oat01-")) {
    Write-Host "That doesn't look like a subscription token (expected sk-ant-oat01-...)." -ForegroundColor Yellow
    $Continue = Read-Host "Continue anyway? (y/n)"
    if ($Continue -ne "y") { exit 1 }
}

# --- 3. Init git and create the repo -------------------------------------
if (-not (Test-Path ".git")) {
    git init -b main | Out-Null
    Write-Host "[ok] git initialised" -ForegroundColor Green
}

git add -A
git commit -m "Cloud second brain: issue queue + Claude worker" --allow-empty | Out-Null
Write-Host "[ok] committed" -ForegroundColor Green

Write-Host "`nCreating PRIVATE repo '$RepoName' and pushing..." -ForegroundColor Cyan
gh repo create $RepoName --private --source=. --push
if ($LASTEXITCODE -ne 0) {
    Write-Host "Repo creation failed - it may already exist. Pushing to existing remote instead." -ForegroundColor Yellow
    git push -u origin main
}
Write-Host "[ok] repo pushed" -ForegroundColor Green

# --- 4. Store the token as a repo secret ---------------------------------
$Token | gh secret set CLAUDE_CODE_OAUTH_TOKEN
Write-Host "[ok] token stored as repo secret CLAUDE_CODE_OAUTH_TOKEN" -ForegroundColor Green

# --- 5. Labels -----------------------------------------------------------
gh label create task    --color 0E8A16 --description "Work for Claude"     2>$null | Out-Null
gh label create question --color 1D76DB --description "Answer only"        2>$null | Out-Null
gh label create digest  --color 5319E7 --description "Daily summary"       2>$null | Out-Null
gh label create blocked --color D93F0B --description "Waiting on Karolis"  2>$null | Out-Null
Write-Host "[ok] labels created" -ForegroundColor Green

# --- 6. Remaining manual step --------------------------------------------
$RepoUrl = gh repo view --json url -q .url

Write-Host "`n=== Almost done ===" -ForegroundColor Cyan
Write-Host "ONE manual step left - install the Claude GitHub App on this repo:"
Write-Host "  https://github.com/apps/claude" -ForegroundColor Yellow
Write-Host "  (Configure -> select '$RepoName' -> Save)"
Write-Host "`nThen test it. Open an issue from your phone or run:"
Write-Host "  gh issue create --title 'Test' --body '@claude Reply with a haiku about queues.'" -ForegroundColor Yellow
Write-Host "`nYour repo: $RepoUrl" -ForegroundColor Green
Write-Host "Install the GitHub mobile app and you can queue tasks from anywhere.`n"

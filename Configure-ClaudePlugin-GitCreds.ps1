<# 
    Configure-ClaudePlugin-GitCreds.ps1

    Configure Git to use HTTPS + PAT ONLY for:
        https://github.com/DragonAngel1st/ClaudeCodePydanticSubagentFactory_plugin.git

    NOTES:
    - This stores the PAT in plaintext in $HOME\.git-credentials (Git's standard behavior).
    - PATs can expire. If cloning starts failing again, users should contact
      Patrick Miron (GitHub: DragonAngel1st) to obtain a fresh PAT.
    - This script is meant for Windows PowerShell (v5) / standard Windows Git.
      If using WSL, use the accompanying .sh script instead.
#>

param()

$RepoOwner = "DragonAngel1st"
$RepoName  = "ClaudeCodePydanticSubagentFactory_plugin"

# Determine user's home directory (Windows)
$home = $env:HOME
if (-not $home) {
    $home = [Environment]::GetFolderPath('UserProfile')
}
$credFile = Join-Path $home ".git-credentials"

Write-Host "============================================================"
Write-Host " Git credential setup for Claude Code plugin repository" -ForegroundColor Cyan
Write-Host " Repo: https://github.com/$RepoOwner/$RepoName.git"
Write-Host "============================================================`n"

Write-Warning "This will store a GitHub Personal Access Token (PAT) in PLAINTEXT in:"
Write-Host "  $credFile`n"
Write-Host "PATs can expire or be revoked. If authentication fails later,"
Write-Host "please contact Patrick Miron (GitHub: DragonAngel1st) for a new PAT.`n"

$confirm = Read-Host "Continue? (y/N)"
if ($confirm -notmatch '^[Yy]$') {
    Write-Host "Aborting."
    exit 1
}

# Prompt for username and PAT
$ghUser = Read-Host "GitHub username"
$ghPatSecure = Read-Host "GitHub PAT (input hidden)" -AsSecureString

if ([string]::IsNullOrWhiteSpace($ghUser) -or -not $ghPatSecure) {
    Write-Error "Username or PAT is empty. Aborting."
    exit 1
}

# Convert SecureString to plain text for writing into .git-credentials
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ghPatSecure)
try {
    $ghPatPlain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}

Write-Host "`nConfiguring global Git credential helper and useHttpPath..."
git config --global credential.helper store | Out-Null
git config --global credential.useHttpPath true | Out-Null

# Backup existing credential file if it exists
if (Test-Path $credFile) {
    $backup = "$credFile.bak.$([int][double]::Parse((Get-Date -UFormat %s)))"
    Write-Host "Backing up existing $credFile to $backup"
    Copy-Item $credFile $backup -Force

    # Remove any existing lines for this specific repo path
    $lines = Get-Content $credFile
    $filtered = $lines | Where-Object { $_ -notmatch "github\.com/$RepoOwner/$RepoName" }
    $filtered | Set-Content $credFile -Encoding UTF8
} else {
    # Ensure directory exists
    $dir = Split-Path $credFile -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "Writing scoped credentials for this repo only..."
# No .git suffix needed; useHttpPath=true will match the path correctly
$credLine = "https://$ghUser:$ghPatPlain@github.com/$RepoOwner/$RepoName"
Add-Content -Path $credFile -Value $credLine -Encoding UTF8

# Clear plaintext PAT from memory variable
$ghPatPlain = $null

Write-Host "`nDone." -ForegroundColor Green
Write-Host
Write-Host "You should now be able to clone this repo without prompts, for example:"
Write-Host "  git clone https://github.com/$RepoOwner/$RepoName.git C:\temp\test-plugin"
Write-Host
Write-Host "If plugin installation in Claude Code starts failing again, your PAT may"
Write-Host "have expired. Please contact Patrick Miron (DragonAngel1st) for renewal.`n"

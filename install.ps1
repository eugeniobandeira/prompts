# install.ps1 — Install Claude Code custom commands globally
# Usage: .\install.ps1
# Copies all commands from .claude/commands/ to ~/.claude/commands/
# so they are available as slash commands in any project.

$source = Join-Path $PSScriptRoot ".claude\commands"
$destination = Join-Path $env:USERPROFILE ".claude\commands"

if (-not (Test-Path $source)) {
    Write-Error "Source directory not found: $source"
    exit 1
}

if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
    Write-Host "Created: $destination"
}

$files = Get-ChildItem -Path $source -Filter "*.md"

if ($files.Count -eq 0) {
    Write-Warning "No .md files found in $source"
    exit 0
}

foreach ($file in $files) {
    $target = Join-Path $destination $file.Name
    Copy-Item -Path $file.FullName -Destination $target -Force
    Write-Host "Installed: $($file.Name)"
}

Write-Host ""
Write-Host "Done. $($files.Count) command(s) installed to $destination"
Write-Host "Restart Claude Code or open a new terminal to use the commands."

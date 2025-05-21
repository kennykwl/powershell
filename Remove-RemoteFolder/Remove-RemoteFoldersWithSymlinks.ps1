<#
.SYNOPSIS
    Deletes specified folders and their contents (including symbolic links) from a list of remote Windows servers.

.DESCRIPTION
    For each server listed in a text file, the script attempts to delete defined folders and subfolders, handling symlinks gracefully.
    Logs all actions taken, including errors, and supports creating the log file if it doesn't exist.

.NOTES
    Author: Kenny Li
    Version: 1.2
    Note: May need to run as administrator with remote file share access. 
    Supports: PowerShell 5.1+

.EXAMPLE
    .\Remove-RemoteFolders.ps1 -ServerListPath "C:\temp\servers.txt" -LogFilePath "C:\temp\Delete.log" -FoldersToDelete "C$\temp\test\folder1","C$\temp\test\folder2"

#>

param (

    [Parameter(Mandatory)]
    [string]$ServerListPath,

    [Parameter(Mandatory)]
    [string]$LogFilePath,

    [Parameter(Mandatory)]
    [string[]]$FoldersToDelete
    
)

function Write-Log {

    param (
    
        [string]$Message,
        [string]$Level = "INFO"
    
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "[$timestamp][$Level] $Message"

}

# Check if the server list file exists before continuing
if (-not (Test-Path $ServerListPath)) {

    Write-Error "Server list file not found at: $ServerListPath"
    exit 1

}

# Create the log file if it doesn't already exist
if (-not (Test-Path $LogFilePath)) {

    New-Item -ItemType File -Path $LogFilePath -Force | Out-Null
    Write-Log "Log file created."

}

$servers = Get-Content -Path $ServerListPath

foreach ($server in $servers) {

    Write-Log "Starting cleanup on server: $server"

    foreach ($folder in $FoldersToDelete) {

        # Build the full UNC path to the folder on the remote server
        $uncPath = "\\$server\$folder"
        if (Test-Path -LiteralPath $uncPath) {
        
            try {
            
                # Delete any symbolic links (reparse points) inside folder to avoid issues
                $parent = Split-Path -Path $uncPath -Parent
                Get-ChildItem $parent -Attributes ReparsePoint -ErrorAction SilentlyContinue | ForEach-Object {
                
                    $_.Delete()
                    Write-Log "Deleted symlink: $($_.FullName) on $server"
                
                }

                # Remove actual folder
                Remove-Item -LiteralPath $uncPath -Recurse -Force -ErrorAction Stop
                Write-Log "Successfully deleted: $uncPath"
                
            }
            catch {
            
                Write-Log "Failed to delete: $uncPath - $_" -Level "ERROR"
            
            }
        } else {
        
            Write-Log "Path not found: $uncPath"
        
        }
    
    }

    Write-Log "Completed cleanup on server: $server"

}

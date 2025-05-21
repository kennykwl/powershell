# Remove-RemoteFoldersWithSymlinks.ps1

## Overview  
This PowerShell script removes specified folders from a list of remote Windows servers.  
It safely handles symbolic links (ReparsePoints) to prevent deletion errors or orphaned links.  
Logs all actions and supports error handling.

## Features
- Deletes folders across remote servers via UNC paths  
- Detects and removes symbolic links before folder deletion  
- Logs operations with timestamps and severity levels  
- Creates log file automatically if it doesn't exist  

## Requirements
- PowerShell 5.1 or later  
- User must have local admin or necessary file share permissions on remote servers  
- Script run context should have access to UNC paths (e.g. `\\server\C$\path`)  

## Parameters

| Parameter        | Type       | Description                                                               |
|------------------|------------|---------------------------------------------------------------------------|
| `ServerListPath` | `string`   | Path to a .txt file with one server name per line                         |
| `LogFilePath`    | `string`   | Path to the log file to record all actions                                |
| `FoldersToDelete`| `string[]` | One or more folder paths (relative to root share, like `C$\temp\folder`)  |

## Example

```powershell
.\Remove-RemoteFoldersWithSymlinks.ps1 `
  -ServerListPath "C:\temp\servers.txt" `
  -LogFilePath "C:\temp\delete.log" `
  -FoldersToDelete "C$\temp\folder1", "D$\archives\old"
```

## Notes
- Use double quotes for folder paths when calling the script  
- Make sure UNC access (\\server\C$\folder) is permitted from the machine where you run this 
- Symlink removal is done via Get-ChildItem -Attributes ReparsePoint

## Author
Kenny Li
Version 1.2

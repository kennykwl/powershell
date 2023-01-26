# This Script removes Folder and any sub-folder and Files inside the folder

$Servers = Get-Content "C:\temp\servers.txt"     # this txt contains a list of servers 
$LogFile = "C:\temp\Delete.log"    # This is the log file

# Create Log File if not exist
If(!(Test-Path $LogFile)){
  New-Item -ItemType File -Path $Logfile
  Add-Content -Path $LogFile -value "[INFO] Log File not found.  Created successfully."  
}

Foreach($server in $servers){
  $paths = ("\\$server\c$\temp\test\folder1","\\$server\c$\temp\test\folder2")    # the folder(s) that need to be deleted
  
  Foreach($path in $paths){
    If(Test-Path -LiteralPath $Path){
        Get-ChildItem "\\$server\C$\test" -Attributes ReparsePoint -ErrorAction SilentlyContinue | % { $_.Delete() }    # Remove-Item cmdlet cannot delete symlinks, and if present, will leave the folder undeleted.  This will remove any symlink inside the folder
        Remove-Item -LiteralPath $path -Recurse -Force
        Add-Content -Path $LogFile -value "[INFO] $path deleted successfully"    # can modify logging logic to display more useful information if needed
     
        }
    Else{
        Add-Content -Path $logFile -value "[INFO] $path does not exist"
        }
    }
}

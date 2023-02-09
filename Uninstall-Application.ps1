<# 
   This was used to uninstall an older application that was no longer in SCCM.  
   Chances are, the cached msi installer is still in the C:\windows\Installer folder
   This can be written better by importing the list of computers from a txt or csv file 
   and running in parallel PS session, and logging to a log file to note down if the app
   was successfully uninstalled or not.
#>

$computerName = "RemoteComputerName"
$appName = "ApplicationName"

# Get the GUID of the installed application
$guid = (Get-WmiObject -Class Win32_Product -ComputerName $computerName | Where-Object {$_.Name -eq $appName}).IdentifyingNumber

# Uninstall the application using the GUID
Invoke-Command -ComputerName $computerName -ScriptBlock {param($guid) Start-Process "msiexec.exe" -Wait -ArgumentList "/x $guid /qn"} -ArgumentList $guid

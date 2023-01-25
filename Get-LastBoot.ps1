# This script is used for finding out the last reboot time of a remote computer

function Get-Lastboot
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName
   )
   
   Get-CimInstance -ClassName Win32_operatingSystem -ComputerName $ComputerName | Select csname, LastBootUpTime 
   }

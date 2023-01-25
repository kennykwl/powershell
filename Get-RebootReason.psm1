# This will give you the last reboot reason of a remote computer

function Get-Lastboot
{
  [CmdletBinding()]
  param
  (
      [parameter(Mandatory=$true)]
      [stringp]$ComputerName
   )
   
   Get-WinEvent -FilterHashTable @{logname='system';id=1074} -MaxEvents 1 -ComputerName $ComputerName | Format-Table -Wrap
 }

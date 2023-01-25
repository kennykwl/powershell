#This was a short script that I used to revoke remote desktop Licenses as a temp fix because they were running out from time to time.

$Licenses = Get-WmiObject Win32_TSIssuedLicense | Where {$_.sIssuedToCOmputer -like "USUE2CXPVDA*" -and $_.LicenseStatus -eq "2"} | Select -first 300
$Licenses.revoke()

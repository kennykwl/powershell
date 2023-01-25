# This will add msedge.exe to the ctxUvi registry key to disable Citrix API hooks

$RegPath = "HKLM:SYSTEM\CurrentControlSet\Services\CtxUvi"
$RegName = "UviProcessExcludes"
$EdgeRegvalue = "msedge.exe"

# Get Current values in UviProcessExcludes
$CurrentValues = Get-ItemProperty -Path $RegPath | Select-Object -ExpandProperty $RegName

# Add the msedge.exe value to existing values in UviProcessExcludes
Set-ItemProperty -Path $RegPath -Name $RegName -Value "$CurrentValues$EdgeRegvalue;"

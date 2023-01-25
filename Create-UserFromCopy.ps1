<#This script create user from a reference user and set initiate password, 
  as well as adding all groups of the reference user to the new user
  and create Userfolder on a network shared and grant the new user full control
#>

$password = ConvertTo-SecureString "Passw@rd123$" -AsPlainText -Force

#Prompt user for a reference User

$ReferenceUser = Read-Host -Prompt 'Please enter the user name to copy from'
$NewUser = Read-Host -Prompt 'Please enter the User name of the new user'
$copyfrom = Get-Aduser $ReferenceUser

New-ADUser -SAMAccountName $NewUser  -Instance $copyfrom -DisplayName $NewUser -Name $NewUser -UserPrincipalName "$NewUser@kennyl.us" -AccountPassword $password
Set-Aduser -Identity $NewUser -ChangePasswordAtLogon $True  #this will force the new user to change the password at first logon

$location = Get-Aduser $NewUser
Move-ADObject -Identity $Location.DistinguishedName -TargetPath "OU=Active,OU=Users,OU=Company,DC=Kennyl,DC=us"  #moving the user to another OU, this can be modified accordingly to need.

#the next line will add new user to all the groups that the reference user was a member of
Get-ADUser -Identity $ReferenceUser -Properties memberof | Select-Object -ExpandProperty memberof |  Add-ADGroupMember -Members $NewUser

$path = "\\fs01\UserFolders\$NewUser"
New-Item -ItemType Directory -Force -Path $path

$acl = Get-acl -path $path
$permission = $NewUser, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow'
$rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permission
$acl.SetAccessRule($rule)
$acl | Set-Acl -Path $path

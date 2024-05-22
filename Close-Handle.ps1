<# 
There are maximum of I believe 2048 handles by default.  This was a temp fix until I figured out what was taking up the handles.
This will force close any File Handle connected to Azure Storage
#>

# this will prompt you to login, login with the account you use for Azure portal

Connect-AzAccount       

$StorageAccountName = "azurestorageaccount"      #replace storage account name here  
$StorageAccountKey = "S2YKMeHoRY8q5DNK7czKya7lXUpYP/66lUkHWckJJZUyAclupCSyoeDfVvUu+MWsW5dnnncVUX+VbudTg9IaMA=="   #Replace Storage Account Key here
$StorageShareName = "azureshare"    #replace the share name here

$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

## This will Get all the opened handles that are currently connected from the IP 192.168.1.8
Get-AzStorageFileHandle -Context $Context -ShareName edibiztalk -Recursive | Where-Object -Property ClientIP -eq 192.168.1.8

## This will close all the handles from this IP

Get-AzStorageFileHandle -Context $Context -ShareName $StorageShareName -Recursive | Where-Object -Property ClientIP -eq 192.168.1.8 | Close-AzStorageFileHandle -context $context -ShareName $StorageShareName

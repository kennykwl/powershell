<#
This script was written when our team started migrating existing MSSQL servers on Azure to user 
Ultra Shared Disk.  This was more interactive for the sake of those team members who are not as 
PowerShell savvy
#>

# Check to see if the system has all required PS modules and is running supported versions

    $requiredModules = @(

        [PSCustomObject]@{

            Name           = 'Az'

        },

        [PSCustomObject]@{

            Name           = 'Az.Accounts'

        },

        [PSCustomObject]@{

            Name           = 'AzureAD'

        }

    )

    $requirePowerShell  = '5.1.1'

    $SupportCore        = $false

 

    $PSVersion = $requirePowerShell.Split(".")

    if ($PSVersion[0] -ge 6) { $PSNeededEdition = "Core" } else { $PSNeededEdition = "Desktop" }

    $PSInstalled = $PSVersionTable

    if (-not $SupportCore -and $PSInstalled.PSEdition -eq "Core") {ErrorDisplay "This script does not run on Powershell Core."}

    if ($PSNeededEdition -eq "Core" -and $PSInstalled.PSEdition -ne "Core") { ErrorDisplay "The script must run in Powershell Core" }

 

if ($PSNeededEdition -eq "Core") {

        $PSInstalledVersion = [string]$PSInstalled.PSVersion.Major + "." + [string]$PSInstalled.PSVersion.Minor + "." + [string]$PSInstalled.PSVersion.Patch

        if ([int]$PSVersion[0] -gt [int]$PSInstalled.PSVersion.Major) {

            ErrorDisplay "The minimum PowerShell version needed is '$requirePowerShell' and you have version '$PSInstalledVersion' installed"

        } elseif ([int]$PSVersion[1] -gt [int]$PSInstalled.PSVersion.Minor) {

            ErrorDisplay "The minimum PowerShell version needed is '$requirePowerShell' and you have version '$PSInstalledVersion' installed"

        } elseif ([int]$PSVersion[2] -gt [int]$PSInstalled.PSVersion.Patch) {

            ErrorDisplay "The minimum PowerShell version needed is '$requirePowerShell' and you have version '$PSInstalledVersion' installed"

        }

    }

    else {

        $PSInstalledVersion = [string]$PSInstalled.PSVersion.Major + "." + [string]$PSInstalled.PSVersion.Minor + "." + [string]$PSInstalled.PSVersion.Build

        if ([int]$PSVersion[0] -gt [int]$PSInstalled.PSVersion.Major) {

            ErrorDisplay "The minimum PowerShell version needed is '$requirePowerShell' and you have version '$PSInstalledVersion' installed"

        } elseif ([int]$PSVersion[1] -gt [int]$PSInstalled.PSVersion.Minor) {

            ErrorDisplay "The minimum PowerShell version needed is '$requirePowerShell' and you have version '$PSInstalledVersion' installed"

        } elseif ([int]$PSVersion[2] -gt [int]$PSInstalled.PSVersion.Build) {

            ErrorDisplay "The minimum PowerShell version needed is '$requirePowerShell' and you have version '$PSInstalledVersion' installed"

        }

     }

 

 

# Get Installed Modules

    Write-Host -ForegroundColor Yellow "-   We will verify if your computer meets the minimum requirements."

    $installedModules = Get-InstalledModule | Select-Object Name, Version

   

    # Default bool

    $modulesMissing = $false

 

  # Check each module is installed and greater or equal to the minimum version

    foreach ($requiredModule in $requiredModules) {

        $installedModule = $installedModules | Where-Object 'Name' -eq $requiredModule.Name

        if ($null -eq $installedModule) {

            Write-Host "Required Module `'$($requiredModule.Name)`'is not installed."  -Fore Black -Back Red; $modulesMissing = $true; continue

        }

 

        else {

            Write-Host "Required Module `'$($requiredModule.Name)`' version $($ver) is installed." -Fore Black -Back Green

        }

 

# Prompt user to install required modules

    if ($modulesMissing -eq $true) {

        Write-Host 'Required modules are not installed!  Please install them and rerun the script!' -Fore Black -Back Red

        Write-Host ' '

        Write-Host ' '

        PAUSE

        EXIT

    }

}

 

#Sign on to Azure with privileged Account

Write-Host "We will now sign you into Azure, please make sure you have already activate your MIM PAG role" -Fore Yellow

Pause

Connect-AzAccount

 

#Set Subscription to MIM

Set-AzContext '[replace subscription here]'  #replace [replace subscription here] with the subscription name

$Context = Get-AzContext

$Subscription = (Get-AzSubscription -subscriptionID $Context.subscription).name

 

$Location = 'West Europe' #replace the region that the Ultra Shared disks are going to be created.

$SkuName = 'UltraSSD_LRS' 

$MaxShares = '5' #maximum of 5 VMs can use the Ultra Shared Disk

 
#the following lines are used for getting the name of the resource group.  We were using a certain naming convention. 
#If reuse this script, will probably need to modify this part of the script according to the new naming convention.

$Agency = Read-Host -prompt 'What is the 2 letters Agency Code for this deployment?'
Write-Host    #since this script is interactive, using write-host to type a new line on screen
$ResourceGroup = "Azwe-" + $agency + "-RG"

$Server1 = Read-Host -prompt 'Enter the server number of the first server that the disk will be used for: (I.E. enter 02 for Azwe-DE-SQL02)'
Write-Host    #since this script is interactive, using write-host to type a new line on screen.  All the standalone "write-host" below are for this very purpose.
$Server2 = Read-Host -prompt 'Enter the server number of the second server that the disk will be used for: (I.E. enter 03 for Azwe-DE-SQL03)'
Write-Host    
$ServerName1 = "Azwe-" + $agency + '-SQL-' + $Server1
Write-Host    
$ServerName2 = "Azwe" + $agency + '-SQL-' + $Server2
Write-Host    

$DiskNo = Read-Host -prompt 'How many disks are you creating?  Disk will start at Disk0.  I.E. 3 disks will span from Disk0 - Disk2'

   

    $n = 0

    Do{

        $diskName = 'Azwe-' + $agency + '-SQL' + $Server1 + '-SQL' + $Server2 + '-ClusterDisk-Zone1-uShared-Disk' + $n

        Write-Host 'Please enter the size of ' -noNewLine

        Write-Host $diskname -noNewLine -Fore Green

            $Size = Read-Host -prompt ' (i.e. 1024)'

        Write-Host

        Write-Host

 

        Write-Host 'Please review the following Information:'

        Write-Host 'Disk to be created: '-noNewline -Fore Green

        Write-Host $diskName -Fore Yellow

        Write-Host 'Size of the disk: ' -noNewLine -Fore Green

        Write-Host $size -Fore Yellow

        Write-Host 'Resource Group: ' -noNewLine -Fore Green

        Write-Host $ResourceGroup -Fore Yellow

        Write-Host 'SuberScription: ' -noNewLine -Fore Green

        Write-Host $Subscription -Fore Yellow

        Write-Host 'Location: ' -noNewLine -Fore Green

        Write-Host $Location -Fore Yellow

        Write-Host 'Disk Account Type: ' -noNewLine -Fore Green

        Write-Host $SkuName -Fore Yellow

        Write-Host 'Max Share: ' -Fore Green -noNewLine

        Write-Host $MaxShares -Fore Yellow

        Write-Host 'Disks will be attached to ' -noNewLine -Fore Green

        Write-Host $ServerName1 -Fore Yellow -noNewLine

        Write-Host ' and ' -noNewLine -Fore Green

        Write-Host $ServerName2 -Fore Yellow

        Write-Host

        Write-Host

 

        $Deploy = ''

        Do{Write-Host 'Type GOAHEAD to deploy or EXIT to end this script: ' -noNewLine -Fore Green

            $Deploy = Read-host

        }While($Deploy.toUpper() -ne 'GOAHEAD' -and $Deploy.toUpper() -ne 'EXIT')

 

        If($Deploy.toUpper() -eq 'GOAHEAD'){

                    $i = '0'

            $diskconfig = New-AzDiskConfig -Location $location -DiskSizeGB $Size -AccountType $skuName -CreateOption Empty -Zone '1' -MaxSharesCount $MaxShares -EncryptionSettingsEnabled $True;

            $diskConfig.EncryptionSettingsCollection = New-Object Microsoft.Azure.Management.Compute.Models.EncryptionSettingsCollection

            $dataDisk = New-AzDisk -ResourceGroupName $ResourceGroup -DiskName $diskName -Disk $diskConfig;

 

            $vm = Get-AzVM -name $ServerName1 -ResourceGroupName $ResourceGroup

            $lun = ($Vm.StorageProfile).Datadisks | sort lun -descending | Select -first 1

            $i = $lun.lun + 1

            $vm = Add-AzVmDataDisk -VM $vm -name $diskName -CreateOption Attach -ManagedDiskID $dataDisk.Id -lun $i

 

            Update-AzVM -VM $Vm -ResourceGroupName $ResourceGroup

            }

 

        Elseif($Deploy.toUpper() -eq 'EXIT')

        {

            Exit

        }

 

    $n = $n + 1

    }while($n -lt $Diskno)

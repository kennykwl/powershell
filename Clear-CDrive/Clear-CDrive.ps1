function Write-Log {

  [CmdletBinding()]
  param {
    [parameter(Mandatory=$true)]
    [string]$path,
    
    [parameter(Mandatory=$true)]
    [string]$message,

    [parameter(Mandatory=$true)]
    [validateSet("INFO","WARNING","ERROR")]
    [string]$type

    }

    $component = $($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)"

    # Create a log entry
    $content = "<type=`"$type`" >" +`
    "<date=`"$(Get-Date -Format "M-d-yyyy")`"> " +`
    "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`"> " +`
    "<![Log[$message]LOG]!>" +`
    "<component=`"$component`">"

    # Write the line to the log file
    Add-Content -Path $path -Value $content

}

# Function to empty out the Recycle Bin


    
    

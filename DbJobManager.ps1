#region Load Job Parameters
  Param 
  ( 
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()] 
    [ValidateSet("Production","Testing","Dryrun")] 
    [string]$RuntimeEnv="Production",

    [Parameter(Mandatory=$false)]
    [string]$VeeamJobName="WinXP",

    [Parameter(Mandatory=$false)] 
    [Alias('Dir')] 
    [string]$Directory="c:\videon\"
  ) 

#Set-ExecutionPolicy unrestricted
clear-host
# Load Veeam snapin
Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

Import-Module -Name '.\_modules\write-log.psm1' -force

Start-Log


# Load Config
. .\_modules\loadconfig.ps1
#endregion

# Connect to VBR server
. .\_modules\veeamconnect.ps1
#endregion

#region Run Mailer
. .\_modules\Mailer.ps1 -VeeamJobName $VeeamJobName
#endregion

#region Run Sure Backup Job
<#
$SureJob = Get-VSBJob -Name "1.     DB-OFCUBS <backup>"

$SureJobState=$SureJob.FindLastSession().State

if ($SureJobState -eq "Working")
{
WRITE-HOST "The sessionID for this job is: " $SureJob.Id
}
#>

#endregion

#region Run  Snapshot Job
#endregion

#region Run Zip Job

#endregion

#region Refresh Environment

#endregion

#region Create Environment

#endregion

Stop-Log
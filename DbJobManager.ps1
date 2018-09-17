#region Load Job Parameters
  Param 
  ( 
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()] 
    [ValidateSet("Production","Testing","Dryrun")] 
    [string]$RuntimeEnv="Production",

    [Parameter(Mandatory=$false)] 
    [Alias('Dir')] 
    [string]$Directory="c:\videon\"
  ) 

#Set-ExecutionPolicy unrestricted

Import-Module -Name '.\_modules\write-log.psm1' -force

clear-host

#endregion


# Load Config
. .\_modules\loadconfig.ps1
#endregion

#region Run Mailer
. .\_modules\Mailer.ps1
#endregion

#region Run Sure Backup Job

#endregion

#region Run  Snapshot Job
#endregion

#region Run Zip Job

#endregion

#region Refresh Environment

#endregion

#region Create Environment

#endregion
#region Load Job Parameters
  Param 
  ( 

    [Parameter(Mandatory=$false)]
    [string]$JobName="WinXP"
  ) 

#Set-ExecutionPolicy unrestricted
clear-host
# Load Veeam snapin
Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

Import-Module -Name '.\_modules\write-log.psm1' -force

Start-Log


# Load Config
. .\_modules\loadconfig.ps1 -JobName $JobName
#endregion

# Connect to VBR server
. .\_modules\veeamconnect.ps1
#endregion

#region Run Mailer
#. .\_modules\Mailer.ps1
#endregion

#region Run Sure Backup Job
#. .\_modules\Surebackup.ps1
#endregion

#region Run  Snapshot Job
#. .\_modules\Snapshot.ps1
#endregion

#region Run Zip Job
. .\_modules\Zip.ps1
#endregion

#region Refresh Environment

#endregion

#region Create Environment

#endregion

Stop-Log
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
#Import-Module -Name $Directory"_modules\merge-keys.psm1"

clear-host

#endregion


#region Load Base Config

    # Base Directory
    # This must match with the UpdateService/LocalePath entry ($Config.UpdateService.LocalePath)
    # in the JSON configuration file if you want to use the automated update/Distribution features!
    $BaseDirectory = "$Directory"
    $ConfigDirectory = $Directory+"_config\"
    $DailyConfigDirectory = $Directory+"_daily_config\"

    # JSON configuration filename to use
    $BaseConfig = "config.json"

    # JSON environment configuration filename to use
    $EnvConfigFile = "$RuntimeEnv.json"

    # JSON configuration filename for current date
    $curdate = Get-Date -format ddMMyyyy
    $CurrentConfigFile = "$curdate.json"

    If(!(test-path "$ConfigDirectory$BaseConfig"))
    {
          Write-Output "--  The Base configuration file is missing!  --"
    } else {
              ## Load Default Config file
              $global:Config = Get-Content "$ConfigDirectory$BaseConfig" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              Write-Output "Base Config file loaded"
    }
    # Check the configuration
    if (!($Config)) {
              Write-Output -Message "---  The Base configuration file could not be loaded! --"
    }

    # Check and load custom config for today
    If(!(test-path "$ConfigDirectory$EnvConfigFile"))
    {
          Write-Output "--  No configuration file for $RuntimeEnv !  --"
    } else {
              ## Load Runtime Environment Config file
              $EnvConfig = Get-Content "$ConfigDirectory$EnvConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              Write-Output "Runtime Environment Config file loaded"
    }


    # Check and load custom config for today
    If(!(test-path "$DailyConfigDirectory$CurrentConfigFile"))
    {
          Write-Output "--  No configuration file for current day!  --"
    } else {
              ## Load Current Day's Config file
              $CurrentConfig = Get-Content "$DailyConfigDirectory$CurrentConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              Write-Output "Current Day's Config file loaded"
    }


#endregion

#region Create Job Config Values from loaded config files
    if ($EnvConfig)
    {
        $EnvConfig.psobject.Properties | ForEach-Object {
        $Config | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
        }
        if ($CurrentConfig)
        {
            $CurrentConfig.psobject.Properties | ForEach-Object {
            $Config | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
            }
        }
    }  
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
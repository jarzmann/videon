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

Import-Module -Name '.\_modules\write-log.psm1' -force

clear-host

#endregion


#region Load Base Config

    # Base Directory
    # This must match with the UpdateService/LocalePath entry ($Config.UpdateService.LocalePath)
    # in the JSON configuration file if you want to use the automated update/Distribution features!
    $BaseDirectory = "$Directory"
    $ConfigDirectory = $Directory+"_config\"
    $DailyConfigDirectory = $Directory+"_daily_config\"
    $SysConfigDirectory = $Directory+"_config\_sys\"

    # JSON configuration filename to use
    $BaseConfig = "config.json"

    # JSON environment configuration filename to use
    $EnvConfigFile = "$RuntimeEnv.json"

    # JSON dev system specific configuration filename to use
    $SysConfigFile = "$env:computername.json"

    # JSON configuration filename for current date
    $curdate = Get-Date -format ddMMyyyy
    $CurrentConfigFile = "$curdate.json"

    If(!(test-path "$ConfigDirectory$BaseConfig"))
    {
      write-log -Message '--  The Base configuration file is missing!  --'
    } else {
              ## Load Default Config file
              $global:Config = Get-Content "$ConfigDirectory$BaseConfig" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              write-log -Message 'Base Config file loaded'
    }
    # Check the configuration
    if (!($Config)) {
              write-log -Message '---  The Base configuration file could not be loaded! --'

    }

    # Check and load runtime environment config
    If(!(test-path "$ConfigDirectory$EnvConfigFile"))
    {
      write-log -Message '--  No configuration file for $RuntimeEnv !  --'
    } else {
              ## Load Runtime Environment Config file
              $EnvConfig = Get-Content "$ConfigDirectory$EnvConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              write-log -Message "Runtime Environment Config file {$EnvConfigFile} loaded"
    }

    # Check and load system specific config
    If(!(test-path "$SysConfigDirectory$SysConfigFile"))
    {
      write-log -Message "--  No system specific configuration file found for $env:computername !  --"
    } else {
              ## Load Runtime Environment Config file
              $SysConfig = Get-Content "$SysConfigDirectory$SysConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              write-log -Message "Config file for $env:computername {$SysConfigFile} loaded!  --"
    }


    # Check and load custom config for today
    If(!(test-path "$DailyConfigDirectory$CurrentConfigFile"))
    {
      write-log -Message "--  No configuration file for current day!  --"
    } else {
              $CurrentConfig = Get-Content "$DailyConfigDirectory$CurrentConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              Write-Output "Current Day's Config file loaded"
              write-log -Message "Current day's config - $CurrentConfigFile - loaded"
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
    if ($SysConfig)
    {
      $SysConfig.psobject.Properties | ForEach-Object {
      $Config | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
      }
    }
}

write-log -Message "$Config"

#endregion



#region Run Mailer
#. .\_modules\Mailer.ps1

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
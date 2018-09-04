﻿Set-ExecutionPolicy unrestricted
clear-host

#region Load Base Config

    # Base Directory
    # This must match with the UpdateService/LocalePath entry ($Config.UpdateService.LocalePath)
    # in the JSON configuration file if you want to use the automated update/Distribution features!
    $global:BaseDirectory = "C:\scripts\PowerShell\"

    # JSON configuration filename to use
    $global:BaseConfig = "config.json"

    If(!(test-path "$BaseDirectory$BaseConfig"))
    {
          Write-Output "--  The Base configuration file is missing!  --"
    } else {
              ## Load Default Config file
              $global:Config = Get-Content "$BaseDirectory$BaseConfig" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
              Write-Output "Base Config file loaded"
    }
    # Check the configuration
    if (!($Config)) {
              Write-Output -Message "--  The Base configuration file could not be loaded! --"
    }

#endregion

#region Read Config

    $global:ConfigVersion = ($Config.basic.ConfigVersion)

    # Customer Info (For future use)
    $global:Company = ($Config.basic.Customer)

    # Environment (Production, Leaduser, Testing, Development)
    $global:environment = ($Config.basic.environment)

#endregion
Set-ExecutionPolicy unrestricted
clear-host

$global:BaseDirectory = "c:\videon\_daily_config\"
$curdate = Get-Date -format ddMMyyyy
$global:DayConfigFile = "$BaseDirectory$curdate.json"


 if (Test-Path $DayConfigFile) 
  { 
      Remove-Item -Path $DayConfigFile -Force 
      #Write-Output "Deleting existing day config  file`n"
  }


$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No'
$ynoptions = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)

$one = New-Object System.Management.Automation.Host.ChoiceDescription '&One', 'One'
$two = New-Object System.Management.Automation.Host.ChoiceDescription '&Two', 'Two'
$three = New-Object System.Management.Automation.Host.ChoiceDescription '&Three', 'Three'
$none = New-Object System.Management.Automation.Host.ChoiceDescription '&None', 'None'
$noptions = [System.Management.Automation.Host.ChoiceDescription[]]($none, $one, $two, $three)


$title = 'Zip Job'
$message = 'Enable Zip Job?'
$RunZipJob = $host.ui.PromptForChoice($title, $message, $ynoptions, 0)

$title2 = 'Force EOM'
$message2 = 'Run in EOM Mode?'
$ForceEom = $host.ui.PromptForChoice($title2, $message2, $ynoptions, 0)

$title3 = 'Create Environment(s)?'
$message3 = 'Select number of environment(s) to create!'
$NoOfBackups = $host.ui.PromptForChoice($title3, $message3, $noptions, 0)

$config = @()
$config += [pscustomobject]@{
  'RunZipJob'=$RunZipJob;
  'ForceEom'=$ForceEom;
  'CreateEnv'=$NoOfBackups;
}

$config | ConvertTo-json | Out-File -FilePath $DayConfigFile
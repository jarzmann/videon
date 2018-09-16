Set-ExecutionPolicy unrestricted
clear-host

$global:BaseDirectory = ".\_daily_config\"
$curdate = Get-Date -format ddMMyyyy
$global:DayConfigFile = "$BaseDirectory$curdate.json"

$name = Read-Host 'What is your name?'
$config = @()
$config += [pscustomobject]@{
  'SmtpServer'="september6th.fsdhgroup.com";
  'Smtpfrom'="september6th@fsdhgroup.com";
  'Smtpto'="september6th-staff@fsdhgroup.com";
  'LogToConsole'="0"
}

$config | ConvertTo-json | Out-File -FilePath $DayConfigFile
$SureJob = Get-VSBJob -Name $Config.SureJobName

$SureJobName = $Config.SureJobName

$SureJobState=$SureJob.FindLastSession().State

if ($SureJobState -eq "Working")
{
  $SId = $SureJob.Id.Guid
  write-log  "SureJob is currently running! The sessionID for this job is: $SId"
  Stop-VSBJob -Job $SureJob
  write-log "SureJob has been terminated!"
}

if ([System.Convert]::ToBoolean($Config.RunSureJob))
{
    #start Sure BAckup Job
    Get-VSBJob -Name $Config.SureJobName | Start-VSBJob -RunAsync
    write-log "$SureJobName has been initiated!"
}else{
    write-log "SureJob not configured to autorun!"
}
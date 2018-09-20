$SureJob = Get-VSBJob -Name $Config.SureJobName

$SureJobState=$SureJob.FindLastSession().State

if ($SureJobState -eq "Working")
{
  $SId = $SureJob.Id.Guid
  write-log  "SureJob is currently running!`nThe sessionID for this job is: $SId"
  Stop-VSBJob -Job $SureJob
  write-log "SureJob has been terminated!"
}

#start Sure BAckup Job
Get-VSBJob -Name $Config.SureJobName | Start-VSBJob -RunAsync
write-log $Config.SureJobName+" has been initiated!"
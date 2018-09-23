$now = Get-Date

# Official Work hours 7am to 7pm
$OfficialWorkHours = (-not($now -ge (Get-Date 07:00) -and $now -lt (Get-Date 19:00)))

# SnapshotJob is enabled and runtime is outside working hours
$comment = "did not run!"
if ($Config.SnapshotJobName -and [System.Convert]::ToBoolean($Config.RunSnapshotJob) -and $OfficialWorkHours)
{   
    Get-VBRJob -Name $Config.SnapshotJobName | Start-VBRJob -RunAsync
    $comment = "is running!"
}
$SnapshotJobName = $Config.SnapshotJobName
$RunSnapshotJob = $Config.RunSnapshotJob
write-log "Run snapshot job for $SnapshotJobName is set to $RunSnapshotJob. Offical Work Hours : $OfficialWorkHours"
write-log "Job $SnapshotJobName $comment."
$now = Get-Date

# Official Work hours 7am to 7pm
$OfficialWorkHours = (-not($now -ge (Get-Date 07:00) -and $now -lt (Get-Date 19:00)))

# SnapshotJob is enabled and runtime is outside working hours
$comment = "did not run!"
if ($Config.SnapshotJobName -and $Config.RunSnapshotJob -and $OfficialWorkHours)
{   
    Get-VBRJob -Name $Config.SnapshotJobName | Start-VBRJob -RunAsync
    $comment = "is running!"
}
write-log "Run snapshot job for $$Config.SnapshotJobName is set to $Config.RunSnapshotJob.`n Offical Work Hours : $OfficialWorkHours"
write-log " Job $$Config.SnapshotJobName $comment."
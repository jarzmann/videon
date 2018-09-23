if ($Config.CreateEnv)
{
  $RestorePoint = Get-VBRBackup -Name $Config.VeeamJobName | Get-VBRRestorePoint -Name $Config.VmName | Sort-Object –Property CreationTime –Descending | Select -First 1
  $Server = $Config.RestoreHost
  $CreateEnvTime = Get-Date -Format yyyyMMdd
  $Reason = "Requested by EOD Backup for $CreateEnvTime"

  ###Start-VBRRestoreVM -VMName "Name" - Reason "Reason" –RestorePoint $RestorePoint –Server $server –ResourcePool $rpool –Datastore $datastore –PowerUp -SkipTagsRestore -RunAsync
  write-log "Create Environment is set"
  $CreateEnv = $Config.CreateEnv
  if ($CreateEnv -eq 1)
  {
    $Name = $Config.VmName+"_$CreateEnvTime"
    write-log "Creating one Environment"
    Start-VBRRestoreVM  -RestorePoint $RestorePoint -Server $server -VMName $Name -Reason $Reason -PowerUp $true -SkipTagsRestore -RunAsync
  }else{
    write-log "Creating $CreateEnv Environments"
    for($counter = 1; $counter -le $Config.CreateEnv; $counter++)
     {
        $Name = $Config.VmName+'_'+$counter+"_$CreateEnvTime"
        write-log "Creating clone $Name"
        Start-VBRRestoreVM  -RestorePoint $RestorePoint -Server $server -VMName $Name -Reason $Reason -SkipTagsRestore -RunAsync
        #no power up - refer to the To-DO
     }
  }
}
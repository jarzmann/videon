  # Get last working day in current month
  $LastWorkingWeekDay =  Get-Date ((get-date).addmonths(1)).adddays(-(get-date ((get-date).addmonths(1)) -format dd)) -Format d
  $today = Get-Date -Format d

  #Check for End of Month - EOM and assign relevant values
  if (($LastWorkingWeekDay -eq $today) -or [System.Convert]::ToBoolean($Config.ForceEOM))
  {
    $folder = $Config.EOMZipDirectory
    $EOM = $true
    $comment = "End of Month Veeam Zip"
    write-log "Natural EOM or forced EOM detected!"
  }elseif ([System.Convert]::ToBoolean($Config.RunZipJob)){
    $folder = $Config.ZipDirectory
    $comment = "User requested Veeam Zip"
    write-log "Custom Zip request detected!"
  }else {
      $folder = $Config.ZipDirectory
  }

  write-log $folder
  
 # write-log "Final EOM Parameters are EOM :$Conifg.RunZipJob"

  # VeeamZip if EOM or Force EOM or RunZipJob enabled
  if ($EOM -or [System.Convert]::ToBoolean($Config.RunZipJob))
  {   
      if (!(Test-Path $folder))
      {
        New-Item -ItemType "directory" -Path $folder
        Write-log "Creating $folder"
      }else{
        #file maintenance activities - e,g delete old files
      } 
      $vm = Find-VBRViEntity -Name $Config.VmName
      Start-VBRZip -Entity $vm -Compression 9 -DisableQuiesce -Folder $folder -RunAsync
      write-log "$comment for $Config.VmName is running!"
  }
#region Initiate Session

    # Get parameters or load defalt values
    param
    (
        [string]$VeeamJobName,
        [switch]$RunSureJob = $true,
        [string]$MailTo = "isteam@fsdhgroup.com",
        [string]$SureJobName = "1.     DB-OFCUBS <backup>",
        [switch]$ForceSure = $false,
        [string]$VeeamServer = "192.168.0.134",
        [switch]$Testing = $false,
        [switch]$SnapshotJob = $true
    )

        $VmName = switch ($VeeamJobName) 
    { 
        DBOFCUBS_HO_PRE-EOD {"DB-OFCUBS-Prod_finclose_14052018"} 
        DBOFCUBS_RC_PRE-EOD {"Flexcube Database and Symplus Database"} 
    }


    # Clear console output
    Clear-Host

    Import-Module -Name 'C:\scripts\ps\write-log.psm1'


    if ($Testing)
    {
        $RunSureJob = $false
        $ForceSure = $false
        $MailTo = "fadewole@fsdhgroup.com"
        $SnapshotJob = $false

        foreach ($key in $MyInvocation.BoundParameters.keys)
        {
            $value = (get-variable $key).Value 
            write-host "$key -> $value"
        }

        write-log -Message 'Test mode' -Level 'info' -LogFileName $VeeamJobName

    }


    # Load Veeam snapin
    Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

    #Get existimh session to Veeam Server
    $w = Get-VBRServerSession

    # Create session if none exists
    if (!$w)
    {
        $Credentials=IMPORT-CLIXML C:\scripts\xml\SecureCredentials.xml
        Connect-VBRServer -Credential $Credentials -Server $VeeamServer
    }

   # $file = Get-Date -format yyyyMMdd
   # $Path = "C:\PreEODBkLog\"+$file+".txt"
    $starttime = Get-Date -format t
#endregion

#region Email Settings
    # Email SMTP server
    $SMTPServer = “email2.fsdhgroup.com”
    # Email FROM
    $EmailFrom = “veeam@fsdhgroup.com”
    # Email TO
    $EmailTo = $MailTo
    # Email subject
    $EmailSubject = $VeeamJobName+“ Backup Task Completed”
    # Email formatting
    $style = “<style>BODY{font-family: Arial; font-size: 10pt;}”
    $style = $style + “TABLE{border: 1px solid black; border-collapse: collapse;}”
    $style = $style + “TH{border: 1px solid black; background: #54b948; padding: 5px; }”
    $style = $style + “TD{border: 1px solid black; padding: 5px;text-align: center; }”
    $style = $style + “</style>”
#endregion

#region Generate Email body content
    $mbody = New-Object PSObject -Property @{
       'Name' = $VeeamJobName
       'End Time' = $starttime
       'Triggered By' = "Veeam Admin"
       'Triggered From' = "Veeam Console"
    }

    $job = Get-VBRJob -Name $VeeamJobName
    $HistoryJob = @()
    $jobhistory = Get-VBRBackupSession | Where {$_.jobId -eq $job.Id.Guid} | Sort EndTimeUTC -Descending | Select -First 5
    foreach($history in $jobhistory)
    {
        $durationTime = $history.EndTimeUTC - $history.CreationTimeUTC
        $duration = "{0:hh} hours and {0:mm} minutes" -f $durationTime
        $historydate = Get-Date $history.EndTimeUTC -Format F

        $HistoryJob += New-Object PSObject -Property @{
           'historystart' = Get-Date $history.CreationTimeUTC -Format g
           'historyend' = Get-Date $history.EndTimeUTC -Format g
           'duration' = $duration
           'Result' = $history.Result
           'User' = $Name
        }
    }

    $CurrentJob = $mbody | Select 'Name','End Time','Triggered By','Triggered From' | ConvertTo-Html -head $style | Out-String
    $HistoryJobs = $HistoryJob | Select  @{Name="Start Time"; Expression = {$_.historystart}},@{Name="Completed Time"; Expression = {$_.historyend}},@{Name="Duration"; Expression = {$_.duration}},'Result'| ConvertTo-Html -head $style | Out-String
#endregion

#region Send Email
    $Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
    $Message.Subject = $EmailSubject
    $Message.IsBodyHTML = $True
    $message.Body = "$CurrentJob <br> <H2>Job History</H4> $HistoryJobs"
    $SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)
    $SMTP.Send($Message)
    write-log -Message 'Test mode' -Level 'info' -LogFileName $VeeamJobName
#endregion

#region SureBackup Job Config

    $now = Get-Date
    # Official Work hours 7am to 7pm
    $OfficialWorkHours = (-not($now -ge (Get-Date 07:00) -and $now -lt (Get-Date 19:00)))
    $RequestedJob = ("DBOFCUBS_HO_PRE-EOD" -or "DBOFCUBS_RC_PRE-EOD") 

    # Surebackup is enabled and runtime is outside working hours
    if ($RunSureJob -and $OfficialWorkHours -and $RequestedJob)
    {   
        
        Get-VSBJob -Name "1.     DB-OFCUBS <backup>" | Start-VSBJob -RunAsync

    }
#endregion

#region Stororage Snapshot Job Config
    # SnapshotJob is enabled and runtime is outside working hours
    if ($SnapshotJob -and $OfficialWorkHours -and $RequestedJob)
    {   
        
        Get-VBRJob -Name "DB-OFCUBS - Storage Snapshot" | Start-VBRJob -RunAsync

    }
#endregion

#region EOM Job Config
    # Get last working day in current month
    $LastWorkingWeekDay =  Get-Date ((get-date).addmonths(1)).adddays(-(get-date ((get-date).addmonths(1)) -format dd)) -Format d
    $today = Get-Date -Format d

    # VeeamZip if today is Last Working Day
    if ($LastWorkingWeekDay -eq $today)
    {   
        $vm = Find-VBRViEntity -Name "DB-OFCUBS-Prod_finclose_14052018"
        Start-VBRZip -Entity $vm -Compression 4 -DisableQuiesce -AutoDelete Never -RunAsync

    }
#endregion

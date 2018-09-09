#region Initiate Session

    # Get parameters or load defalt values
    param
    (
        [string]$VeeamJobName,
        [string]$MailTo=$Config.Smtpto,
        [string]$VeeamServer=$Config.VeeamServer
    )

    <#    $VmName = switch ($VeeamJobName) 
    { 
        DBOFCUBS_HO_PRE-EOD {"DB-OFCUBS-Prod_finclose_14052018"} 
        DBOFCUBS_RC_PRE-EOD {"Flexcube Database and Symplus Database"} 
    }#>


    # Clear console output
    Clear-Host

    Import-Module -Name '.\_modules\write-log.psm1' -force


    foreach ($key in $MyInvocation.BoundParameters.keys)
    {
        $value = (get-variable $key).Value 
        write-log -Message "$key -> $value" -Level 'info'
    }

    # Load Veeam snapin & Connect to Veeam
#. .\_modules\veeamconnect.ps1

    $starttime = Get-Date -format t
#endregion

#region Email Settings
    # Email SMTP server
    $SMTPServer = $Config.SmtpServer
    # Email FROM
    $EmailFrom = $Config.Smtpfrom
    # Email TO
    $EmailTo = $Config.Smtpto
    # Email subject
    $EmailSubject = "$VeeamJobName Backup Task Completed"
    # Email formatting
   <# $style = “<style>BODY{font-family: Arial; font-size: 10pt;}”
    $style = $style + “TABLE{border: 1px solid black; border-collapse: collapse;}”
    $style = $style + “TH{border: 1px solid black; background: 54b948; padding: 5px;}”
    $style = $style + “TD{border: 1px solid black; padding: 5px;text-align: center;}”
    $style = $style + “</style>”#>
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
    $Message.IsBodyHTML = [System.Convert]::ToBoolean($Config.FormatHTML)
    $message.Body = "$CurrentJob <br> <H2>Job History</H4> $HistoryJobs"
    $SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)
    $SMTP.Send($Message)
    write-log -Message 'Mail sent' -Level 'info'
#endregion


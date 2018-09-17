#region Initiate Session

    # Get parameters or load defalt values
    param
    (
        [string]$VeeamJobName,
        [string]$MailTo=$EmailConfig.Smtpto,
        [string]$VeeamServer=$Config.VeeamServer
    )

    <#    $VmName = switch ($VeeamJobName) 
    { 
        DBOFCUBS_HO_PRE-EOD {"DB-OFCUBS-Prod_finclose_14052018"} 
        DBOFCUBS_RC_PRE-EOD {"Flexcube Database and Symplus Database"} 
    }#>

    # Function StringFind - Used by Job History to find username & System
    function StringFind ($string, $firstkey, $secondkey) {
        if (firstkey -eq "UserName")
        {
            $preset = 10
        } else {
            $preset = 16
        }
        $start = $string.IndexOf($firstkey) + $preset
        $end = $string.IndexOf($secondkey) - 2
        $found = $string.Substring($start, $end-$start)
        return $found
    }

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
    $SMTPServer = $EmailConfig.SmtpServer
    # Email FROM
    $EmailFrom = $EmailConfig.Smtpfrom
    # Email TO
    $EmailTo = $EmailConfig.Smtpto
    # Email subject
    $EmailSubject = "$VeeamJobName Backup Task Completed"
    # Email formatting
    $style = '<style>BODY{font-family: Arial; font-size: 10pt;}'
    $style += 'TABLE{border: 1px solid black; border-collapse: collapse;}'
    $style += 'TH{border: 1px solid black; background: 54b948; padding: 5px;}'
    $style += 'TD{border: 1px solid black; padding: 5px;text-align: center;}'
    $style += '</style>'
#endregion

#region Generate Email body content
    if($w)
    {
        write-log -Message 'Existing Veeam Server Session reused' -Level 'info'
        $LoggedIn = $w.Split("\")
        $mbody = New-Object PSObject -Property @{
           'Name' = $VeeamJobName
           'End Time' = $starttime
           'Triggered By' = $w[1]
           'Triggered From' = $w[0]
        }
        $job = Get-VBRJob -Name $VeeamJobName
        $jobhistory = Get-VBRBackupSession | Where {$_.jobId -eq $job.Id.Guid} | Sort EndTimeUTC -Descending | Select -First 5    
        write-log -Message 'Job &Job History successful loaded' -Level 'info'
    }else{

        write-log -Message 'Sample Dataset loaded and/or dryrun in effect'
        $mbody = New-Object PSObject -Property @{
           'Name' = $VeeamJobName
           'End Time' = $starttime
           'Triggered By' = "Veeam Admin"
           'Triggered From' = "Veeam Console"
        }
        # add dry run job & job history sample data import here.
    }
        $HistoryJob = @()
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
               'User' = StringFind($History.AuxData, "UserName","UserDomainName")
            }
        }

        $CurrentJob = $mbody | Select 'Name','End Time','Triggered By','Triggered From' | ConvertTo-Html -head $style | Out-String
        $HistoryJobs = $HistoryJob | Select  @{Name="Start Time"; Expression = {$_.historystart}},@{Name="Completed Time"; Expression = {$_.historyend}},@{Name="Duration"; Expression = {$_.duration}},'Result'| ConvertTo-Html -head $style | Out-String
   
#endregion

#region Send Email
    $Message = New-Object System.Net.Mail.MailMessage
    $Message.From = $EmailConfig.SmtpFrom 
    $Message.To.Add($EmailConfig.Smtpto) 
    $Message.Subject = $EmailSubject
    $Message.IsBodyHTML = [System.Convert]::ToBoolean($Config.FormatHTML)
    $message.Body = "$CurrentJob <br> <H2>Job History</H4> $HistoryJobs"
    $SMTP = New-Object Net.Mail.SmtpClient($EmailConfig.SMTPServer, $EmailConfig.SMTPPort)
    $SMTP.EnableSsl = [System.Convert]::ToBoolean($EmailConfig.SmtpEnableSSL)
    $SMTP.Credentials = New-Object System.Net.NetworkCredential($EmailConfig.SmtpUser, $EmailConfig.SmtpPass)
    #$SMTP
    
    $SMTP.Send($Message)
    write-log -Message "Message Body : $CurrentJob <br> <H2>Job History</H4> $HistoryJobs"
    write-log -Message 'Mail sent' 
    
#endregion


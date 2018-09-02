################################################################################
##  Params
################################################################################
   
    param
    (
        [string]$VeeamServer = "192.168.0.134",
        [switch]$PurgeEnabled = $true, 
        [int]$PurgeRetention = 2, 
        [string]$MailTo = "fadewole@fsdhgroup.com",
        [Parameter(Mandatory=$true)][string[]]$VMNames, 
        [string]$VcenterName = "vcenter01",  
        [string]$Directory = "C:\ZIPBackup",  
        [string]$CompressionLevel = "9", 
        [switch]$EnableQuiescence = $true,   
        [switch]$EnableEncryption = $false, 
        [string]$Retention = "Never",
        [switch]$EnableNotification = $True 

    )

    foreach ($key in $MyInvocation.BoundParameters.keys)
        {
            $value = (get-variable $key).Value 
            write-host "$key -> $value"
        }
        Write-Host($VcenterName)

    If(!(test-path $Directory))
    {
          New-Item -ItemType Directory -Force -Path $Directory
    }

################################################################################
## SMB Backup Space Credentials
################################################################################
$DriveName = "EOMBackup"
#$UserName = "epoadmin"
#SecretPass = ConvertTo-SecureString "@@@@@@@" -AsPlainText -Force
# Creating Credential Object to use with PSDrive
#$Creds = New-Object System.Management.Automation.PSCredential($UserName, $SecretPass)
#$Creds=IMPORT-CLIXML C:\scripts\xml\DomainSecureCredentials.xml
# Using PSDrive to create the drive
#New-PSDrive -Name $DriveName -Credential $Creds -Root "\\fsdh.net\fsdh_fs\FsdhDb\EOM_Backup" -PSProvider FileSystem
#New-PSDrive -Name $DriveName -Root "B:\" -PSProvider FileSystem
#$RemoteRepo = "${DriveName}:\"
#$RemoteRepo = New-PSDrive -Name B

################################################################################
## Notification Settings
################################################################################
# Email SMTP server settings
$SMTPServer = "email2.fsdhgroup.com"
$SMTPServerPort = "25"
$SMTPEnableSSL = $False
#$SMTPUser = "mysmtpuser" # SMTP User authentication (optional)
#$SMTPPass = "mysmtppasswd"
# Email "envelope" settings
$EmailFrom = "veeam@fsdhgroup.com"
$EmailTo = $MailTo
$EmailSubject = [string]::Join(" | ", $VMNames) +" ZIP Job: Completed"

## Email Formatting
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

################################################################################
## Main
################################################################################

# Load Veeam snapin
Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

#Get existimh session to Veeam Server
$w = Get-VBRServerSession

# Create session if none exists
if (!$w)
{
    $Credentials=IMPORT-CLIXML C:\scripts\xml\SecureCredential2s.xml
    Connect-VBRServer -Credential $Credentials -Server $VeeamServer
}

$Server = Get-VBRServer -name $VcenterName

$MesssagyBody = @()

foreach ($VMName in $VMNames)
{
  $VM = Find-VBRViEntity -Name $VMName -Server $Server
  #$OldPath = "$Directory\$VMName*.vbk"
  
  If ($EnableEncryption)
  {
    $EncryptionKey = Add-VBREncryptionKey -Password (cat $EncryptionKey | ConvertTo-SecureString)
    $ZIPSession = Start-VBRZip -Entity $VM -Folder $Directory -Compression $CompressionLevel -DisableQuiesce:(!$EnableQuiescence) -AutoDelete $Retention -EncryptionKey $EncryptionKey
  }
  
  Else 
  {
    $ZIPSession = Start-VBRZip -Entity $VM -Folder $Directory -Compression $CompressionLevel -DisableQuiesce:(!$EnableQuiescence) -AutoDelete $Retention 
  }
  
  #Move-Item -Path $OldPath -Destination $RemoteRepo


  If ($EnableNotification) 
  {
    $TaskSessions = $ZIPSession.GetTaskSessions().logger.getlog().updatedrecords
    $FailedSessions =  $TaskSessions | where {$_.status -eq "EWarning" -or $_.Status -eq "EFailed"}
  
  if ($FailedSessions -ne $Null)
  {
    $MesssagyBody = $MesssagyBody + ($ZIPSession | Select-Object @{n="Name";e={($_.name).Substring(0, $_.name.LastIndexOf("("))}} ,@{n="Start Time";e={$_.CreationTime}},@{n="End Time";e={$_.EndTime}},Result,@{n="Details";e={$FailedSessions.Title}})
  }
   
  Else
  {
    $MesssagyBody = $MesssagyBody + ($ZIPSession | Select-Object @{n="Name";e={($_.name).Substring(0, $_.name.LastIndexOf("("))}} ,@{n="Start Time";e={$_.CreationTime}},@{n="End Time";e={$_.EndTime}},Result,@{n="Details";e={($TaskSessions | sort creationtime -Descending | select -first 1).Title}})
  }
  
  }   
}
If($EnableNotification)
{
$Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
$Message.Subject = $EmailSubject
$Message.IsBodyHTML = $True
$Message.Body = $MesssagyBody | ConvertTo-Html -head $style | Out-String

$SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)
$SMTP = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPServerPort)
$SMTP.EnableSsl = $SMTPEnableSSL

# Enable if you mail server requires authentication
#$SMTP.Credentials = New-Object System.Net.NetworkCredential($SMTPUser, $SMTPPass);

$SMTP.Send($Message)

}

<#
If($PurgeEnabled)
{
# Delete all Files in the remote Repo that are older than specified above
$CurrentDate = Get-Date
#$DatetoDelete = $CurrentDate.AddDays($PurgeRetention)
#Modify Delete data to Monthly
$DatetoDelete = $CurrentDate.AddDays(-$PurgeRetention*30)
Get-ChildItem ${RemoteRepo}\*.vbk | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
}

#>

# Remove the mapped drive
#Remove-PSDrive -Name $DriveName
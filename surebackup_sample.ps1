# Load Veeam snapin
Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue
 
Clear-Host

# Connect to VBR server
$w = Get-VBRServerSession
if (!$w)
{
    $Credentials=IMPORT-CLIXML C:\scripts\xml\SecureCredentials.xml
    Connect-VBRServer -Credential $Credentials
}

$SureJob = Get-VSBJob -Name "1.     DB-OFCUBS <backup>"

$SureJobState=$SureJob.FindLastSession().State

if ($SureJobState -eq "Working")
{
WRITE-HOST "The sessionID for this job is: " $SureJob.Id
}


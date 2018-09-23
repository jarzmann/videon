  # Load Veeam snapin
    Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

    #Get existimh session to Veeam Server
    $w = Get-VBRServerSession

    # Create session if none exists
    if (!$w)
    {
        $Credentials=IMPORT-CLIXML C:\videon\_config\_sys\SecureCredentials.xml
        Connect-VBRServer -Credential $Credentials -Server $Config.VeeamServer
    }

<# 
.Synopsis 
   Write-Log writes a message to a specified log file with the current time stamp. 
.DESCRIPTION 
   The Write-Log function is designed to add logging capability to other scripts. 
   In addition to writing output and/or verbose you can write to a log file for 
   later debugging. 
.NOTES 
   Created by: Jason Wasser @wasserja 
   Modified: 11/24/2015 09:30:19 AM   
 
   Changelog: 
    * Code simplification and clarification - thanks to @juneb_get_help 
    * Added documentation. 
    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks 
    * Revised the Force switch to work as it should - thanks to @JeffHicks 
 
   To Do: 
    * Add error handling if trying to create a log file in a inaccessible location. 
    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate 
      duplicates. 
.PARAMETER Message 
   Message is the content that you wish to add to the log file.  
.PARAMETER Path 
   The path to the log file to which you would like to write. By default the function will  
   create the path and file if it does not exist.  
.PARAMETER Level 
   Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational) 
.PARAMETER NoClobber 
   Use NoClobber if you do not wish to overwrite an existing file. 
.EXAMPLE 
   Write-Log -Message 'Log message'  
   Writes the message to c:\Logs\PowerShellLog.log. 
.EXAMPLE 
   Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log 
   Writes the content to the specified log file and creates the path and file specified.  
.EXAMPLE 
   Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error 
   Writes the message to the specified log file as an error message, and writes the message to the error pipeline. 
.LINK 
   https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0 
#> 
function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('Dirlog')] 
        [string]$LogDirPath=$Config.LogDirectory, 

        [Parameter(Mandatory=$false)] 
        [Alias('Filelog')] 
        [string]$LogFileName=$Config.LogFileName, 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$LogToConsole=[System.Convert]::ToBoolean($Config.LogToConsole), 

        [Parameter(Mandatory=$false)] 
        [switch]$LogToFile=[System.Convert]::ToBoolean($Config.LogToFile)      
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = $Config.VerbosePreference 

        #Get Log file time
        $LogTime = Get-Date -Format yyyyMMdd

        #Set Log file path
        $Path="$LogDirPath$LogFileName-$LogTime.log"

        $Seperator = "***************************************************************************************************"
    } 

    Process 
    { 
        #Rewrite - Writes to File, Console or Both
        function Rewrite($message)
        {
            if ($LogToFile) {$Message | Out-File -FilePath $Path -Append}
            #if ($LogToFile) {$Seperator | Out-File -FilePath $Path -Append}
            #Add-Content -Path $Path -Value ""

            if ($LogToConsole) 
            {
              # Write message to error, warning, or verbose pipeline and specify $LevelText 
              switch ($Level) { 
                'Error' {Write-Output $Message} 
                'Warn' {Write-Warning $Message } 
                'Info' {Write-Host $Message} 
              } 
            }
        }

        if (!(Test-Path $Path)) 
        { 
            $NewLogFile = New-Item $Path -Force -ItemType File
            Rewrite "Creating $Path" 

          } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write log entry to $Path 
        Rewrite "$FormattedDate $LevelText $Message"
    } 
    End 
    { 
    } 
}



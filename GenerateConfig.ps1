Set-ExecutionPolicy unrestricted
clear-host

$global:BaseDirectory = "C:\test\"
$global:DefaultConfigFile = "default.json"
$global:ProdConfigFile = "production.json"
$global:DayConfigFile = "today.json"

$global:BaseConfig = Get-Content "$BaseDirectory$DefaultConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
$global:ProdConfig = Get-Content "$BaseDirectory$ProdConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
$global:DayConfig = Get-Content "$BaseDirectory$DayConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue

function merge ($target, $source) {
    $source.psobject.Properties | % {
        if ($_.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject' -and $target."$($_.Name)" ) {
            merge $target."$($_.Name)" $_.Value
        }
        else {
            $target | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
        }
    }
}

function GenerateMainConfig ($new, $firstsource, $secondsource) {
    merge $new $firstsource
    merge $new $secondsource
    return
}


$MainConfig = $BaseConfig.PsObject.Copy()

#GenerateMainConfig $MainConfig $ProdConfig $DayConfig


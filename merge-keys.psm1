<# 
.Synopsis 
   Merges JSON keys 
.DESCRIPTION 
   Used to cascademerge json keys, were new key will be overwritten by firstkey and secondkey when appicable. 
   Main puropose is to generate per job Main config from default, Runtime environment (default is production) 
   and currentday config
.NOTES 
   Created by: Jimi Adewole
   Modified: 06/09/2018
.NOTES 
   Modify so cascade merge can take multiple keys. Eg. function CascadeMerge ($new, array(keys))
   Modified: 06/09/2018
#>

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

function CascadeMerge ($mergedkey, $firstkey, $secondkey) {
    merge $mergedkey $firstkey
    merge $mergedkey $secondkey
    return
}

function clone($obj)
{
    $newobj = New-Object PsObject
    $obj.psobject.Properties | % {Add-Member -MemberType NoteProperty -InputObject $newobj -Name $_.Name -Value $_.Value}
    return $newobj
}

function Join-Objects($source, $extend){
    if($source.GetType().Name -eq "PSCustomObject" -and $extend.GetType().Name -eq "PSCustomObject"){
        foreach($Property in $source | Get-Member -type NoteProperty, Property){
            if($extend.$($Property.Name) -eq $null){
              continue;
            }
            $source.$($Property.Name) = Join-Objects $source.$($Property.Name) $extend.$($Property.Name)
        }
    }else{
       $source = $extend;
    }
    return $source
}
function AddPropertyRecurse($source, $toExtend){
    if($source.GetType().Name -eq "PSCustomObject"){
        foreach($Property in $source | Get-Member -type NoteProperty, Property){
            if($toExtend.$($Property.Name) -eq $null){
              $toExtend | Add-Member -MemberType NoteProperty -Value $source.$($Property.Name) -Name $Property.Name `
            }
            else{
               $toExtend.$($Property.Name) = AddPropertyRecurse $source.$($Property.Name) $toExtend.$($Property.Name)
            }
        }
    }
    return $toExtend
}

function Json-Merge($source, $extend){
    $merged = Join-Objects $source $extend
    $extended = AddPropertyRecurse $merged $extend
    return $extended
}

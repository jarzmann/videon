$externalip = "199.199.199.199"
$subNetworking = @()
$subNetworking += [pscustomobject]@{
    'externalDns'='testclient.netsmartcloud.lan';
    'externalIp'="$externalip"
}
$subNetworking += [pscustomobject]@{
    'externalDns'='testclientuat.netsmartcloud.lan';
    'externalIp'="$externalip"
}

$subSystems = @()
$subSystems += [pscustomobject]@{
    'name'='server1.domain.lan';
    'ip'='10.10.10.10';
    'os'='RHEL';
    'osVersion'='6';
    'systemType'='DB'
}
$subSystems += [pscustomobject]@{
    'name'='server2.domain.lan';
    'ip'='10.10.10.11';
    'os'='RHEL';
    'osVersion'='6';
    'systemType'='DB'
}

$subNetworking
$subSystems


$jsonDoc = [pscustomobject]@{
    _id = "99999"
    clientLongName = "Client Long"
    clientShortName = "Client Short"
    clientID = "99999"
    clientSize = "1"
    clientLocation = "NY"
    product = "product99"
    networking = $subNetworking
    systems = $subSystems
}

$jsonDoc | ConvertTo-Json
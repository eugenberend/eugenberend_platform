$netAdapterName = "vEthernet (Default Switch)"
$subnetAddress = "172.17.20.0/24"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

$netNatExists = Get-NetNat | Where-Object {$_.InternalIPInterfaceAddressPrefix -eq $subnetAddress}
if(!$netNatExists) {
    New-NetNat -Name "Default NAT" `
                -InternalIPInterfaceAddressPrefix $subnetAddress
}

New-NetIPAddress -IPAddress "172.17.20.1" -PrefixLength 24 -InterfaceAlias $netAdapterName
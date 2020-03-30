$netAdapterName = "Minikube"
$subnetAddress = "172.17.20.0/24"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

$netNatExists = Get-NetNat | Where-Object {$_.InternalIPInterfaceAddressPrefix -eq $subnetAddress}
if(!$netNatExists) {
    New-NetNat -Name $netAdapterName `
                -InternalIPInterfaceAddressPrefix $subnetAddress
}
$switchExists = (Get-VMSwitch -Name $netAdapterName -ErrorAction SilentlyContinue).Count -gt 0
if(!$switchExists) {
    $switch = New-VMSwitch -Name $netAdapterName `
                            -SwitchType Internal
}

$netAdapter = Get-NetAdapter | Where-Object {$_.Name -like "*$netAdapterName*"}
Rename-NetAdapter -Name $netAdapter.Name -NewName $netAdapterName
New-NetIPAddress -IPAddress "172.17.20.1" -PrefixLength 24 -InterfaceAlias $netAdapterName
choco install kubernetes-cli
$iPAddress = get-vm ubuntu-minikube | Get-VMNetworkAdapter | Select -ExpandProperty IpAddresses | Select -First 1

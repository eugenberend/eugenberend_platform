choco install kubernetes-cli
$iPAddress = get-vm ubuntu-minikube | `
            Get-VMNetworkAdapter | `
            Select-Object -ExpandProperty IpAddresses | `
            Select-Object -First 1

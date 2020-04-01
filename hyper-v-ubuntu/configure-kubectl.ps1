choco install kubernetes-cli

$configFolder = "$HOME\.kube"
$configName = "downloaded_config"
$configPath = "$configFolder\$configName"

vagrant scp default:/home/vagrant/.kube/config $configPath

# Function extracts paths from kube config using regex
function ExtractItem($item, $configPath) {
    $regex = "^\s*$($item):\s*(.*)$"
    $string = Get-Content $configPath | Select-String $item
    $check = $string -match $regex
    if ($check) {
        return $Matches[1]
    }
    else {
        return $false
    }
}

$certAuthorityPath = ExtractItem -item "certificate-authority" -configPath $configPath # Extract cert authority file path
vagrant scp default:$certAuthorityPath $configFolder # Download this file locally

$clientCertPath = ExtractItem -item "client-certificate" -configPath $configPath # Extract client cert file path
vagrant scp default:$clientCertPath $configFolder # Download this file locally

$clientKey = ExtractItem -item "client-key" -configPath $configPath # Extract client cert file path
vagrant scp default:$clientKey $configFolder # Download this file locally

$iPAddress = Get-VM ubuntu-minikube | `
            Get-VMNetworkAdapter | `
            Select-Object -ExpandProperty IpAddresses | `
            Select-Object -First 1

kubectl config set-cluster minikube `
                            --certificate-authority="$configFolder\ca.crt" `
                            --embed-certs=true `
                            --server="http://$($ipAddress):8080"

kubectl config set-credentials admin `
                            --client-certificate="$configFolder\client.crt" `
                            --client-key="$configFolder\client.key"

kubectl config set-context minikube `
                            --cluster=minikube `
                            --user=admin

kubectl config use-context minikube

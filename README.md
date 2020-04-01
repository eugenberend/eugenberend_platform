# Windows

This solution deploys Ubuntu VM on Hyper-V and installs minikube on this VM.

## Requirements and restrictions

* Windows 10 x64 1803 or later
* SLAT-capable CPU
* Vagrant cannot into guest network adapter configuration if Hyper-V is used. Therefore, this solution uses virtual switch named "Default Switch" which exists by default. This is good enough for our lab purposes. Usage of non-default switch requires DHCP server, such as [Mini DHCP](https://www.dhcpserver.de/), which adds unnecessary complication.

## How to run minikube

1. Install Hyper-V `enable-hyper-v.ps1`
2. Install Chocolatey `install-chocolatey.ps1`
3. * Install vagrant `install-vagrant.ps1`
4. Run `create-ssh-key.ps1`
5. Run `provide-vm.ps1`. It provides VM and installs minikube
6. Run `configure-kubectl.ps1` to install and configure kubectl
7. Run `kubectl get pods --all-namespaces` to prove correctness

* - Vagrant may need to reboot your Windows host machine, in case Hyper-V wasn't installed before.

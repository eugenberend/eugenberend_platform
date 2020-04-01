# Windows

This solution deploys Ubuntu VM on Hyper-V and installs minikube on this VM.

## Requirements and restrictions

* Windows 10 x64 1803 or later
* SLAT-capable CPU
* Vagrant cannot into guest network adapter configuration if Hyper-V is used. Therefore, this solution uses virtual switch named "Default Switch" which exists by default. This is good enough for our lab purposes. Usage of non-default switch requires DHCP server, such as [Mini DHCP](https://www.dhcpserver.de/), which adds unnecessary complication.

## How to run minikube

1. Install Hyper-V `create-ubuntu-vm\enable-hyper-v.ps1`
2. Install Chocolatey `create-ubuntu-vm\install-chocolatey.ps1`
3. * Install vagrant `create-ubuntu-vm\install-vagrant.ps1`
4. Run `create-ubuntu-vm\create-ssh-key.ps1`
5. Run `create-ubuntu-vm\provide-vm.ps1`. It provides VM and installs minikube

* - Vagrant needs to reboot your Windows host machine

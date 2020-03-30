# Requirements and restrictions

* Windows 10 x64 1803 or later
* SLAT-capable CPU
* Vagrant cannot into guest network adapter configuration if Hyper-V is used. Therefore, this solution uses virtual switch named "Default Switch" which exists by default. This is good enough for our lab purposes. Usage of non-default switch requires DHCP server, such as [Mini DHCP](https://www.dhcpserver.de/), which adds unnecessary complication.

# How to

## Initialize environment on Windows

1. Install Hyper-V `create-ubuntu-vm\enable-hyper-v.ps1`
2. * Install vagrant `create-ubuntu-vm\install-vagrant.ps1`
3. Run `create-ubuntu-vm\create-ssh-key.ps1`
4. Run `create-ubuntu-vm\vagrant up`. It provides minikube with ansible too
5.

* - Vagrant needs to reboot your Windows host machine

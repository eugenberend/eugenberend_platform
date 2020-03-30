$packageName = "vagrant.msi"
$packageUrl = "https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.msi"
Write-Host "Downloading $packageName..."
wget $packageUrl -O $packageName
Write-Host "Installing $packageName..."
msiexec /i $packageName /q /n
Write-Host "Removing $packageName..."
rm -force $packageName

$vagrantHome = "D:\HV\.vagrant"
New-Item -ItemType Directory -Path $vagrantHome -Force

[System.Environment]::SetEnvironmentVariable('VAGRANT_HOME', $vagrantHome, [System.EnvironmentVariableTarget]::Machine)

# TODO: Replace this shit with `choco install vagrant`
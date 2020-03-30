choco install vagrant
$vagrantHome = "D:\HV\.vagrant"
New-Item -ItemType Directory -Path $vagrantHome -Force

[System.Environment]::SetEnvironmentVariable('VAGRANT_HOME', $vagrantHome, [System.EnvironmentVariableTarget]::Machine)

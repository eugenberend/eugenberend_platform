choco install kubernetes-cli
choco install minikube
minikube start
Start-Process kubectl -ArgumentList "proxy" -WindowStyle Hidden
Start-Process minikube -ArgumentList "dashboard" -WindowStyle Hidden

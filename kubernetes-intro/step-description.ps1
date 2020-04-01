# Install minikube

choco install minikube kubernetes-cli

# Start minikube

minikube start

# Display config

kubectl config view

# Check cluster info

kubectl cluster-info

# View all containers

minikube ssh "docker ps -a"

# Remove all containers

minikube ssh "docker rm -f `$(docker ps -aq)"

# View all pods

kubectl get pods -n kube-system

# Remove all pods

kubectl delete pod --all -n kube-system

# Get all component statuses

kubectl get cs

# Figure out why containers are restored

# Create a directory

new-item -itemtype Directory -Path kubernetes-intro\web

# Create Dockerfile in 'web' folder and define web server listening on 8000 and run under UID=1001
# Build image

# Create deployment yaml

cd kubernetes-intro
New-Item -ItemType File web-pod.yaml

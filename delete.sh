#!/bin/bash

# Function to uninstall Docker
uninstall_docker() {
    sudo apt-get purge docker.io -y
    sudo apt-get autoremove -y
}

# Function to uninstall Minikube
uninstall_minikube() {
    sudo minikube delete
    sudo rm /usr/local/bin/minikube
    sudo snap remove kubectl
}

# Check if Docker is installed
if command -v docker >/dev/null 2>&1; then
    echo "Uninstalling Docker..."
    uninstall_docker
fi

# Check if Minikube is installed
if command -v minikube >/dev/null 2>&1; then
    echo "Uninstalling Minikube..."
    uninstall_minikube
fi

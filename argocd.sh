#!/bin/bash

# For Docker Installation
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER && newgrp docker

sleep 30

# For Minikube & Kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
sudo snap install kubectl --classic

if [ $? -eq 0 ]; then


####################
# Create a Cluster #
####################

# minikube start #

minikube start --driver=docker

#############################
# Deploy Ingress Controller #
#############################

minikube addons enable ingress

kubectl wait --namespace kube-system \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

export INGRESS_HOST=$(minikube ip)

###################
# Install Helm    #
###################

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install Argo CD CLI
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Wait for Argo CD resources to be available
sleep 60


###################
# Install Argo CD #
###################

git clone https://github.com/vfarcic/devops-catalog-code.git

cd devops-catalog-code

git pull

helm repo add argo https://argoproj.github.io/argo-helm

helm upgrade --install argocd argo/argo-cd \
    --namespace argocd --create-namespace \
    --set server.ingress.hosts="{argocd.$INGRESS_HOST.nip.io}" \
    --values argo/argocd-values.yaml --wait
    --disable-webhooks

export PASS=$(kubectl --namespace argocd \
    get secret argocd-initial-admin-secret \
    --output jsonpath="{.data.password}" | base64 -d)

argocd login --insecure --username admin --password $PASS \
    --grpc-web argocd.$INGRESS_HOST.nip.io

echo $PASS

argocd account update-password

sleep 30

kubectl port-forward service/argocd-server -n argocd 8080:443 &

sleep 5

curl -I http://localhost:8080

# Open http://localhost:8080 in your web browser

cd ..

#######################
# Destroy The Cluster #
#######################

# minikube delete

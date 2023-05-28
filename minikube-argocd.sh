# For Docker Installation
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER && newgrp docker

# For Minikube & Kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
sudo snap install kubectl --classic
minikube start --driver=docker


# Source: https://gist.github.com/84324e2d6eb1e62e3569846a741cedea

####################
# Create a Cluster #
####################

# minikube start

#############################
# Deploy Ingress Controller #
#############################

minikube addons enable ingress

kubectl --namespace ingress-nginx wait \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

export INGRESS_HOST=$(minikube ip)

###################
# Install Helm    #
###################

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

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

export PASS=$(kubectl --namespace argocd \
    get secret argocd-initial-admin-secret \
    --output jsonpath="{.data.password}" | base64 -d)

argocd login --insecure --username admin --password $PASS \
    --grpc-web argocd.$INGRESS_HOST.nip.io

echo $PASS

# argocd account update-password

# open http://argocd.$INGRESS_HOST.nip.io

# cd ..

#######################
# Destroy The Cluster #
#######################

# minikube delete

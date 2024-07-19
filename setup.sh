#!/bin/bash


set -e

echo "1. Starting updates and installing necessary dependencies..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2

echo "2. Starting Docker installation..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce

echo "3. Updating Docker CPU and memory settings..."
sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
{
    "default-runtime": "runc",
    "experimental": false,
    "features": {
        "buildkit": false
    },
    "default-ulimits": {
        "nofile": {
            "Name": "nofile",
            "Hard": 65536,
            "Soft": 65536
        }
    },
    "max-concurrent-downloads": 3
}
EOF'

echo "4. Restarting Docker..."
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "5. Adding user to Docker group..."
sudo usermod -aG docker ${USER}

echo "6. Starting Minikube installation..."
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

echo "7. Starting kubectl installation..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "8. Starting Minikube..."
sudo minikube start --driver=docker --cpus=2 --memory=2048 --force

echo "9. Pointing Docker daemon to Minikube..."
eval $(sudo minikube docker-env)

echo "10. Starting Helm installation..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "11. Starting Terraform installation..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y
sudo apt-get install -y terraform

echo "12. Starting Git installation..."
sudo apt-get install -y git

echo "13. Cloning project repository..."
git clone https://github.com/mustafakamay/devops.git
cd devops

echo "14. Building Docker images..."
cd devops-task/src/producer
docker build -t producer:latest .
cd ../consumer
docker build -t consumer:latest .
cd ../../..

echo "15. Starting Minikube cluster with Terraform..."
cd devops-task/terraform
terraform apply -auto-approve

echo "Setup completed and applications are running."

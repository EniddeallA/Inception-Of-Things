#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y curl vim net-tools
export PATH=$PATH:/sbin/

sudo ifconfig eth1 192.168.56.110 netmask 255.255.255.0 up

export K3S_CONFIG_FILE="/vagrant/confs/configS.yaml"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=server sh - 

# ===============================================================================
echo "[Log]Wating the node to be ready"
sleep 10
kubectl wait --for=condition=Ready node/akhalidS
# ===============================================================================

sudo kubectl get nodes -o wide
# ===============================================================================

# # Install nginx-ingress
# ## https://kubernetes.github.io/ingress-nginx/deploy/#quick-start
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/cloud/deploy.yaml;
sleep 5
while kubectl get endpoints -n ingress-nginx | grep '<none>' > /dev/null; do echo "Waiting for ingress endpoints to be ready..."; sleep 1; done; echo "Endpoint is ready!"
kubectl get all -n ingress-nginx;
kubectl get endpoints -n ingress-nginx;
while kubectl get deployment -n ingress-nginx | grep '0/1' > /dev/null; do echo "Waiting for ingress Deployment to be ready..."; sleep 1; done; echo "Endpoint is ready!"

#===============================================================================

kubectl apply -f /vagrant/confs/app1.yaml;
kubectl apply -f /vagrant/confs/app2.yaml;
kubectl apply -f /vagrant/confs/app3.yaml;
#===============================================================================

kubectl apply -f /vagrant/confs/ig-all.yml;



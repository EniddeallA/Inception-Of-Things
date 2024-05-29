sudo apt update && sudo apt upgrade -y && sudo apt install curl -y;
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san akhalidS --node-ip 192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110 " sh -;
sudo cat /var/lib/rancher/k3s/server/node-token >> /vagrant/token.env;
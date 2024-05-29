sudo apt update && sudo apt upgrade -y && sudo apt install curl -y;
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 -t $(cat /vagrant/token.env) --node-ip=192.168.56.111" sh -;
sudo rm /vagrant/token.env
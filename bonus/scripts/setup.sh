#!/bin/bash
# install docker
if ! command -v docker &> /dev/null; then
  sudo apt-get update
  sudo apt-get install ca-certificates curl -y
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
else
  echo "Docker is already installed."
fi
# install k3d
if ! command -v k3d &> /dev/null; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
  echo "k3d is already installed."
fi
# install argocd
if ! command -v argocd &> /dev/null; then 
  curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
  rm argocd-linux-amd64
else
  echo "Argocd is already installed."
fi
# install kubectl
if ! command -v kubectl &> /dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  chmod +x kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  rm kubectl.sha256
else
  echo "Kubectl is already installed."
fi
# install helm
if ! command -v helm &> /dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "Helm is already installed."
fi
#gitlab instalation
k3d cluster create gitlab -p 8888:80@loadbalancer
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f ./confs/values.yaml \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s
kubectl wait --for=condition=ready --timeout=-1s pod -l app=webservice -n gitlab  

gitlab_pwd=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
ip=$(hostname -I | cut -d ' ' -f1)

echo "127.0.0.1 gitlab.localhost.com" | sudo tee -a /etc/hosts
nohup kubectl port-forward service/gitlab-webservice-default  -n gitlab --address 0.0.0.0 5555:8181 > /dev/null 2>&1 &

# install git
if ! command -v git &> /dev/null; then
  sudo apt install git -y
else
  echo "git is already installed."
fi

git clone https://github.com/mkaddani42/mkaddani-ops-demo.git mkaddani
cd mkaddani
git remote add gitlab http://root:${gitlab_pwd}@${ip}:5555/root/mkaddani-ops-demo.git
git push gitlab
rm -rf mkaddani

export GITLAB_URL="http://root:${gitlab_pwd}@${ip}:5555/root/mkaddani-ops-demo.git"
cd .. 

kubectl create namespace dev
kubectl create namespace argocd

# apply argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sed -i "s|GITLAB_URL|`echo $GITLAB_URL`|g" ./confs/app.yml
kubectl apply -f ./confs/app.yml
kubectl wait --for=condition=ready --timeout=-1s pod -l app.kubernetes.io/name=argocd-server -n argocd
argocd_pwd=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
nohup kubectl port-forward svc/argocd-server -n argocd 8880:443 --address 0.0.0.0 > /dev/null 2>&1 &

echo "Argocd server is running on http://${ip}:8880"
echo "Argocd Username: 'admin'. Password: '${argocd_pwd}'"
echo "Gitlab server is running on http://${ip}:5555"
echo "Gitlab Username: 'root'. Password: '${gitlab_pwd}'"
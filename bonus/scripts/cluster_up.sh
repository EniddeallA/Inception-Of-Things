#!/usr/bin/env bash

# Part Three starting
k3d cluster delete akhalid-cluster
## Create k3d cluster and merge it with kubeconfig so kubectl work fine -----------------------------------------------
echo "===============================[K3D akhalid-cluster set-up]=========================================";
k3d cluster create akhalid-cluster --port 80:80@loadbalancer --port 443:443@loadbalancer --servers 1 --agents 2;
k3d kubeconfig merge akhalid-cluster --kubeconfig-switch-context;
sleep 6
kubectl get pods --all-namespaces;

## Create the NameSpaces - soft isolation -----------------------------------------------------------------------------
echo "===============================[K3D akhalid-cluster Create NameSpaces]==============================";
kubectl create ns argocd;
kubectl create ns dev;
kubectl create ns gitlab;
kubectl get namespaces;


### Install GitLAB -----------------------------------------------------------------------------------------------------
helm repo add gitlab http://charts.gitlab.io/
helm install gitlab gitlab/gitlab -n gitlab   -f ../confs/values.yaml \
  --set certmanager-issuer.email=akhalid@1337.ma \
  --set global.hosts.domain=local.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --set global.edition=ce \
  --timeout 600m

### Applying ingress
kubectl apply -f ../confs/ingress.gitlab.yaml 

#-------------------------------------------------------------------------------------------------------------------
echo waiting gitlab at www.gitlab.local.com
while true; do
  if curl -s -o /dev/null -w "%{http_code}\n" http://www.gitlab.local.com/users/sign_in | grep -q '200'; then
    echo "Gitlab is up!"
    break  # Exit the loop if the link is accessible
  else
    echo "Gitlab is not up yet ..."
  fi
  sleep 5  # Wait for 5 seconds before the next check
done

echo Please create a Public repo at www.gitlab.local.com/root/mkaddani-ops-demo Manually
while true; do
  if curl -s -o /dev/null -w "%{http_code}\n" http://www.gitlab.local.com/root/mkaddani-ops-demo | grep -q '200'; then
    echo "Repo is Public!"
    break  # Exit the loop if the link is accessible
  else
    echo "Repo is not public ."
  fi
  sleep 5  # Wait for 5 seconds before the next check
done
#-------------------------------------------------------------------------------------------------------------------

### Get Creds of GitLab
MYGITLABUSER="root"
MYGITLABPASS=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode)
SCRIPTPATH=$PWD

# Set variables
GITHUB_REPO="https://github.com/mkaddani42/mkaddani-ops-demo"
GITLAB_USERNAME=$MYGITLABUSER  # Replace with your actual GitLab username
GITLAB_PASSWORD=$MYGITLABPASS  # Replace with your actual GitLab password
GITLAB_REPO_URL="www.gitlab.local.com/root/mkaddani-ops-demo.git"  # Replace with your actual GitLab repo URL
WORK_DIR="/tmp/mkaddani-ops-demo-clone"

# Clone the GitHub repository
git clone $GITHUB_REPO $WORK_DIR

# Change to the cloned repository directory
cd $WORK_DIR

# Add GitLab remote with username and password
echo git remote add gitlab "http://$GITLAB_USERNAME:$GITLAB_PASSWORD@$GITLAB_REPO_URL"
git remote add gitlab "http://$GITLAB_USERNAME:$GITLAB_PASSWORD@$GITLAB_REPO_URL"

# Push to GitLab
git push -u gitlab main

# Remove the cloned repository
cd ..
rm -rf $WORK_DIR
cd $SCRIPTPATH
echo "Cloned, pushed, and cleaned up successfully!"  

echo cheking  the repo at www.gitlab.local.com/root/mkaddani-ops-demo Public status
while true; do
  if curl -s -o /dev/null -w "%{http_code}\n" http://www.gitlab.local.com/root/mkaddani-ops-demo | grep -q '200'; then
    echo "OK!"
    break  # Exit the loop if the link is accessible
  else
    echo "Not OK!"
  fi
  sleep 5  # Wait for 5 seconds before the next check
done

### Install Argocd
kubectl apply -n argocd -f ../confs/argocd.install.yaml
sleep 5
while kubectl get endpoints -n argocd | grep '<none>' > /dev/null; do echo "Waiting for argocd endpoints to be ready..."; sleep 1; done; echo "Endpoint is ready!"
kubectl apply -f ../confs/ingress.argocd.yaml


#-------------------------------------------------------------------------------------------------------------------
echo waiting argocd at www.argocd.local.com
while true; do
  if curl -s -o /dev/null -w "%{http_code}\n" http://www.argocd.local.com/ | grep -q '200'; then
    echo "Argocd is up!"
    break  # Exit the loop if the link is accessible
  else
    echo "Argocd ..."
  fi
  sleep 5  # Wait for 5 seconds before the next check
done


kubectl apply -f ../confs/app1.argocd.yaml
kubectl apply -f ../confs/ingress.willapp.yaml
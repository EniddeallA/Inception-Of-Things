## Create k3d cluster and merge it with kubeconfig so kubectl work fine
echo "===============================[K3D akhalid-cluster set-up]=========================================";
k3d cluster create akhalid-cluster --port 8080:80@loadbalancer --port 8443:443@loadbalancer --servers 1 --agents 7;
k3d kubeconfig merge akhalid-cluster --kubeconfig-switch-context;
kubectl get pods --all-namespaces;

## Create the NameSpaces - soft isolation
echo "===============================[K3D akhalid-cluster Create NameSpaces]==============================";
kubectl create ns argocd;
kubectl create ns dev;
kubectl get namespaces;

## Applying ArgoCD Manifest
### https://argo-cd.readthedocs.io/en/stable/
echo "===============================[Install ArgoCD]=============================="
kubectl apply -n argocd -f ../confs/argocd.install.yaml
while kubectl get endpoints -n argocd | grep '<none>' > /dev/null; do echo "Waiting for argocd endpoints to be ready..."; sleep 1; done; echo "Endpoint is ready!"
echo 'exposing Argocd via ingress'


kubectl apply -f ../confs/ingress.argocd.yaml
echo "waiting argocd at localhost:8080/argocd"
while true; do
  if curl -L -s -o /dev/null -w "%{http_code}\n" localhost:8080/argocd | grep -q '200'; then
    echo "Argocd is up!"
    break  # Exit the loop if the link is accessible
  else
    echo "Argocd ..."
  fi
  sleep 5  # Wait for 5 seconds before the next check
done

kubectl apply -f ../confs/app1.argocd.yaml
kubectl apply -f ../confs/ingress.willapp.yaml

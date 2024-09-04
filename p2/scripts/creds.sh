#!/usr/bin/env bash

echo '==========================[ArgoCD]=================================='
echo www.argocd.local.com
echo Please use this credentials 
echo ArgoCD user: admin
echo ArgoCD password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

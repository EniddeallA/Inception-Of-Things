# Inception-Of-Things

This project aims to introduce you to kubernetes from a developer perspective.
- Setting up small clusters and discovering the mechanics of continuous integration.
- Setting up a personal virtual machine with Vagrant and the distribution of choice.
- Using K3s and its Ingress.
- Discovering K3d and simplifying life.
- Using Helm to install and manage Kubernetes applications.
---
 ### Terminologies
  > **Kubernetes(K8s):** An open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.
  
  > **K3s:** A lightweight, certified Kubernetes distribution designed for resource-constrained environments and edge computing.
  
  > **Vagrant:** An open-source tool for building and managing virtualized development environments.
   
  > **Ingress:** A Kubernetes API object that manages external access to services within a cluster, typically HTTP.
   
  > **K3d** A utility for running K3s clusters in Docker containers, simplifying local Kubernetes cluster management.
   
  > **Argo CD:** A declarative, GitOps continuous delivery tool for Kubernetes, which automates application deployments and synchronizations.
  
  > **Helm:** A package manager for Kubernetes that simplifies the deployment and management of applications through Helm charts.
---

## Summary
This project is divided into three parts you have to do in the following order:
- Part 1: K3s and Vagrant
- Part 2: K3s and three simple applications
- Part 3: K3d and Argo CD

### Part 1: K3s and Vagrant
  Setting up a Kubernetes environment using K3s on two virtual machines managed by Vagrant.
  1. Setting Up Virtual Machines:
     - Create a Vagrantfile to configure and provision two virtual machines (Server & ServerWorker) with minimal resources.
  3. Installing K3s:
     - On Server: Install K3s in controller mode, making this machine the primary node in your Kubernetes cluster.
     - On ServerWorker: Install K3s in agent mode, configuring this machine to join the cluster as a worker node.
  5. Installing kubectl:
     - Install kubectl on both machines to interact with the Kubernetes cluster. This allows you to manage and monitor the cluster and its resources.

### Part 2: K3s and three simple applications
  Extending our K3s setup by deploying and managing web applications.

  1. Setting up the infrastructure following the logic illustrated by the diagram below:

![part2_infra](https://github.com/EniddeallA/Inception-Of-Things/blob/main/part2_infra.png)
  
  2. Deploying applications:
     - Deploy three web applications on the K3s cluster (app1 & app2 & app3) with app2 having 3 replicas. Ensure that each application is accessible via different hostnames.
  3. Configuring the K3s cluster:
     - app1 is displayed when the hostname app1.com is used to access the IP address 192.168.56.110.
     - app2 is displayed when the hostname app2.com is used to access the IP address 192.168.56.110.
     - app3 is displayed by default when any other hostname is used to access the IP address 192.168.56.110.
  5. Configurating Ingress:
     - Set up an Ingress controller to manage routing rules and host-based traffic routing to your applications.
### Part 3: K3d and Argo CD
  Setting up K3d and Argo CD to advance Kubernetes management and implement continuous integration practices.

  1. Installing K3d.
  2. Setting up the infrastructure following the logic illustrated by the diagram below:

![part3_infra](https://github.com/EniddeallA/Inception-Of-Things/blob/main/part3_infra.png)

  3. Creating two namespaces in your K3d cluster:
      - Argo CD Namespace: Dedicated to Argo CD’s components and configurations.
      - dev Namespace: Used for deploying and managing your application.
  4. Deploying and Managing Application with Argo CD:
     - Use an application from Dockerhub or Create your own docker image with two versions.
     - Configure Argo CD to automatically deploy your application from an online GitHub repository.
     - Apply Ingress and Argocd.

### Bonus
  Same setup as Part 3 but we integrate a local GitLab instead of Online Github.
  1. Setting Up Local GitLab using Helm with minimal values in a dedicated namespace ```gitlab``` on our cluster:
  ```bash
    helm install gitlab gitlab/gitlab -n gitlab   -f ../confs/values.yaml \
    --set certmanager-issuer.email=akhalid@1337.ma \
    --set global.hosts.domain=local.com \
    --set global.hosts.externalIP=0.0.0.0 \
    --set global.hosts.https=false \
    --set global.edition=ce \
    --timeout 600m
  ```
  2. Configuring Argo CD and Ingress to work with our Gitlab instance
